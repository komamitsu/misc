let is_prime n =
  let rec loop i =
    if i > n / 2 then true
    else (
      if n mod i = 0 then false
      else loop (i + 1)
    ) in
  loop 2

let primes n =
  let ns =
    let rec loop i l =
      if i < 2 then l
      else loop (i - 1) (i :: l) in
    loop n [] in
  let rec loop ns ps =
    let hd = List.hd ns in
    let ps = hd :: ps in
    let ns = List.filter (fun x -> x mod hd != 0) ns in
    let max_in_ns = List.nth ns ((List.length ns) - 1) in
    if (sqrt (float_of_int max_in_ns)) < float_of_int hd
    then List.sort compare (ps @ ns)
    else loop ns ps
  in
  loop ns []

let _ = 
  assert (is_prime 13);
  assert (not (is_prime 14));
  assert (primes 10 = [2; 3; 5; 7]);
  let ps = primes 150000 in
  Printf.printf "%d\n" (List.nth ps 10000)

