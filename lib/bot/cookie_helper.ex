defmodule Bot.CookieHelper do
  def get_cookies(username, password) do
    resp =
      HTTPoison.post!(
        "https://chat.qed-verein.de/rubychat/account",
        "username=#{username}&password=#{password}"
      )

    resp.headers
    |> Enum.filter(fn
      {key, _} -> String.match?(key, ~r/\Aset-cookie\z/i)
    end)
    |> Enum.map(fn {_, value} ->
      value |> String.split(";") |> hd |> String.split("=", parts: 2) |> List.to_tuple()
    end)
  end
end
