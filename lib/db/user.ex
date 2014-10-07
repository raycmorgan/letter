defmodule User do
  use Letter.Model

  schema "users" do
    field :created_at, :float
    field :updated_at, :float

    has_many :gmail_keys, GmailKey
  end
end
