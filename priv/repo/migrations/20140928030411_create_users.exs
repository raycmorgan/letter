defmodule Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    """
    CREATE TABLE IF NOT EXISTS users(
      id text primary key default uuid_generate_v4(),
      created_at float,
      updated_at float
    )
    """
  end

  def down do
    "DROP TABLE users"
  end
end
