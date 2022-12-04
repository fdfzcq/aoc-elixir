defmodule Year2022.Day2 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str),
    do:
      str
      |> String.split("\n")
      |> Enum.map(fn s -> String.split(s, " ") end)
      |> Enum.map(&calc_score/1)
      |> Enum.sum()

  defp calc_score([shape_opp, shape_you]) do
    case shape_you do
      "X" -> 1 + winning_score("C", "A", shape_opp)
      "Y" -> 2 + winning_score("A", "B", shape_opp)
      "Z" -> 3 + winning_score("B", "C", shape_opp)
    end
  end

  defp winning_score(win_shape, _draw_shape, win_shape), do: 6
  defp winning_score(_win_shape, draw_shape, draw_shape), do: 3
  defp winning_score(_win_shape, _draw_shape, _shape_opp), do: 0

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str),
    do:
      str
      |> String.split("\n")
      |> Enum.map(fn s -> String.split(s, " ") end)
      |> Enum.map(&calc_score_2/1)
      |> Enum.sum()

  defp calc_score_2([shape_opp, win_result]) do
    case win_result do
      "X" -> to_score(to_lose_shape(shape_opp)) + 0
      "Y" -> to_score(shape_opp) + 3
      "Z" -> to_score(to_win_shape(shape_opp)) + 6
    end
  end

  defp to_lose_shape("A"), do: "C"
  defp to_lose_shape("B"), do: "A"
  defp to_lose_shape("C"), do: "B"
  defp to_win_shape("C"), do: "A"
  defp to_win_shape("B"), do: "C"
  defp to_win_shape("A"), do: "B"

  defp to_score("A"), do: 1
  defp to_score("B"), do: 2
  defp to_score("C"), do: 3

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 2)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 2)
end
