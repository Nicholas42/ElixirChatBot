defmodule Bot.BotMacro do
  alias Bot.Channel
  alias Bot.BotMacro

  defmacro onMessage(do: block) do
    m_message = Macro.var(:message, nil)
    m_name = Macro.var(:name, nil)
    m_state = Macro.var(:state, nil)
    m_msg = Macro.var(:msg, nil)

    quote do
      def on_message(
            message: unquote(m_message),
            name: unquote(m_name),
            state: unquote(m_state),
            msg: unquote(m_msg)
          ) do
        _ = unquote(m_message)
        _ = unquote(m_name)
        state = unquote(m_state)
        msg = unquote(m_msg)

        if Map.get(msg, "type") == "post" and Map.get(msg, "bottag") == 0 do
          result = unquote(block)

          case result do
            [post, state] ->
              Channel.post_message(post, Map.get(msg, "channel"))
              state = state

            nil ->
              nil

            post ->
              Channel.post_message(post, Map.get(msg, "channel"))
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

      def handle_cast({:message, msg}, state) do
        if Map.get(msg, "type") == "post" and Map.get(msg, "bottag") == 0 do
          message = Map.get(msg, "message")
          name = Map.get(msg, "name")

          on_message(message: message, name: name, state: state, msg: msg)
        else
          {:noreply, state}
        end
      end
    end
  end
end
