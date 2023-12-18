defmodule Day18 do
  use AOC, day: 18
  require Integer

  @line_break_pattern ~r{\R}
  @line_pattern ~r"(?<dir>R|D|U|L) (?<dist>\d+) \(#(?<col>[0-9abcdef]{6})\)"

  def parse_line_simple(line) do
    [dir, dist] = Regex.run(@line_pattern, line, capture: [:dir, :dist])

    {case dir do
       "D" -> :down
       "R" -> :right
       "L" -> :left
       "U" -> :up
     end, String.to_integer(dist)}
  end

  def parse_line_hex(line) do
    [<<dist::binary-size(5), dir::binary-size(1)>>] =
      Regex.run(@line_pattern, line, capture: [:col])

    {case dir do
       "0" -> :right
       "1" -> :down
       "2" -> :left
       "3" -> :up
     end, String.to_integer(dist, 16)}
  end

  def parse(input, line_parsers) do
    input |> String.split(@line_break_pattern) |> Enum.map(line_parsers)
  end

  def enclosed_area(steps) do
    steps
    |> Enum.reduce({{0, 0}, 1}, fn
      # increase the area when walking down, and add each step to the area as well
      {:down, dist}, {{x, y}, area} -> {{x, y + dist}, area + x * dist + dist}
      # decrese the area when walking back up
      {:up, dist}, {{x, y}, area} -> {{x, y - dist}, area - x * dist}
      # the perimeter is included in the area so we need to include the steps into the area when walking right
      {:right, dist}, {{x, y}, area} -> {{x + dist, y}, area + dist}
      # and not subtract them again
      {:left, dist}, {{x, y}, area} -> {{x - dist, y}, area}
    end)
    |> elem(1)
  end

  def part(1, input) do
    input
    |> parse(&parse_line_simple/1)
    |> enclosed_area
  end

  def part(2, input) do
    input
    |> parse(&parse_line_hex/1)
    |> enclosed_area
  end
end
