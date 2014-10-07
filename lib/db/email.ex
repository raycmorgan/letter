defmodule Email do
  use Letter.Model
  import Ecto.Query, only: [from: 2]

  schema "emails" do
    field :created_at, :float
    field :updated_at, :float

    field :gmail_id, :string
    field :thread_id, :string
    field :history_id, :string
    field :labels, {:array, :string}

    belongs_to :user, User
  end

  def latest_email_for_user(user_id) do
    query = from e in Email,
            where: ^user_id == e.user_id,
            order_by: [desc: e.history_id],
            limit: 1

    case Repo.all(query) do
      [] -> nil
      [email|_] -> email
    end
  end

  def non_present_gmail_ids(ids) do
    query = from e in Email,
            where: e.gmail_id in array(^ids, :string),
            select: e.gmail_id

    results = Repo.all(query)

    id_set = for id <- ids, into: HashSet.new, do: id
    present_id_set = for res <- results, into: HashSet.new, do: res

    HashSet.difference(id_set, present_id_set)
  end

  def insert_if_not_present(email) do
    case Repo.all(from e in Email, where: ^email.gmail_id == e.gmail_id) do
      []        -> email |> DB.InsertMiddleware.timestamps |> Repo.insert
      [email|_] -> email
    end
  end

  def insert_or_update(email) do
    case Repo.all(from e in Email, where: ^email.gmail_id == e.gmail_id) do
      [] ->
        email
        |> DB.InsertMiddleware.timestamps
        |> Repo.insert

      [cur_email|_] ->
        %Email{email | id: cur_email.id, created_at: cur_email.created_at}
        |> DB.UpdateMiddleware.timestamps
        |> Repo.update
    end
  end
end
