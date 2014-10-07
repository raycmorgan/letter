defmodule Letter do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    port = case System.get_env("PORT") do
      nil -> 4000
      val -> String.to_integer(val)
    end

    children = [
      worker(Repo, []),
      worker(Plug.Adapters.Cowboy, [SimpleServer, [], [port: port]], function: :http),
      # supervisor(Letter.Sync.NodeSupervisor, [])
      supervisor(Letter.Sync.VNodeSupervisor, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Letter.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule Authenticator do
  def run do
    url = Gmail.authorize_url(GmailClient.dev,
      scope: "https://www.googleapis.com/auth/gmail.modify",
      # state: "1234"
    )

    IO.puts "URL: #{url}"
  end
end
