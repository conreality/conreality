(* This is free and unencumbered software released into the public domain. *)

open Check_common
open Consensus.Prelude

(* Prelude.String *)

module String_test = struct
  let is_empty () =
    same_bool true (String.is_empty "");
    same_bool false (String.is_empty "a")
end

(* Test suite definition *)

let () =
  Alcotest.run "Consensus.Prelude.String test suite" [
    "String", [
      "String.is_empty", `Quick, String_test.is_empty;
    ];
  ]
