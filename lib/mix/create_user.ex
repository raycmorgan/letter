defmodule Mix.Tasks.Letter.Db do
  defmodule CreateUser do
    use Mix.Task
    # use Database

    @shortdoc "Setup the project"

    def run(_) do
      Repo.start_link

      u = %User{} |> DB.InsertMiddleware.timestamps |> Repo.insert
      IO.puts "Created User:"
      IO.inspect(u)
    end
  end
end
