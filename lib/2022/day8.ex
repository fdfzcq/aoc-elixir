defmodule Year2022.Day8 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str) do
    str
    |> to_coordinates_map()
    |> find_visible(%{}, str)
    |> map_size()
  end

  defp to_coordinates_map(str) do
    str
    |> String.split("\n")
    |> Enum.reduce({0, %{}}, fn line, {y, m} ->
      {_, new_m} =
        Enum.reduce(String.codepoints(line), {0, m}, fn c, {x, mm} ->
          {x + 1, Map.put(mm, {x, y}, String.to_integer(c))}
        end)

      {y + 1, new_m}
    end)
    |> elem(1)
  end

  defp find_visible(c_map, v_map, str) do
    max_x = String.split(str, "\n") |> Enum.at(0) |> String.length() |> Kernel.-(1)
    max_y = div(map_size(c_map), max_x + 1) - 1
    new_v_map = find_horizontal_visible(max_x, max_y, c_map, v_map)
    find_vertical_visible(max_x, max_y, c_map, new_v_map)
  end

  defp find_horizontal_visible(max_x, max_y, c_map, v_map) do
    0..max_x
    |> Enum.reduce(
      v_map,
      fn x, m ->
        {new_m, _} =
          0..max_y
          |> Enum.reduce({m, -1}, &maybe_visible(x, &1, &2, c_map))

        {new_new_m, _} =
          0..max_y
          |> Enum.reverse()
          |> Enum.reduce({new_m, -1}, &maybe_visible(x, &1, &2, c_map))

        new_new_m
      end
    )
  end

  defp find_vertical_visible(max_x, max_y, c_map, v_map) do
    0..max_y
    |> Enum.reduce(
      v_map,
      fn y, m ->
        {new_m, _} =
          0..max_x
          |> Enum.reduce({m, -1}, &maybe_visible(&1, y, &2, c_map))

        {new_new_m, _} =
          0..max_x
          |> Enum.reverse()
          |> Enum.reduce({new_m, -1}, &maybe_visible(&1, y, &2, c_map))

        new_new_m
      end
    )
  end

  defp maybe_visible(x, y, {m, max}, cm) do
    v = Map.get(cm, {x, y})

    case v do
      v when v <= max -> {m, max}
      _ -> {Map.put(m, {x, y}, v), v}
    end
  end

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str) do
    c_map =
      str
      |> to_coordinates_map()

    c_map
    |> find_visible(%{}, str)
    |> scenic_score_map(c_map, %{}, str)
    |> Map.values()
    |> Enum.max()
  end

  defp scenic_score_map(t_map, c_map, s_map, str) do
    max_x = String.split(str, "\n") |> Enum.at(0) |> String.length() |> Kernel.-(1)
    max_y = div(map_size(c_map), max_x + 1) - 1

    t_map
    |> Map.keys()
    |> Enum.reduce(
      s_map,
      fn {x, y}, m ->
        if not is_center({x, y}, {max_x, max_y}) do
          Map.put(m, {x, y}, 0)
        else
          v = Map.get(c_map, {x, y})

          s_up =
            0..(y - 1)
            |> Enum.reverse()
            |> Enum.reduce_while(%{}, &maybe_visible2(x, &1, &2, c_map, v))
            |> map_size()

          s_down =
            (y + 1)..max_y
            |> Enum.reduce_while(%{}, &maybe_visible2(x, &1, &2, c_map, v))
            |> map_size()

          s_left =
            0..(x - 1)
            |> Enum.reverse()
            |> Enum.reduce_while(%{}, &maybe_visible2(&1, y, &2, c_map, v))
            |> map_size()

          s_right =
            (x + 1)..max_x
            |> Enum.reduce_while(%{}, &maybe_visible2(&1, y, &2, c_map, v))
            |> map_size()

          Map.put(m, {x, y}, s_up * s_down * s_left * s_right)
        end
      end
    )
  end

  defp maybe_visible2(x, y, m, cm, h) do
    v = Map.get(cm, {x, y})

    case v do
      v when v < h -> {:cont, Map.put(m, {x, y}, v)}
      _ -> {:halt, Map.put(m, {x, y}, v)}
    end
  end

  defp is_center({x, y}, {max_x, max_y}), do: x != 0 && y != 0 && x != max_x && y != max_y

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 8)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 8)
end
