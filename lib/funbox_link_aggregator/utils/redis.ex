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

  def get_range(key, min, max) do
    Redix.command(:redix, ["ZRANGEBYSCORE", key, min, max])
  end

  def delete(key) do
    Redix.command(:redix, ["DEL", key])
  end
end
