defmodule Year2021.Day13 do
  def run1(), do: part1(parse_input(input()))
  def test1(), do: part1(parse_input(test_input()))

  defp part1({dots, [fold_ins | _]}), do: dots |> fold(fold_ins) |> MapSet.size()

  ## part2

  def run2(), do: part2(parse_input(input()))
  def test2(), do: part2(parse_input(test_input()))

  defp part2({dots, instructions}),
    do:
      instructions
      |> Enum.reduce(dots, &fold(&2, &1))
      |> MapSet.to_list()
      |> Enum.sort(fn {x1, y1}, {x2, y2} ->
        y1 < y2 || (y1 == y2 && x1 < x2)
      end)
      |> plot({0, 0}, "")

  defp plot([], _, str), do: IO.puts(str)
  defp plot([{x, y} | t], {x, y}, str), do: plot(t, {x + 1, y}, str <> "#")
  defp plot([{dx, y} | t], {x, y}, str), do: plot([{dx, y} | t], {x + 1, y}, str <> ".")

  defp plot(list, {_, y}, str) do
    IO.puts(str)
    plot(list, {0, y + 1}, "")
  end

  ## utils

  defp fold(dots, fold_ins),
    do:
      dots
      |> MapSet.to_list()
      |> Enum.reduce(dots, &fold(&1, &2, fold_ins))

  defp fold({x, _}, dots, {:x, fold_x}) when x < fold_x, do: dots
  defp fold({_, y}, dots, {:y, fold_y}) when y < fold_y, do: dots

  defp fold(dot, dots, fold),
    do:
      dots
      |> MapSet.delete(dot)
      |> MapSet.put(fold_dot(dot, fold))

  defp fold_dot({x, y}, {:x, fold_x}), do: {fold_x - x + fold_x, y}
  defp fold_dot({x, y}, {:y, fold_y}), do: {x, fold_y - y + fold_y}

  defp parse_input(str) do
    [dots_str, fold_ins_str] = String.split(str, "\n\n")
    {to_map(dots_str), to_fold_instructions(fold_ins_str)}
  end

  defp to_map(dots_str),
    do:
      dots_str
      |> String.split("\n")
      |> Enum.reduce(MapSet.new(), &add_to_map/2)

  defp add_to_map(dot_str, mapset) do
    [x_str, y_str] = String.split(dot_str, ",")
    MapSet.put(mapset, {String.to_integer(x_str), String.to_integer(y_str)})
  end

  defp to_fold_instructions(fold_ins_str) do
    fold_ins_str
    |> String.split("\n")
    |> Enum.map(fn str ->
      case str do
        "fold along y=" <> y_str -> {:y, String.to_integer(y_str)}
        "fold along x=" <> x_str -> {:x, String.to_integer(x_str)}
      end
    end)
  end

  defp input(), do: Utils.read_input_from_file(2021, 13)
  defp test_input(), do: Utils.read_test_input_from_file(2021, 13)
end
