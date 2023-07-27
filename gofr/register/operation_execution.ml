open Operation.Operation_definitions
open Register_definitions

let id_reg x = Reg (int_of_op Identity, 1, [ x ])
let exec_identity bank = bank

let rec add_info_at_idx idx n bank added_from_load =
  let reg = get_reg idx bank in
  match reg with
  | Empty -> (
      let bank' = set_opcode idx n bank in
      match get_reg idx bank' with
      | Empty -> bank'
      | Reg (op_int, _, _) -> (
          match op_of_int op_int with
          | UserDefined x -> set_n_args idx x (set_opcode idx x bank')
          | _ -> set_n_args idx (get_n_args (op_of_int op_int)) bank'))
  | Reg (_, nargs, args) -> (
      let added_info_bank =
        if nargs = 0 then
          match op_of_int n with
          | Void -> bank
          | UserDefined _ -> set_n_args idx n bank
          | _ ->
              add_info_at_idx idx n
                (replace_reg_at_idx idx Empty bank)
                added_from_load
        else if List.length args >= nargs then
          add_info_at_idx idx n
            (replace_reg_at_idx idx Empty bank)
            added_from_load
        else add_arg idx n bank
      in
      let new_reg = (get_regmap added_info_bank) idx in
      match new_reg with
      | Reg (op, _, args) ->
          if List.length args = get_n_args (op_of_int op) && not added_from_load
          then exec idx added_info_bank
          else added_info_bank
      | Empty -> added_info_bank)

and exec_if_ready idx bank =
  match get_reg idx bank with
  | Reg (op, _, args) ->
      if List.length args = get_n_args (op_of_int op) then exec idx bank
      else bank
  | Empty -> bank

and exec (idx : int) (bank : reg_bank) : reg_bank =
  let incorrect_n_args op expected_args n_args =
    failwith
      (Printf.sprintf "%s expected %d arguments but got %d instead"
         (string_of_op op) expected_args n_args)
  in
  let reg = (get_regmap bank) idx in
  match reg with
  | Empty -> bank
  | Reg (op, expected_args, args) -> (
      (* I think I should be enforcing that args are Identity here but that fails in the
         case where op = [Identity; Move] so I'm not sure how to handle this yet (if at all) *)
      (* let _ = if args <> [] then if op <> int_of_op Identity then failwith "" in *)
      match op_of_int op with
      | Identity -> exec_identity bank
      | Jump -> (
          match args with
          | [ jump_type; jump_dest'; jump_cond ] ->
              let jump_dest =
                if jump_type = jump_UNCOND then jump_dest'
                else
                  match get_reg jump_cond bank with
                  | Reg (jump_cond_type, _, [ first_arg ]) ->
                      if op_of_int jump_cond_type = Identity then
                        if first_arg <= 0 then jump_dest' else idx
                      else 0
                  | _ -> failwith "Conditional jump failed"
              in
              let new_bank =
                replace_reg_at_idx idx (id_reg jump_dest)
                  (jump_dest, max (get_max_reg bank) jump_dest, get_regmap bank)
              in
              let rec jump_recur jump_index jump_bank =
                let _ = Printf.printf "%d %d\n" idx jump_index in
                if jump_index > get_max_reg jump_bank then
                  failwith "Runaway jump encountered"
                else
                  match get_reg jump_index jump_bank with
                  | Reg (jump_op, _, _) ->
                      if op_of_int jump_op = Break then jump_bank
                      else
                        jump_recur (jump_index + 1)
                          (exec_if_ready jump_index jump_bank)
                  | _ -> jump_recur (jump_index + 1) jump_bank
              in
              if jump_dest = idx then new_bank
              else jump_recur jump_dest new_bank
          | _ -> incorrect_n_args Jump expected_args (List.length args))
      | Arith -> (
          match args with
          | [ arith_opcode; src1; src2; dest ] ->
              let val1 =
                match get_reg src1 bank with
                | Reg (_, _, [ first_arg ]) -> first_arg
                | _ -> failwith "Tried to do arithmetic on a faulty register"
              in
              let val2 =
                match get_reg src2 bank with
                | Reg (_, _, [ first_arg ]) -> first_arg
                | _ -> failwith "Tried to do arithmetic on a faulty register"
              in
              let new_val =
                if arith_opcode = arith_ADD then val1 + val2
                else if arith_opcode = arith_SUB then val1 - val2
                else if arith_opcode = arith_MUL then val1 * val2
                else if arith_opcode = arith_DIV then val1 / val2
                else 0
              in
              replace_reg_at_idx idx Empty
                (replace_reg_at_idx dest (id_reg new_val) bank)
          | _ -> incorrect_n_args Arith expected_args (List.length args))
      | Move -> (
          match args with
          | [ arg_type; srcBegin'; srcLength; dest' ] ->
              let srcBegin =
                if arg_type = move_SET then srcBegin'
                else if arg_type = move_OFFSET_POS then idx + srcBegin'
                else if arg_type = move_OFFSET_DEST then idx
                else 0
              in
              let dest =
                if arg_type = move_SET then dest'
                else if
                  arg_type = move_OFFSET_POS || arg_type = move_OFFSET_DEST
                then idx + dest'
                else 0
              in
              let rec set_loop idx bank_target =
                if srcBegin + idx >= srcBegin + srcLength then bank_target
                else
                  set_loop (idx + 1)
                    (replace_reg_at_idx (dest + idx)
                       (get_reg (srcBegin + idx) bank)
                       bank_target)
              in
              replace_reg_at_idx idx (id_reg srcLength) (set_loop 0 bank)
          | _ -> incorrect_n_args Move expected_args (List.length args))
      | Load -> (
          match args with
          | [ arg_type; src_reg; dest_reg ] ->
              let src_data =
                match
                  get_reg
                    (if arg_type = load_SET then src_reg
                     else if arg_type = load_OFFSET_POS then idx + src_reg
                     else if arg_type = load_OFFSET_NEG then idx - src_reg
                     else 0)
                    bank
                with
                | Empty -> failwith "Tried to load from an Empty register"
                | Reg (_, _, args') -> List.hd args'
              in
              replace_reg_at_idx idx (id_reg src_data)
                (add_info_at_idx
                   (if arg_type = load_SET then dest_reg
                    else if arg_type = load_OFFSET_POS then idx + dest_reg
                    else if arg_type = load_OFFSET_NEG then idx - dest_reg
                    else 0)
                   src_data bank true)
          | _ -> incorrect_n_args Load expected_args (List.length args))
      | _ -> bank)

let incr_r : reg_bank -> reg_bank = function
  | r, m, l ->
      let new_bank = (r + 1, max m (r + 1), l) in
      exec_if_ready (get_r new_bank) new_bank

let decr_r : reg_bank -> reg_bank = function
  | r, m, l ->
      let new_bank = (r - 1, m, l) in
      exec_if_ready (get_r new_bank) new_bank

let set_r x : reg_bank -> reg_bank = function _, m, l -> (x, m, l)
let exec_r bank = match bank with r, _, _ -> exec r bank
let add_info n bank = add_info_at_idx (get_r bank) n bank false
let add_info_op op bank = add_info_at_idx (get_r bank) (int_of_op op) bank false
