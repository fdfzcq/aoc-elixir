defmodule Year2021.Day14 do
  def run1(n), do: process(parse_input(input()), n)
  def test1(n), do: process(parse_input(test_input()), n)

  defp start_string(), do: test_input() |> String.codepoints()

  defp process({str, instructions}, n) do
    instructions
    |> Enum.reduce(%{}, &calc_instruction(&1, &2, instructions, n)})
  end

  defp calc_instruction({pair, char}, map, instructions, steps) do
    step(pair, instructions, [], map, steps)
  end

  defp step([c1, c2|t], instructions, acc, map, steps) do
    case Map.get(instructions, c1 <> c2) do
      nil -> step([c2 | t], instructions, [c1|acc], steps)
      c -> step([c2 | t], instructions, [c, c1|acc])
    end
  end

  ## utils

  defp parse_input(str) do
    [init_str, instructions_str] = String.split(str, "\n\n")
    instructions = instructions_str
      |> String.split("\n")
      |> Enum.map(
        fn ins_str ->
          [pair, char] = String.split(ins_str, " -> ")
          {pair, char}
        end)
      |> Map.new()
    {String.codepoints(init_str), instructions}
  end

  defp input(), do: Utils.read_input_from_file(2021, 14)
  defp test_input(), do: Utils.read_test_input_from_file(2021, 14)
end
