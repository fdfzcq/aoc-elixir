defmodule Year2022.Day19 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defstruct [:id, :ore, :clay, :obsidian, :geode]

  defp part1(str) do
    str
    |> String.split("\n")
    |> Enum.map(fn line -> Regex.scan(~r/[[:digit:]]+/, line) end)
    |> Enum.map(fn [
                     [blueprint],
                     [ore_robot],
                     [clay_robot],
                     [obsidian_robot1],
                     [obsidian_robot2],
                     [geode_robot1],
                     [geode_robot2]
                   ] ->
      %__MODULE__{
        id: String.to_integer(blueprint),
        ore: String.to_integer(ore_robot),
        clay: String.to_integer(clay_robot),
        obsidian: {String.to_integer(obsidian_robot1), String.to_integer(obsidian_robot2)},
        geode: {String.to_integer(geode_robot1), String.to_integer(geode_robot2)}
      }
    end)
    |> Enum.map(&calc_max_geode/1)
    |> Enum.reduce(1, fn v, acc -> acc * v end)
  end

  defp calc_max_geode(blueprint), do: calc_max_geode(blueprint, [{{1, 0, 0, 0}, {0, 0, 0, 0}}], 0)

  defp calc_max_geode(_blueprint, maps, minutes) when minutes >= 32,
    do: Enum.reduce(maps, 0, fn {_, {_, _, _, g}}, max -> max(g, max) end)

  defp calc_max_geode(blueprint, maps, minutes) do
    IO.inspect(minutes)

    newm =
      Enum.reduce(maps, [], fn {{orr, cr, obr, gr}, {o, c, ob, g}} = map, acc ->
        new_map = {{orr, cr, obr, gr}, {o + orr, c + cr, ob + obr, g + gr}}

        acc0 =
          case build_robot(blueprint, map, :geode, new_map) do
            {:built, nm2} -> [nm2 | acc]
            _ -> acc
          end

        acc1 =
          case build_robot(blueprint, map, :obsidian, new_map) do
            {:built, nm2} -> [nm2 | acc0]
            _ -> acc0
          end

        acc2 =
          case {build_robot(blueprint, map, :clay, new_map), cr < 10 && c <= 100} do
            {{:built, nm2}, true} -> [nm2 | acc1]
            _ -> acc1
          end

        case {build_robot(blueprint, map, :ore, new_map), orr < 8 && o <= 10} do
          {{:built, nm2}, true} -> [nm2, new_map | acc2]
          _ -> [new_map | acc2]
        end
      end)

    new_maps =
      Enum.sort(
        newm,
        fn {{_, c1, ob1, g1}, _}, {{_, c2, ob2, g2}, _} ->
          if g1 == g2 do
            if ob1 == ob2 do
              c1 > c2
            else
              ob1 > ob2
            end
          else
            g1 > g2
          end
        end
      )
      |> Enum.take(100)

    calc_max_geode(blueprint, new_maps, minutes + 1)
  end

  defp build_robot(blueprint, map, type, new_map) do
    resources_needed = Map.get(blueprint, type)
    resources = get_resources_for_robot_type(map, type)

    case resources_needed do
      {r1, r2} ->
        if r1 <= elem(resources, 0) && r2 <= elem(resources, 1) do
          {:built, update_resources_map_for_robot_type(new_map, resources_needed, type)}
        else
          map
        end

      r ->
        if r <= resources do
          {:built, update_resources_map_for_robot_type(new_map, resources_needed, type)}
        else
          map
        end
    end
  end

  defp get_resources_for_robot_type({_, {o, c, ob, _}}, type) do
    case type do
      :ore -> o
      :clay -> o
      :obsidian -> {o, c}
      :geode -> {o, ob}
    end
  end

  defp update_resources_map_for_robot_type(
         {{orr, cr, obr, gr}, {o, c, ob, g}},
         resources_needed,
         type
       ) do
    case type do
      :ore ->
        {{orr + 1, cr, obr, gr}, {o - resources_needed, c, ob, g}}

      :clay ->
        {{orr, cr + 1, obr, gr}, {o - resources_needed, c, ob, g}}

      :obsidian ->
        {ore_needed, clay_needed} = resources_needed
        {{orr, cr, obr + 1, gr}, {o - ore_needed, c - clay_needed, ob, g}}

      :geode ->
        {ore_needed, obsidian_needed} = resources_needed
        {{orr, cr, obr, gr + 1}, {o - ore_needed, c, ob - obsidian_needed, g}}
    end
  end

  ## part 2

  # def run2(), do: part2(input())
  # def test2(), do: part2(test_input())

  # defp part2(str) do
  # end

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 19)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 19)
end
