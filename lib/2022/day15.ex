defmodule Year2022.Day15 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str) do
    map =
      str
      |> String.split("\n")
      |> Enum.reduce(%{}, &parse_signals/2)

    map
    |> Map.to_list()
    |> impossible_beacons(2_000_000, MapSet.new(Map.values(map)))
  end

  defp parse_signals(line, signal_map) do
    [sx, sy, bx, by] =
      Regex.scan(~r/[-[:digit:]]+/, line) |> Enum.map(fn [v] -> String.to_integer(v) end)

    Map.put(signal_map, {sx, sy}, {bx, by})
  end

  defp impossible_beacons(list, y, beacons) do
    impossible_ranges =
      list
      |> Enum.reduce([], fn {{sx, sy}, {bx, by}}, ranges ->
        dist_sb = abs(sx - bx) + abs(sy - by)
        dist_x = dist_sb - abs(sy - y)

        if dist_x <= 0 do
          ranges
        else
          [{sx - dist_x, sx + dist_x} | ranges]
        end
      end)
      |> Enum.sort()
      |> merge_ranges()
      |> Enum.uniq()

    res =
      0..4_000_000
      |> Enum.find(fn v ->
        !MapSet.member?(beacons, {v, y}) && !Enum.member?(impossible_ranges, v) && v <= 4_000_000
      end)

    case res do
      nil -> :noop
      v -> IO.inspect(v * 4_000_000 + y)
    end
  end

  defp merge_ranges([{min, max} | t]), do: merge_ranges(t, max, Enum.to_list(min..max))

  defp merge_ranges([], _, range), do: range

  defp merge_ranges([{min, max} | t], acc_max, ranges) do
    case {acc_max < min, acc_max < max} do
      {true, true} -> merge_ranges(t, max, ranges ++ Enum.to_list(min..max))
      {false, true} -> merge_ranges(t, max, ranges ++ Enum.to_list((acc_max + 1)..max))
      {false, false} -> merge_ranges(t, acc_max, ranges)
    end
  end

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str) do
    map =
      str
      |> String.split("\n")
      |> Enum.reduce(%{}, &parse_signals/2)

    0..4_000_000
    |> Enum.reduce(%{}, &possible_beacons2(Enum.to_list(map), &2, &1))
  end

  defp possible_beacons2(list, mem, y) do
    {impossible_ranges, _, _, new_mem} =
      list
      |> Enum.reduce({[], 999_999_999, 0, mem}, fn {{sx, sy}, {bx, by}},
                                                   {ranges, a_min, a_max, m} ->
        case Map.get(mem, {sx, sy}, nil) do
          {a, b} ->
            if sy >= y do
              {[{a - 1, b + 1} | ranges], min(a_min, a - 1), max(a_max, b + 1),
               Map.put(m, {sx, sy}, {a - 1, b + 1})}
            else
              if a + 1 < b - 1 do
                {[{a + 1, b - 1} | ranges], min(a_min, a + 1), max(a_max, b - 1),
                 Map.put(m, {sx, sy}, {a + 1, b - 1})}
              else
                {ranges, a_min, a_max, Map.put(m, {sx, sy}, :gone)}
              end
            end

          nil ->
            dist_sb = abs(sx - bx) + abs(sy - by)
            dist_x = dist_sb - abs(sy - y)

            if dist_x <= 0 do
              {ranges, a_min, a_max, m}
            else
              {[{sx - dist_x, sx + dist_x} | ranges], min(a_min, sx - dist_x),
               max(a_max, sx + dist_x), Map.put(m, {sx, sy}, {sx - dist_x, sx + dist_x})}
            end

          _ ->
            {ranges, a_min, a_max, m}
        end
      end)

    merge_ranges_and_find_beacon(Enum.sort(impossible_ranges), y)
    new_mem
  end

  defp merge_ranges_and_find_beacon([{_, b} | t], y), do: merge_ranges_and_find_beacon(t, b, y)

  defp merge_ranges_and_find_beacon([], _, _), do: :noop

  defp merge_ranges_and_find_beacon([{min, max} | t], acc_max, y) do
    case {acc_max < min, acc_max < max} do
      {true, true} ->
        IO.inspect({acc_max + 1, y})
        IO.inspect((acc_max + 1) * 4_000_000 + y)
        System.halt(0)

      {false, true} ->
        merge_ranges_and_find_beacon(t, max, y)

      {false, false} ->
        merge_ranges_and_find_beacon(t, acc_max, y)
    end
  end

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 15)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 15)
end
