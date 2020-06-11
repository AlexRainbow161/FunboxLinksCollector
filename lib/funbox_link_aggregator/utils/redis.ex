defmodule FunboxLinkAggregator.Utils.Redis do

  def get(key) do
    Redix.command(:redix, ["GET", key])
  end

  def set(key, value) do
    Redix.command(:redix, ["SET", key, value])
  end

  def add_to_range(key, value, score) do
    Redix.command(:redix, ["ZADD", key, score, value])
  end

  def get_by_score(key, score) do
    Redix.command(:redix, ["ZRANGEBYSCORE", key, score])
  end

  @spec get_range(charlist(), number(), number()) ::
          {:error,
           atom
           | %{
               :__exception__ => any,
               :__struct__ => Redix.ConnectionError | Redix.Error,
               optional(:message) => binary,
               optional(:reason) => atom
             }}
          | {:ok,
             nil
             | binary
             | [nil | binary | [any] | integer | Redix.Error.t()]
             | integer
             | Redix.Error.t()}
  def get_range(key, min, max) do
    Redix.command(:redix, ["ZRANGEBYSCORE", key, min, max])
  end
end
