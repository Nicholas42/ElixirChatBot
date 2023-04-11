defmodule Bot.Application do
  use Application

  def start(_type, _args) do
    [username, password] =
      File.read!("login.txt")
      |> Enum.map(&String.trim/1)

    cookies =
      Bot.CookieHelper.get_cookies(username, password)
      |> Enum.map(fn {key, value} -> "#{key}=#{value}" end)
      |> Enum.join("; ")

    children = [
      {Bot.Websocket,
       [
         url: "wss://chat.qed-verein.de/websocket?version=2&channel=elixir",
         state: %Bot.State{},
         opts: [
           extra_headers: [cookie: cookies, origin: "https://chat.qed-verein.de"],
           debug: [:trace],
           name: Bot.Websocket
         ]
       ]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one) |> IO.inspect()
  end

  def post(message, name \\ "ElixirBot") do
    WebSockex.cast(Bot.Websocket, {:send, %Bot.Message{name: name, message: message}})
  end
end
