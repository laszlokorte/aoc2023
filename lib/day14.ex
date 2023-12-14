defmodule Day14 do
  use AOC, day: 14

  @linke_break_pattern ~r{\R}

  def parse(input) do
    lines = input |> String.split(@linke_break_pattern, trim: true)

    elements =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        line
        |> String.codepoints()
        |> Enum.with_index()
        |> Enum.map(fn
          {"O", x} -> {:round, x, y}
          {"#", x} -> {:cube, x, y}
          {".", x} -> {:empty, x, y}
        end)
      end)
      |> Enum.filter(fn
        {:round, _, _} -> true
        {:cube, _, _} -> true
        {:empty, _, _} -> false
      end)

    {Enum.count(lines), elements}
  end

  def tilt_column({_, stones}, total_height) do
    stones
    |> Enum.scan({:wall, -1}, fn
      {:round, _}, {_, prevy} -> {:round, prevy + 1}
      {:cube, y}, _ -> {:cube, y}
    end)
    |> Enum.map(fn
      {:round, x} -> total_height - x
      _ -> 0
    end)
  end

  def part1(input) do
    {total_height, elements} = parse(input)

    elements
    |> Enum.sort_by(&elem(&1, 2))
    |> Enum.group_by(&elem(&1, 1), &{elem(&1, 0), elem(&1, 2)})
    |> Enum.flat_map(&tilt_column(&1, total_height))
    |> Enum.sum()
  end

  def part2(input) do
    input
  end
end
