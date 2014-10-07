defmodule GmailKey do
  use Letter.Model

  schema "gmail_keys" do
    field :created_at, :float
    field :updated_at, :float

    field :access_token, :string
    field :refresh_token, :string
    field :access_token_expiry, :float

    belongs_to :user, User
  end
end
