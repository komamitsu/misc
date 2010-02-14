#load "unix.cma"

exception Hoge

let f_e i =
  if i >= 0 then raise Hoge

let test_e n =
  let rec loop i =
    if i > 0 
    then (try f_e i with Hoge -> loop (i - 1)) in
  loop n

let f i =
  if i >= 0 then ()

let test n =
  let rec loop i =
    if i > 0
    then (f i; loop (i - 1)) in
  loop n

let _ =
  let n = 100_000_000 in
  let s = Unix.gettimeofday () in
  test n;
  let e = Unix.gettimeofday () in
  Printf.printf "normal :    %f\n" (e -. s);
  let s = Unix.gettimeofday () in
  test_e n;
  let e = Unix.gettimeofday () in
  Printf.printf "exception : %f\n" (e -. s)

