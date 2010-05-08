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
    val to_string : t -> string
  end

module MakeMinMax (Game : GameType) :
  sig
    type gt = Game.t
    type result = {player:Player.t; score:int; condition:gt; children:result list}
    val eval : Player.t -> gt -> result
    val eval_with_alpha_beta_cut : Player.t -> gt -> result
  end
=
  struct
    type gt = Game.t

    type result = {player:Player.t; score:int; condition:gt; children:result list}

    let eval player condition = 
      let rec _eval player condition depth =
        match Game.eval player condition depth with
        | Some score ->
            {player = player; score = score; 
             condition = condition; children = []}
        | None ->
          let next_player = Player.next_player player in
          let next_choices = Game.find player condition depth in
          let children =
            List.fold_left
              (fun result nc -> (_eval next_player nc (depth + 1))::result)
              [] next_choices in
          let init, compare = 
            match player with
            | Player.First -> (min_int, max)
            | Player.Last  -> (max_int, min) in
          let score = 
            List.fold_left 
              (fun s child -> compare s child.score) init children in
          {player = player; score = score; 
           condition = condition; children = children}
      in
      _eval player condition 0

    let eval_with_alpha_beta_cut player condition = 
      let rec _eval player condition depth alpha beta =
(*
Printf.printf "#1 player[%s] depth[%d] condition[%s] alpha[%d] beta[%d]\n"
  (if player = Player.First then "first" else "last ")
  depth (Game.to_string condition) alpha beta;
*)
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
                let children, alpha, beta = status in
(*
Printf.printf "child: alpha[%d] beta[%d]\n" alpha beta;
*)
                if alpha < beta then (
                  let child = _eval next_player nc (depth + 1) alpha beta in
                  let children = child::children in
                  match player with
                  | Player.First when child.score > alpha ->
                      (children, child.score, beta)
                  | Player.Last  when child.score < beta  ->
                      (children, alpha, child.score)
                  | _ -> (children, alpha, beta)
                )
                else (
(*
Printf.printf "Cut!!!\n";
*)
                  status
                )
              )
              ([], alpha, beta) next_choices in
(*
Printf.printf "#2 player[%s] depth[%d] condition[%s] alpha[%d] beta[%d]\n"
  (if player = Player.First then "first" else "last ")
  depth (Game.to_string condition) alpha beta;
*)
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

      let i = ref (-2)
      let ii = ref (100 - 2)
      (* let nums = [|1;2;3;4;5;6;7;8|] *)
      let nums = [|8;7;6;5;4;3;2;1|]

      let find player cond depth =
        if depth >= 2 then (
          i := !i + 2;
          [nums.(!i); nums.(!i + 1)]
        )
        else (
          ii := !ii + 2;
          [!ii; !ii + 1]
        )

      let eval player cond depth =
        if depth > 2 then Some cond else None

      let to_string i = string_of_int i
    end
  )

let _ =
  SampleMinMax.eval_with_alpha_beta_cut Player.First 7
