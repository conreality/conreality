(* This is free and unencumbered software released into the public domain. *)

open Ocamlbuild_plugin
open Command

let cxx = "c++" (*find_command ["clang++"; "g++"; "c++"]*)

let stdlib_dir = lazy begin
  let ocamlc_where = !Options.build_dir / (Pathname.mk "ocamlc.where") in
  let () = Command.execute ~quiet:true (Cmd(S[!Options.ocamlc; A"-where"; Sh">"; P ocamlc_where])) in
  String.chomp (read_file ocamlc_where)
end

let () =
  dispatch begin function

  | Before_options ->
    Options.use_ocamlfind := true

  | After_rules ->
    ocaml_lib ~extern:true "opencv_core";
    ocaml_lib ~extern:true "opencv_objdetect";

    dep  ["link"; "ocaml"; "use_vision"] ["src/consensus/libconsensus-vision.a"];

    flag ["link"; "ocaml"; "library"; "byte"; "use_vision"]
      (S[A"-dllib"; A"-lconsensus-vision";
         A"-cclib"; A"-lconsensus-vision"]);

    flag ["link"; "ocaml"; "library"; "native"; "use_vision"]
      (S[A"-cclib"; A"src/consensus/libconsensus-vision.a"]);

    flag ["link"; "ocaml"; "program"; "byte"; "use_vision"]
      (S[A"-dllpath"; A"_build/src/consensus";
         A"-dllib"; A"-lconsensus-vision";
         A"-cclib"; A"src/consensus/libconsensus-vision.a"]);

    flag ["link"; "ocaml"; "program"; "native"; "use_vision"]
      (S[A"-cclib"; A"src/consensus/libconsensus-vision.a"]);

    rule "ocaml C++ stubs: cc -> o"
      ~prod:"%.o"
      ~dep:"%.cc"
      begin fun env _build ->
        let cc = env "%.cc" in
        let o = env "%.o" in
        let tags = tags_of_pathname cc ++ "c++" ++ "compile" in
        Cmd(S[A cxx; T tags; A"-c"; A"-I"; A !*stdlib_dir; A"-fPIC"; A"-o"; P o; Px cc])
      end

  | _ -> ()
  end
