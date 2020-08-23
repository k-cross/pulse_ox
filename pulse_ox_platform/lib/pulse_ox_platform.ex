defmodule PulseOxPlatform do
  @moduledoc """
  Responsible for coordinating the pub/sub mechanisms.
  """

  alias :mnesia, as: Mnesia

  @attributes [
    :datetime,
    :serial_number,
    :spo2,
    :bpm,
    :desaturation,
    :perfusion_index,
    :reliable?
  ]

  def init_db do
    Mnesia.create_schema([node()])
    Mnesia.start()

    Mnesia.create_table(PulseOximeter, attributes: @attributes)
    |> case do
      {:atomic, :ok} -> :ok
      {:aborted, {:already_exists, PulseOximeter}} -> :ok
      _ -> :error
    end
    |> case do
      :ok ->
        case Mnesia.add_table_index(PulseOximeter, :datetime) do
          {:atomic, :ok} -> :ok
          {:aborted, {:already_exists, _, _}} -> :ok
          _ -> :error
        end
    end
  end

  @spec insert(%PulseOxReader{}) :: term()
  def insert(event) do
    Mnesia.transaction(fn ->
      Mnesia.write(PulseOximeter, event)
    end)
  end

  @spec get_from(DateTime.t()) :: %PulseOxReader{}
  def get_from(time) do
    Mnesia.transaction(fn ->
      Mnesia.select(PulseOximeter, [
        {
          {PulseOximeter, :"$1", :_, :_, :_, :_, :_, :_},
          [{:>=, :"$1", time}],
          [:"$$"]
        }
      ])
    end)
  end
end
