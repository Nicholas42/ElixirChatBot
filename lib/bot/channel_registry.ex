defmodule Bot.ChannelRegistry do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end
  def init(bots: bots, cookie: cookie) do
    {:ok, [bots: bots, cookie: cookie, channels: %{}]}
  end

  def handle_call({:add, channel}, _from, bots: bots, cookie: cookie, channels: channels) do
    {:ok, pid} =
      DynamicSupervisor.start_child(
        Bot.DynamicSupervisor,
        {Bot.Websocket,
         [
           url: "wss://chat.qed-verein.de/websocket?version=2&channel=#{channel}",
           state: %Bot.State{bots: bots},
           opts: [
             extra_headers: [cookie: cookie, origin: "https://chat.qed-verein.de"],
             debug: [:trace]
           ]
         ]}
      )

    {:reply, pid, [bots: bots, cookie: cookie, channels: Map.put(channels, channel, pid)]}
  end

  def handle_cast({:post, message, channel}, state) do
    IO.inspect({message, channel, state})
    WebSockex.cast(Map.get(state[:channels], channel), {:send, message})
    {:noreply, state}
  end
end

