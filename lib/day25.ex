defmodule Day25 do
  use AOC, day: 25

  @line_break_pattern ~r{\R}
  @colon ": "
  @spaces ~r{\s+}

  def parse(input) do
    input
    |> String.split(@line_break_pattern, trim: true)
    |> Enum.map(&String.split(&1, @colon, parts: 2, trim: true))
    |> Enum.flat_map(fn
      [from, tos] ->
        tos
        |> String.split(@spaces, trim: true)
        |> Enum.map(&{from, &1})
    end)
  end

  def part(1, input, _env) do
    input
    |> parse
    |> Enum.map(fn {a, b} -> "#{a} -- #{b}" end)
    |> Enum.join("\n")
    |> then(&"\n\ngraph G {\n#{&1}\n}")
    |> then(fn _ -> "solved manually" end)
  end

  def part(2, _input, _env) do
    "does not exist"
  end
end
