open Board.Board_definitions
open Board.Board_printing

(* open Register.Register_definitions
   open Register.Register_printing
   open Register.Operation_execution *)
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

let _ = init_gui ()
let done_board = draw_loop blank_board
let _ = print_board done_board
