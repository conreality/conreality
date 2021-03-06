(* This is free and unencumbered software released into the public domain. *)

module CCCP : sig
  type t
  val is_configured : t -> bool
  val listen : t -> Messaging.CCCP.Callback.t -> Messaging.CCCP.Server.t Lwt.t
end

#ifdef ENABLE_IRC
module IRC : sig
  type t
  val is_configured : t -> bool
  val connect : t -> Messaging.IRC.Callback.t -> Messaging.IRC.Connection.t Lwt.t
end
#endif

module ROS : sig
  type t
  val is_configured : t -> bool
  val connect : t -> unit Lwt.t
end

module STOMP : sig
  type t
  val is_configured : t -> bool
  val connect : t -> unit Lwt.t
end

type t = {
  mutable cccp:  CCCP.t;
#ifdef ENABLE_IRC
  mutable irc:   IRC.t;
#endif
  mutable ros:   ROS.t;
  mutable stomp: STOMP.t;
}
