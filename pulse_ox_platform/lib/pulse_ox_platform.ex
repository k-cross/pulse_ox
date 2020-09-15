defmodule PulseOxPlatform do
  @moduledoc """
  Responsible for coordinating the pub/sub mechanisms.
  """

  import Ecto.Query

  alias PulseOxPlatform.Repo
  alias PulseOx.Schema.Event

  @spec insert(%PulseOxReader{}) :: term()
  def insert(event) do
    event
    |> Event.changeset()
    |> Repo.insert()
  end

  @spec get_today() :: %PulseOxReader{}
  def get_today() do
    Date.utc_today()
    |> Timex.to_datetime()
    |> start_time_query(Event)
    |> reliability_query()
    |> PulseOxPlatform.Repo.all()
  end

  @spec get_range(DateTime.t(), DateTime.t()) :: %PulseOxReader{}
  def get_range(start, finish) do
    start
    |> start_time_query(Event)
    |> finish_time_query(finish)
    |> reliability_query()
    |> PulseOxPlatform.Repo.all()
  end

  defp start_time_query(t, q), do: from(e in q, where: e.inserted_at > ^t)
  defp finish_time_query(t, q), do: from(e in q, where: e.inserted_at < ^t)
  defp reliability_query(q), do: from(e in q, where: e.perfusion_index > 0.1)
end
