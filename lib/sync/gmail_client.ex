defmodule Letter.Sync.GmailClient do
  use GenServer
  require Logger

  @sync_frequency 4

  def start_link(key) do
    GenServer.start_link(__MODULE__, key)
  end

  def init(key=%GmailKey{}) do
    :erlang.send_after(0, self(), :sync)
    {:ok, key}
  end

  def handle_call(:get_state, _from, key) do
    {:reply, key, key}
  end

  def handle_info(:sync, key) do
    Logger.info("Syncing client #{key.id}")
    start_time = Timex.Time.now(:msecs)

    key = case GmailPoller.process_key(key) do
      {:ok, key} -> key
      {:error, _response, key} -> key
    end

    msecs_since_start = trunc(Timex.Time.now(:msecs) - start_time)
    interval = div 60_000, @sync_frequency
    :erlang.send_after(max(0, interval - msecs_since_start), self(), :sync)

    {:noreply, key}
  end

  def handle_info(message, key) do
    super(message, key)
  end
end
