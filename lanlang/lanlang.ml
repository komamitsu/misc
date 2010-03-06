open Printf

type symbol = string

type expr =
  | Value of value
  | SetVar of symbol * expr
  | GetVar of symbol
  | CallFunc of symbol * expr list
  | CallInnarFunc of symbol * expr list
and value =
  | Symbol of symbol
  | Int of int
  | String of string
  | Bool of bool
  | Func of symbol list * expr list
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

  let empty_env () = [Hashtbl.create 10]

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
    Hashtbl.create 10 :: env

  let drop_current_env env =
    match env with
    | [] -> failwith "drop_current_env: No current_env"
    | hd :: tl -> tl
end

open Env

let rec eval_expr_list env expr_list =
  List.fold_left
    (fun (env, _) expr -> eval_expr env expr)
    (env, Null) expr_list
and eval_expr env = function
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
      | Func (args, expr_list) ->
          let env_with_args = 
            List.fold_left2 
              (fun env arg param -> 
                let new_env, v = eval_expr env param in
                append_to_current_env new_env arg v) 
              (create_next_env env) args params in
          let _, v =
            eval_expr_list env_with_args expr_list in
          (env, v)
      | _ -> failwith "CallFunc: This is not a function"
  )
  | CallInnarFunc (f, params) -> 
      let v = innar_func env params f in
      (env, v)
and innar_func env params name : value =
  match name with
  | "print" -> 
      let expr = List.hd params in 
      let _, v = eval_expr env expr in (
        match v with
        | Symbol s -> printf "(symbol : %s)" s
        | Int i -> print_int i
        | String s -> print_string s
        | Bool b -> print_string (if b then "(true)" else "(false)")
        | Func _ -> print_string "(function)"
        | Null -> print_string "(null)"
      ); v
  | "concat" -> 
      String (
        List.fold_left 
          (fun acc expr ->
            let _, v = eval_expr env expr in
            match v with
            | String s -> acc ^ s
            | _ -> failwith "concat: not String type"
          ) "" params
      )
  | _ -> 
      failwith (sprintf "innar_func: %s was not found" name)

let sample = [
  SetVar ("hello",
    Value (
      Func (
        ["first_name"; "last_name"],
        [
          SetVar ("full_name", 
            CallInnarFunc ("concat", [
              Value (String "I am ");
              GetVar "first_name";
              Value (String " ");
              GetVar "last_name";
              Value (String ".")
            ]));
          CallInnarFunc ("print", [GetVar "full_name"])
        ]
    )));
    CallFunc ("hello", 
      [
        Value (String "Larry");
        Value (String "Wall")
      ]
    )
]

let _ =
  eval_expr_list (empty_env ()) sample

