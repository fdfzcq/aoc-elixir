defmodule Year2015.Day5 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str) do
    str
    |> String.split("\n")
    |> Enum.filter(&is_nice_string1/1)
    |> length()
  end

  defp is_nice_string1(str), do:
    contains_three_vowels(str) &&
    contains_repeated_letters(str) &&
    does_not_contain_invalid_str(str)

  defp contains_three_vowels(str), do:
    String.codepoints(str)
    |> Enum.filter(&is_vowel/1)
    |> length()
    |> Kernel.>=(3)

  defp is_vowel("a"), do: true
  defp is_vowel("e"), do: true
  defp is_vowel("i"), do: true
  defp is_vowel("o"), do: true
  defp is_vowel("u"), do: true
  defp is_vowel(_), do: false

  defp contains_repeated_letters([]), do: false
  defp contains_repeated_letters([c, c|_]), do: true
  defp contains_repeated_letters([_|t]), do: contains_repeated_letters(t)

  defp contains_repeated_letters(str), do:
    contains_repeated_letters(String.codepoints(str))

  defp does_not_contain_invalid_str(str), do:
    String.contains?(str, ["ab", "cd", "pq", "xy"])

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str) do
    str
    |> String.split("\n")
    |> Enum.map(&String.codepoints/1)
    |> Enum.filter(&is_nice_string2/1)
    |> length()
  end

  defp is_nice_string2(str), do:
    has_repeated_pair(str) && has_symetric_trio(str)

  defp has_repeated_pair([a, b|t]) do
    case String.contains?(Enum.join(t), a <> b) do
      true -> true
      false -> has_repeated_pair([b|t])
    end
  end
  defp has_repeated_pair([_]), do: false

  defp has_symetric_trio([]), do: false
  defp has_symetric_trio([a, _, a|_]), do: true
  defp has_symetric_trio([_|t]), do: has_symetric_trio(t)

  # utils

  defp input(), do: Utils.read_input_from_file(2015, 5)
  defp test_input(), do: Utils.read_test_input_from_file(2015, 5)
end
