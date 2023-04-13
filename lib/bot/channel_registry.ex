defmodule Bot.ChannelRegistry do
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(channels: channels, bots: bots) do
    children =
      channels
      |> Enum.map(fn channel ->
        Supervisor.child_spec(
          {Bot.Channel, [channel: channel, bots: bots]},
          id: {Bot.Channel, channel}
        )
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end
end
