alias Nerves.UART
alias Device.Masimo.RAD8

name = UART.enumerate() |> Map.keys() |> List.last()
{:ok, pid} = UART.start_link()
