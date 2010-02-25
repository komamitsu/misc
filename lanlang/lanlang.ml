(*
(* File calc.ml *)
let _ =
	try
		let lexbuf = Lexing.from_channel stdin in
		while true do
			let result = Parser.main Lexer.token lexbuf in
				print_int result; print_newline(); flush stdout
		done
	with Lexer.Eof ->
		exit 0
*)

let _ =
  try
    let lexbuf = Lexing.from_channel stdin in
    while true do
      let result = Lexer.token lexbuf in
      Printf.printf "<%s>" result; flush stdout
    done
  with Lexer.Eof -> exit 0