defmodule Bot.BotMacro do
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
            Bot.Application.post_message(result)
          end
        end

        {:noreply, state}
      end
    end
  end

  defmacro botInit(name \\ nil, do: body) do
    m_init_arg = Macro.var(:init_arg, nil)

    quote do
      use GenServer

      def start_link(_) do
        name = unquote(name) || __MODULE__

        GenServer.start_link(__MODULE__, nil, name: name)
      end

      def init(init_arg) do
        unquote(m_init_arg) = init_arg
        _ = unquote(m_init_arg)
        {:ok, unquote(body)}
      end
    end
  end
end
