defmodule Letter.Sync.VNodeSupervisor do
  use Supervisor

  def start_link(arg \\ []) do
    Supervisor.start_link(__MODULE__, arg)
  end

  def init(arg) do
    keys = Repo.all(GmailKey)
    children = for key <- keys do
      worker(Letter.Sync.GmailClient, [key], id: key.id)
    end

    supervise(children, strategy: :one_for_one)
  end

  def start_child(pid, key) do
    Supervisor.start_child(pid, 
      worker(Letter.Sync.GmailClient, [key], id: key.id))
  end
end
