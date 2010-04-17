#load "nums.cma"
open Num

let rec fib len i n1 n2 =
  if String.length (string_of_num n1) >= len then i - 1
  else fib len (i + 1) n2 (n1 +/ n2)

let _ =
  Printf.printf "%d\n" (fib 1000 2 (num_of_int 1) (num_of_int 1))
