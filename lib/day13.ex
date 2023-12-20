defmodule Day13 do
  use AOC, day: 13

  import Enum

  @blank_line ~r{\R\R}
  @line_break_pattern ~r{\R}

  def parse_cell("#"), do: 1
  def parse_cell("."), do: 0

  def parse_grid(input) do
    input
    |> String.split(@line_break_pattern, trim: true)
    |> map(&String.codepoints/1)
    |> map(fn line -> map(line, &parse_cell/1) end)
    |> then(
      &[
        {:x, transpose(&1)},
        {:y, &1}
      ]
    )
  end

  def transpose(grid) do
    zip(grid) |> map(&Tuple.to_list/1)
  end

  def count_differences(side_a, side_b) do
    zip_with(side_a, side_b, fn line_a, line_b ->
      zip(line_a, line_b) |> count(&(elem(&1, 0) != elem(&1, 1)))
    end)
    |> sum()
  end

  def is_mirrored_at(list, index, smudges) do
    min_size = Kernel.min(index, count(list) - index)
    left = slice(list, index - min_size, min_size)
    right = slice(list, index, min_size)

    count_differences(reverse(left), right) == smudges
  end

  def find_mirror_axis(grid, smudges) do
    1..(count(grid) - 1) |> find(&is_mirrored_at(grid, &1, smudges))
  end

  def solve(input, smudges) do
    input
    |> String.split(@blank_line, trim: true)
    |> flat_map(&parse_grid/1)
    |> map(&{elem(&1, 0), find_mirror_axis(elem(&1, 1), smudges)})
    |> map(fn
      {_, nil} -> 0
      {:x, max} -> max
      {:y, max} -> 100 * max
    end)
    |> sum()
  end

  def part(1, input) do
    solve(input, 0)
  end

  def part(2, input) do
    solve(input, 1)
  end
end
