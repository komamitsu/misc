open Player
type t = Player.t option array array

let create ?(x=8) ?(y=8) () =
  let b = Array.init y (fun _ -> Array.create x None) in
  b.(x / 2 - 1).(y / 2 - 1) <- Some First;
  b.(x / 2 - 1).(y / 2)     <- Some Last;
  b.(x / 2).(y / 2 - 1)     <- Some Last;
  b.(x / 2).(y / 2)         <- Some First;
  b
   
let get_pos t x y = t.(y).(x)

let set_pos t x y v = t.(y).(x) <- (Some v)

let length_x t = Array.length t.(0)

let length_y t = Array.length t

let is_out_of_board t x y =
  x < 0 || x >= length_x t || y < 0 || y >= length_y t

let clone t =
  (Marshal.from_string (Marshal.to_string t []) 0 : t)

let dir_list =
  let dirs = [-1; 0; 1] in
  List.filter
    (fun x -> x <> (0, 0))
    (List.flatten 
      (List.map 
        (fun y -> List.map (fun x -> (x, y)) dirs) dirs))

let reverse player t x y =
  let _reverse dir_x dir_y =
    let rec loop rs x y =
      if is_out_of_board t x y then []
      else (
        match get_pos t x y with
        | None -> []
        | Some p when p = player -> rs
        | Some _ -> loop ((x, y)::rs) (x + dir_x) (y + dir_y)
      ) in
    let rs = loop [] (x + dir_x) (y + dir_y) in
    List.iter (fun (x, y) -> set_pos t x y player) rs;
    List.length rs
  in
  List.fold_left
    (fun count (dir_x, dir_y) ->
      count + _reverse dir_x dir_y) 0 dir_list

let _ =
  let b = create () in
  let c = clone b in
  set_pos c 3 0 Last;
  set_pos c 3 1 Last;
  set_pos c 4 2 Last;
  set_pos c 5 2 Last;
  set_pos c 6 2 First;
  set_pos c 5 4 First;
  assert (reverse First c 3 2 = 3);
  assert (c = [|
    [|None; None; None; Some Last; None; None; None; None|];
    [|None; None; None; Some Last; None; None; None; None|];
    [|None; None; None; None; Some First; Some First; Some First; None|];
    [|None; None; None; Some First; Some First; None; None; None|];
    [|None; None; None; Some Last; Some First; Some First; None; None|];
    [|None; None; None; None; None; None; None; None|];
    [|None; None; None; None; None; None; None; None|];
    [|None; None; None; None; None; None; None; None|]|]
  )
