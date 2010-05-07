module Player =
  struct
    type t = First | Last
    let next_player = function First -> Last | Last -> First
  end

module type GameType =
  sig
    type t
    val find : Player.t -> t -> int -> t list
    val eval : Player.t -> t -> int -> int option
  end

module MakeMinMax (Game : GameType) :
  sig
    type gt = Game.t
    type result = {player:Player.t; score:int; condition:gt; children:result list}
    val eval : Player.t -> gt -> result
  end
=
  struct
    type gt = Game.t

    type result = {player:Player.t; score:int; condition:gt; children:result list}

    let eval player condition = 
      let rec _eval player condition depth alpha beta =
        match Game.eval player condition depth with
        | Some score ->
            {player = player; score = score; 
             condition = condition; children = []}
        | None ->
          let next_player = Player.next_player player in
          let next_choices = Game.find player condition depth in
          let children, alpha, beta =
            List.fold_left
              (fun status nc -> 
                if alpha < beta then
                  let children, alpha, beta = status in
                  let child = _eval next_player nc (depth + 1) alpha beta in
                  let children = child::children in
                  match player with
                  | Player.First when child.score > alpha ->
                      (children, child.score, beta)
                  | Player.Last  when child.score < beta  ->
                      (children, alpha, child.score)
                  | _ -> (children, alpha, beta)
                else
                  status
              )
              ([], alpha, beta) next_choices in
          {player = player;
           score = if player = Player.First then alpha else beta;
           condition = condition; children = children}
      in
      _eval player condition 0 min_int max_int
  end

module SampleMinMax = 
  MakeMinMax(
    struct
      type t = int

      let counter = ref 1

      let find player cond depth =
        let rec loop i choises =
          if i > depth then choises
          else loop (i + 1) (((i * depth * !counter) mod 7)::choises)
        in
        counter := !counter + 1;
        loop 0 [] 

      let eval player cond depth =
        if depth > 2 then Some cond else None
    end
  )

let _ =
  SampleMinMax.eval Player.First 4
