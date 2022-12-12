defmodule Utils do
  def read_input_from_file(file_name) do
    {:ok, content} = File.read(File.cwd!() <> "/lib/2021/" <> file_name)
    content
  end

  def read_input_from_file(year, day) do
    {:ok, content} =
      File.read(
        File.cwd!() <>
          "/lib/" <> Integer.to_string(year) <> "/day" <> Integer.to_string(day) <> ".txt"
      )

    content
  end

  def read_test_input_from_file(year, day) do
    {:ok, content} =
      File.read(
        File.cwd!() <>
          "/lib/" <> Integer.to_string(year) <> "/day" <> Integer.to_string(day) <> "_test.txt"
      )

    content
  end

  def to_coordinates_map(str, fun) do
    str
    |> String.split("\n")
    |> Enum.reduce({0, %{}}, fn line, {y, m} ->
      {_, new_m} =
        Enum.reduce(String.codepoints(line), {0, m}, fn c, {x, mm} ->
          {x + 1, Map.put(mm, {x, y}, fun.(c))}
        end)

      {y + 1, new_m}
    end)
    |> elem(1)
  end
end
