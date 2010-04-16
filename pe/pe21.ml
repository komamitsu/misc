let sum_of_proper_divisors n =
  let rec divisors i ds =
    if i > n / 2 then ds
    else divisors (i + 1) (if n mod i = 0 then (i::ds) else ds)
  in
  let ds = divisors 1 [] in
  List.fold_left (fun a x -> a + x) 0 ds

let _ =
  let max = 10000 in
  let a = Array.init (max + 1) (fun _ -> -1) in
  let rec loop i =
    if i >= max then ()
    else (
      let sopd = sum_of_proper_divisors i in
      a.(i) <- sopd;
      loop (i + 1)
    ) in
  loop 1;
  let rec loop i l =
    if i >= max then l
    else (
      let sopd = a.(i) in
      let l =
        if sopd >= max then l
        else (
          let pair_sopd = a.(sopd) in
          if i = pair_sopd && i <> sopd then (
Printf.printf "i(%d) sopd(%d) pair_sopd(%d)\n" i sopd pair_sopd;
            let l = if List.exists (fun x -> x = i) l then l else (i::l) in
            if List.exists (fun x -> x = pair_sopd) l then l else (pair_sopd::l)
          ) else l 
        ) in
      loop (i + 1) l
    ) in
  let l = loop 1 [] in
  List.iter (fun x -> Printf.printf "%d " x) l; print_newline ();
  Printf.printf "%d\n" (List.fold_left (fun a x -> a + x) 0 l)
