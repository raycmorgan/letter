defmodule Letter.Sync.NodeSupervisor do
  use Supervisor

  def start_link(arg \\ []) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(arg) do
    children = [
      supervisor(Letter.Sync.VNodeSupervisor, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def keys_owned do
    Supervisor.which_children(__MODULE__)
    |> Enum.flat_map(fn ({_, pid, _, _}) ->
      Supervisor.which_children(pid)
      |> Enum.map(fn ({id, _, _, _}) -> id end)
    end)
  end
end