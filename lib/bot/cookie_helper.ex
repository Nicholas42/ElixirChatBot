defmodule Bot.CookieHelper do
  def get_cookies() do
    [username, password | _] =
      File.read!("login.txt")
      |> String.split("\n")
      |> Enum.map(&String.trim/1)

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
      value |> String.split(";") |> hd |> String.split("=", parts: 2) |> Enum.join("=")
    end)
    |> Enum.join("; ")
  end
end
