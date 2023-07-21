type space = Nil | Black | White
type position = int * int
type fboard = int * (position -> space)

let max_dim = function m, _ -> m
let get_board = function _, b -> b
let get_piece x y (board : fboard) = (get_board board) (x, y)
let is_empty x = x = Nil

let is_opponent color1 color2 =
  match (color1, color2) with
  | Black, White -> true
  | White, Black -> true
  | _ -> false

let is_within_bounds x y (board : fboard) =
  let max_x, max_y = (max_dim board, max_dim board) in
  x >= 0 && x < max_x && y >= 0 && y < max_y

let rec has_group_liberty visited x y board friendly_color =
  if List.mem (x, y) visited || not (is_within_bounds x y board) then false
  else
    let piece = get_piece x y board in
    if is_empty piece then true
    else
      let neighbors = [ (x - 1, y); (x + 1, y); (x, y - 1); (x, y + 1) ] in
      let new_visited = (x, y) :: visited in
      (* let _ =
           if (x, y) = (0, 0) || (x, y) = (1, 0) then
             Printf.printf "Looking at neighbors for (%d, %d)\n--------------\n" x
               y
         in *)
      List.exists
        (fun (nx, ny) ->
          let result =
            (nx >= 0 && ny >= 0)
            && (is_empty (get_piece nx ny board)
               || (get_board board) (nx, ny) = friendly_color
                  && has_group_liberty new_visited nx ny board friendly_color)
          in
          (* let _ =
               if (x, y) = (0, 0) || (x, y) = (1, 0) then
                 Printf.printf "Case (%d, %d): %s\n[%s %s %s %s]\n" nx ny
                   (string_of_bool result)
                   (string_of_bool (is_within_bounds nx ny board))
                   (string_of_bool (is_empty (get_piece nx ny board)))
                   (string_of_bool ((get_board board) (nx, ny) = friendly_color))
                   (string_of_bool
                      (has_group_liberty new_visited nx ny board friendly_color))
             in *)
          result)
        neighbors

let get_neighbors (x, y) = [ (x - 1, y); (x + 1, y); (x, y - 1); (x, y + 1) ]

let check_for_capture x y board friendly_color : bool =
  let piece = get_piece x y board in
  let neighbors = get_neighbors (x, y) in
  let all_neighbors_are_opponents =
    List.for_all
      (fun (nx, ny) -> is_opponent piece (get_piece nx ny board))
      neighbors
  in
  all_neighbors_are_opponents
  || not (has_group_liberty [] x y board friendly_color)

let rec place x y (value : space) (board : fboard) : fboard option * int =
  if (get_board board) (x, y) <> Nil && value <> Nil then (None, 0)
  else
    let rec clear_neighbors (x, y) board friendly_color : fboard * int =
      if not (is_within_bounds x y board) then (board, 0)
      else if (get_board board) (x, y) = friendly_color then (
        let new_board = Option.get (fst (place x y Nil board)) in
        let neighbors = [ (x - 1, y); (x + 1, y); (x, y - 1); (x, y + 1) ] in
        Printf.printf "Capturing (%d, %d)\n" x y;
        List.fold_left
          (fun (acc : fboard * int) neighbor ->
            match clear_neighbors neighbor (fst acc) friendly_color with
            | new_board', num_captures -> (new_board', num_captures + snd acc))
          (new_board, 1) neighbors)
      else (board, 0)
    in
    let new_board (row, col) =
      if row = x && col = y then value else (get_board board) (row, col)
    in
    let new_max_dim = max (max x y + 1) (max_dim board) in
    if value = Nil then (Some (new_max_dim, new_board), 1)
    else
      (* let _ =
           if has_group_liberty [] x y board (get_piece x y board) then
             Printf.printf "%d, %d has group liberty\n" x y
           else Printf.printf "%d, %d doesn't have group liberty\n" x y
         in *)
      let capture_count = ref 0 in
      let board_after_captures = ref (new_max_dim, new_board) in
      for i = 0 to new_max_dim do
        for j = 0 to new_max_dim do
          let friendly_color = get_piece i j (new_max_dim, new_board) in
          if
            check_for_capture i j !board_after_captures friendly_color
            && friendly_color <> Nil
          then (
            let board_after_captures', num_captured =
              clear_neighbors (i, j) !board_after_captures friendly_color
            in
            capture_count := !capture_count + num_captured;
            board_after_captures := board_after_captures'
            (* match place i j Nil !board_after_captures with
               | Some b -> board_after_captures := b
               | _ -> ()) *))
        done
      done;
      (Some !board_after_captures, !capture_count)

let rec place_moves (l : (int * int * space) list) (board : fboard) :
    fboard option * int =
  match l with
  | [] -> (Some board, 0)
  | (x, y, value) :: t -> (
      match place x y value board with
      | Some b, c ->
          let new_board, capture_count = place_moves t b in
          (new_board, capture_count + c)
      | _ -> (None, 0))

let blank_board : fboard = (0, fun (_, _) -> Nil)
let clear x y board = place x y Nil board
