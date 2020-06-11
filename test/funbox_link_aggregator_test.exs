defmodule FunboxLinkAggregatorTest do
  use ExUnit.Case
  use Plug.Test

  doctest FunboxLinkAggregator

  alias FunboxLinkAggregator.Router

  @opts Router.init([])

  test "greets the world" do
    assert FunboxLinkAggregator.hello() == :world
  end

  test "redis get/set/delete" do
    assert FunboxLinkAggregator.Utils.Redis.set(:test, "Hi") == {:ok, "OK"}
    assert FunboxLinkAggregator.Utils.Redis.get(:test) == {:ok, "Hi"}
    assert FunboxLinkAggregator.Utils.Redis.delete(:test) == {:ok, 1}
  end

  test "redis range add/get/delete" do
    now = DateTime.to_unix(DateTime.utc_now)
    assert FunboxLinkAggregator.Utils.Redis.add_to_range(:testlist, "Hi Redis", now) == {:ok, 1}
    assert FunboxLinkAggregator.Utils.Redis.get_range(:testlist, now, now) == {:ok, ["Hi Redis"]}
    assert FunboxLinkAggregator.Utils.Redis.delete(:testlist) == {:ok, 1}
  end

  test "plug page not found" do
    conn = 
      conn(:get, "/notimplement")
      |> Router.call(@opts)

    assert conn.status == 404
    assert conn.state == :sent
    assert conn.resp_body == "Requested page not found!"
  end

  test "plug home page" do
    conn =
      conn(:get, "/")
      |> Router.call(@opts)

    assert conn.status == 200
    assert conn.state == :sent
    assert conn.resp_body == Poison.encode!(%{status: :ok})
  end

  test "plug get domains" do
    conn = 
      conn(:get, "visited_domains", %{from: 0, to: 1})
      |> Router.call(@opts)

    assert conn.status == 200
    assert conn.state == :sent
    assert conn.resp_body == Poison.encode!(%{status: :ok, domains: []})
  end

  test "plug post links" do
    conn = 
      conn(:post, "visited_links", %{links: ["ya.ru", "stackoverflow.com", "ya.ru?query=123"]})
      |> Router.call(@opts)

    assert conn.status == 200
    assert conn.state == :sent
    assert conn.resp_body == Poison.encode!(%{status: :ok})
  end

  test "plug post links error" do
    conn = 
      conn(:post, "visited_links", %{missing_links: ["ya.ru", "stackoverflow.com", "ya.ru?query=123"]})
      |> Router.call(@opts)
      
    assert conn.status == 500
    assert conn.state == :sent
  end

  test "links info add/get" do
    now = DateTime.to_unix(DateTime.utc_now())
    assert FunboxLinkAggregator.Models.LinksInfo.add(["ya.ru", "stackoverflow.com", "ya.ru?query=123"]) == :ok
    assert FunboxLinkAggregator.Models.LinksInfo.get_uniq_domains_by_timestamp(now, now) == {:ok, %{domains: ["ya.ru", "stackoverflow.com"]}}
  end
end
