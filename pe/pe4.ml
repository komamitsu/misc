open Printf

let is_palindromic n = 
  let s = string_of_int n in
  let len = String.length s in
  let rec loop i =
    if i > len / 2 then true
    else (
      if s.[i] = s.[len - 1 - i] then loop (i + 1)
      else false
    ) in
  loop 0

let _ =
  let rec fa a l =
    if a > 999 then l
    else (
      let rec fb b l =
        if b > 999 then l
        else (
          let l = 
            if is_palindromic (a * b) then (a * b) :: l else l
          in
          fb (b + 1) l
        )
      in
      fa (a + 1) (fb 100 l)
    ) in
  let l = fa 100 [] in
  printf "%d\n" (List.hd (List.sort (fun a b -> - (a - b)) l))

