open Printf

type symbol = string

type expr =
  | Value of value
  | SetVar of symbol * expr
  | GetVar of symbol
  | CallFunc of symbol * expr
  | CallInnarFunc of symbol * expr
  | ExprList of expr list
and value =
  | Symbol of symbol
  | Int of int
  | String of string
  | Bool of bool
  | Func of symbol list * expr
  | Null

module Env : sig
  type t
  val empty_env : unit -> t
  val append_to_current_env : t -> symbol -> value -> t
  val find_from_env : t -> symbol -> value
  val create_next_env : t -> t
  val drop_current_env : t -> t
end
  = 
struct
  type t = (symbol, value) Hashtbl.t list

  let empty_env_unit () = Hashtbl.create 10

  let empty_env () = [empty_env_unit ()]

  let append_to_current_env env k v = 
    match env with
    | [] -> failwith "append_to_current_env: No current_env"
    | hd :: tl -> 
        Hashtbl.replace hd k v;
        hd :: tl

  let rec find_from_env env k = 
    match env with
    | [] -> raise Not_found
    | hd :: tl -> 
        try Hashtbl.find hd k with 
        | Not_found -> find_from_env tl k

  let create_next_env env =
    (empty_env_unit ()) :: env

  let drop_current_env env =
    match env with
    | [] -> failwith "drop_current_env: No current_env"
    | hd :: tl -> tl
end

open Env

let rec eval_expr env = function
  | Value v -> (env, v)
  | SetVar (k, e) -> 
      let env, v = eval_expr env e in
      let new_env = append_to_current_env env k v in
      (new_env, v)
  | GetVar k -> 
      let v = find_from_env env k in 
      (env, v)
  | CallFunc (f, params) -> (
      match find_from_env env f with
      | Func (args, expr_list) -> (
        match params with
        | ExprList ps ->
            let env_with_args = 
              List.fold_left2 
              (fun env arg param -> 
                let new_env, v = eval_expr env param in
                append_to_current_env new_env arg v) 
              (create_next_env env) args ps in
            eval_expr env_with_args expr_list
        | _ -> failwith "CallFunc: Not ExprList was given"
      )
      | _ -> failwith "CallFunc: This is not a function"
    )
  | CallInnarFunc (f, params) -> 
      let v = innar_func env params f in
      (env, v)
  | ExprList expr_list ->
      List.fold_left
      (fun (env, _) expr -> eval_expr env expr)
      (env, Null) expr_list
and innar_func env (params : expr) name : value =
  let get_values () =
    match params with
    | ExprList ps ->
        let env, vs = 
          List.fold_left 
          (fun (env, vs) expr ->
            let new_env, v = eval_expr env expr in
            (new_env, v::vs)) (env, []) ps in
        (env, List.rev vs)
    | _ -> failwith "CallFunc: Not ExprList was given"
  in
  match name with
  | "print" -> 
      let env, vs = get_values () in
      let v = List.nth vs 0 in (
        match v with
        | Symbol s -> printf "(symbol : %s)" s
        | Int i -> print_int i
        | String s -> print_string s
        | Bool b -> print_string (if b then "(true)" else "(false)")
        | Func _ -> print_string "(function)"
        | Null -> print_string "(null)"
      ); v
  | "concat" -> 
      let env, vs = get_values () in
      String (
        List.fold_left 
          (fun acc v ->
            match v with
            | String s -> acc ^ s
            | _ -> failwith (sprintf "%s: Invalid type" name)
          ) "" vs
      )
  | ">" -> 
      let env, vs = get_values () in (
        match (List.nth vs 0), (List.nth vs 1) with
        | Int a, Int b -> Bool (a > b)
        | String a, String b -> Bool (String.compare a b > 0)
        | _ -> failwith (sprintf "%s: Invalid type" name)
      )
  | ">=" -> 
      let env, vs = get_values () in (
        match (List.nth vs 0), (List.nth vs 1) with
        | Int a, Int b -> Bool (a >= b)
        | String a, String b -> Bool (String.compare a b >= 0)
        | _ -> failwith (sprintf "%s: Invalid type" name)
      )
  | "<" ->
      let env, vs = get_values () in (
        match (List.nth vs 0), (List.nth vs 1) with
        | Int a, Int b -> Bool (a < b)
        | String a, String b -> Bool (String.compare a b < 0)
        | _ -> failwith (sprintf "%s: Invalid type" name)
      )
  | "<=" ->
      let env, vs = get_values () in (
        match (List.nth vs 0), (List.nth vs 1) with
        | Int a, Int b -> Bool (a <= b)
        | String a, String b -> Bool (String.compare a b <= 0)
        | _ -> failwith (sprintf "%s: Invalid type" name)
      )
  | "==" ->
      let env, vs = get_values () in (
        match (List.nth vs 0), (List.nth vs 1) with
        | Int a, Int b -> Bool (a = b)
        | String a, String b -> Bool (String.compare a b = 0)
        | _ -> failwith (sprintf "%s: Invalid type" name)
      )
  | "!=" ->
      let env, vs = get_values () in (
        match (List.nth vs 0), (List.nth vs 1) with
        | Int a, Int b -> Bool (a != b)
        | String a, String b -> Bool (String.compare a b != 0)
        | _ -> failwith (sprintf "%s: Invalid type" name)
      )
  | "if" -> (
        match params with
        | ExprList (expr_cond::expr_true::expr_false::[]) ->
            let env, v = eval_expr env expr_cond in (
              match v with
              | Bool b ->
                  let env, v =
                    eval_expr env 
                      (if b then expr_true else expr_false) in
                  v
              | _ -> failwith (sprintf "%s: Invalid type" name)
            )
        | _ -> failwith (sprintf "%s: Invalid type" name)
      )
  | _ -> 
      failwith (sprintf "innar_func: %s was not found" name)

let sample = ExprList [
  SetVar ("hello",
    Value (
      Func (
        ["first_name"; "last_name"],
        ExprList [
          SetVar ("full_name", 
            CallInnarFunc ("concat", ExprList [
              Value (String "I am ");
              GetVar "first_name";
              Value (String " ");
              GetVar "last_name";
              Value (String ".\n")
            ]));
          CallInnarFunc ("print", ExprList [GetVar "full_name"])
        ]
    )));
  CallFunc ("hello", 
    ExprList [
      Value (String "Larry");
      Value (String "Wall")
    ]
  );
  CallInnarFunc ("if",
    ExprList [
      CallInnarFunc (">=", ExprList [Value (Int 1234); Value (Int 1235)]);
      ExprList [
        CallInnarFunc ("print", ExprList [Value (String "foo")])
      ];
      ExprList [
        SetVar ("tmp", Value (String "bar"));
        CallInnarFunc ("print", ExprList [GetVar "tmp"])
      ]
    ]);
]

let _ =
  eval_expr (empty_env ()) sample

