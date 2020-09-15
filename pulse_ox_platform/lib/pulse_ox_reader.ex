defmodule PulseOxReader do
  @moduledoc """
  The PulseOxReader is made to be a way to monitor pulse oximeter devices and be able
  to setup and deploy with minimal effort.

  Thank you to Nishanth Menon's Masimo-Datacapture project for clearly documenting the
  RAD8 device and TJ Daw for inspiring me to create this based on a project he
  already he already created.

  Neither one was completely suitable for my purposes unfortunately. I wanted to store the
  results on a local device and be able to pull them off in a CSV format while also potentially
  being able to visualize the live data while connected.
  """

  require Logger

  alias Nerves.UART

  # TODO: make this configurable
  @reader Device.Masimo.RAD8

  defstruct [:datetime, :serial, :spo2, :bpm, :perfusion_index, :alert, :info]

  def init do
    serial_device = find_device()
    {:ok, pid} = UART.start_link(name: :reader)
    @reader.connect(pid, serial_device)

    pid
  end

  def reconnect(pid) do
    serial_device = find_device()
    @reader.connect(pid, serial_device)
  end

  def next(pid) do
    case UART.read(pid) do
      {:ok, str} ->
        case @reader.parse_string(str) do
          %PulseOxReader{spo2: :no_reading} = por ->
            por

          %PulseOxReader{
            datetime: dt,
            serial: sn,
            spo2: spo2,
            bpm: bpm,
            perfusion_index: pi,
            info: info,
            alert: alert
          } = por ->
            evt = [
              datetime: dt,
              serial_number: sn,
              spo2: spo2,
              bpm: bpm,
              perfusion_index: pi,
              reliable?: :maybe
            ]

            PulseOxPlatform.insert(evt)
            por

          _ ->
            :error
        end

      {:error, _} = err ->
        err
    end
  end

  defp find_device do
    UART.enumerate()
    |> Map.keys()
    |> List.last()
    |> case do
      "" ->
        Logger.warn("Cannot find a serial device")
        "/dev/null"

      device_str ->
        device_str
    end
  end
end
