defmodule BotApplication do
  alias Bot.ChannelRegistry
  use Application

  def start(_type, _args) do
    cookie = Bot.CookieHelper.get_cookies()
    channels = ["elixir", "rubentest"]

    bots =
      Application.get_application(Bot)
      |> :application.get_key(:modules)
      |> elem(1)
      |> Enum.filter(& &1.__info__(:attributes)[:is_bot])

    children =
      [
        {Registry, keys: :unique, name: Bot.Registry},
        {ChannelRegistry, channels: channels, bots: bots, cookie: cookie}
      ] ++
        Enum.map(bots, &{&1, []})

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
