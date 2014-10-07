defmodule GmailPoller do
  require Logger

  def process_key(key) do
    Logger.info "Processing #{key.id}"

    {fun, args} = case Email.latest_email_for_user(key.user_id) do
      nil -> {:load_inbox, [key]}
      %Email{history_id: history_id} -> {:load_history, [key, history_id]}
    end

    case apply(__MODULE__, fun, args) do
      {:ok, _res, messages, key} ->
        process_messages(key, messages)
        {:ok, key}
      {:error, response} ->
        Logger.error "Failed to process #{key.id}"
        IO.inspect response
        {:error, response, key}
    end
  end

  defp process_messages(key, messages) do
    # non_present_ids = messages
    # |> Enum.map(&(&1["id"]))
    # |> Email.non_present_gmail_ids

    for message <- messages do
      email = %Email{
        gmail_id: message["id"],
        thread_id: message["threadId"],
        history_id: message["historyId"],
        labels: message["labelIds"],
        user_id: key.user_id,
      }

      Email.insert_or_update(email)
    end
  end

  # ------

  def load_inbox(key, allow_refresh \\ true) do
    {time, inbox} = :timer.tc(Gmail, :inbox, [key.access_token])
    Logger.info "Time for inbox call: #{time/1000}ms"

    case inbox do
      response=%{status_code: 200, body: body} ->
        messages = fetch_messages(body["messages"], key.access_token)

        {:ok, response, messages}
      %{status_code: 401} when allow_refresh == true ->
        # Try to refresh the access_token and try again
        case refresh_access_token(key) do
          {:ok, key} -> load_inbox(key, false)
          {:error, response} -> {:error, response}
        end
      response -> {:error, response}
    end
  end

  def load_history(key, starting_after, allow_refresh \\ true) do
    {time, inbox} = :timer.tc(Gmail, :history, [key.access_token, starting_after])
    Logger.info "Time for history call: #{time/1000}ms"

    case inbox do
      response=%{status_code: 200, body: %{"history" => history}} ->
        result = for h <- history, Dict.has_key?(h, "messages"), is_list(h["messages"]) do
          h["messages"]
        end |> List.flatten

        Logger.debug "History returned #{length(result)} new messages"
        messages = fetch_messages(result, key.access_token)

        {:ok, response, messages, key}
      response=%{status_code: 200} ->
        {:ok, response, [], key}
      %{status_code: 401} when allow_refresh == true ->
        # Try to refresh the access_token and try again
        case refresh_access_token(key) do
          {:ok, key} -> load_history(key, starting_after, false)
          {:error, response} -> {:error, response}
        end
      response -> {:error, response}
    end
  end

  # ------

  defp refresh_access_token(key) do
    key |> refresh_access_token(
      Gmail.refresh_access_token(GmailClient.dev, key.refresh_token))
  end

  defp refresh_access_token(key, %{status_code: 200, body: %{"access_token" => access_token}}) do
    key = %GmailKey{key | access_token: access_token}
    Repo.update(key)
    {:ok, key}
  end
  defp refresh_access_token(key, response), do: {:error, response}

  defp fetch_messages([], _token), do: []
  defp fetch_messages(messages, token) do
    message_ids = for message <- messages, do: message["id"]
    Gmail.bulk_fetch_messages(token, message_ids)
  end
end
