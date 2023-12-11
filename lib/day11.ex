defmodule Day11 do
  use AOC, day: 11

  @linke_break_pattern ~r{\R}
  @galaxy_symbol "#"
  @emptiness_symbol "."

  def find_galaxies(input) do
    input
    |> String.split(@linke_break_pattern)
    |> Enum.map(&String.codepoints/1)
    |> Enum.with_index()
    |> Enum.flat_map(fn {lines, y} ->
      lines
      |> Enum.with_index()
      |> Enum.filter(&(elem(&1, 0) == @galaxy_symbol))
      |> Enum.map(fn {_, x} -> {x, y} end)
    end)
    |> Enum.into(MapSet.new())
  end

  def all_chars_same({chars, _}, char) do
    chars |> Enum.all?(&(&1 == @emptiness_symbol))
  end

  def find_emptyness(input) do
    lines = input |> String.split(@linke_break_pattern)

    empty_rows =
      lines
      |> Enum.map(&String.codepoints/1)
      |> Enum.with_index()
      |> Enum.filter(&all_chars_same(&1, @emptiness_symbol))
      |> Enum.map(&elem(&1, 1))

    empty_columns =
      lines
      |> Enum.map(&String.codepoints/1)
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.with_index()
      |> Enum.filter(&all_chars_same(&1, @emptiness_symbol))
      |> Enum.map(&elem(&1, 1))

    {empty_rows, empty_columns}
  end

  def adjust_spacing(galaxies, {empty_rows, empty_cols}, expansion_factor \\ 1) do
    galaxies
    |> Enum.map(fn
      {x, y} ->
        {
          x + (expansion_factor - 1) * Enum.count(empty_cols, &(&1 < x)),
          y + (expansion_factor - 1) * Enum.count(empty_rows, &(&1 < y))
        }
    end)
  end

  def galaxy_distances_sum(input, expansion_factor \\ 1) do
    galaxies = input |> find_galaxies
    emptiness = input |> find_emptyness

    actual_galaxies = adjust_spacing(galaxies, emptiness, expansion_factor)

    galaxy_pairs = for a <- actual_galaxies, b <- actual_galaxies, do: {a, b}

    galaxy_pairs
    |> Enum.map(fn {{xa, ya}, {xb, yb}} -> {xb - xa, ya - yb} end)
    |> Enum.map(fn {dx, dy} -> abs(dx) + abs(dy) end)
    |> Enum.sum()
    |> Integer.floor_div(2)
  end

  def part1(input) do
    galaxy_distances_sum(input, 2)
  end

  def part2(input) do
    galaxy_distances_sum(input, 1_000_000)
  end
end
