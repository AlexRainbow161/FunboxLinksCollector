defmodule FunboxLinkAggregator.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/bot" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!("Hello World"))
  end

  get "/" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(message()))
  end

  match _ do
    send_resp(conn, 404, "Requested page not found!")
  end

  defp message do
    %{
      response_type: "in_chanel",
      text: "Hello From Bot"
    }
  end
end
