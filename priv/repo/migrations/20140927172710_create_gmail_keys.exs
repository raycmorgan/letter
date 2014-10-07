defmodule Letter.Repo.Migrations.CreateGmailKeys do
  use Ecto.Migration

  def up do
    [
    "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"",
    """
    CREATE TABLE IF NOT EXISTS gmail_keys(
      id text primary key default uuid_generate_v4(),
      created_at float,
      updated_at float,
      access_token text,
      refresh_token text,
      access_token_expiry float,
      user_id text
    )
    """
    ]
  end

  def down do
    ["DROP TABLE gmail_keys", "DROP EXTENSION \"uuid-ossp\""]
  end
end
