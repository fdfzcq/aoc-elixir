defmodule Year2022.Day3 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str), do:
    str
    |> String.split("\n")
    |> Enum.map(&find_item_type/1)
    |> Enum.map(&to_priority/1)
    |> Enum.sum()

  defp do_find_item_type({comp1, comp2}), do:
    comp1
    |> Enum.find(fn c -> Enum.member?(comp2, c) end)

  defp find_item_type(rucksack), do:
    rucksack
    |> String.to_charlist()
    |> Enum.split(div(String.length(rucksack), 2))
    |> do_find_item_type()

  defp to_priority(c) when c > 96, do: c - 96
  defp to_priority(c), do: c - 38

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str), do:
    str
    |> String.split("\n")
    |> Enum.map(&String.to_charlist/1)
    |> Enum.chunk_every(3)
    |> Enum.map(&find_group_badge_item_type/1)
    |> Enum.map(&to_priority/1)
    |> Enum.sum()

  defp find_group_badge_item_type([s1, s2, s3]), do:
    Enum.find(s1, fn c -> Enum.member?(s2, c) && Enum.member?(s3, c) end)

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 3)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 3)
end
