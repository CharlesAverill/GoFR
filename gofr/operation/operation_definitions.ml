type opcode = Identity | Increment | Move | UserDefined of int | Void
type opinfo = opcode * int * string

let op_of_int x =
  if x < 0 then Void
  else
    match x with
    | 0 -> Identity
    | 1 -> Increment
    | 2 -> Move
    | x -> UserDefined x

let int_of_op x =
  let rec int_finder n = if op_of_int n = x then n else int_finder (n + 1) in
  int_finder 0

let operations_info : opinfo list =
  [
    (Identity, 1, "Identity");
    (Increment, 1, "Increment");
    (Move, 2, "Move");
    (UserDefined 0, 0, "UserDefined");
    (Void, 0, "Void");
  ]

let matches_opcode_constr op1 op2 =
  op1 = op2
  ||
  match op1 with
  | UserDefined _ -> ( match op2 with UserDefined _ -> true | _ -> false)
  | _ -> false

let is_usrdef op = match op with UserDefined _ -> true | _ -> false

let string_of_op (op : opcode) : string =
  let rec search_opinfo (l : opinfo list) =
    match l with
    | [] -> ""
    | (o, _, s) :: t ->
        if matches_opcode_constr o op then s else search_opinfo t
  in
  search_opinfo operations_info

let string_of_opint x = string_of_op (op_of_int x)

let get_n_args (op : opcode) : int =
  let rec search_opinfo (l : opinfo list) =
    match l with
    | [] -> -1
    | (o, n, _) :: t -> if o = op then n else search_opinfo t
  in
  match op with UserDefined x -> x | _ -> search_opinfo operations_info
