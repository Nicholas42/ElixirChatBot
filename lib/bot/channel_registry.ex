defmodule Bot.ChannelRegistry do
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(channels: channels, bots: bots, cookie: cookie) do
    children =
      channels
      |> Enum.map(fn channel ->
        Supervisor.child_spec(
          {Bot.Websocket,
           [
             url: "wss://chat.qed-verein.de/websocket?version=2&channel=#{channel}",
             state: %Bot.State{bots: bots},
             opts: [
               extra_headers: [cookie: cookie, origin: "https://chat.qed-verein.de"],
               debug: [:trace],
               name: channel_name(channel)
             ]
           ]},
          id: {Bot.Websocket, channel}
        )
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end

  def post_message(message, channel) do
    WebSockex.cast(channel_name(channel), {:send, message})
  end

  defp channel_name(channel) do
    {:via, Registry, {Bot.Registry, channel}}
  end
end
