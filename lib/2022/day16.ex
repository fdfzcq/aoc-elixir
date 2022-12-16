defmodule Year2022.Day16 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defstruct [:rate, :tunnels]

  defp part1(str) do
    map =
      str
      |> String.split("\n")
      |> Enum.reduce(
        %{},
        fn line, map ->
          [rate] =
            Regex.scan(~r/[[:digit:]]+/, line) |> Enum.map(fn [v] -> String.to_integer(v) end)

          [line1, line2] = String.split(line, "; ")
          [c1, c2 | _] = String.replace(line1, "Valve ", "") |> String.codepoints()
          valve = c1 <> c2

          tunnels =
            String.replace(line2, ~r/^(tunnels|tunnel) (lead|leads) to (valves|valve) /, "")
            |> String.split(", ")

          Map.put(map, valve, {rate, tunnels})
        end
      )

    status_map =
      Map.to_list(map)
      |> Enum.filter(fn {_, {r, _}} -> r == 0 end)
      |> Enum.map(fn {k, _} -> {k, 0} end)
      |> Map.new()

    find_max_flow(MapSet.new([{"AA", 0, 0, status_map}]), 0, map)
  end

  defp find_max_flow(valves, 30, _) do
    Enum.max(valves, fn {_, _, rate1, _}, {_, _, rate2, _} -> rate1 > rate2 end)
  end

  defp find_max_flow(valves, n, mem) do
    next_steps =
      Enum.reduce(MapSet.to_list(valves), MapSet.new(), fn {v, current_rate, released, map},
                                                           acc ->
        if map_size(map) != map_size(mem) do
          new_acc =
            Map.get(mem, v)
            |> elem(1)
            |> Enum.filter(&should_continue?(&1, v, map, mem))
            |> Enum.reduce(acc, fn x, a ->
              MapSet.put(a, {x, current_rate, released + current_rate, map})
            end)

          if Map.get(map, v, nil) != 0 do
            MapSet.put(
              new_acc,
              {v, Map.get(mem, v) |> elem(0) |> Kernel.+(current_rate), released + current_rate,
               Map.put(map, v, 0)}
            )
          else
            new_acc
          end
        else
          MapSet.put(acc, {v, current_rate, released + current_rate, map})
        end
      end)

    find_max_flow(Enum.take(next_steps, 20), n + 1, mem)
  end

  defp should_continue?(target, v, status, map),
    do: do_should_continue?(target, status, map, MapSet.new([v]))

  defp do_should_continue?(target, status, map, mem) do
    if MapSet.member?(mem, target) do
      false
    else
      if Map.get(status, target) == 0 do
        Map.get(map, target)
        |> elem(1)
        |> Enum.any?(&do_should_continue?(&1, status, map, MapSet.put(mem, target)))
      else
        true
      end
    end
  end

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str) do
    map =
      str
      |> String.split("\n")
      |> Enum.reduce(
        %{},
        fn line, map ->
          [rate] =
            Regex.scan(~r/[[:digit:]]+/, line) |> Enum.map(fn [v] -> String.to_integer(v) end)

          [line1, line2] = String.split(line, "; ")
          [c1, c2 | _] = String.replace(line1, "Valve ", "") |> String.codepoints()
          valve = c1 <> c2

          tunnels =
            String.replace(line2, ~r/^(tunnels|tunnel) (lead|leads) to (valves|valve) /, "")
            |> String.split(", ")

          Map.put(map, valve, {rate, tunnels})
        end
      )

    status_map =
      Map.to_list(map)
      |> Enum.filter(fn {_, {r, _}} -> r == 0 end)
      |> Enum.map(fn {k, _} -> {k, 0} end)
      |> Map.new()

    find_max_flow2(MapSet.new([{{"AA", "AA"}, 0, 0, status_map}]), 0, map)
  end

  defp find_max_flow2(valves, 26, _) do
    Enum.max(valves, fn {_, _, rate1, _}, {_, _, rate2, _} -> rate1 > rate2 end)
  end

  defp find_max_flow2(valves, n, mem) do
    next_steps =
      Enum.reduce(MapSet.to_list(valves), MapSet.new(), fn {{v1, elephant}, current_rate,
                                                            released, map},
                                                           acc ->
        if map_size(map) != map_size(mem) do
          moves =
            Map.get(mem, v1)
            |> elem(1)
            |> Enum.filter(&should_continue?(&1, v1, map, mem))

          elephant_moves =
            Map.get(mem, elephant)
            |> elem(1)
            |> Enum.filter(&should_continue?(&1, elephant, map, mem))

          acc0 =
            moves
            |> Enum.reduce(
              acc,
              fn move, aa ->
                Enum.reduce(elephant_moves, aa, fn em, a ->
                  MapSet.put(a, {{move, em}, current_rate, released + current_rate, map})
                end)
              end
            )

          acc1 =
            if Map.get(map, v1, nil) != 0 && Map.get(map, elephant, nil) != 0 && v1 != elephant do
              MapSet.put(
                acc0,
                {{v1, elephant},
                 current_rate + elem(Map.get(mem, v1), 0) + elem(Map.get(mem, elephant), 0),
                 current_rate + released, map |> Map.put(v1, 0) |> Map.put(elephant, 0)}
              )
            else
              acc0
            end

          acc2 =
            if Map.get(map, v1, nil) != 0 do
              Enum.reduce(elephant_moves, acc1, fn e, a ->
                MapSet.put(
                  a,
                  {{v1, e}, current_rate + elem(Map.get(mem, v1), 0), current_rate + released,
                   map |> Map.put(v1, 0)}
                )
              end)
            else
              acc1
            end

          if Map.get(map, elephant, nil) != 0 do
            Enum.reduce(moves, acc1, fn e, a ->
              MapSet.put(
                a,
                {{e, elephant}, current_rate + elem(Map.get(mem, elephant), 0),
                 current_rate + released, map |> Map.put(elephant, 0)}
              )
            end)
          else
            acc2
          end
        else
          MapSet.put(acc, {{v1, elephant}, current_rate, released + current_rate, map})
        end
      end)
      |> MapSet.to_list()
      |> Enum.sort(fn {_, r1, l1, _}, {_, r2, l2, _} ->
        if r1 == r2 do
          l1 > l2
        else
          r1 > r2
        end
      end)
      |> Enum.take(5000)
      |> MapSet.new()

    find_max_flow2(next_steps, n + 1, mem)
  end

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 16)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 16)
end
