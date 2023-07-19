type space = Nil | Black | White
type fboard = Board of (int * (int -> int -> space option))

let max_dim = function Board (m, _) -> m
let get_board = function Board (_, b) -> b

let place x y value board : fboard option =
  let new_board row col =
    if row = x && col = y then Some value else (get_board board) row col
  in
  Some (Board (max (max x y) (max_dim board), new_board))

let rec place_moves (l : (int * int * space) list) (board : fboard) :
    fboard option =
  match l with
  | [] -> Some board
  | (x, y, value) :: t -> (
      match place x y value board with Some b -> place_moves t b | _ -> None)

let blank_board : fboard =
  Board (0, fun x y -> if x < 0 || y < 0 then None else Some Nil)

let clear x y board = place x y Nil board
