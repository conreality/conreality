(* This is free and unencumbered software released into the public domain. *)

type t = bool
val of_string : string -> bool
val to_string : bool -> string
val compare : t -> t -> int
