#load "nums.cma"
open Num

let primes n =
  let ns =
    let rec loop i l =
      if i < 2 then l
      else loop (i - 1) (i :: l) in
    loop n [] in
  let rec loop ns ps =
    let hd = List.hd ns in
    let ps = hd :: ps in
    let max_in_ns = ref 0 in
    let ns =
      List.filter 
        (fun x -> 
          if x > !max_in_ns then max_in_ns := x;
          x mod hd != 0) ns in
    if (sqrt (float_of_int !max_in_ns)) < float_of_int hd
    then List.sort compare (ps @ ns)
    else loop ns ps
  in
  loop ns []

let _ =
  let ps = primes 2000000 in
  let sum = 
    List.fold_left 
      (fun a x -> a +/ (num_of_int x)) (num_of_int 0) ps in
  Printf.printf "%s\n" (string_of_num sum)
