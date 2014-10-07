defmodule Letter.Model do
  defmacro __using__(_) do
    quote do
      @schema_defaults primary_key: {:id, :string, []},
                       foreign_key_type: :string
      use Ecto.Model
    end
  end
end
