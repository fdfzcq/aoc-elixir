defmodule Year2022.Day6 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str),
    do:
      str
      |> String.codepoints()
      |> first_marker_index(4)

  defp first_marker_index([a, b, c, d | tail], n) do
    if no_repeat([a, b, c, d]) do
      n
    else
      first_marker_index([b, c, d | tail], n + 1)
    end
  end

  defp no_repeat([]), do: true

  defp no_repeat([h | t]) do
    if Enum.member?(t, h) do
      false
    else
      no_repeat(t)
    end
  end

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str),
    do:
      str
      |> String.codepoints()
      |> first_start_message_index(14)

  defp first_start_message_index(list = [_h | tail], n) do
    if no_repeat(Enum.slice(list, 0..13)) do
      n
    else
      first_start_message_index(tail, n + 1)
    end
  end

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 6)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 6)
end
