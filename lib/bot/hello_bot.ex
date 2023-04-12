defmodule Bot.HelloBot do
  import Bot.BotMacro
  alias Bot.Message

  botInit do
  end

  onMessage do
    cond do
      message == "Hello, Mike" -> %Message{name: "Mike", message: "Hello, #{name}"}
      message == "Hello there" -> %Message{message: "General Kenobi!", name: "General Grievous"}
      true -> nil
    end
  end
end
