open Printf

type symbol = string

type expr =
  | Value of value
  | SetVar of symbol * value
  | GetVar of symbol
  | CallFunc of symbol * value list
  | CallInnarFunc of symbol * value list
and value =
  | Symbol of symbol
  | Int of int
  | String of string
  | Bool of bool
  | Func of symbol list * expr list
  | Null

type env = (value, value) Hashtbl.t list

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

let innar_func env params name =
  match name with
  | "print" -> 
      let v = List.hd params in (
        match v with
        | Symbol s -> printf "(symbol : %s)" s
        | Int i -> print_int i
        | String s -> print_string s
        | Bool b -> print_string (if b then "(true)" else "(false)")
        | Func _ -> print_string "(function)"
        | Null -> print_string "(null)"
      ); v
  | _ -> 
      failwith (sprintf "innar_func: %s was not found" name)

let rec eval_expr_list env expr_list =
  List.fold_left
    (fun (env, result) expr ->
      let rec eval_loop env expr =
        match expr with
        | Value v -> (env, expr)
        | other_expr -> 
            let env, expr = 
              eval_expr env other_expr in
            eval_loop env expr in
      eval_loop env expr
    ) (env, Value Null) expr_list
and eval_expr env = function
  | Value v -> (env, Value v)
  | SetVar (k, v) -> 
      let new_env = append_to_current_env env k v in
      (new_env, Value v)
  | GetVar k -> 
      let v = find_from_env env k in 
      (env, Value v)
  | CallFunc (f, params) -> (
      match find_from_env env f with
      | Func (args, expr_list) ->
          let env_with_args = 
            List.fold_left2 
              (fun env arg param -> 
                append_to_current_env env arg param) 
              (create_next_env env) args params in
          let _, result =
            eval_expr_list env_with_args expr_list in
          (env, result)
      | _ -> failwith "CallFunc: This is not a function"
  )
  | CallInnarFunc (f, params) -> 
      let result = innar_func env params f in
      (env, Value result)

let sample = [
  CallInnarFunc ("print", [Int 1234]);
  Value (Int 123)
]

let _ =
  eval_expr_list (empty_env ()) sample

