defmodule Day13 do
  use AOC, day: 13

  @blank_line ~r{\R\R}
  @line_break_pattern ~r{\R}

  def parse_cell("#"), do: 1
  def parse_cell("."), do: 0

  def parse_grid(input) do
    grid =
      input
      |> String.split(@line_break_pattern, trim: true)
      |> Enum.map(&String.codepoints/1)
      |> Enum.map(fn line -> Enum.map(line, &parse_cell/1) end)

    [
      {:x, transpose(grid)},
      {:y, grid}
    ]
  end

  def transpose(grid) do
    Enum.zip(grid) |> Enum.map(&Tuple.to_list/1)
  end

  def count_differences(side_a, side_b) do
    Enum.zip_with(side_a, side_b, fn line_a, line_b ->
      Enum.zip(line_a, line_b) |> Enum.count(&(elem(&1, 0) != elem(&1, 1)))
    end)
    |> Enum.sum()
  end

  def is_mirrored_at(list, index, smudges) do
    min_size = min(index, Enum.count(list) - index)
    left = Enum.slice(list, index - min_size, min_size)
    right = Enum.slice(list, index, min_size)

    count_differences(Enum.reverse(left), right) == smudges
  end

  def find_mirror_axis(grid, smudges) do
    1..(Enum.count(grid) - 1) |> Enum.find(&is_mirrored_at(grid, &1, smudges))
  end

  def solve(input, smudges) do
    input
    |> String.split(@blank_line, trim: true)
    |> Enum.flat_map(&parse_grid/1)
    |> Enum.map(&{elem(&1, 0), find_mirror_axis(elem(&1, 1), smudges)})
    |> Enum.map(fn
      {_, nil} -> 0
      {:x, max} -> max
      {:y, max} -> 100 * max
    end)
    |> Enum.sum()
  end

  def part(1, input) do
    solve(input, 0)
  end

  def part(2, input) do
    solve(input, 1)
  end
end
