defmodule Bot.BotMacro do
  alias Bot.ChannelRegistry
  alias Bot.BotMacro
  defmacro onMessage(do: block) do
    m_message = Macro.var(:message, nil)
    m_name = Macro.var(:name, nil)

    quote do
      def handle_cast({:message, msg}, state) do
        if Map.get(msg, "type") == "post" and Map.get(msg, "bottag") == 0 do
          unquote(m_message) = Map.get(msg, "message")
          unquote(m_name) = Map.get(msg, "name")
          _ = unquote(m_name)
          _ = unquote(m_message)

          IO.inspect(msg)
          result = unquote(block)
          IO.inspect(result)

          if result do
            ChannelRegistry.post_message(result, Map.get(msg, "channel"))
          end
        end

        {:noreply, state}
      end
    end
  end

  defmacro __using__(opts) do
    m_init_arg = Macro.var(:init_arg, nil)

    quote do
      use GenServer
      import BotMacro
      alias Bot.Message
      Module.register_attribute(__MODULE__, :is_bot, persist: true)
      Module.put_attribute(__MODULE__, :is_bot, true)

      def start_link(_) do
        name = unquote(opts[:name]) || __MODULE__

        GenServer.start_link(__MODULE__, nil, name: name)
      end

      def init(init_arg) do
        unquote(m_init_arg) = init_arg
        _ = unquote(m_init_arg)
        {:ok, unquote(opts[:do])}
      end
    end
  end
end
