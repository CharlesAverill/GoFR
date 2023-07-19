open Operation.Operation_definitions
open Register_definitions

let id_reg x = Reg (int_of_op Identity, 1, [ x ])
let exec_identity bank = bank

let incorrect_n_args op expected_args n_args =
  failwith
    (Printf.sprintf "%s expected %d arguments but got %d instead"
       (string_of_op op) expected_args n_args)

let rec exec (reg : register) (bank : reg_bank) : reg_bank =
  let r = get_r bank in
  let rec reduce_args (args : int list) (reduce_bank : reg_bank) : reg_bank =
    match args with
    | [] -> bank
    | h :: t ->
        let reg_to_reduce = get_reg h reduce_bank in
        (* Base case - if the register is already Identity then don't recurse *)
        if (match reg_to_reduce with Reg (o, _, _) -> o | _ -> -1) = 0 then bank
        else
          let reduced_bank = exec reg_to_reduce reduce_bank in
          reduce_args t reduced_bank
    (* reduce_args t (replace_reg_at_idx h (get_reg h (exec (get_reg h reduce_bank) reduce_bank)) reduce_bank) *)
  in
  match reg with
  | Empty -> bank
  | Reg (op, expected_args, old_args) -> (
      let reduced_bank = reduce_args old_args bank in
      let args =
        match get_reg (get_r bank) reduced_bank with
        | Empty -> []
        | Reg (_, _, a) -> a
      in
      match op_of_int op with
      | Identity -> exec_identity bank
      | Increment ->
          if List.length args <> expected_args then
            incorrect_n_args Increment expected_args (List.length args)
          else
            let to_incr = List.hd args in
            let new_val =
              match get_reg to_incr reduced_bank with
              | Empty -> failwith "Tried to increment an Empty register"
              | Reg (_, _, args') -> List.hd args'
            in
            replace_reg_at_idx r (id_reg (new_val + 1)) reduced_bank
      | _ -> bank)
