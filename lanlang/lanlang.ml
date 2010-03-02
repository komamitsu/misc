open Printf

type symbol = string

type stmt =
  | Expr of expr
  | Bind of symbol * expr
  | Print of expr
and expr = 
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
  | Atom of atom
  | Appl of symbol
  | If of boolean * expr * expr
and atom = 
  | Int of int 
and boolean =
  | Ge of expr * expr
  | Gt of expr * expr
  | Le of expr * expr
  | Lt of expr * expr

let rec eval_expr env = function
  | Add (a, b) -> (eval_expr env a) + (eval_expr env b)
  | Sub (a, b) -> (eval_expr env a) - (eval_expr env b)
  | Mul (a, b) -> (eval_expr env a) * (eval_expr env b)
  | Div (a, b) -> (eval_expr env a) / (eval_expr env b)
  | Atom a -> (match a with Int a -> a)
  | Appl k -> Hashtbl.find env k
  | If (cond, a, b) ->
      if (
        match cond with
        | Ge (a, b) -> a >= b
        | Gt (a, b) -> a > b
        | Le (a, b) -> a <= b
        | Lt (a, b) -> a < b
      ) then eval_expr env a
      else eval_expr env b

let rec eval_stmt env stmt =
  ignore (
    match stmt with
    | Expr e -> ignore (eval_expr env e)
    | Bind (s, e) -> Hashtbl.replace env s (eval_expr env e)
    | Print e -> printf "=> %d\n" (eval_expr env e)
  );
  env

let sample_stmt_list =
(* 
 * x = 17 - 13;
 * y = 3 + 7;
 * 31 + 11;
 * print (5 * x / y);   # => 2
 * z = if (19 <= 19) then 29 else 37
 * print z;             # => 29
 * z = if (19 > 19) then 29 else 37
 * print z;             # => 37
 *)
  [
    Bind ("x", Sub (Atom (Int 17), Atom (Int 13)));
    Bind ("y", Add (Atom (Int 3), Atom (Int 7)));
    Expr (Add (Atom (Int 31), Atom (Int 11)));
    Print (Div (Mul (Atom (Int 5), Appl "x"), Appl "y"));
    Bind ("z", If (Le (Atom (Int 19), Atom (Int 19)), Atom (Int 29), Atom (Int 37)));
    Print (Appl "z");
    Bind ("z", If (Gt (Atom (Int 19), Atom (Int 19)), Atom (Int 29), Atom (Int 37)));
    Print (Appl "z");
  ]
  
let _ =
  let empty = Hashtbl.create 10 in
  List.fold_left 
    (fun env stmt -> eval_stmt env stmt)
    empty sample_stmt_list

