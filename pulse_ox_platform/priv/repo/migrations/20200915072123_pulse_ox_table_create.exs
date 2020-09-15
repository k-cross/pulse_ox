defmodule PulseOxPlatform.Repo.Migrations.PulseOxTableCreate do
  use Ecto.Migration

  def change do
    create table("event") do
      timestamps(updated_at: false)
      add :spo2, :integer, null: false
      add :bpm, :integer, null: false
      add :perfusion_index, :float, null: false
    end
  end
end
