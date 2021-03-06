(* This is free and unencumbered software released into the public domain. *)

#if OCAMLVERSION < 4020
type bytes = string
#endif

external length : string -> int = "%string_length"
external get : string -> int -> char = "%string_safe_get"
external set : bytes -> int -> char -> unit = "%string_safe_set"
external create : int -> bytes = "caml_create_string"
val make : int -> char -> string
#if OCAMLVERSION >= 4020
val init : int -> (int -> char) -> string
#endif
val copy : string -> string
val sub : string -> int -> int -> string
val fill : bytes -> int -> int -> char -> unit
val blit : string -> int -> bytes -> int -> int -> unit
val concat : string -> string list -> string
val iter : (char -> unit) -> string -> unit
val iteri : (int -> char -> unit) -> string -> unit
val map : (char -> char) -> string -> string
#if OCAMLVERSION >= 4020
val mapi : (int -> char -> char) -> string -> string
#endif
val trim : string -> string
val escaped : string -> string
val index : string -> char -> int
val rindex : string -> char -> int
val index_from : string -> int -> char -> int
val rindex_from : string -> int -> char -> int
val contains : string -> char -> bool
val contains_from : string -> int -> char -> bool
val rcontains_from : string -> int -> char -> bool
val uppercase : string -> string
val lowercase : string -> string
val capitalize : string -> string
val uncapitalize : string -> string
type t = string
val compare : t -> t -> int
external unsafe_get : string -> int -> char = "%string_unsafe_get"
external unsafe_set : bytes -> int -> char -> unit = "%string_unsafe_set"
external unsafe_blit : string -> int -> bytes -> int -> int -> unit
  = "caml_blit_string" "noalloc"
external unsafe_fill : bytes -> int -> int -> char -> unit
  = "caml_fill_string" "noalloc"

val is_empty : string -> bool
val of_bool : bool -> string
val of_float : float -> string
val of_int : int -> string
