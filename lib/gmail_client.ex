defmodule GmailClient do
  def dev do
    %Gmail.Client{
      client_id: "834340800324-ea0oj8iq6bvvhp1fh9tt99sksg0pfbdl.apps.googleusercontent.com",
      client_secret: "UDXmGUsI_Wk-cMyKsUvmauv-",
      redirect_uri: "http://localhost:4000",
    }
  end
end