defmodule Year2022.Day14 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str) do
    str
    |> String.split("\n")
    |> Enum.reduce(MapSet.new(), &draw_rocks/2)
    |> pour_sand(1)
  end

  defp draw_rocks(line, rocks) do
    dots =
      line
      |> String.split(" -> ")
      |> Enum.map(fn s -> Enum.map(String.split(s, ","), &String.to_integer/1) end)

    draw_rock(dots, rocks)
  end

  defp draw_rock([[x1, y1], [x2, y2] | tail], rocks) do
    new_rocks =
      case {x1, y1} do
        {x, _} when x == x2 ->
          min(y1, y2)..max(y1, y2) |> Enum.reduce(rocks, fn v, a -> MapSet.put(a, {x, v}) end)

        {_, y} when y == y2 ->
          min(x1, x2)..max(x1, x2) |> Enum.reduce(rocks, fn v, a -> MapSet.put(a, {v, y}) end)
      end

    draw_rock([[x2, y2] | tail], new_rocks)
  end

  defp draw_rock(_, rocks), do: rocks

  defp pour_sand(rocks, units), do: pour_sand(rocks, units, {500, 0})

  defp pour_sand(_, units, {_, y}) when y > 200, do: units - 1

  defp pour_sand(rocks, units, {x, y}) do
    if MapSet.member?(rocks, {x, y + 1}) do
      if MapSet.member?(rocks, {x - 1, y + 1}) do
        if MapSet.member?(rocks, {x + 1, y + 1}) do
          pour_sand(MapSet.put(rocks, {x, y}), units + 1, {500, 0})
        else
          pour_sand(rocks, units, {x + 1, y + 1})
        end
      else
        pour_sand(rocks, units, {x - 1, y + 1})
      end
    else
      pour_sand(rocks, units, {x, y + 1})
    end
  end

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str) do
    str
    |> String.split("\n")
    |> Enum.reduce(MapSet.new(), &draw_rocks/2)
    |> pour_sand2(1)
  end

  defp pour_sand2(rocks, units) do
    {_, max_y} =
      rocks
      |> MapSet.to_list()
      |> Enum.max(fn {_, y1}, {_, y2} -> y1 > y2 end)

    pour_sand2(rocks, units, {500, 0}, max_y + 2)
  end

  defp pour_sand2(rocks, units, {x, y}, floor_y) do
    if MapSet.member?(rocks, {x, y + 1}) || y + 1 == floor_y do
      if MapSet.member?(rocks, {x - 1, y + 1}) || y + 1 == floor_y do
        if MapSet.member?(rocks, {x + 1, y + 1}) || y + 1 == floor_y do
          if {x, y} == {500, 0} do
            units
          else
            pour_sand2(MapSet.put(rocks, {x, y}), units + 1, {500, 0}, floor_y)
          end
        else
          pour_sand2(rocks, units, {x + 1, y + 1}, floor_y)
        end
      else
        pour_sand2(rocks, units, {x - 1, y + 1}, floor_y)
      end
    else
      pour_sand2(rocks, units, {x, y + 1}, floor_y)
    end
  end

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 14)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 14)
end
