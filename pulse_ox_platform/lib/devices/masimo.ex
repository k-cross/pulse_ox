defmodule Device.Masimo do
  @moduledoc """
  Settings for Serial and UART interfaces for Masimo pulse oximeters.

  """

  defmodule RAD8 do
    @moduledoc """
    Settings and structure for the RAD8 Pulse Oximeter.
    The exceptions are encoded as hexadecimal ascii strings and alarms use 5 bits as a mask.

    Exception codes and meanings:
    * 000: normal operation
    * 001: no sensor
    * 002: defective sensor
    * 004: low perfusion
    * 008: pulse search
    * 010: interference
    * 020: sensor off
    * 040: ambient light
    * 080: unrecognized sensor
    * 100: reserved
    * 200: reserved
    * 400: low signal IQ
    * 800: masimo SET -- the flag indicating the algorithm is running in full SET mode
    requiring a SET sensor and clean data.

    Alarm bits:
    1. spo2 high: higher than set range
    2. spo2 low: lower than set range
    3. bpm high: higher than set range
    4. bpm low: lower than set range
    5. mute button: press and release mute button

    Serial Output Example:

     "03/06/05 21:11:30 SN=0000066575 SPO2=098% BPM=057 PI=07.02% SPCO=--.-% SPMET=--.-% DESAT=-- PIDELTA=+-- ALARM=0038 EXC=000800"
    """

    alias Nerves.UART

    @baud_rate 9600
    @data_bits 8
    @parity :none
    @stop_bits 1
    @separator "\r\n"

    # Exceptions are displayed as 3 digit ASCII encoded hexadecimal values
    @known_exceptions %{
      "000000" => :normal,
      "000001" => :no_sensor,
      "000002" => :sensor_defective,
      "000004" => :low_perfusion,
      "000008" => :pulse_search,
      "000010" => :interference,
      "000020" => :sensor_off,
      "000040" => :ambient_light,
      "000080" => :sensor_unrecognized,
      "000400" => :low_signal_iq,
      "000800" => :masimo_set
    }

    # Corresponds to specific bits that are set
    @alarm %{
      "0000" => :normal,
      "0001" => :spo2_high,
      "0002" => :spo2_low,
      "0004" => :bpm_high,
      "0008" => :bpm_low,
      "0016" => :triggered,
      "0032" => :mute_pressed
    }

    def read(pid), do: UART.read(pid)

    def connect(pid, serial_device) do
      UART.open(
        pid,
        serial_device,
        speed: @baud_rate,
        active: false,
        parity: @parity,
        flow_control: :none,
        stop_bits: @stop_bits,
        data_bits: @data_bits,
        framing: {UART.Framing.Line, separator: @separator}
      )
    end

    def parse_string(str) do
      split_str = String.split(str)

      if length(split_str) == 12 do
        [_date_str, _time_str | reduced_split] = split_str
        dt = DateTime.utc_now()

        [
          sn,
          str_spo2,
          str_bpm,
          str_pi,
          str_spco,
          str_spmet,
          str_desat,
          str_pi_delta,
          alarm_code,
          exc_code
        ] = format_vars(reduced_split)

        [spo2, bpm, perf_index, spco, spmet, desat, pi_delta] =
          [str_spo2, str_bpm, str_pi, str_spco, str_spmet, str_desat, str_pi_delta]
          |> Enum.map(fn el ->
            case Float.parse(el) do
              {num, _} -> num
              _ -> :no_reading
            end
          end)

        alarm =
          case @alarm[alarm_code] do
            nil -> :unknown
            code -> code
          end

        info =
          case @known_exceptions[exc_code] do
            nil -> :unknown
            code -> code
          end

        %PulseOxReader{
          datetime: dt,
          serial: sn,
          spo2: spo2,
          bpm: bpm,
          perfusion_index: perf_index,
          spco: spco,
          spmet: spmet,
          desat: desat,
          pi_delta: pi_delta,
          info: info,
          alert: alarm
        }
      else
        nil
      end
    end

    defp format_vars(var_list) do
      Enum.map(var_list, fn var ->
        var
        |> String.split("=", trim: true, parts: 2)
        |> List.last()
      end)
    end
  end
end
