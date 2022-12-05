defmodule Year2022.Day5 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str) do
    [str1, str2] = String.split(str, "\n\n")
    crates = parse_crates(str1)

    str2
    |> to_instructions()
    |> move_crates(crates)
    |> to_message()
  end

  defp to_message(crates),
    do:
      1..map_size(crates)
      |> Enum.reduce(
        "",
        fn i, acc -> acc <> hd(Map.get(crates, i)) end
      )

  defp to_instructions(str),
    do:
      str
      |> String.split("\n")
      |> Enum.map(fn s ->
        [_, n, f, t] = s |> String.split(~r/move | from | to /)
        {String.to_integer(n), String.to_integer(f), String.to_integer(t)}
      end)

  defp move_crates(instructions, crates),
    do:
      instructions
      |> Enum.reduce(
        crates,
        fn {number, from, to}, cr ->
          old_from = Map.get(cr, from)
          old_to = Map.get(cr, to)
          {new_from, new_to} = move(old_from, old_to, number)

          cr
          |> Map.put(from, new_from)
          |> Map.put(to, new_to)
        end
      )

  defp move(from, to, 0), do: {from, to}
  defp move([hd | from], to, n), do: move(from, [hd | to], n - 1)

  defp parse_crates(str) do
    lines = String.split(str, "\n")
    parse_crates(length(lines) - 1, lines)
  end

  defp parse_crates(n, lines), do: parse_crates(n - 1, lines, init_crates(Enum.at(lines, n)))

  defp parse_crates(-1, _lines, crates), do: crates

  defp parse_crates(n, lines, crates),
    do: parse_crates(n - 1, lines, to_crates(crates, Enum.at(lines, n)))

  defp init_crates(str),
    do:
      str
      |> String.codepoints()
      |> Enum.filter(fn c -> c != " " end)
      |> Enum.map(fn c -> {String.to_integer(c), []} end)
      |> Map.new()

  defp to_crates(crates, str),
    do:
      str
      |> String.codepoints()
      |> Enum.reduce(
        {0, crates},
        fn c, {n, cr} ->
          case {rem(n, 4), c} do
            {1, c} when c != " " and c != nil ->
              {n + 1, Map.put(cr, div(n, 4) + 1, [c | Map.get(cr, div(n, 4) + 1)])}

            _ ->
              {n + 1, cr}
          end
        end
      )
      |> elem(1)

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str) do
    [str1, str2] = String.split(str, "\n\n")
    crates = parse_crates(str1)

    str2
    |> to_instructions()
    |> move_crates2(crates)
    |> to_message()
  end

  defp move_crates2(instructions, crates),
    do:
      instructions
      |> Enum.reduce(
        crates,
        fn {number, from, to}, cr ->
          old_from = Map.get(cr, from)
          old_to = Map.get(cr, to)
          {new_from, new_to} = move2(old_from, old_to, number)

          cr
          |> Map.put(from, new_from)
          |> Map.put(to, new_to)
        end
      )

  defp move2(from, to, number) do
    {move, new_from} = Enum.split(from, number)
    {new_from, move ++ to}
  end

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 5)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 5)
end
