defmodule Letter.Sync.Supervisor do
  use Supervisor

  def start_link(arg \\ []) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(arg) do
    children = []
    supervise(children, strategy: :one_for_one)
  end

  def start_child(key) do
    Supervisor.start_child(__MODULE__, 
      worker(Letter.Sync.GmailPoller, [key], id: key.id))
  end

  def keys_owned do
    Supervisor.which_children(__MODULE__)
    |> Enum.map(fn ({id, _, _, _}) -> id end)
  end

  def kill_a_child do
    {_, pid, _, _} = Supervisor.which_children(__MODULE__) |> Enum.at(0)
    :erlang.exit(pid, :kill)
  end
end