defmodule Device.Random do
  @moduledoc """
  Builds a randomized data device to start, demo, and test all other parts of the application.
  Great as a development tool.

  TODO: turn devices into a behavior so all have a common implementable interface.
  """

  def connect(_pid, _serial_device), do: :ok

  @doc """
  Simulate the time it takes to read data from the serial device
  """
  @spec read(pid()) :: {:ok, String.t()}
  def read(_pid), do: {:ok, :timer.sleep(1000) |> to_string()}

  @spec parse_string(String.t()) :: PulseOxReader.t()
  def parse_string(_str) do
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
