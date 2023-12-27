defmodule AOC do
  defprotocol Day do
    @spec number(t) :: String.t()
    def number(_)
    @spec input(t, Integer.t(), String.t()) :: String.t()
    def input(_, part, env)
  end

  defmacro __using__(opts) do
    padded_day = opts |> Keyword.get(:day) |> Integer.to_string() |> String.pad_leading(2, "0")

    quote do
      defstruct []

      defimpl AOC.Day do
        @external_resource unquote("inputs/day-#{padded_day}-test-1.txt")
        @external_resource unquote("inputs/day-#{padded_day}-test-2.txt")
        @external_resource unquote("inputs/day-#{padded_day}-prod.txt")

        @inputdata Map.new([
                     {{1, :test},
                      File.read(unquote("inputs/day-#{padded_day}-test-1.txt"))
                      |> elem(1)},
                     {{2, :test},
                      File.read(unquote("inputs/day-#{padded_day}-test-2.txt"))
                      |> elem(1)},
                     {{1, :prod},
                      File.read(unquote("inputs/day-#{padded_day}-prod.txt"))
                      |> elem(1)},
                     {{2, :prod},
                      File.read(unquote("inputs/day-#{padded_day}-prod.txt"))
                      |> elem(1)}
                   ])

        def number(_) do
          unquote(Keyword.get(opts, :day))
        end

        def input(_, part, env) do
          Map.get(@inputdata, {part, env})
        end
      end
    end
  end
end
