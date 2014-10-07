defmodule Repo do
  use Ecto.Repo, adapter: Ecto.Adapters.Postgres
  require Logger

  def conf do
    parse_url "ecto://ray:@localhost/letter_dev"
  end

  def priv do
    app_dir(:letter, "priv/repo")
  end

  def log({:query, sql}, fun) do
    {time, result} = :timer.tc(fun)
    Logger.debug "#{trunc(time / 1000)}ms >> #{String.replace(sql, "\n", " ")}"
    result
  end

  def log(_arg, fun), do: fun.()
end
