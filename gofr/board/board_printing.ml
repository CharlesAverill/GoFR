open Board_definitions

let print_space = function
  | Black -> print_char '@'
  | White -> print_char 'O'
  | Nil -> print_char '+'

let print_board (board : fboard) =
  for _ = 0 to max_dim board + 3 do
    print_char '-'
  done;
  print_newline ();

  for row = 0 to max_dim board do
    print_char '|';
    for col = 0 to max_dim board do
      print_space ((get_board board) (row, col))
    done;
    print_newline ()
  done;

  print_char '|';
  print_newline ();

  board
