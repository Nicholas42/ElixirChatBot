defmodule BotApplication do
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
        {DynamicSupervisor, name: Bot.DynamicSupervisor},
        {Bot.ChannelRegistry, [bots: bots, cookie: cookie]}
      ] ++ Enum.map(bots, &{&1, []})

    ret = Supervisor.start_link(children, strategy: :one_for_one)
    channels |> Enum.map(&GenServer.call(Bot.ChannelRegistry, {:add, &1}))
    ret
  end

  def post_message(message, channel) do
    IO.inspect({message, channel})
    GenServer.cast(Bot.ChannelRegistry, {:post, message, channel})
  end
end
