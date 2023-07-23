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
          | _ -> set_n_args idx (get_n_args (op_of_int n)) bank
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
          then exec new_reg added_info_bank
          else added_info_bank
      | Empty -> added_info_bank)

and exec_if_ready reg bank =
  match reg with
  | Reg (op, _, args) ->
      if List.length args = get_n_args (op_of_int op) then exec reg bank
      else bank
  | Empty -> bank

and exec (reg : register) (bank : reg_bank) : reg_bank =
  let incorrect_n_args op expected_args n_args =
    failwith
      (Printf.sprintf "%s expected %d arguments but got %d instead"
         (string_of_op op) expected_args n_args)
  in
  let r = get_r bank in
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
          | jump_dest :: [] ->
              let new_bank =
                (jump_dest, max (get_max_reg bank) jump_dest, get_regmap bank)
              in
              replace_reg_at_idx r Empty
                (exec_if_ready (get_reg (get_r new_bank) new_bank) new_bank)
          | _ -> incorrect_n_args Jump expected_args (List.length args))
      | Increment -> (
          match args with
          | reg_pointer :: [] ->
              let new_val =
                match get_reg reg_pointer bank with
                | Empty -> failwith "Tried to increment an Empty register"
                | Reg (_, _, args') -> List.hd args'
              in
              replace_reg_at_idx r Empty
                (replace_reg_at_idx reg_pointer (id_reg (new_val + 1)) bank)
          | _ -> incorrect_n_args Increment expected_args (List.length args))
      | Decrement -> (
          match args with
          | reg_pointer :: [] ->
              let new_val =
                match get_reg reg_pointer bank with
                | Empty -> failwith "Tried to decrement an Empty register"
                | Reg (_, _, args') -> List.hd args'
              in
              replace_reg_at_idx r Empty
                (replace_reg_at_idx reg_pointer (id_reg (new_val - 1)) bank)
          | _ -> incorrect_n_args Increment expected_args (List.length args))
      | Move -> (
          match args with
          | [ srcBegin; srcEnd; dest ] ->
              let rec set_loop idx bank_target =
                if srcBegin + idx > srcEnd then bank_target
                else
                  set_loop (idx + 1)
                    (replace_reg_at_idx (dest + idx)
                       (get_reg (srcBegin + idx) bank)
                       bank_target)
              in
              replace_reg_at_idx r
                (id_reg (srcEnd - srcBegin + 1))
                (set_loop 0 bank)
          | _ -> incorrect_n_args Move expected_args (List.length args))
      | Load -> (
          match args with
          | [ src_reg; dest_reg ] ->
              let src_data =
                match get_reg src_reg bank with
                | Empty -> failwith "Tried to load from an Empty register"
                | Reg (_, _, args') -> List.hd args'
              in
              replace_reg_at_idx r (id_reg src_data)
                (add_info_at_idx dest_reg src_data bank true)
          | _ -> incorrect_n_args Load expected_args (List.length args))
      | _ -> bank)

let incr_r : reg_bank -> reg_bank = function
  | r, m, l ->
      let new_bank = (r + 1, max m (r + 1), l) in
      exec_if_ready (get_reg (get_r new_bank) new_bank) new_bank

let decr_r : reg_bank -> reg_bank = function
  | r, m, l ->
      let new_bank = (r - 1, m, l) in
      exec_if_ready (get_reg (get_r new_bank) new_bank) new_bank

let exec_r bank = match bank with r, _, _ -> exec (get_reg r bank) bank
let add_info n bank = add_info_at_idx (get_r bank) n bank false
let add_info_op op bank = add_info_at_idx (get_r bank) (int_of_op op) bank false
