defmodule Day8 do
    def test1, do: part1(test_input())

    def run1, do: part1(input())

    def part1(input_str) do
        input_str
        |> String.split("\n")
        |> Enum.map(&find_simple_digits/1)
        |> List.flatten()
        |> length()
    end

    defp find_simple_digits(line_str) do
        line_str
        |> String.split(" | ")
        |> Enum.at(1)
        |> String.split(" ")
        |> Enum.filter(fn str -> is_simple_digit(String.length(str)) end)
    end

    defp is_simple_digit(2), do: true
    defp is_simple_digit(3), do: true
    defp is_simple_digit(4), do: true
    defp is_simple_digit(7), do: true
    defp is_simple_digit(_), do: false

    ## part 2

    def test2, do: part2(test_input())
    def run2, do: part2(input())

    def part2(input_str) do
        input_str
        |> String.split("\n")
        |> Enum.map(&decode_digits/1)
        |> Enum.sum()
    end

    defp decode_digits(line_str) do
        [input_str, output_str] = String.split(line_str, " | ")
        decoder_map = find_decoder(String.split(input_str, " "))
        {output, _} = output_str
            |> String.split(" ")
            |> Enum.map(&decode_digits(&1, decoder_map))
            |> Enum.join()
            |> Integer.parse()
        output
    end

    defp find_decoder(input_list) do
        input_list
        |> Enum.map(&String.codepoints/1)
        |> Enum.sort(&(length(&1) <= length(&2)))
        |> decoder
    end

    defp decoder(input_list) when is_list(input_list) do
        m = input_list
        |> Enum.reduce(%{}, &update_map(&1, &2))
        |> Enum.map(&decoder/1)
        |> Map.new()
        finalize_decoder(m, input_list)
    end
    defp decoder({char, occr}) do
        case occr do
            6 -> {char, "b"}
            4 -> {char, "e"}
            9 -> {char, "f"}
            7 -> {char, ["d", "g"]}
            8 -> {char, ["a", "c"]}
        end
    end

    defp finalize_decoder(map, inputs) do
        [v1, v2] = Enum.find(inputs, fn i -> length(i) == 2 end)
        map =
            case Map.get(map, v1) do
                list when is_list(list) -> Map.put(map, v1, "c")
                _ -> Map.put(map, v2, "c")
            end
        c = inputs
        |> Enum.find(fn i -> length(i) == 4 end)
        |> Enum.find(fn c -> is_list(Map.get(map, c)) end)
        map
        |> Map.put(c, "d")
        |> Enum.map(
            fn {k, v} ->
                case v do
                    ["d", "g"] -> {k, "g"}
                    ["a", "c"] -> {k, "a"}
                    _ -> {k, v}
                end
            end
        )
        |> Map.new()
    end

    defp update_map(charlist, map) do
        Enum.reduce(charlist, map,
            fn c, m ->
                Map.put(m, c, Map.get(m, c, 0) + 1)
            end)
    end

    defp decode_digits(str, decoder_map) do
        charlist = String.codepoints(str)
        case length(charlist) do
            2 -> 1
            4 -> 4
            3 -> 7
            7 -> 8
            _ ->
                decoded = Enum.map(charlist, fn c -> Map.get(decoder_map, c) end)
                case ["a", "b", "c", "d", "e", "f", "g"] -- decoded do
                    ["d"] -> 0
                    ["c"] -> 6
                    ["e"] -> 9
                    ["b", "f"] -> 2
                    ["b", "e"] -> 3
                    ["c", "e"] -> 5
                end
        end
    end

    defp test_input, do: Utils.read_input_from_file("day8_test.txt")
    defp input, do: Utils.read_input_from_file("day8.txt")
end