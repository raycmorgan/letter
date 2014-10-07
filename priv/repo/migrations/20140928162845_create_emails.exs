defmodule Repo.Migrations.CreateEmails do
  use Ecto.Migration

  def up do
    ["""
    CREATE TABLE IF NOT EXISTS emails(
      id text primary key default uuid_generate_v4(),
      created_at float,
      updated_at float,
      user_id text,

      gmail_id text,
      thread_id text,
      history_id text,
      labels text[]
    )
    """,
    "CREATE INDEX ON emails (user_id, created_at DESC)"
    ]
  end

  def down do
    "DROP TABLE emails"
  end
end
