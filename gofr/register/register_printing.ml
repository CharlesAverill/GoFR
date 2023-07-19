open Register_definitions
open Operation.Operation_definitions

let print_reg reg tail rindicator rnumber =
  let single_reg_rep = function
    | Empty -> "Empty"
    | Reg (op, _, _) -> string_of_int op
  in
  let regstr =
    match reg with
    | Empty -> Printf.sprintf "| %s |" (single_reg_rep reg)
    | Reg (op, n, rlist) ->
        let opstr = string_of_opint op in
        let liststr = String.concat ", " (List.map string_of_int rlist) in
        (if rnumber <> -1 then Printf.sprintf "| R%d " rnumber else "")
        ^ Printf.sprintf "| %s | N=%d |" opstr n
        ^ if rlist = [] then "" else Printf.sprintf " %s |" liststr
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
      let rec iter_regs x = function
        | [] -> ()
        | h :: t ->
            (match h with idx, reg -> print_reg reg (t = []) (idx = r) x);
            iter_regs (x + 1) t
      in
      iter_regs 0 reglist

let print_flowchart (og_bank : reg_bank) (ops : (reg_bank -> reg_bank) list) =
  let _ =
    print_endline "Initial bank:";
    print_bank og_bank
  in
  let rec fc_recur b o n =
    match o with
    | [] -> ()
    | h :: t ->
        let new_bank = h b in
        let _ = print_endline (Printf.sprintf "Step %d" n) in
        let _ = print_bank new_bank in
        fc_recur new_bank t (n + 1)
  in
  fc_recur og_bank ops 1
