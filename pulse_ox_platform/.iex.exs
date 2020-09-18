alias Nerves.UART
alias Device.Masimo.RAD8
alias PulseOxPlatform.{Repo, Data}
alias PulseOx.Schema.Event

name = UART.enumerate() |> Map.keys() |> List.last()
{:ok, pid} = UART.start_link()
