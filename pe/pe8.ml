type pos = A | B | C

let pw i = int_of_float ((float_of_int i) ** 2.0)

let calc sum =
  let rec loop pos a b c =
    let is_pn = (pw a) + (pw b) = (pw c) in
    let total = a + b + c in
    if total = sum && is_pn then Some (a, b, c)
    else (
      if total > sum then None
      else (
        match pos with
        | C -> loop C a b (c + 1)
        | B -> (
            match (loop B a (b + 1) (c + 1), loop C a b (c + 1)) with
            | None, None -> None
            | Some x, _ -> Some x
            | _, Some x -> Some x
        )
        | A -> (
            match (loop A (a + 1) (b + 1) (c + 1), loop B a (b + 1) (c + 1)) with
            | None, None -> None
            | Some x, _ -> Some x
            | _, Some x -> Some x
        )
      )
    )
  in
  loop A 1 2 3

let _ =
  let a, b, c = 
    match calc 1000 with
    | Some (a, b, c) -> a, b, c
    | None -> failwith "not found"
  in
  Printf.printf "a:%d, b:%d, c:%d\n" a b c

