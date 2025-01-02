defmodule ECommerce.Utils.TimeUtil do
  def pretty_print(date = %DateTime{}) do
    "#{date.day}/#{date.month}/#{date.year}"
  end

  @epoch DateTime.from_unix!(0)
  def get_current_time() do
    {:ok, time} = DateTime.now("Asia/Saigon", Tzdata.TimeZoneDatabase)
    DateTime.diff(time, @epoch)
  end
end
