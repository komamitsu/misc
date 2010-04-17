let rec letters_of_num n =
  let one_to_nineteen = 
  (*  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 *)
    [|0; 3; 3; 5; 4; 4; 3; 5; 5; 4; 3; 6; 6; 8; 8; 7; 7; 9; 8; 8|]
  in
  let twenty_to_ninety =
  (* 00 10 20 30 40 50 60 70 80 90 *)
    [|0; 0; 6; 6; 5; 5; 5; 7; 6; 6|]
  in
  match true with
  | _ when n = 1000 -> 3 + 8
  | _ when n >= 100 ->
      let h = n / 100 in
      let m = n mod 100 in
      one_to_nineteen.(h) + 7 + 
        if m = 0 then 0 else (letters_of_num m) + 3
  | _ when n >= 20 -> 
      twenty_to_ninety.(n / 10) + (letters_of_num (n mod 10))
  | _ -> 
      one_to_nineteen.(n)

let _ =
  (*
  assert (letters_of_num 1 = 3);
  assert (letters_of_num 10 = 3);
  assert (letters_of_num 19 = 8);
  assert (letters_of_num 20 = 6);
  assert (letters_of_num 21 = 9);
  assert (letters_of_num 99 = 10);
  assert (letters_of_num 100 = 10);
  assert (letters_of_num 101 = 16);
  assert (letters_of_num 199 = 13 + 10);
  assert (letters_of_num 200 = 3 + 7);
  assert (letters_of_num 299 = 3 + 7 + 3 + 6 + 4);
  assert (letters_of_num 1000 = 3 + 8);
  assert (letters_of_num 115 = 20);
  assert (letters_of_num 342 = 23);
  *)
  let rec loop n sum =
    if n <= 0 then sum
    else loop (n - 1) (sum + (letters_of_num n)) in
  Printf.printf "%d\n" (loop 1000 0)
