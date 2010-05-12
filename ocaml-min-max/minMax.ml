module Player =
  struct
    type t = First | Last
    let next_player = function First -> Last | Last -> First
  end

open Player
open Printf

type 'a result = {
  player:Player.t;
  score:int;
  children:('a * 'a result) list
}

let eval player condition finder evaluater = 
  let rec _eval player condition depth =
    match evaluater player condition depth with
    | Some score -> {player = player; score = score; children = []}
    | None ->
        let next_player = next_player player in
        let next_choices = finder player condition depth in
        let children =
          List.fold_left
            (fun rl (nc, new_cond) -> 
              (nc, _eval next_player new_cond (depth + 1))::rl)
            [] next_choices in
        let init, compare = 
          match player with
          | First -> (min_int, max)
          | Last  -> (max_int, min) in
        let score = 
          List.fold_left 
            (fun s (choice, child) -> compare s child.score) 
            init children in
        {player = player; score = score; children = children}
  in
  _eval player condition 0

let eval_with_alpha_beta player condition finder evaluater = 
  let rec _eval player condition depth alpha beta =
    match evaluater player condition depth with
    | Some score -> {player = player; score = score; children = []}
    | None ->
        let next_player = next_player player in
        let next_choices = finder player condition depth in
        let children, alpha, beta =
          List.fold_left
            (fun (rl, alpha, beta) (nc, new_cond) -> 
              if alpha >= beta then (rl, alpha, beta)
              else
                let child =
                  _eval next_player new_cond (depth + 1) alpha beta in
                let score = child.score in
                match player with
                | First when score > alpha -> ((nc, child)::rl, score, beta)
                | Last  when score < beta  -> ((nc, child)::rl, alpha, score)
                | _                        -> ((nc, child)::rl, alpha, beta)
            )
            ([], alpha, beta) next_choices in
        let score =
          match player with First -> alpha | Last -> beta in
        {player = player; score = score; children = children}
  in
  _eval player condition 0 min_int max_int

let _ =
  let i = ref (-2) in
  let ii = ref (100 - 2) in
  (* let nums = [|1;2;3;4;5;6;7;8|] in *)
  let nums = [|5;6;7;8;4;3;2;1|] in
  eval_with_alpha_beta First 777
    (* find next choices *)
    (fun player condition depth ->
        if depth >= 2 then (
          i := !i + 2;
          [(!i + 200, nums.(!i)); (!i + 201, nums.(!i + 1))]
        )
        else (
          ii := !ii + 2;
          [(!ii + 200, !ii); (!ii + 201, !ii)]
        ))
    (* evaluate the condition *)
    (fun player condition depth ->
      if depth > 2 then Some condition else None)

