defmodule Year2022.Day4 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str),
    do:
      str
      |> String.split("\n")
      |> Enum.filter(&is_fully_contained_group/1)
      |> length()

  defp is_fully_contained_group(group_str) do
    [ass1, ass2] =
      group_str
      |> String.split(",")
      |> Enum.map(fn s -> String.split(s, "-") |> Enum.map(&String.to_integer/1) end)

    contains(ass1, ass2) || contains(ass2, ass1)
  end

  defp contains([s1, s2], [s3, s4]), do: s1 <= s3 && s2 >= s4

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str),
    do:
      str
      |> String.split("\n")
      |> Enum.filter(&is_overlap_group/1)
      |> length()

  defp is_overlap_group(group_str) do
    [ass1, ass2] =
      group_str
      |> String.split(",")
      |> Enum.map(fn s -> String.split(s, "-") |> Enum.map(&String.to_integer/1) end)

    overlap(ass1, ass2) || overlap(ass2, ass1)
  end

  defp overlap([s1, s2], [s3, _s4]), do: s2 >= s3 && s1 <= s3

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 4)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 4)
end
