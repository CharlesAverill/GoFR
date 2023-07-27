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
   | (max : int) Largest register number so far
   | (regmap : int -> register ) Map from indices to registers
*)
type reg_list = int -> register
type reg_bank = int * int * reg_list

let fresh_bank : reg_bank = (1, 1, fun _ -> Empty)
let get_r : reg_bank -> int = function r, _, _ -> r

let set_r x (bank : reg_bank) : reg_bank =
  match bank with _, m, l -> (x, max x m, l)

let get_max_reg : reg_bank -> int = function _, max, _ -> max
let get_regmap : reg_bank -> reg_list = function _, _, regmap -> regmap

let get_reg (index : int) (bank : reg_bank) : register =
  match bank with _, _, registers -> registers index

let replace_reg_at_idx (index : int) (value : register) (bank : reg_bank) :
    reg_bank =
  match bank with
  | r, m, rmap -> (r, max m index, fun x -> if x = index then value else rmap x)

let set_opcode idx n (bank : reg_bank) =
  replace_reg_at_idx idx (Reg (n, 0, [])) bank

let set_n_args idx n (bank : reg_bank) =
  let reg_op =
    match get_reg idx bank with Reg (op, _, _) -> op | Empty -> -1
  in
  replace_reg_at_idx idx (Reg (reg_op, n, [])) bank

let add_arg idx n (bank : reg_bank) =
  let op, n_args, args =
    match get_reg idx bank with
    | Reg (op, n_args, args) -> (op, n_args, args)
    | Empty -> (-1, 0, [])
  in
  replace_reg_at_idx idx (Reg (op, n_args, args @ [ n ])) bank
