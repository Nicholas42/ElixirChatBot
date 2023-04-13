defmodule Bot.ChannelRegistry do
  use Agent
  def start_link(arg) do
    Agent.start_link(fn -> init(arg)end )
  end
  def init([channels: channels, bots: bots, cookie: cookie]) do
    channels
    |> Enum.map(fn channel ->
      WebSockex.start_link(
        "wss://chat.qed-verein.de/websocket?version=2&channel=#{channel}",
        Bot.Websocket,
        %Bot.State{bots: bots},
        extra_headers: [cookie: cookie, origin: "https://chat.qed-verein.de"],
        debug: [:trace],
        name: channel_name(channel)
      )
    end)
  end

  def post_message(message, channel) do
    WebSockex.cast(channel_name(channel), {:send, message})
  end

  defp channel_name(channel) do
    {:via, Registry, {Bot.Registry, channel}}
  end
end
