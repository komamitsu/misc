open Printf

let calc l =
  let rec _calc sels sel i = function
    | [] -> sel::sels
    | lst ->
(* printf "sel: %s, i: %d, lst: %s\n" sel i (List.fold_left (fun a x -> a ^ (string_of_int x)) "" lst); *)
        let pickup = List.nth lst i in
        let rest = List.filter (fun x -> pickup <> x) lst in
        let sels = _calc sels (sel ^ (string_of_int pickup)) 0 rest in
        if i < (List.length lst) - 1 then _calc sels sel (i + 1) lst
        else sels
  in
  _calc [] "" 0 l

let _ =
  let l = calc [9; 8; 7; 6; 5; 4; 3; 2; 1; 0] in
(* List.iter (fun x -> printf "%s " x) l; print_newline () *)
  printf "%s\n" (List.nth l (1_000_000 - 1))
