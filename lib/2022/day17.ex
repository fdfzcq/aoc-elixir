defmodule Year2022.Day17 do
  def run1(), do: part1(:non_test)
  def test1(), do: part1(:test)

  defp part1(mode) do
    instructions(mode)
    |> rock_fall(0, 0, 0, 0, [{0, 0}, {1, 0}, {2, 0}, {3, 0}, {4, 0}, {5, 0}, {6, 0}])
  end

  defp instructions(:test), do: String.codepoints(test_input())
  defp instructions(_), do: String.codepoints(input())

  defp rock_fall(_, 6000, height, _, _, _), do: height

  defp rock_fall(ins, rocks_count, height, i, max_y, floor) do
    rock = init_rock(rem(rocks_count, 5), max_y)
    {new_h, new_i, new_floor} = move_rock(ins, rock, height, i, floor, max_y)
    {new_floor1, new_max_y} = truncate_floor(new_floor, new_h)
    rock_fall(ins, rocks_count + 1, new_h, new_i, new_max_y, new_floor1)
  end

  defp truncate_floor(floor, height) do
    {min_y, max_y} =
      0..6
      |> Enum.reduce({height, 0}, fn v, {min, max} ->
        {_, my} =
          Enum.max(Enum.filter(floor, fn {x, _} -> x == v end), fn {_, y1}, {_, y2} -> y1 > y2 end)

        {min(my, min), max(my, max)}
      end)

    {Enum.filter(floor, fn {_, y} -> y > min_y - 1 end)
     |> Enum.map(fn {x, y} -> {x, y - min_y} end), max_y - min_y}
  end

  defp move_rock(ins, rock, h, i, floor, max_y) do
    new_rock0 =
      case Enum.at(ins, rem(i, length(ins))) do
        ">" -> move_horizontal(rock, 1, floor)
        "<" -> move_horizontal(rock, -1, floor)
      end

    if Enum.any?(new_rock0, fn {x, y} ->
         Enum.any?(floor, fn {fx, fy} -> x == fx && y == fy + 1 end)
       end) do
      {_, y} = Enum.max(new_rock0, fn {_, y1}, {_, y2} -> y1 > y2 end)
      {max(y - max_y + h, h), i + 1, floor ++ new_rock0}
    else
      new_rock1 = Enum.map(new_rock0, fn {x, y} -> {x, y - 1} end)
      move_rock(ins, new_rock1, h, i + 1, floor, max_y)
    end
  end

  defp move_horizontal(rock, a, floor) do
    if Enum.any?(rock, fn {x, y} ->
         x == 0 || Enum.any?(floor, fn {fx, fy} -> fy == y && fx == x - 1 end)
       end) && a == -1 do
      rock
    else
      if Enum.any?(rock, fn {x, y} ->
           x == 6 || Enum.any?(floor, fn {fx, fy} -> fy == y && fx == x + 1 end)
         end) && a == 1 do
        rock
      else
        Enum.map(rock, fn {x, y} -> {x + a, y} end)
      end
    end
  end

  defp init_rock(rock_shape, y) do
    case rock_shape do
      0 -> [{2, y + 4}, {3, y + 4}, {4, y + 4}, {5, y + 4}]
      1 -> [{2, y + 5}, {3, y + 5}, {4, y + 5}, {3, y + 4}, {3, y + 6}]
      2 -> [{2, y + 4}, {3, y + 4}, {4, y + 4}, {4, y + 5}, {4, y + 6}]
      3 -> [{2, y + 4}, {2, y + 5}, {2, y + 6}, {2, y + 7}]
      4 -> [{2, y + 4}, {3, y + 4}, {2, y + 5}, {3, y + 5}]
    end
  end

  ## part 2

  # def run2(), do: part2(input())
  # def test2(), do: part2(test_input())

  # defp part2(str) do
  #   # reuse code in part 1
  # end

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 17)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 17)
end
