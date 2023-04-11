defmodule Bot.HelloBot do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_init_arg) do
    {:ok, nil}
  end

  def handle_cast({:message, content}, state) do
    if Map.get(content, "type") == "post" and Map.get(content, "bottag") == 0 do
      msg = Map.get(content, "message")

      if msg == "Hello, Mark" do
        Bot.Application.post("Hello, #{Map.get(content, "name")}", "Mark")
      end

      if msg == "Hello there" do
        Bot.Application.post("General Kenobi!", "General Grievous")
      end
    end

    {:noreply, state}
  end
end
