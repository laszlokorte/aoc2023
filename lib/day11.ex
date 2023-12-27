defmodule Day11 do
  use AOC, day: 11

  import Enum

  @line_break_pattern ~r{\R}
  @galaxy_symbol "#"
  @emptiness_symbol "."

  def find_galaxies(input) do
    input
    |> String.split(@line_break_pattern, trim: true)
    |> map(&String.codepoints/1)
    |> with_index()
    |> flat_map(fn {lines, y} ->
      lines
      |> with_index()
      |> filter(&(elem(&1, 0) == @galaxy_symbol))
      |> map(fn {_, x} -> {x, y} end)
    end)
    |> into(MapSet.new())
  end

  def all_chars_same({chars, _}, char) do
    chars |> all?(&(&1 == char))
  end

  def find_emptyness(input) do
    lines = input |> String.split(@line_break_pattern, trim: true)

    empty_rows =
      lines
      |> map(&String.codepoints/1)
      |> with_index()
      |> filter(&all_chars_same(&1, @emptiness_symbol))
      |> map(&elem(&1, 1))

    empty_columns =
      lines
      |> map(&String.codepoints/1)
      |> zip()
      |> map(&Tuple.to_list/1)
      |> with_index()
      |> filter(&all_chars_same(&1, @emptiness_symbol))
      |> map(&elem(&1, 1))

    {empty_rows, empty_columns}
  end

  def adjust_spacing(galaxies, {empty_rows, empty_cols}, expansion_factor \\ 1) do
    galaxies
    |> map(fn
      {x, y} ->
        {
          x + (expansion_factor - 1) * count(empty_cols, &(&1 < x)),
          y + (expansion_factor - 1) * count(empty_rows, &(&1 < y))
        }
    end)
  end

  def galaxy_distances_sum(input, expansion_factor \\ 1) do
    galaxies = input |> find_galaxies
    emptiness = input |> find_emptyness

    actual_galaxies = adjust_spacing(galaxies, emptiness, expansion_factor)

    for(a <- actual_galaxies, b <- actual_galaxies, do: {a, b})
    |> map(fn {{xa, ya}, {xb, yb}} -> {xb - xa, ya - yb} end)
    |> map(fn {dx, dy} -> abs(dx) + abs(dy) end)
    |> sum()
    |> Integer.floor_div(2)
  end

  def part(1, input, _env) do
    galaxy_distances_sum(input, 2)
  end

  def part(2, input, _env) do
    galaxy_distances_sum(input, 1_000_000)
  end
end
