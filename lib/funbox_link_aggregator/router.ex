defmodule FunboxLinkAggregator.Router do
  use Plug.Router
  use Plug.ErrorHandler

  import FunboxLinkAggregator.Models.LinksInfo

  plug(:match)
  plug(:dispatch)

  post "/visited_links" do
    conn
    |> send_resp(add(conn.params["links"]))
  end

  get "/visited_domains" do
    conn
    |> send_resp(get_uniq_domains_by_timestamp(conn.params["from"], conn.params["to"]))
  end

  get "/" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(ok()))
  end

  match _ do
    send_resp(conn, 404, "Requested page not found!")
  end
  

  defp ok(result = %{}) do
    result
    |> Map.put(:status, :ok)
  end

  defp ok(message) do
    case message do
      :nil -> ok()
      _ -> %{
        status: :ok,
        result: message
      }
    end
  end

  defp ok() do
    %{
      status: :ok
    }
  end

  defp error(reason) do
    %{
      status: :error,
      reason: inspect(reason)
    }
  end

  defp send_resp(conn, {:error, reason}) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(500, Poison.encode!(error(reason)))
  end

  defp send_resp(conn, {:ok, result}) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(ok(result)))
  end

  defp send_resp(conn, :ok) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(ok()))
  end

  def handle_errors(conn, %{kind: _kind, reason: reason, stack: _stack}) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(500, Poison.encode!(error(reason)))
  end
end
