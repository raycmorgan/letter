defmodule Gmail do
  require Logger 

  defmodule Client do
    @derive [Enumerable, Access]
    defstruct client_id: "", client_secret: "", redirect_uri: ""
  end

  defmodule Response do
    @derive [Enumerable, Access]
    defstruct status_code: nil, body: nil, headers: %{}
  end

  @oauth_url "https://accounts.google.com/o/oauth2"

  def authorize_url(client, params) do
    defaults = %{
      client_id: client.client_id,
      redirect_uri: client.redirect_uri,
      response_type: "code",
      access_type: "offline",
      approval_prompt: "force"
    }

    query_string = Dict.merge(defaults, params) |> URI.encode_query

    "#{@oauth_url}/auth?#{query_string}"
  end

  def exchange_code_for_token(client, code) do
    url = "#{@oauth_url}/token"
    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]
    body = URI.encode_query(
      code: code,
      client_id: client.client_id,
      client_secret: client.client_secret,
      redirect_uri: client.redirect_uri,
      grant_type: "authorization_code"
    )

    HTTPoison.request(:post, url, body, headers, [])
  end

  @doc """
  https://developers.google.com/accounts/docs/OAuth2WebServer#refresh

  ```
  POST /o/oauth2/token HTTP/1.1
  Host: accounts.google.com
  Content-Type: application/x-www-form-urlencoded

  client_id=8819981768.apps.googleusercontent.com&
  client_secret={client_secret}&
  refresh_token=1/6BMfW9j53gdGImsiyUH5kU5RsR4zwI9lUVX-tqf8JXQ&
  grant_type=refresh_token
  ```
  """
  def refresh_access_token(client, refresh_token) do
    body = %{
      client_id: client.client_id,
      client_secret: client.client_secret,
      refresh_token: refresh_token,
      grant_type: "refresh_token"
    } |> URI.encode_query

    url = "https://accounts.google.com/o/oauth2/token"
    Logger.info "Fetching: #{url}"

    HTTPoison.request(:post, url,
      body, [{"Content-Type", "application/x-www-form-urlencoded"}], []) |> to_json
  end

  def inbox(access_token) do
    url = "https://www.googleapis.com/gmail/v1/users/me/messages?labelIds=INBOX"

    Logger.info "Fetching: #{url}"

    HTTPoison.request(:get, url,
      "", [{"Authorization", "Bearer #{access_token}"}], []) |> to_json
  end

  def history(access_token, starting_after) do
    url = "https://www.googleapis.com/gmail/v1/users/me/history?labelId=INBOX&startHistoryId=#{starting_after}"

    Logger.info "Fetching: #{url}"

    HTTPoison.request(:get, url,
      "", [{"Authorization", "Bearer #{access_token}"}], []) |> to_json
  end

  def bulk_fetch_messages(access_token, message_ids) do
    # TODO: more generic bulk request function
    parts = for id <- message_ids do
      """
      Content-Type: application/http

      GET gmail/v1/users/me/messages/#{id}

      """
    end

    boundary_key = "boundary__batch"
    body = """
    --#{boundary_key}
    #{Enum.join(parts, "--#{boundary_key}\n")}--#{boundary_key}--
    """

    headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"Content-Length", String.length(body)},
      {"Content-Type", "multipart/mixed; boundary=#{boundary_key}"}
    ]

    {time, message_resp} = :timer.tc(HTTPoison, :request, [
      :post, "https://www.googleapis.com/batch", body, headers, []
    ])
    Logger.info "Time for batch call: #{time/1000}ms"

    {time, messages} = :timer.tc(fn ->
      # TODO: very ad-hoc/brittle parsing
      boundary = String.split(message_resp.headers["Content-Type"], "=") |> Enum.at(1)

      String.split(message_resp.body, "--#{boundary}")
      |> Enum.map(fn (part) -> String.split(part, "\r\n\r\n", parts: 3) |> Enum.at(2) end)
      |> Enum.filter(fn (res) -> res end)
      |> Enum.map(fn(body) -> :jiffy.decode(body, [:return_maps]) end)
    end)
    Logger.info "Time for decode call: #{time/1000}ms"

    messages
  end

  defp to_json(response) do
    %Gmail.Response{
      status_code: response.status_code,
      headers: response.headers,
      body: :jiffy.decode(response.body, [:return_maps])
    }
  end
end
