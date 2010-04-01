open Printf
open Num

let max_prime n =
  let rec loop n i =
    if n // (num_of_int 2) </ i then (
      n
    )
    else (
      if mod_num n i =/ (num_of_int 0) then (
        loop (n // i) i
      )
      else (
        loop n (succ_num i)
      )
    )
  in
  loop n (num_of_int 2)


let _ =
  printf "%d\n" (int_of_num (max_prime (num_of_string "600851475143")))

