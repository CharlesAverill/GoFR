open Board.Board_definitions
open Board.Board_printing
open Register.Register_definitions
open Register.Register_printing
open Register.Operation_execution
open Board.Board_graphics

let _ = print_newline ()

let _self_replicating_test () =
  print_flowchart true fresh_bank
    [
      (* R1: Identity 5*)
      add_info 1;
      add_info 5;
      (* R2: Identity 10 *)
      incr_r;
      add_info 1;
      add_info 10;
      (* R3 : Move 1, 3 (curry) *)
      incr_r;
      add_info 3;
      add_info 1;
      add_info 3;
      (* R4 : Identity 5 *)
      incr_r;
      add_info 1;
      add_info 5;
      (* R5 : Load 4 3*)
      incr_r;
      add_info 4;
      add_info 4;
      add_info 3;
      (* R4 : Jump*)
      decr_r;
      add_info 2;
      (* Decrement and auto-exec R3 Move *)
      decr_r;
      (* R4 : Jump 8*)
      incr_r;
      add_info 8;
    ]

let _do_gui_test () =
  let board = ref blank_board in
  let rbank = ref fresh_bank in
  let _ = list_rbank rbank in
  let _ = init_gui !board !rbank in
  let done_board = draw_loop blank_board in
  let _ = print_board done_board in
  print_bank !rbank

let _do_auto_boardtest () =
  let done_board =
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
            blank_board))
  in
  print_board done_board

let tmachine_test () =
  print_flowchart false fresh_bank
    [
      (* R0 : TM HEAD *)
      add_info_op Identity;
      add_info 0;
      (* R1 : CONSTANT 1 *)
      incr_r;
      add_info_op Identity;
      add_info 1;
      (* R3 - R13 : COMPUTATION SUBSPACE*)
      incr_r;
      incr_r;
      incr_r;
      incr_r;
      incr_r;
      incr_r;
      incr_r;
      incr_r;
      incr_r;
      incr_r;
      incr_r;
      incr_r;
      (* TM BUILTINS *)
      (* R14 : LEFT *)
      add_info_op Decrement;
      incr_r;
      add_info_op Load;
      add_info 2;
      add_info 14;
      (* R15 : RIGHT*)
      add_info_op Increment;
      incr_r;
      add_info_op Load;
      add_info 2;
      add_info 15;
      (* PROGRAM MEMORY *)
      (* R16 : Program Size *)
      add_info_op Identity;
      add_info 5;
      incr_r;
      add_info_op Move;
      add_info 15;
      add_info 15;
      add_info 3;
      add_info_op Jump;
      add_info 3;
    ]

let _ = tmachine_test ()
