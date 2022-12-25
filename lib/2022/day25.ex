defmodule Year2022.Day25 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str), do:
    str
    |> String.split("\n")
    |> Enum.map(&snafu_to_decimal/1)
    |> Enum.sum()
    |> decimal_to_snafu()

  defp snafu_to_decimal(str), do:
    str
    |> String.codepoints()
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(0,
      fn {c, i}, acc ->
        v = case c do
          "-" -> -1
          "=" -> -2
          _ -> String.to_integer(c)
        end
        acc + (5 ** i) * v
      end)

  defp decimal_to_snafu(num), do: decimal_to_snafu(num, false, "")

  defp decimal_to_snafu(0, true, acc), do: "1" <> acc
  defp decimal_to_snafu(0, _, acc), do: acc
  defp decimal_to_snafu(num, carried_over?, acc) do
    v0 = rem(num, 5)
    v1 = if carried_over? do
      v0 + 1
    else
      v0
    end
    {new_carried_over?, c} = case v1 do
      5 -> {true, "0"}
      4 -> {true, "-"}
      3 -> {true, "="}
      2 -> {false, "2"}
      1 -> {false, "1"}
      0 -> {false, "0"}
    end
    decimal_to_snafu(div(num, 5), new_carried_over?, c <> acc)
  end

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 25)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 25)
end
