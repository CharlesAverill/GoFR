open Register_definitions
open Operation.Operation_definitions

let print_reg reg tail rindicator rnumber =
  let single_reg_rep = function
    | Empty -> "Empty"
    | Reg (op, _, _) -> string_of_int op
  in
  let regstr =
    Printf.sprintf "| R%d " rnumber
    ^
    match reg with
    | Empty -> Printf.sprintf "| %s |" (single_reg_rep reg)
    | Reg (op, n, rlist) ->
        let opstr = string_of_opint op in
        let liststr = String.concat ", " (List.map string_of_int rlist) in
        Printf.sprintf "| %s | N=%d |" opstr n
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
  | r, m, regmap ->
      let rec iter_regs idx =
        if idx > m then ()
        else (
          print_reg (regmap idx) (idx = m) (idx = r) idx;
          iter_regs (idx + 1))
      in
      iter_regs 1

let print_flowchart_inner interactive og_bank print_banks
    (ops : (reg_bank -> reg_bank) list) =
  let _ =
    if print_banks then (
      print_endline "Initial bank:";
      print_bank og_bank)
  in
  let rec fc_recur b o n =
    match o with
    | [] -> ()
    | h :: t ->
        let _ = if interactive then read_line () else "" in
        let _ =
          if print_banks then print_endline (Printf.sprintf "Step %d" n)
        in
        let new_bank = h b in
        let _ = if print_banks then print_bank new_bank in
        fc_recur new_bank t (n + 1)
  in
  fc_recur og_bank ops 1

let print_flowchart interactive og_bank =
  print_flowchart_inner interactive og_bank true

let run_flowchart_quiet interactive og_bank =
  print_flowchart_inner interactive og_bank false
