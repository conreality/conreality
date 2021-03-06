(* This is free and unencumbered software released into the public domain. *)

open Prelude

type t = { path: string list; message_type: string; qos_policy: int }

let separator_string = "/"
let separator_char = (Char.of_string separator_string)

let create path =
  if (List.exists (fun part -> String.contains part separator_char) path) then begin
    raise (Invalid_argument "topic path component must not contain the separator character")
  end;
  {path = path; message_type = ""; qos_policy = 0}

let path topic = topic.path
let message_type topic = topic.message_type
let qos_policy topic = topic.qos_policy

let of_string path = create [path] (* TODO: String.split path separator_char *)
let to_string topic = String.concat separator_string topic.path
