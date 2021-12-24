defmodule Day10 do
  def test, do: process(test_input())
  def run, do: process(input())

  ## part 1

  def process1(str) do
    str
    |> String.split("\n")
    |> Enum.reduce([], &find_corrupted_input(&1, &2))
    |> Enum.map(&to_score/1)
    |> Enum.sum()
  end

  def find_corrupted_input(line_str, acc),
    do: find_corrupted_input(String.codepoints(line_str), [], acc)

  def find_corrupted_input([], _, acc), do: acc

  def find_corrupted_input([p | t], visited, acc) do
    case p do
      p when p in ["(", "[", "{", "<"] ->
        find_corrupted_input(t, [p | visited], acc)

      _ ->
        find_corrupted_input(p, t, visited, acc)
    end
  end

  def find_corrupted_input(_, [], _, acc), do: acc

  def find_corrupted_input(p, rest, [q | t], acc) do
    case is_pair(q, p) do
      true ->
        find_corrupted_input(rest, t, acc)

      _ ->
        [p | acc]
    end
  end

  ## end of part 1

  ## part 2

  defp process(str) do
    list =
      str
      |> String.split("\n")
      |> Enum.reduce([], &find_missing_input(&1, &2))
      |> Enum.map(&calc_score(&1, 0))
      |> Enum.sort()

    Enum.at(list, div(length(list) - 1, 2))
  end

  defp find_missing_input(line_str, acc),
    do: find_missing_input(String.codepoints(line_str), [], acc)

  defp find_missing_input([], [], acc), do: acc
  defp find_missing_input([], visited, acc), do: [visited | acc]

  defp find_missing_input([p | t], visited, acc) do
    case p do
      p when p in ["(", "[", "{", "<"] ->
        find_missing_input(t, [p | visited], acc)

      _ ->
        find_missing_input(p, t, visited, acc)
    end
  end

  defp find_missing_input(_, _, [], acc), do: acc

  defp find_missing_input(p, rest, [q | t], acc) do
    case is_pair(q, p) do
      true ->
        find_missing_input(rest, t, acc)

      _ ->
        acc
    end
  end

  defp calc_score([], acc), do: acc
  defp calc_score([p | t], acc), do: calc_score(t, acc * 5 + to_score(p))

  ## end of part 2

  defp is_pair("(", ")"), do: true
  defp is_pair("[", "]"), do: true
  defp is_pair("<", ">"), do: true
  defp is_pair("{", "}"), do: true
  defp is_pair(_, _), do: false

  defp to_score("("), do: 1
  defp to_score("["), do: 2
  defp to_score("{"), do: 3
  defp to_score("<"), do: 4
  defp to_score(")"), do: 3
  defp to_score("]"), do: 57
  defp to_score("}"), do: 1197
  defp to_score(">"), do: 25137

  defp test_input, do: Utils.read_input_from_file("day10_test.txt")
  defp input, do: Utils.read_input_from_file("day10.txt")
end
