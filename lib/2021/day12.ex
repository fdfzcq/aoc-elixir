defmodule Day12 do
  def test(), do: process(to_graph(test_input()))
  def run(), do: process(to_graph(input()))

  defp process(graph),
    do:
      graph
      |> process("start", ["start"])
      |> IO.inspect()
      |> length()

  defp process(_, "end", path), do: [path]

  defp process(graph, vertex, path) do
    graph
    |> Map.get(vertex)
    |> Enum.reduce(
      [],
      fn v, acc ->
        case can_visit(path, v) do
          false -> acc
          true -> [[v | path] | acc]
        end
      end
    )
    |> Enum.reduce(
      [],
      fn p, acc ->
        acc ++ process(graph, hd(p), p)
      end
    )
  end

  defp can_visit(_, "start"), do: false

  defp can_visit(path, v) do
    case lowercase?(v) do
      false ->
        true

      true ->
        case has_visited_small_cave_twice(path) && Enum.member?(path, v) do
          true -> false
          _ -> true
        end
    end
  end

  defp has_visited_small_cave_twice(path) do
    path
    |> Enum.filter(&lowercase?/1)
    |> Enum.sort()
    |> repeated?()
  end

  defp repeated?([]), do: false
  defp repeated?([v, v | _]), do: true
  defp repeated?([_ | t]), do: repeated?(t)

  ## utils

  defp lowercase?(c), do: String.upcase(c) != c

  defp to_graph(str), do: str |> String.split("\n") |> Enum.reduce(%{}, &to_graph(&1, &2))

  defp to_graph(line_str, graph) do
    [end1, end2] = String.split(line_str, "-")
    add_edge(graph, end1, end2)
  end

  defp add_edge(graph, end1, end2) do
    graph
    |> Map.put(end1, [end2 | Map.get(graph, end1, [])])
    |> Map.put(end2, [end1 | Map.get(graph, end2, [])])
  end

  defp test_input, do: Utils.read_input_from_file("day12_test.txt")
  defp input, do: Utils.read_input_from_file("day12.txt")
end
