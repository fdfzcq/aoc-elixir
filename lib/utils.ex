defmodule Utils do
    def read_input_from_file(file_name) do
        {:ok, content} = File.read(File.cwd! <> "/lib/2021/" <> file_name)
        content
    end

    def read_input_from_file(year, day) do
        {:ok, content} = File.read(File.cwd! <> "/lib/" <> Integer.to_string(year) <> "/day" <> Integer.to_string(day) <> ".txt")
        content
    end

    def read_test_input_from_file(year, day) do
        {:ok, content} = File.read(File.cwd! <> "/lib/" <> Integer.to_string(year) <> "/day" <> Integer.to_string(day) <> "_test.txt")
        content
    end
end