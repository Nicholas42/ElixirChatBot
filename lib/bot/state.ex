defmodule Bot.State do
  defstruct delay: 0, channel: "elixir"

  def update_delay(state, new_delay) do
    %Bot.State{delay: max(new_delay, state.delay)}
  end
end
