defmodule Year2022.Day10 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str),
    do:
      str
      |> String.split("\n")
      |> to_cycles(1, 1, %{}, [20, 60, 100, 140, 180, 220])
      |> IO.inspect()
      |> Map.to_list()
      |> Enum.map(fn {k, v} -> k * v end)
      |> Enum.sum()

  defp to_cycles([], _, _, map, _), do: map

  defp to_cycles([ins | tail], value, cycle, map, strong_cycles) do
    {new_value, new_cycle} =
      case ins do
        "noop" -> {value, cycle + 1}
        "addx " <> a -> {value + String.to_integer(a), cycle + 2}
      end

    new_map =
      cond do
        Enum.member?(strong_cycles, new_cycle) ->
          Map.put(map, new_cycle, new_value)

        Enum.find(strong_cycles, fn n -> n > cycle && n < new_cycle end) != nil ->
          Map.put(map, Enum.find(strong_cycles, fn n -> n > cycle && n < new_cycle end), value)

        true ->
          map
      end

    to_cycles(tail, new_value, new_cycle, new_map, strong_cycles)
  end

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str),
    do:
      str
      |> String.split("\n")
      |> draw(-1, "", 1)

  defp draw([], _, line, _), do: IO.puts(line)

  defp draw([ins | tail], crt_pos, line, x) do
    {new_line, new_crt_pos, new_x} =
      case ins do
        "noop" ->
          new_crt = crt_pos + 1
          {line <> to_pixel(new_crt, x), new_crt, x}

        "addx " <> str ->
          new_line1 = line <> to_pixel(crt_pos + 1, x)

          new_line2 =
            case String.length(new_line1) do
              40 ->
                IO.puts(new_line1)
                to_pixel(crt_pos + 1, x)

              _ ->
                new_line1 <> to_pixel(crt_pos + 2, x)
            end

          {new_line2, crt_pos + 2, x + String.to_integer(str)}
      end

    case String.length(new_line) do
      40 ->
        IO.puts(new_line)
        draw(tail, new_crt_pos, "", new_x)

      _ ->
        draw(tail, new_crt_pos, new_line, new_x)
    end
  end

  defp to_pixel(c, x) do
    if rem(c, 40) in (x - 1)..(x + 1) do
      "#"
    else
      "."
    end
  end

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 10)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 10)
end
