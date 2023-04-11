defmodule Bot.TdBot do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_init_arg) do
    {:ok, nil}
  end

  def handle_cast({:message, content}, state) do
    if Map.get(content, "type") == "post" and Map.get(content, "bottag") == 0 do
      message = Map.get(content, "message")

      if String.starts_with?(message, "!print") do
        post(String.replace_prefix(message, "!print", "") |> String.trim())
      end
    end

    {:noreply, state}
  end

  defp post(message) do
    if message != "" do
      HTTPoison.post!("http://192.168.1.141/text", {:form, [{"text", message}]})
    end
  end
end
