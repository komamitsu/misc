let ( *** ) a b = int_of_float (float_of_int a ** float_of_int b)

let sum_of_one_hundred =
  let rec loop n sum =
    if n < 1 then sum
    else loop (n - 1) (sum + n) in
  loop 100 0

let sum_of_square n =
  let rec loop n sum =
    if n < 1 then sum
    else loop (n - 1) (sum + n * n)
  in
  loop n 0

let square_of_sum n =
  let rec loop n sum =
    if n < 1 then sum * sum
    else loop (n - 1) (sum + n)
  in
  loop n 0

let _ =
  let sum_of_square = sum_of_square 100 in
  let square_of_sum = square_of_sum 100 in
  Printf.printf "sum_of_square %d\n" sum_of_square;
  Printf.printf "square_of_sum %d\n" square_of_sum;
  Printf.printf "difference %d\n" (square_of_sum - sum_of_square)
