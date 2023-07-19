open Board_definitions

let print_space = function
  | Some Black -> print_char '@'
  | Some White -> print_char 'O'
  | Some Nil -> print_char '+'
  | _ -> print_char '#'

let print_board board =
  for _ = 0 to max_dim board + 3 do
    print_char '-'
  done;
  print_newline ();

  for row = 0 to max_dim board do
    print_char '|';
    for col = 0 to max_dim board do
      print_space ((get_board board) row col)
    done;
    print_newline ()
  done;

  print_char '|';
  print_newline ();

  board
