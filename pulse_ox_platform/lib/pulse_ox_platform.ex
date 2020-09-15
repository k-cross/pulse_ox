defmodule PulseOxPlatform do
  @moduledoc """
  Responsible for coordinating the pub/sub mechanisms.
  """

  alias PulseOx.{Repo, Schema.Event}

  @spec insert(%PulseOxReader{}) :: term()
  def insert(event) do
    event
    |> Event.changeset()
    |> Repo.insert()
  end

  @spec get_today() :: %PulseOxReader{}
  def get_today() do
    # Date.today()
  end

  @spec get_range(DateTime.t(), DateTime.t()) :: %PulseOxReader{}
  def get_range(start, finish) do
  end
end
