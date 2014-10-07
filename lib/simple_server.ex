defmodule SimpleServer do
  require Logger
  import Plug.Conn
  use Plug.Router

  plug :match
  plug :dispatch

  @user_id "a32cbae5-0389-47ef-9ee1-f0a72b9ab512"
  @gmail_key_id "04a48819-6c43-4bc6-bff7-ff0b5127750f"

  get "/" do
    params = URI.decode_query(conn.query_string)

    case params do
      %{"code" => code} ->
        response = Gmail.exchange_code_for_token(GmailClient.dev, code).body |> JSEX.decode!

        %GmailKey{
          access_token: response["access_token"],
          refresh_token: response["refresh_token"],
          user_id: @user_id
        } |> DB.InsertMiddleware.timestamps |> Repo.insert

        send_resp(conn, 200, "OK")
      _ ->
        send_resp(conn, 404, "Not Found")
    end
  end

  get "/messages" do
    import Ecto.Query, only: [from: 2]

    query = from e in Email,
            where: e.user_id == ^@user_id,
            order_by: [desc: e.created_at],
            limit: 100,
            select: e

    res = Repo.all(query)

    conn
    |> put_resp_header("Content-Type", "application/json")
    |> send_resp(200, :jiffy.encode(%{messages: res}))
  end

  get "/messages/fetch" do
    case Repo.get(GmailKey, @gmail_key_id) do
      nil ->
        send_resp(conn, 404, "Not Found")
      key ->
        case GmailPoller.load_inbox(key) do
          {:ok, _res, messages} ->
            {time, encoded} = :timer.tc(:jiffy, :encode, [%{messages: messages}])
            Logger.info "Time for encode call: #{time}"

            conn
            |> put_resp_header("Content-Type", "application/json")
            |> send_resp(200, encoded)
          {:error, _response} ->
            conn
            |> put_resp_header("Content-Type", "application/json")
            |> send_resp(500, JSEX.encode!(%{error: "Gmail Error"}))
        end
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
