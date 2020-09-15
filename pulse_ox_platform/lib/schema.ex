defmodule PulseOx.Schema.Event do
  @moduledoc """
  The schema for pulse oximeter reading events.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "event" do
    timestamps(updated_at: false)
    field(:spo2, :integer, null: false)
    field(:bpm, :integer, null: false)
    field(:perfusion_index, :float, null: false)
  end

  @required [:spo2, :bpm, :pi]

  def changeset(data) do
    %__MODULE__{}
    |> cast(data, @required)
    |> validate_required(@required)
    |> validate_number(:perfusion_index, greater_than: 0.10)
  end
end
