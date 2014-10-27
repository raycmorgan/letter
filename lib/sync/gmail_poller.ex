defmodule Letter.Sync.GmailPoller do
  use GenServer
  require Logger

  @sync_frequency 4

  defmodule State do
    defstruct key: nil, poll_count: 0, last_poll_at: 0, next_poll_at: 0
  end

  def start_link(key) do
    GenServer.start_link(__MODULE__, key)
  end

  def init(key=%GmailKey{}) do
    :erlang.send_after(0, self(), :sync)
    {:ok, %State{key: key}}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:sync, state) do
    Logger.info("Syncing client #{state.key.id} (#{state.poll_count})")
    start_time = Timex.Time.now(:msecs)

    updated_key = case GmailPoller.process_key(state.key) do
      {:ok, key} -> key
      {:error, _response, key} -> key
    end

    msecs_since_start = trunc(Timex.Time.now(:msecs) - start_time)
    interval = div 60_000, @sync_frequency
    next_poll_in = max(0, interval - msecs_since_start)
    :erlang.send_after(next_poll_in, self(), :sync)

    {:noreply, %State{
      key: updated_key,
      poll_count: state.poll_count + 1,
      last_poll_at: start_time,
      next_poll_at: Timex.Time.now(:msecs) + next_poll_in
      }}
  end

  def handle_info(message, key) do
    super(message, key)
  end
end
