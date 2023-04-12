defmodule Bot.TdBot do
  use Bot.BotMacro

  onMessage do
    if String.starts_with?(message, "!print") do
      post(String.replace_prefix(message, "!print", "") |> String.trim())
    end

    nil
  end

  defp post(message) do
    if message != "" do
      HTTPoison.post!("http://192.168.1.141/text", {:form, [{"text", message}]})
    end
  end
end
