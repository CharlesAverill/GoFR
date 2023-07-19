open Operations

(* type register
   -------------
   | (opcode : int) Represents what function will be executed
   | (nargs  : int) Represents how many arguments this function expects
   | (args   : register list) Pointers to arguments to be passed in
   -------------
*)
type register = Empty | Reg of (int * int * register list)

(* type reg_bank
   -------------
   | (R : int) Index of register currently being targeted
   | (regs : (int * register) list) Map from indices to registers
*)
type reg_bank = int * (int * register) list

let print_reg reg tail rindicator =
  let single_reg_rep = function
    | Empty -> "Empty"
    | Reg (op, _, _) -> string_of_int op
  in
  let regstr =
    match reg with
    | Empty -> Printf.sprintf "| %s |" (single_reg_rep reg)
    | Reg (op, n, rlist) ->
        let opstr = string_of_opint op in
        let liststr = String.concat ", " (List.map single_reg_rep rlist) in
        Printf.sprintf "|%s | %d | %s |" opstr n liststr
  in
  let border = String.make (String.length regstr) '-' ^ "\n" in
  print_string
    (border ^ regstr
    ^ (if rindicator then " <- R" else "")
    ^ "\n"
    ^ if tail then border else "")

let print_bank (bank : reg_bank) : unit =
  match bank with
  | r, reglist ->
      let rec iter_regs = function
        | [] -> ()
        | h :: t ->
            (match h with idx, reg -> print_reg reg (t == []) (idx == r));
            iter_regs t
      in
      iter_regs reglist

let fresh_bank = (0, [ (0, Empty) ])

let append_fresh_register : reg_bank -> reg_bank = function
  | r, bank_list -> (r, bank_list @ [ (List.length bank_list, Empty) ])

let set_opcode n (bank : reg_bank) =
  let rec replace_at_index index value = function
    | [] -> []
    | idx_h :: t -> (
        match idx_h with
        | idx, _ ->
            if index = 0 then (idx, Reg (value, 0, [])) :: t
            else idx_h :: replace_at_index (index - 1) value t)
  in
  match bank with r, bank_list -> (r, replace_at_index r n bank_list)

let _ = print_string "\n"
let b = append_fresh_register fresh_bank
let b' = set_opcode 1 b
let _ = print_bank b'
