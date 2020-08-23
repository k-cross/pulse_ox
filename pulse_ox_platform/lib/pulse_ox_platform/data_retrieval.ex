defmodule PulseOxPlatform.DataRetrieval do
  @moduledoc """
  Pulls the pulse oximeter data from the mNEsia database into a CSV file in order
  for other things and people to perform further analysis on it. Like easily sharing the
  data with doctors.
  """

  alias :mnesia, as: Mnesia

  def get_records_by_datetime_range(start, finish) do
  end
end
