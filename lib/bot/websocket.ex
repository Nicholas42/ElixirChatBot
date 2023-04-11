defmodule Bot.Websocket do
  use WebSockex

  def start_link(url: url, state: state, opts: opts) do
    WebSockex.start_link(url, __MODULE__, state, opts)
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
end
