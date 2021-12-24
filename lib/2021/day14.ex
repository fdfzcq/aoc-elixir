defmodule Year2021.Day14 do
  def run1(n) do
    {str, ins} = parse_input(input())

    res =
      0..(n - 1)
      |> Enum.reduce(str, fn _, s -> step1(s, ins, []) end)
      |> Enum.reduce(%{}, fn c, m -> Map.put(m, c, Map.get(m, c, 0) + 1) end)

    IO.inspect(Enum.max_by(res, fn {_, v} -> v end))
    IO.inspect(Enum.min_by(res, fn {_, v} -> v end))
  end

  defp step1([c1, c2 | t], instructions, acc) do
    case Map.get(instructions, c1 <> c2) do
      nil -> step1([c2 | t], instructions, [c1 | acc])
      c -> step1([c2 | t], instructions, [c, c1 | acc])
    end
  end

  defp step1(_, _, acc), do: Enum.reverse(acc)

  ## part 2

  def run(n), do: process(parse_input(input()), n)
  def test(n), do: process(parse_input(test_input()), n)

  defp process({str, instructions}, n) do
    {score, _} = step(str, instructions, %{}, n, score_of(str))
    score
  end

  defp step(_, _, acc, 0, score), do: {score, acc}

  defp step([c1, c2 | t], instructions, acc, steps, score) do
    case Map.get(instructions, c1 <> c2) do
      nil ->
        step([c2 | t], instructions, acc, steps, score + c_score(c1))

      c ->
        {score1, new_acc1} =
          case Map.get(acc, {c1, c, steps - 1}) do
            nil -> step([c1, c], instructions, acc, steps - 1, score_of([c, c1]))
            value -> {value, acc}
          end

        {score2, new_acc2} =
          case Map.get(new_acc1, {c, c2, steps - 1}) do
            nil -> step([c, c2], instructions, new_acc1, steps - 1, score_of([c, c2]))
            value -> {value, new_acc1}
          end

        c_score = score1 + score2 - c_score(c)
        new_acc = Map.put(new_acc2, {c1, c2, steps}, c_score)
        step([c2 | t], instructions, new_acc, steps, score + c_score - c_score(c2) - c_score(c1))
    end
  end

  defp step(_, _, acc, _, score), do: {score, acc}

  defp score_of(str), do: number_of(str, "F") - number_of(str, "B")

  defp number_of(str, char), do: Enum.count(str, fn c -> c == char end)

  defp c_score("F"), do: 1
  defp c_score("B"), do: -1
  defp c_score(_), do: 0

  ## utils

  defp parse_input(str) do
    [init_str, instructions_str] = String.split(str, "\n\n")

    instructions =
      instructions_str
      |> String.split("\n")
      |> Enum.map(fn ins_str ->
        [pair, char] = String.split(ins_str, " -> ")
        {pair, char}
      end)
      |> Map.new()

    {String.codepoints(init_str), instructions}
  end

  defp input(), do: Utils.read_input_from_file(2021, 14)
  defp test_input(), do: Utils.read_test_input_from_file(2021, 14)
end
