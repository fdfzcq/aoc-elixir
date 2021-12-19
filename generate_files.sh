#!/bin/sh

year=$1
day=$2

file="lib/$year/day$day"

cat << EOF > ${file}.ex
defmodule Year$year.Day$day do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str) do
    
  end

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str) do
    
  end

  # utils

  defp input(), do: Utils.read_input_from_file($year, $day)
  defp test_input(), do: Utils.read_test_input_from_file($year, $day)
end
EOF

touch ${file}.txt
touch ${file}_test.txt