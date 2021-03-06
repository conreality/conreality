(* This is free and unencumbered software released into the public domain. *)

#if OCAMLVERSION < 4020
type bytes = string
#endif

open Prelude

type addr = int64

module type S = sig
  val init   : unit -> unit
  val close  : unit -> unit
  val access : addr -> int -> unit
  val read   : addr -> int -> bytes
  val write  : addr -> bytes -> int
end

module F (T : S) = struct
  let init   = T.init
  let close  = T.close
  let access = T.access
  let read   = T.read
  let write  = T.write
end

(** lseek(2), read(2), and write(2) *)
module IO : S = struct
  type opened = { fd: Unix.file_descr }

  type state = opened option

  let state = ref (None : state)

  let init () =
    match !state with
    | Some _ -> () (* already initialized *)
    | _ -> begin
        let flags = [Unix.O_RDWR; Unix.O_SYNC] in
        let fd = Unix.openfile "/dev/mem" flags 0 in
        state := Some { fd }
      end

  let close () =
    match !state with
    | None -> ()
    | Some { fd } -> begin
        state := None;
        Unix.close fd
      end

  let access addr length = ()

  let read addr length =
    assert (addr >= 0L);
    assert (length >= 0);
    match !state with
    | None -> failwith "RAM.init not yet called"
    | Some { fd } -> begin
        (* TODO: optimize this using pread(2) to eliminate the seek. *)
        let _ = Unix.LargeFile.lseek fd addr Unix.SEEK_SET in
        let buffer = Bytes.make length '\x00' in
        let rc = Unix.read fd buffer 0 length in
        let _ = assert (rc = length) in
        buffer
      end

  let write addr buffer =
    assert (addr >= 0L);
    match !state with
    | None -> failwith "RAM.init not yet called"
    | Some { fd } -> begin
        (* TODO: optimize this using pwrite(2) to eliminate the seek. *)
        let _ = Unix.LargeFile.lseek fd addr Unix.SEEK_SET in
        let length = Bytes.length buffer in
        let rc = Unix.single_write fd buffer 0 length in
        let _ = assert (rc = length) in
        length
      end
end

(* fstat(2), mmap(2) *)
module Mmap : S = struct
  type mmap = (char, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t

  type ranges = (addr, mmap) Hashtbl.t

  type opened = { fd: Unix.file_descr; ranges: ranges }

  type state = opened option

  let state = ref (None : state)

  let init () =
    match !state with
    | Some _ -> () (* already initialized *)
    | _ -> begin
        let flags = [Unix.O_RDWR; Unix.O_SYNC] in
        let fd = Unix.openfile "/dev/mem" flags 0 in
        let ranges = Hashtbl.create 0 in
        state := Some { fd; ranges }
      end

  let close () =
    match !state with
    | None -> ()
    | Some { fd; ranges } -> begin
        state := None;
        Unix.close fd;
        Hashtbl.reset ranges
      end

  let access addr length =
    match !state with
    | None -> failwith "RAM.init not yet called"
    | Some { fd; ranges } -> begin
        let mmap = Bigarray.Array1.map_file fd ~pos:addr Bigarray.char Bigarray.c_layout true length in
        let _ = Hashtbl.replace ranges addr mmap in
        state := Some { fd; ranges }
      end

  let lookup ranges addr =
    try Hashtbl.find ranges addr with
    | Not_found ->
      failwith (Printf.sprintf "RAM.access 0x%08LX not yet called" addr)

  let read addr length =
    assert (addr >= 0L);
    assert (length >= 0);
    match !state with
    | None -> failwith "RAM.init not yet called"
    | Some { ranges } -> begin
        let mmap = lookup ranges addr in
        let _ = assert (length <= Bigarray.Array1.dim mmap) in
        let read_byte_at = Bigarray.Array1.get mmap in
        Bytes.init length read_byte_at
      end

  let write addr buffer =
    assert (addr >= 0L);
    match !state with
    | None -> failwith "RAM.init not yet called"
    | Some { ranges } -> begin
        let length = Bytes.length buffer in
        let mmap = lookup ranges addr in
        let _ = assert (length <= Bigarray.Array1.dim mmap) in
        let write_byte_at = Bigarray.Array1.set mmap in
        let _ = Bytes.iteri write_byte_at buffer in
        length
      end
end

#if 1=1
include F(IO)
#else
include F(Mmap)
#endif

let read_byte addr =
  Bytes.get (read addr 1) 0

let read_int32 addr =
  Bytes.to_int32 (read addr 4)

let read_int64 addr =
  Bytes.to_int64 (read addr 8)

let write_byte addr byte =
  write addr (Bytes.make 1 byte) |> ignore

let write_int32 addr word =
  write addr (Bytes.of_int32 word) |> ignore

let write_int64 addr word =
  write addr (Bytes.of_int64 word) |> ignore
