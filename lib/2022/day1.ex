defmodule Year2022.Day1 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str), do:
    str
    |> String.split("\n\n")
    |> Enum.reduce(0, &find_max_calories/2)
    |> IO.puts()

  defp find_max_calories(str, max), do:
    calories = str
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
    |> max(max)

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str), do:
    str
    |> String.split("\n\n")
    |> Enum.reduce({0, 0, 0}, &find_max_top_calories/2)
    |> sum_tuple
    |> IO.puts()

  defp find_max_top_calories(str, {max1, max2, max3}) do
    calories = str
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
    case calories do
      calories when calories > max1 -> {calories, max1, max2}
      calories when calories > max2 -> {max1, calories, max2}
      calories when calories > max3 -> {max1, max2, calories}
      _ -> {max1, max2, max3}
    end
  end

  defp sum_tuple({m1, m2, m3}), do: m1 + m2 + m3

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 1)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 1)
end
