defmodule Year2021.Day22 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str) do
    str
    |> String.split("\n")
    |> Enum.reduce([], &parse_input_line/2)
    |> Enum.reverse()
    |> Enum.reduce({[], [[]]}, &reboot/2)
    |> calc_res()
  end

  defp calc_res({cubes, overlaps}) do
    cube_size = Enum.map(cubes, &size/1) |> Enum.sum()
    overlaps = calc_overlaps_sum(overlaps, :plus, 0)
    cube_size - overlaps
  end

  defp calc_overlaps_sum([], _, acc), do: acc
  defp calc_overlaps_sum([overlaps|t], sign, acc) do
    sum = Enum.map(overlaps, &size/1) |> Enum.sum()
    case sign do
      :plus -> calc_overlaps_sum(t, :minus, acc + sum)
      :minus -> calc_overlaps_sum(t, :plus, acc - sum)
    end
  end

  defp reboot({action, x, y, z}, {acc, overlap_acc}) do
    within_range = Enum.filter(acc,
      fn {x1, y1, z1} -> overlaps(x, x1) && overlaps(y, y1) && overlaps(z, z1) end)
    case within_range do
      [] ->
        case action do
          :on -> {[{x, y, z}|acc], overlap_acc}
          :off -> {acc, overlap_acc}
        end
      _ ->
        new_overlaps = calc_overlaps(overlap_acc, acc, {x, y, z})
        case action do
          :on ->
            {[{x, y, z}|acc], new_overlaps}
          _ ->
            {acc, new_overlaps}
        end
    end
  end

  defp calc_overlaps([], _, _), do: []
  defp calc_overlaps([h|t], acc, cube) do
    case h do
      [] -> [find_overlaps(acc, cube)]
      _ ->
        case t do
          [] -> [h ++ find_overlaps(acc, cube)|calc_overlaps([[]], h, cube)]
          _ -> [h ++ find_overlaps(acc, cube)|calc_overlaps(t, h, cube)]
        end
    end
  end

  defp find_overlaps(set, {x, y, z}) do
    set
      |> Enum.filter(
        fn {x1, y1, z1} -> overlaps(x, x1) && overlaps(y, y1) && overlaps(z, z1) end)
      |> Enum.reduce([], &find_overlaps(&1, {x, y, z}, &2))
  end

  defp size({{fx, tx}, {fy, ty}, {fz, tz}}), do: (tx - fx + 1) * (ty - fy + 1) * (tz - fz + 1)

  defp find_overlaps({x1, y1, z1}, {x, y, z}, accs) do
    [{overlap_range(x1, x), overlap_range(y1, y), overlap_range(z1, z)}|accs]
  end

  defp overlaps({f1, t1}, {f2, t2}), do: (f1 <= f2 && t1 >= f2) || (f2 <= f1 && t2 >= f1)

  defp overlap_range({f1, t1}, {f2, t2}) when f1 <= f2 and t1 <= t2, do:
    {f2, t1}
  defp overlap_range({f1, t1}, {f2, t2}) when f1 <= f2 and t1 >= t2, do:
    {f2, t2}
  defp overlap_range({f1, t1}, {f2, t2}) when f1 >= f2 and t1 <= t2, do:
    {f1, t1}
  defp overlap_range({f1, t1}, {f2, t2}) when f1 >= f2 and t1 >= t2, do:
    {f1, t2}

  defp parse_input_line(line, acc) do
    {action, rest} = case line do
      "on " <> rest -> {:on, rest}
      "off " <> rest -> {:off, rest}
    end
    [x_range, y_range, z_range] = String.split(rest, ",")
       |> Enum.map(&parse_range/1)
    [{action, x_range, y_range, z_range}|acc]
  end

  defp parse_range(range_str) do
    [from, to] = String.slice(range_str, 2..-1)
    |> String.split("..")
    |> Enum.map(&String.to_integer/1)
    {from, to}
  end

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str) do

  end

  # utils

  defp input(), do: Utils.read_input_from_file(2021, 22)
  defp test_input(), do: Utils.read_test_input_from_file(2021, 22)
end
