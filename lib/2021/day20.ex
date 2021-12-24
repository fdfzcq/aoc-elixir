defmodule Year2021.Day20 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(input), do: process(input, 2)

  defp process(str, steps) do
    [enhancement_algo_str, input_image_str] = String.split(str, "\n\n")

    input_image_str
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce(
      %{},
      fn {line, y}, acc ->
        String.codepoints(line)
        |> Enum.with_index()
        |> Enum.reduce(
          acc,
          fn {c, x}, new_acc ->
            Map.put(new_acc, {x, y}, c)
          end
        )
      end
    )
    |> enhance_image(enhancement_algo_str, steps)
    |> Map.values()
    |> Enum.count(fn c -> c == "#" end)
  end

  defp enhance_image(image, _, 0), do: image

  defp enhance_image(image, enhance_algo, steps),
    do:
      image
      |> IO.inspect()
      |> Enum.reduce(%{}, &enhance_image(&1, &2, image, enhance_algo, steps))
      |> enhance_image(enhance_algo, steps - 1)

  defp enhance_image({{x, y}, _}, visited, image, enhance_algo, steps),
    do:
      neighbours({x, y})
      |> Enum.filter(fn coor -> !Map.has_key?(visited, coor) end)
      |> Enum.reduce(visited, &enhance_pixel(&1, &2, image, enhance_algo, steps))

  defp neighbours({x, y}),
    do: [
      {x - 1, y - 1},
      {x, y - 1},
      {x + 1, y - 1},
      {x - 1, y},
      {x, y},
      {x + 1, y},
      {x - 1, y + 1},
      {x, y + 1},
      {x + 1, y + 1}
    ]

  defp enhance_pixel({x, y}, visited, image, enhance_algo, steps) do
    i = to_output_index({x, y}, image, steps)
    Map.put(visited, {x, y}, String.at(enhance_algo, i))
  end

  defp to_output_index({x, y}, image, steps) do
    neighbours({x, y})
    |> Enum.map(fn coor ->
      case Map.get(image, coor, default_pixel(steps)) do
        "." -> 0
        _ -> 1
      end
    end)
    |> Integer.undigits(2)
  end

  defp default_pixel(steps) when rem(steps, 2) == 1, do: "#"
  defp default_pixel(_), do: "."

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str), do: process(str, 50)

  # utils

  defp input(), do: Utils.read_input_from_file(2021, 20)
  defp test_input(), do: Utils.read_test_input_from_file(2021, 20)
end
