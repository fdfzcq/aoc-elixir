defmodule Year2022.Day23 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str) do
    str
    |> Utils.to_coordinates_map(fn c -> c end)
    |> Map.filter(fn {_, c} -> c == "#" end)
    |> Map.keys()
    |> MapSet.new()
    |> move_elves(0)
    #|> calc_ground_tiles()  - part 1
  end

  defp calc_ground_tiles(map) do
    list = MapSet.to_list(map)
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(list, fn {x, _} -> x end)
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(list, fn {_, y} -> y end)
    (max_x - min_x + 1) * (max_y - min_y + 1) - MapSet.size(map)
  end

  defp move_elves(map, round), do: move_elves(MapSet.to_list(map), map, round, [:n, :s, :w, :e])

  # part 1 - defp move_elves(_, map, round, _) when round >= 10, do: map

  defp move_elves(elves, map, round, dirs) do
    new_map =
      elves
      |> Enum.reduce(
        %{},
        fn c, acc ->
          prop =
            case Enum.map(dirs, fn d -> has_elf?(map, c, d) end) do
              [false, false, false, false] ->
                c

              res ->
                case res |> Enum.zip(dirs) |> Enum.find(fn {v, _} -> !v end) do
                  nil -> c
                  {_, d} -> move(c, d)
                end
            end

          Map.update(acc, prop, [c], fn a -> [c | a] end)
        end
      )
      |> Map.to_list()
      |> Enum.reduce(
        MapSet.new(),
        fn {prop, origs}, acc ->
          if length(origs) == 1 do
            MapSet.put(acc, prop)
          else
            origs
            |> Enum.reduce(acc, fn o, a -> MapSet.put(a, o) end)
          end
        end
      )

    if map == new_map do
      IO.inspect(round + 1)
    else
      move_elves(MapSet.to_list(new_map), new_map, round + 1, tl(dirs) ++ [hd(dirs)])
    end
  end

  defp move({x, y}, d) do
    case d do
      :n -> {x, y - 1}
      :s -> {x, y + 1}
      :w -> {x - 1, y}
      :e -> {x + 1, y}
    end
  end

  defp has_elf?(map, coor, dir),
    do: Enum.any?(to_coors(coor, dir), fn c -> MapSet.member?(map, c) end)

  defp to_coors({x, y}, :n), do: [{x, y - 1}, {x - 1, y - 1}, {x + 1, y - 1}]

  defp to_coors({x, y}, :s), do: [{x, y + 1}, {x - 1, y + 1}, {x + 1, y + 1}]

  defp to_coors({x, y}, :w), do: [{x - 1, y}, {x - 1, y - 1}, {x - 1, y + 1}]

  defp to_coors({x, y}, :e), do: [{x + 1, y}, {x + 1, y - 1}, {x + 1, y + 1}]

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str) do
  end

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 23)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 23)
end
