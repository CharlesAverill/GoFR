open Board.Board_definitions
open Board.Board_printing
open Register.Register_definitions
open Register.Register_printing
open Board.Board_graphics

let _ = print_newline ()

(* let _ =
   print_board
     (Option.get
        (place_moves
           [ (0, 0, White); (1, 1, Black); (2, 2, White); (1, 1, Nil) ]
           blank_board)) *)

(* let b = append_fresh_register fresh_bank
   let b' = set_opcode 1 b
   let _ = print_bank b' *)

(* let testbank =
     fresh_bank |> set_opcode 0 |> set_n_args 1 |> add_arg 0 |> incr_r
     |> set_opcode 1 |> set_n_args 1 |> add_arg 0
     |> fun x -> exec (get_reg (get_r x) x) x

   let _ = print_bank testbank *)

(* let _ =
   print_flowchart fresh_bank
     [
       set_opcode 0;
       set_n_args 1;
       add_arg 0;
       incr_r;
       set_opcode 1;
       set_n_args 1;
       add_arg 0;
       (fun x -> exec (get_reg (get_r x) x) x);
     ] *)

let board = ref blank_board
let rbank = ref fresh_bank
let _ = list_rbank rbank
let _ = init_gui !board
let done_board = draw_loop blank_board
(* let done_board =
   Option.get
     (fst
        (place_moves
           [
             (1, 1, Black);
             (0, 0, White);
             (0, 1, Black);
             (1, 0, White);
             (2, 0, Black);
           ]
           blank_board)) *)

let _ = print_board done_board
let _ = print_bank !rbank

(* let _ =
   if has_group_liberty [] 0 0 done_board White then
     print_endline "White has liberty"
   else print_endline "White should be captured" *)
