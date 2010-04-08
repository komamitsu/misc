(*
let walk len =
  let rec _w x y t =
    if x = len && y = len then t + 1
    else (
      let t = if x < len then _w (x + 1) y t else t in
      if y < len && not (x = 0 && y = 0) then _w x (y + 1) t else t
    )
  in
  (_w 0 0 0) * 2

let walk len =
  let c = ref 0 in
  let s = Stack.create () in
  Stack.push (0, 0) s;
  try 
    while true do
      let x, y = Stack.pop s in
      if x = len && y = len then c := !c + 1
      else (
        if x < len then Stack.push (x + 1, y) s;
        if y < len then Stack.push (x, y + 1) s
      )
    done;
    !c
  with Stack.Empty -> !c

let _ =
  let rec loop i n =
    if i > n then ()
    else (
      Printf.printf "i(%d) c(%d)\n" i (walk i);
      loop (i + 1) n
    ) in
  loop 1 10

*)
