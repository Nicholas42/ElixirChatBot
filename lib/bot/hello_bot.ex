defmodule Bot.HelloBot do
  use Bot.BotMacro

  onMessage do
    cond do
      message == "Hello, Mike" -> %Message{name: "Mike", message: "Hello, #{name}"}
      message == "Hello there" -> %Message{message: "General Kenobi!", name: "General Grievous"}
      true -> nil
    end
  end
end
