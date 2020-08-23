defmodule Device.Random do
  @moduledoc """
  Builds a randomized data device to start and test for all other parts of the application.
  """

  def connect(_pid, _serial_device) do
    :ok
  end

  def parse_string(str) do
    %PulseOxReader{
      datetime: DateTime.utc_now(),
      serial: "random",
      spo2: round(:rand.normal(97, 1)),
      bpm: round(:rand.normal(150, 3)),
      perfusion_index: Float.round(:rand.normal(1.5, 0.05), 3),
      info: :stable,
      alert: :none
    }
  end
end
