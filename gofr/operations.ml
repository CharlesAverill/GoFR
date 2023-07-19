type op = Identity | Increment | Void

let op_of_int = function 0 -> Identity | 1 -> Increment | _ -> Void

let string_of_op = function
  | Identity -> "Identity"
  | Increment -> "Increment"
  | Void -> "Void"

let string_of_opint x = string_of_op (op_of_int x)
