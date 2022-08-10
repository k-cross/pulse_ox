defmodule PulseOx.Schema.Event do
  @moduledoc """
  The schema for pulse oximeter reading events.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "event" do
    timestamps(updated_at: false)
    field(:spo2, :integer)
    field(:bpm, :integer)
    field(:perfusion_index, :float)
  end

  @required [:spo2, :bpm, :perfusion_index]

  def changeset(%PulseOxReader{} = por) do
    por
    |> Map.from_struct()
    |> nil_or_int_conversion(:spo2)
    |> nil_or_int_conversion(:bpm)
    |> changeset()
  end

  def changeset(data) do
    %__MODULE__{}
    |> cast(data, @required)
    |> validate_required(@required)
    |> validate_number(:perfusion_index, greater_than: 0.10)
  end

  defp nil_or_int_conversion(map, key) do
    Map.update(map, key, nil, fn
      x when is_number(x) -> round(x)
      _ -> nil
    end)
  end
end
