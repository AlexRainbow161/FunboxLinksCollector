defmodule FunboxLinkAggregator.Models.LinksInfo do
  import FunboxLinkAggregator.Utils.Redis
  import DateTime

  def add(links) when is_list(links) do
    now = to_unix(utc_now())
    Enum.each links, fn link ->
      if String.length(link) > 0 do
        add_to_range(key(), get_link_struct_json(link, now) , now)
      end
    end
  end

  def add(_value) do
    {:error, "Cannot find Links array in json request body"}
  end

  def get_uniq_domains_by_timestamp(from, to) when is_integer(from) and is_integer(to) do
    case get_range(key(), from, to) do
      {:error, reason} -> {:error, reason}
      {:ok, result} ->
        domains = Enum.map result, fn it ->
          Poison.decode!(it)["link"]
          |> get_domain()
        end
        domains = Enum.uniq(domains) |> Enum.filter(fn link -> link != :nil end)
        {:ok, %{domains: domains}}
      _ -> {:ok, []}
    end
  end

  def get_uniq_domains_by_timestamp(from, to) do
    get_uniq_domains_by_timestamp(String.to_integer(from), String.to_integer(to))
  end

  defp key do
    :links
  end

  defp get_link_struct_json(link, timestamp) do
    l = %{
          link: link,
          timestamp: timestamp,
          salt: :random.uniform()
        }
    Poison.encode!(l)
  end

  defp get_domain(link) do
    domain = Regex.run(domain_pattern(), link)
    if domain do
      domain |> Enum.at(0)
    else
      domain
    end
  end

  defp domain_pattern do
    ~r"[a-zA-Z0-9]+\.[a-zA-Z0-9]+"
  end

end
