defmodule FunboxLinkAggregator.Endpoint do

  use Plug.Router

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  forward("/", to: FunboxLinkAggregator.Router)

  @spec child_spec(any) :: %{
          id: FunboxLinkAggregator.Endpoint,
          start: {FunboxLinkAggregator.Endpoint, :start_link, [...]}
        }
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  @spec start_link(any) :: {:error, any} | {:ok, pid}
  def start_link(_opts),
    do: Plug.Cowboy.http(__MODULE__, [])

end
