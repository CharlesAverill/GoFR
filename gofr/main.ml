open Board
open Board_printing
open Register

let example_test () : fboard =
  let initial_board = blank_board in
  let board' =
    match place 0 0 White initial_board with
    | Some b -> b
    | None -> failwith "Failed to place white"
  in
  let board'' =
    match place 1 1 Black board' with
    | Some b -> b
    | None -> failwith "Failed to place black"
  in
  let board''' =
    match place 2 2 White board'' with
    | Some b -> b
    | None -> failwith "Failed to place white"
  in
  let final_board =
    match clear 1 1 board''' with
    | Some b -> b
    | None -> failwith "Failed to clear position"
  in
  print_board final_board

(* let _ = example_test () *)
