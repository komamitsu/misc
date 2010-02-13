let qs l =
  let rec part pivot left right = function
    | [] -> (left, right)
    | hd :: tl when hd < pivot ->
        part pivot (hd :: left) right tl
    | hd :: tl ->
        part pivot left (hd :: right) tl
  in
  let rec sort = function
    | [] -> []
    | hd :: tl ->
        let left, right = part hd [] [] tl in
        sort left @ hd :: sort right
  in
  sort l

let _ =
  let elms = [7; 2; 5; 9; 6; 1; 3; 8; 4] in
  List.iter
    (fun x -> Printf.printf "%d " x) (qs elms);
  print_newline ()

