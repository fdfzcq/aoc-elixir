defmodule Year2015.Day4 do
  def part1(), do: run1(input())
  def test1(), do: run1(test_input())

  def part2(), do: run2(input(), 117_946)

  defp run1(str), do: run1(str, 0)

  defp run1(str, n) do
    case :crypto.hash(:md5, str <> Integer.to_string(n)) |> Base.encode16(case: :lower) do
      "00000" <> _ -> n
      _ -> run1(str, n + 1)
    end
  end

  defp run2(str, n) do
    case :crypto.hash(:md5, str <> Integer.to_string(n)) |> Base.encode16(case: :lower) do
      "000000" <> _ -> n
      _ -> run2(str, n + 1)
    end
  end

  defp input(), do: Utils.read_input_from_file(2015, 4)
  defp test_input(), do: Utils.read_test_input_from_file(2015, 4)
end
