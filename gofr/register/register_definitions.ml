(* type register
   -------------
   | (opcode : int) Represents what function will be executed
   | (nargs  : int) Represents how many arguments this function expects
   | (args   : int list) Pointers to arguments to be passed in
   -------------
*)
type register = Empty | Reg of (int * int * int list)

(* type reg_bank
   -------------
   | (R : int) Index of register currently being targeted
   | (regs : (int * register) list) Map from indices to registers
*)
type reg_list = (int * register) list
type reg_bank = int * reg_list

let fresh_bank : reg_bank = (0, [ (0, Empty) ])

let append_fresh_register : reg_bank -> reg_bank = function
  | r, bank_list -> (r, bank_list @ [ (List.length bank_list, Empty) ])

let get_r : reg_bank -> int = function r, _ -> r

let incr_r bank : reg_bank =
  let bank' =
    if get_r bank + 1 >= List.length (snd bank) then append_fresh_register bank
    else bank
  in
  match bank' with r, l -> (r + 1, l)

let decr_r : reg_bank -> reg_bank = function r, l -> (r - 1, l)

let get_reg (index : int) (bank : reg_bank) : register =
  match bank with _, registers -> snd (List.nth registers index)

let sub_bank (new_r : int) (bank : reg_bank) : reg_bank =
  match bank with _, registers -> (new_r, registers)

let replace_reg_at_idx (index : int) (value : register) (bank : reg_bank) :
    reg_bank =
  let rec get_bank_list (idx : int) (bank_list : reg_list) =
    match bank_list with
    | [] -> []
    | h :: t -> (
        match h with
        | index, _ ->
            if idx = 0 then (index, value) :: t
            else h :: get_bank_list (idx - 1) t)
  in
  match bank with r, bank_list -> (r, get_bank_list index bank_list)

let set_opcode n (bank : reg_bank) =
  replace_reg_at_idx (get_r bank) (Reg (n, 0, [])) bank

let set_n_args n (bank : reg_bank) =
  let r = get_r bank in
  let reg_op = match get_reg r bank with Reg (op, _, _) -> op | Empty -> -1 in
  replace_reg_at_idx r (Reg (reg_op, n, [])) bank

let add_arg n (bank : reg_bank) =
  let r = get_r bank in
  let op, n_args, args =
    match get_reg r bank with
    | Reg (op, n_args, args) -> (op, n_args, args)
    | Empty -> (-1, 0, [])
  in
  replace_reg_at_idx (get_r bank) (Reg (op, n_args, args @ [ n ])) bank
