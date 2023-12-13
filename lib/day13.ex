defmodule Day13 do
  use AOC, day: 13

  @blank_line ~r{\R\R}
  @linke_break_pattern ~r{\R}

  def parse_cell("#"), do: 1
  def parse_cell("."), do: 0

  def parse_grid(input) do
    input
    |> String.split(@linke_break_pattern, trim: true)
    |> Enum.map(&String.codepoints/1)
    |> Enum.map(fn line -> Enum.map(line, &parse_cell/1) end)
  end

  def transpose(grid) do
    Enum.zip(grid) |> Enum.map(&Tuple.to_list/1)
  end

  def count_differences(a, b) do
    Enum.zip_with(a, b, fn x, y ->
      Enum.zip_with(x, y, fn p, q -> if p == q, do: 0, else: 1 end) |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def is_mirrored_at(list, index, smudges) do
    count = Enum.count(list)
    right_size = count - index
    left_size = index
    min_size = min(left_size, right_size)
    left = Enum.slice(list, index - min_size, min_size)
    right = Enum.slice(list, index, min_size)

    count_differences(Enum.reverse(left), right) == smudges
  end

  def find_mirror_axis(grid, smudges) do
    vertical = 1..(Enum.count(grid) - 1) |> Enum.find(&is_mirrored_at(grid, &1, smudges))

    horizontal =
      1..(Enum.count(transpose(grid)) - 1)
      |> Enum.find(&is_mirrored_at(transpose(grid), &1, smudges))

    if vertical do
      {:y, vertical}
    else
      {:x, horizontal}
    end
  end

  def part1(input) do
    input
    |> String.split(@blank_line, trim: true)
    |> Enum.map(&parse_grid/1)
    |> Enum.map(&find_mirror_axis(&1, 0))
    |> Enum.map(fn
      {:x, max} -> max
      {:y, max} -> 100 * max
    end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split(@blank_line, trim: true)
    |> Enum.map(&parse_grid/1)
    |> Enum.map(&find_mirror_axis(&1, 1))
    |> Enum.map(fn
      {:x, max} -> max
      {:y, max} -> 100 * max
    end)
    |> Enum.sum()
  end
end
