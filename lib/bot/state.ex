defmodule Bot.State do
  defstruct delay: 0, channel: "elixir", bots: []

  def update_delay(state, new_delay) do
    %{state | delay: max(new_delay, state.delay)}
  end
end
