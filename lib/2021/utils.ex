defmodule Utils do
    def read_input_from_file(file_name) do
        {:ok, content} = File.read(File.cwd! <> "/lib/" <> file_name)
        content
    end
end