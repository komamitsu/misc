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
and atom = 
  Int of int

let rec eval_expr env = function
  | Add (a, b) -> (eval_expr env a) + (eval_expr env b)
  | Sub (a, b) -> (eval_expr env a) - (eval_expr env b)
  | Mul (a, b) -> (eval_expr env a) * (eval_expr env b)
  | Div (a, b) -> (eval_expr env a) / (eval_expr env b)
  | Atom a -> (match a with Int a -> a)
  | Appl k -> Hashtbl.find env k

let rec eval_stmt env stmt =
  ignore (
    match stmt with
    | Expr e -> ignore (eval_expr env e)
    | Bind (s, e) -> Hashtbl.replace env s (eval_expr env e)
    | Print e -> printf "=> %d\n" (eval_expr env e)
  );
  env

let rec eval_stml_list env = function
  | [] -> ()
  | hd :: tl -> eval_stml_list (eval_stmt env hd) tl

let sample_stmt_list =
(* 
 * x = 17 - 13;
 * y = 3 + 7;
 * 31 + 11;
 * print (5 * x / y);
 *)
  [
    Bind ("x", Sub (Atom (Int 17), Atom (Int 13)));
    Bind ("y", Add (Atom (Int 3), Atom (Int 7)));
    Expr (Add (Atom (Int 31), Atom (Int 11)));
    Print (Div (Mul (Atom (Int 5), Appl "x"), Appl "y"))
  ]
  
let _ =
  let empty = Hashtbl.create 10 in
  List.fold_left 
    (fun env stmt -> eval_stmt env stmt)
    empty sample_stmt_list

