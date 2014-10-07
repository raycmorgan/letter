defmodule MailTest do
  use ExUnit.Case

  test "the truth" do
    import Ecto.Query, only: [from: 2]

    query = from g in GmailKey,
            where: g.id > 1,
            select: g

    res = Repo.all(query)
    IO.inspect res


    # config = OAuth2Ex.config(
    #   id:            "834340800324-ea0oj8iq6bvvhp1fh9tt99sksg0pfbdl.apps.googleusercontent.com",
    #   secret:        "UDXmGUsI_Wk-cMyKsUvmauv-",
    #   authorize_url: "https://accounts.google.com/o/oauth2/auth",
    #   token_url:     "https://accounts.google.com/o/oauth2/token",
    #   scope:         "https://www.googleapis.com/auth/gmail.modify",
    #   response_type: "code&access_type=offline&approval_prompt=force",
    #   callback_url:  "http://localhost:4000"
    # )

    # server = HTTP.server(fn (req) ->
    #   case {req.method, String.split(req.path, "/")} do
    #     {:get, [""]} ->
    #       # ...
    #     {:get, ["code"]} ->
    #       # ...
    #   end
    # end)

    # IO.inspect OAuth2Ex.get_authorize_url(config)

    # token = OAuth2Ex.get_token(config, "233381d1551a96ce")
    # IO.puts token

    # token = OAuth2Ex.Token.browse_and_retrieve!(config, receiver_port: 4000)

    # token
    # |> IO.inspect
    # |> :erlang.term_to_binary
    # |> Base.encode64
    # |> IO.inspect

    # token = load_token
    # IO.inspect token

    # response = OAuth2Ex.HTTP.get(token, "https://www.googleapis.com/gmail/v1/users/me/messages")

    # token = token_from_refresh_token(config)["access_token"]

    # response = HTTPoison.request(:get, "https://www.googleapis.com/gmail/v1/users/me/messages",
    #   "", [{"Authorization", "Bearer #{token}"}], [])

    # IO.puts response.body
  end

  def load_token do
    "g3QAAAAJZAAKX19zdHJ1Y3RfX2QAFUVsaXhpci5PQXV0aDJFeC5Ub2tlbmQADGFjY2Vzc19" <>
    "0b2tlbm0AAAA9eWEyOS5od0NnY1ZURjd1VDFnczBQVlQyWTZMNXFoZG5ZVGpfTnhtb0Y3Vn" <>
    "VPSmtjT0VRc1RxMmFOak92a2QAC2F1dGhfaGVhZGVybQAAAAZCZWFyZXJkAAZjb25maWdkA" <>
    "ANuaWxkAApleHBpcmVzX2F0YlQeRWdkAApleHBpcmVzX2luYgAADhBkAA1yZWZyZXNoX3Rv" <>
    "a2VubQAAAC0xL2M1VTExdzlnQVF6WmQ1WmozV0hmYmpYSnlKZ2JUN1A5ZFNDbW9lR1gtRTh" <>
    "kAAdzdG9yYWdlZAADbmlsZAAKdG9rZW5fdHlwZW0AAAAGQmVhcmVy"
    |> Base.decode64
    |> elem(1)
    |> :erlang.binary_to_term
  end

  def token_from_refresh_token(config) do
    token = load_token

    response = HTTPoison.request(:post,
      "https://accounts.google.com/o/oauth2/token",
      "grant_type=refresh_token&client_id=#{config.id}&client_secret=#{config.secret}&refresh_token=#{token.refresh_token}",
      [{"Content-Type", "application/x-www-form-urlencoded"}], [])

    JSEX.decode!(response.body)
  end
end
