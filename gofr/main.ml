open Board.Board_definitions
open Board.Board_printing
open Register.Register_definitions
open Register.Register_printing
open Register.Operation_execution
open Operation.Operation_definitions
open Board.Board_graphics

let _ = print_newline ()

let _self_replicating_test () =
  let prog_size = 5 in
  let prog_size_reg = 6 in
  print_flowchart false fresh_bank
    [
      (* R1 - R2 : DATA *)
      add_info_op Identity;
      add_info 1;
      incr_r;
      add_info_op Identity;
      add_info 10;
      (* Program Termination *)
      incr_r;
      add_info_op Break;
      (* R4 : CONSTANT 1 *)
      incr_r;
      add_info_op Identity;
      add_info 1;
      (* SELF-REPLICATING PROGRAM *)
      (* Self-Replicator *)
      incr_r;
      add_info_op Move;
      add_info move_OFFSET_DEST;
      add_info 1;
      add_info prog_size_reg;
      (* R6 : Program Size *)
      incr_r;
      add_info_op Identity;
      add_info prog_size;
      incr_r;
      add_info_op Load;
      add_info load_OFFSET_NEG;
      add_info 1;
      add_info 2;
      (* Program *)
      add_info_op Arith;
      add_info arith_ADD;
      add_info 1;
      add_info 4;
      incr_r;
      add_info_op Arith;
      add_info arith_SUB;
      add_info 2;
      add_info 4;
      incr_r;
      add_info_op Identity;
      add_info 1;
      incr_r;
      add_info_op Load;
      add_info load_OFFSET_NEG;
      add_info 1;
      add_info 3;
      decr_r;
      add_info_op Identity;
      add_info 2;
      incr_r;
      add_info_op Load;
      add_info load_OFFSET_NEG;
      add_info 1;
      add_info 2;
      decr_r;
      add_info_op Jump;
      add_info jump_Z;
      add_info 2;
      incr_r;
      incr_r;
      add_info_op Load;
      add_info load_OFFSET_NEG;
      add_info 1;
      add_info 2;
      add_info_op Jump;
      add_info jump_UNCOND;
      add_info 5;
      add_info 1;
    ]

let _jump_test () =
  print_flowchart false fresh_bank
    [
      incr_r;
      incr_r;
      add_info_op Break;
      incr_r;
      incr_r;
      incr_r;
      add_info_op Jump;
      add_info jump_UNCOND;
      add_info 1;
      add_info 1;
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

let _tmachine_test () =
  print_flowchart false fresh_bank
    [
      (* R1 : TM HEAD *)
      add_info_op Identity;
      add_info 0;
      (* R2 : CONSTANT 1 *)
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
      add_info_op Arith;
      add_info 2;
      add_info 1;
      add_info 2;
      incr_r;
      add_info_op Load;
      add_info 1;
      (* R15 : RIGHT*)
      add_info_op Arith;
      add_info 1;
      add_info 1;
      add_info 2;
      incr_r;
      add_info_op Load;
      add_info 1;
      (* PROGRAM MEMORY *)
      (* R16 : Program Size *)
      add_info_op Identity;
      add_info 5;
      incr_r;
      (* R17 : Duplication Routine *)
      (* TODO *)
      (* Load LEFT *)
      add_info_op Move;
      add_info 15;
      add_info 15;
      add_info 3;
      (* Execute LEFT *)
      add_info_op Jump;
      add_info 3;
      (* Load RIGHT *)
      add_info_op Jump;
      add_info 16;
      add_info_op Move;
      add_info 14;
      add_info 14;
      add_info 3;
      (* Execute RIGHT *)
      add_info_op Jump;
      add_info 3;
    ]

let _ = _self_replicating_test ()
