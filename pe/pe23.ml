let divisors_of_int n =
  let rec loop i l =
    if i > n / 2 then l
    else loop (i + 1) (if n mod i = 0 then i::l else l)
  in
  loop 1 []

let is_abundant_num n =
  let sum_of_divisors = 
    List.fold_left (fun a x -> a + x) 0 (divisors_of_int n)
  in
  sum_of_divisors > n

let abundant_nums limit =
  let rec loop i l =
    if limit < i then l
    else loop (i + 1) (if is_abundant_num i then i::l else l)
  in
  loop 1 []

let sums_of_abundant_nums limit =
  let abundant_nums = abundant_nums limit in
  let rec loop h l = 
    match l with
    | [] -> h
    | hd::tl ->
        loop (List.fold_left (fun a x -> Hashtbl.replace h (hd + x) true; h) h l) tl
  in
  loop (Hashtbl.create 30000) abundant_nums

let _ =
  let limit = 28123 in
  let sums_of_abundant_nums = sums_of_abundant_nums limit in
  Printf.printf "got sums_of_abundant_nums!\n"; flush stdout;
  let rec loop i l =
    Printf.printf "in loop %d \n" i; flush stdout;
    if i > limit then l
    else 
      let l =
        if try Hashtbl.find sums_of_abundant_nums i with Not_found -> false 
          then l else i::l in
      loop (i + 1) l
  in
  let l = loop 1 [] in
  Printf.printf "%d\n" (List.fold_left (fun a x -> a + x) 0 l)
