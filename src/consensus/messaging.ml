(* This is free and unencumbered software released into the public domain. *)

open Prelude

module Topic = struct
  #include "messaging/topic.ml"
end

module CCCP = struct
  #include "messaging/cccp.ml"
end

#ifdef ENABLE_IRC
module IRC = struct
  #include "messaging/irc.ml"
end
#endif

module MQTT = struct
  #include "messaging/mqtt.ml"
end

module ROS = struct
  #include "messaging/ros.ml"
end

module STOMP = struct
  #include "messaging/stomp.ml"
end
