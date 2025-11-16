defmodule HomeAuto.MQTT.Topic do
  @moduledoc false

  def matches(topic, pattern) do
    if String.ends_with?(pattern, "/#") do
      prefix = String.replace_suffix(pattern, "/#", "")

      String.starts_with?(topic, prefix)
    else
      [prefix | rest] = String.split(pattern, "+", parts: 2)
      rest = List.first(rest) || ""

      if String.starts_with?(topic, prefix) do
        parts =
          String.replace_prefix(topic, prefix, "")
          |> String.replace_suffix(rest, "")
          |> String.split("/")

        length(parts) == 1
      end
    end
  end
end
