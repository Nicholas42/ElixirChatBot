defmodule Bot.Websocket do
  use WebSockex

  def start_link(channel: channel, bots: bots) do
    cookie = Bot.CookieHelper.get_cookies()

    WebSockex.start_link(
      "wss://chat.qed-verein.de/websocket?version=2&channel=#{channel}",
      __MODULE__,
      %Bot.State{bots: bots},
      extra_headers: [cookie: cookie, origin: "https://chat.qed-verein.de"],
      debug: [:trace],
      name: channel_name(channel)
    )
  end

  def handle_frame({:text, msg}, state) do
    result = JSON.decode!(msg)

    if is_map(result) do
      Enum.each(state.bots, &GenServer.cast(&1, {:message, result}))
      {:ok, Bot.State.update_delay(state, Map.get(result, "delay", 0))}
    else
      IO.puts("Does this happen?")
      {:ok, state}
    end
  end

  def handle_cast({:send, message}, state) do
    frame =
      {:text,
       JSON.encode!(
         channel: state.channel,
         name: message.name,
         message: message.message,
         delay: state.delay + 1,
         bottag: 1
       )}

    {:reply, frame, state}
  end

  def post_message(message, channel) do
    WebSockex.cast(channel_name(channel), {:send, message})
  end

  defp channel_name(channel) do
    {:via, Registry, {Bot.Registry, channel}}
  end
end
