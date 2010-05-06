type player = First | Last
type 'a t =
  {finder: player -> 'a -> int -> 'a list;
   evaluator: player -> 'a -> int -> int option}

type 'a result = {score:int; condition:'a; children:'a result list}

let create finder evaluator = {finder = finder; evaluator = evaluator}

let next_player = function First -> Last | Last -> First

let eval t player condition = 
  let rec _eval player condition depth =
    match t.evaluator player condition depth with
    | Some score -> {score = score; condition = condition; children = []}
    | None ->
      let next_player = next_player player in
      let next_choices = t.finder player condition depth in
      let children =
        List.fold_left
          (fun result nc -> (_eval next_player nc (depth + 1))::result)
          [] next_choices in
      let init, compare = 
        match player with
        | First -> (min_int, max)
        | Last  -> (max_int, min) in
      let score = 
        List.fold_left (fun s child -> compare s child.score) init children in
      {score = score; condition = condition; children = children}
  in
  _eval player condition 0


