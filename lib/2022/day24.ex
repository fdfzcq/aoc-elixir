defmodule Year2022.Day24 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str) do
    map = Utils.to_coordinates_map(str, fn c -> c end)
    b_maps = to_blizzard_maps(map)
    t1 = steps([{1, 0}], {max(:x) - 1, max(:y)}, b_maps, 0) |> IO.inspect()
    t2 = steps([{max(:x) - 1, max(:y)}], {1, 0}, b_maps, t1) |> IO.inspect()
    steps([{1, 0}], {max(:x) - 1, max(:y)}, b_maps, t2) |> IO.inspect()
  end

  defp max(:x), do: 101 # 7
  defp max(:y), do: 36 # 5

  defp steps(moves, goal, bmaps, step) do
    new_moves = Enum.reduce(moves, [],
      fn {x, y}, acc ->
        next = [{x, y}, {x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
        |> Enum.filter(&filter_walls/1)
        |> Enum.filter(&filter_blizzards(&1, bmaps, step))
        acc ++ next
      end)
      |> Enum.uniq()
    if new_moves == [] || Enum.any?(new_moves, fn c -> c == goal end) do
      step
    else
      steps(new_moves, goal, bmaps, step + 1)
    end
  end

  defp filter_blizzards({x, y}, {x_map, y_map}, step) do
    xs = Map.get(x_map, x, [])
    if Enum.any?(xs, fn {{_, by}, v} -> do_move({:y, by}, v, step) == y end) do
      false
    else
      ys = Map.get(y_map, y, [])
      if Enum.any?(ys, fn {{bx, _}, v} -> do_move({:x, bx}, v, step) == x end) do
        false
      else
        true
      end
    end
  end

  defp do_move({type, v}, dir, steps) do
    case dir do
      d when d == "v" or d == ">" -> 1 + rem(v + steps - 1, max(type) - 1)
      _ -> max(type) - 1 - rem((max(type) - 1) - (v - steps), max(type) - 1)
    end
  end

  defp filter_walls({x, y}), do:
    (x == 1 && y == 0) || (x == max(:x) - 1 && y == max(:y)) || (x > 0 && x < max(:x) && y > 0 && y < max(:y))

  defp to_blizzard_maps(map) do
    blizzards = map |> Map.filter(fn {_, v} -> v != "#" && v != "." end) |> Map.to_list()
    x_map = blizzards |> Enum.filter(fn {_, v} -> v == "v" || v == "^" end) |> Enum.group_by(fn {{x, _}, _} -> x end)
    y_map = blizzards |> Enum.filter(fn {_, v} -> v == "<" || v == ">" end) |> Enum.group_by(fn {{_, y}, _} -> y end)
    {x_map, y_map}
  end

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str) do

  end

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 24)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 24)
end
