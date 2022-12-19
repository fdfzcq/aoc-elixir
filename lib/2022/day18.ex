defmodule Year2022.Day18 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str) do
    list =
      str
      |> String.split("\n")
      |> Enum.map(fn line ->
        String.split(line, ",") |> Enum.map(fn c -> String.to_integer(c) end)
      end)

    x_list = Enum.map(list, fn [x, y, z] -> {x, y, z} end)
    y_list = Enum.map(list, fn [x, y, z] -> {y, x, z} end)
    z_list = Enum.map(list, fn [x, y, z] -> {z, x, y} end)
    surface0 = calc_surface(x_list, 0)
    surface1 = calc_surface(y_list, surface0)
    calc_surface(z_list, surface1)
  end

  defp calc_surface(list, surface) do
    sorted =
      list
      |> Enum.sort(fn {x1, _, _}, {x2, _, _} -> x1 < x2 end)

    surface1 = calc_surface(sorted, 0, [], [], 1, surface)
    calc_surface(Enum.reverse(sorted), 50, [], [], -1, surface1)
  end

  defp calc_surface([], _, _, _, _, surface), do: surface

  defp calc_surface([{z0, x0, y0} | t], z, prev, current, acc, surface) do
    if z0 == z do
      if Enum.member?(prev, {x0, y0}) do
        calc_surface(t, z, prev, [{x0, y0} | current], acc, surface)
      else
        calc_surface(t, z, prev, [{x0, y0} | current], acc, surface + 1)
      end
    else
      calc_surface([{z0, x0, y0} | t], z + acc, current, [], acc, surface)
    end
  end

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str) do
    list =
      str
      |> String.split("\n")
      |> Enum.map(fn line ->
        String.split(line, ",") |> Enum.map(fn c -> String.to_integer(c) end)
      end)

    air = find_air_map([[-1, -1, -1]], list, MapSet.new())
    x_list = Enum.map(list, fn [x, y, z] -> {x, y, z} end)
    x_air = Enum.map(air, fn [x, y, z] -> {x, y, z} end)
    y_list = Enum.map(list, fn [x, y, z] -> {y, x, z} end)
    y_air = Enum.map(air, fn [x, y, z] -> {y, x, z} end)
    z_list = Enum.map(list, fn [x, y, z] -> {z, x, y} end)
    z_air = Enum.map(air, fn [x, y, z] -> {z, x, y} end)
    surface0 = calc_surface2(x_list, 0, x_air)
    surface1 = calc_surface2(y_list, surface0, y_air)
    calc_surface2(z_list, surface1, z_air)
  end

  defp calc_surface2(list, surface, air) do
    sorted =
      list
      |> Enum.sort(fn {x1, _, _}, {x2, _, _} -> x1 < x2 end)

    surface1 = calc_surface2(sorted, 0, [], [], 1, surface, air)
    calc_surface2(Enum.reverse(sorted), 50, [], [], -1, surface1, air)
  end

  defp find_air_map(points, sorted, air) do
    if points == [] do
      MapSet.to_list(air)
    else
      {new_points, new_air} =
        Enum.reduce(points, {[], air}, fn [x, y, z], {acc, a} ->
          newp =
            [
              [x + 1, y, z],
              [x - 1, y, z],
              [x, y + 1, z],
              [x, y - 1, z],
              [x, y, z + 1],
              [x, y, z - 1]
            ]
            |> Enum.filter(fn v -> Enum.all?(v, &(&1 >= -1 && &1 <= 50)) end)
            |> Enum.filter(&(!MapSet.member?(a, &1)))
            |> Enum.filter(&(!Enum.member?(sorted, &1)))

          {acc ++ newp, Enum.reduce(newp, a, &MapSet.put(&2, &1))}
        end)

      find_air_map(new_points, sorted, new_air)
    end
  end

  defp calc_surface2([], _, _, _, _, surface, _), do: surface

  defp calc_surface2([{z0, x0, y0} | t], z, prev, current, acc, surface, air) do
    if z0 == z do
      if !Enum.member?(prev, {x0, y0}) && Enum.member?(air, {z0 - acc, x0, y0}) do
        calc_surface2(t, z, prev, [{x0, y0} | current], acc, surface + 1, air)
      else
        calc_surface2(t, z, prev, [{x0, y0} | current], acc, surface, air)
      end
    else
      calc_surface2([{z0, x0, y0} | t], z + acc, current, [], acc, surface, air)
    end
  end

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 18)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 18)
end
