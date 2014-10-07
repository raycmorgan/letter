defmodule DB.InsertMiddleware do
  def timestamps(model) do
    now = Timex.Time.now(:secs)
    %{model | created_at: now, updated_at: now}
  end
end

defmodule DB.UpdateMiddleware do
  def timestamps(model) do
    now = Timex.Time.now(:secs)
    %{model | updated_at: now}
  end
end
