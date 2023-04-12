defmodule BotApplication do
  use Application

  def start(_type, _args) do
    cookies = Bot.CookieHelper.get_cookies()

    bots = [Bot.HelloBot, Bot.TdBot]

    children =
      [
        {Bot.Websocket,
         [
           url: "wss://chat.qed-verein.de/websocket?version=2&channel=elixir",
           state: %Bot.State{bots: bots},
           opts: [
             extra_headers: [cookie: cookies, origin: "https://chat.qed-verein.de"],
             debug: [:trace],
             name: Bot.Websocket
           ]
         ]}
      ] ++ Enum.map(bots, &{&1, []})

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def post_message(message) do
    WebSockex.cast(Bot.Websocket, {:send, message})
  end
end
