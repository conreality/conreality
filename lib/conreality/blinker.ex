defmodule Conreality.Blinker do
  alias Nerves.Leds
  require Logger

  @interval 200 # ms

  def start_link(led_list) when is_list(led_list) do
    Logger.info "Blinker started for LEDs: #{inspect led_list}"
    pid = spawn_link(__MODULE__, :loop, [led_list])
    {:ok, pid}
  end

  def loop(led_list) do
    Enum.each(led_list, &blink(&1))
    loop(led_list)
  end

  defp blink(led) do
    #Logger.debug "Blinking LED #{led}..."
    Leds.set [{led, true}]
    :timer.sleep @interval
    Leds.set [{led, false}]
    :timer.sleep @interval
  end
end
