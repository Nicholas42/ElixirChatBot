defmodule Bot.Websocket do
  use WebSockex

  def start_link(url: url, state: state, opts: opts) do
    WebSockex.start_link(url, __MODULE__, state, opts) |> IO.inspect()
  end

  def handle_frame({type, msg}, state) do
    IO.puts("frame")
    result = JSON.decode!(msg)
    IO.puts("Received Message - Type: #{inspect(type)} -- Message: #{inspect(result)}")

    if is_map(result) do
      {:ok, Bot.State.update_delay(state, Map.get(result, "delay", 0))}
    else
      {:ok, state}
    end
  end

  def handle_cast({:send, message}, state) do
    IO.puts("foo")
    frame =
      {:text,
       JSON.encode!(
         channel: state.channel,
         name: message.name,
         message: message.message,
         delay: state.delay,
         bottag: 1
       )}

    IO.puts("bar")
    {:reply, frame, state}
  end
end
