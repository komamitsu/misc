open Printf

let num = 20

let primes_of_int n =
  let rec loop n i a =
    if i > n then a
    else (
      if n mod i = 0 then (
        a.(i) <- a.(i) + 1;
        loop (n / i) i a
      )
      else loop n (i + 1) a
    ) in
  loop n 2 (Array.make (num + 1) 0)

let _ =
  (* Array.iter (fun x -> printf "%d " x) (primes_of_int 60) *)
  let a = Array.make (num + 1) 0 in
  let rec loop n =
    if n < 0 then ()
    else (
      let my_a = primes_of_int n in
      let rec _loop i =
        if i < 0 then ()
        else (
          if a.(i) < my_a.(i) then a.(i) <- my_a.(i);
          _loop (i - 1)
        ) in
      _loop n;
      loop (n - 1)
    ) in
  loop num;
  let acc, _ = 
    Array.fold_left
      (fun (acc, i) e -> 
        let acc =
          if e = 0 then acc
          else (
            let calc = int_of_float (float_of_int i ** float_of_int e) in
            calc * acc
          ) in
        (acc, i + 1)) (1, 0) a
  in
  printf "%d\n" acc




