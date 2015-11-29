(* This is free and unencumbered software released into the public domain. *)

open Prelude

type t = string * (string -> Device.t)

let bcm2835_gpio_pin (id : string) : Device.t =
  failwith "Not implemented as yet" (* TODO *)

let bcm2836_gpio_pin (id : string) : Device.t =
  failwith "Not implemented as yet" (* TODO *)

let sysfs_gpio_chip (id : string) : Device.t =
  ((Sysfs.open_gpio_chip (Int.of_string id)) :> Device.t)

let sysfs_gpio_pin (id : string) : Device.t =
  ((Sysfs.open_gpio_pin (Int.of_string id) GPIO.Mode.Input) :> Device.t)

let list =
  [("bcm2835.gpio.pin", bcm2835_gpio_pin);
   ("bcm2836.gpio.pin", bcm2836_gpio_pin);
   ("sysfs.gpio.chip" , sysfs_gpio_chip);
   ("sysfs.gpio.pin",   sysfs_gpio_pin)]

let count = List.length list

let exists name =
  List.exists (fun (k, v) -> k = name) list

let find name =
  List.find (fun (k, v) -> k = name) list

let iter (f : (t -> unit)) =
  List.iter (fun driver -> f driver |> ignore) list
