module MinMax :
  sig
    type player = First | Last
    type 'a t
    type 'a result = {player:player; score:int; condition:'a; children:'a result list}

    val create :
        (player -> 'a -> int -> 'a list) ->
        (player -> 'a -> int -> int option) -> 'a t

    val eval : 'a t -> player -> 'a -> 'a result
  end
=
  struct
  type player = First | Last
  type 'a t =
    {finder: player -> 'a -> int -> 'a list;
     evaluator: player -> 'a -> int -> int option}

  type 'a result = {player:player; score:int; condition:'a; children:'a result list}

  let create finder evaluator = {finder = finder; evaluator = evaluator}

  let next_player = function First -> Last | Last -> First

  let eval t player condition = 
    let rec _eval player condition depth =
      match t.evaluator player condition depth with
      | Some score ->
          {player = player; score = score; 
           condition = condition; children = []}
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
          List.fold_left 
            (fun s child -> compare s child.score) init children in
        {player = player; score = score; 
         condition = condition; children = children}
    in
    _eval player condition 0
end

let _ =
  let counter = ref 1 in
  let mm =
    MinMax.create
      (fun player cond depth ->
        let rec loop i choises =
          if i > depth then choises
          else loop (i + 1) (((i * depth * !counter) mod 7)::choises)
        in
        counter := !counter + 1;
        loop 0 [])
      (fun player cond depth ->
        if depth > 2 then Some cond else None) in
  MinMax.eval mm MinMax.First 4

