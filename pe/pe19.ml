let days_of_month year month =
  if month = 2 then (
    if year mod 4 = 0 && 
      not (year mod 100 = 0 && not (year mod 400 = 0))
    then 29 else 28
  )
  else (
    if List.exists (fun x -> x = month) [4; 6; 9; 11]
    then 30 else 31
  )

type date = {year:int; month:int}

let calc start_date start_dotw end_date =
  let rec loop date dotw count =
Printf.printf "year(%d) month(%d) dotw(%d) count(%d)\n" date.year date.month dotw count;
    if date.year > end_date.year ||
      (date.year = end_date.year && date.month > end_date.month)
    then (dotw, count)
    else (
      let count = if dotw = 0 then (count + 1) else count in
      let days_of_the_month = 
        days_of_month date.year date.month in
      let dotw = (dotw + days_of_the_month) mod 7 in
      loop (
        if date.month <> 12 
        then {year = date.year; month = date.month + 1}
        else {year = date.year + 1; month = 1}
      ) dotw count
    )
  in
  loop start_date start_dotw 0

let _ =
  assert (days_of_month 2000 1 = 31);
  assert (days_of_month 2000 2 = 29);
  assert (days_of_month 2100 2 = 28);
  assert (days_of_month 2001 2 = 28);
  assert (days_of_month 2004 2 = 29);
  assert (days_of_month 2000 3 = 31);
  assert (days_of_month 2000 4 = 30);
  assert (days_of_month 2000 12 = 31);
  let dotw, count = 
    calc {year = 1900; month = 1} 1 {year = 1900; month = 12} in
  let dotw, count = 
    calc {year = 1901; month = 1} dotw {year = 2000; month = 12} in
  (*
  let dotw, count = 
    calc {year = 2009; month = 1} 4 {year = 2010; month = 5} in
  *)
  Printf.printf "dotw(%d) count(%d)\n" dotw count
