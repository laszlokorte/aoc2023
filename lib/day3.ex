defmodule Day3 do
  use AOC, day: 3

  @symbols ~r{[^\d\.]}
  @digits ~r{\d+}
  @gears ~r{\*}

  def is_symbol(s) do
    s |> String.match?(@symbols)
  end

  def has_neighbour_symbol(start..e, prev, current, next) do
    len = e - start + 1

    prev |> String.slice(start - 1, len + 2) |> Day3.is_symbol() ||
      next |> String.slice(start - 1, len + 2) |> Day3.is_symbol() ||
      current |> String.slice(start - 1, 1) |> Day3.is_symbol() ||
      current |> String.slice(start + len, 1) |> Day3.is_symbol()
  end

  def find_ranges(str, pattern) do
    Regex.scan(pattern, str, return: :index)
    |> Enum.map(fn [{s, l}] -> Range.new(s, s + l - 1) end)
  end

  def find_numbers([prev, current, next]) do
    current
    |> Day3.find_ranges(@digits)
    |> Enum.filter(fn range -> has_neighbour_symbol(range, prev, current, next) end)
    |> Enum.map(fn range ->
      {
        range,
        String.slice(current, range) |> String.to_integer()
      }
    end)
  end

  def find_gears([front, prev, current, next, tail]) do
    surrounding_nums =
      Enum.concat([
        find_numbers([front, prev, current]),
        find_numbers([prev, current, next]),
        find_numbers([current, next, tail])
      ])
      |> Enum.map(fn {s..e, num} -> {Range.new(s - 1, e + 1), num} end)

    gears =
      current
      |> Day3.find_ranges(@gears)
      |> Enum.map(fn g ->
        Enum.filter(surrounding_nums, fn {r, num} -> !Range.disjoint?(g, r) end)
      end)
      |> Enum.filter(fn l -> length(l) == 2 end)
      |> Enum.map(fn [{_, a}, {_, b}] -> {a, b} end)
  end

  def split_pad(str, padding \\ 1) do
    str
    |> String.split("\n", trim: true)
    |> Enum.concat(List.duplicate("...", padding))
    |> Enum.reverse()
    |> Enum.concat(List.duplicate("...", padding))
    |> Enum.reverse()
    |> Enum.map(fn l -> "." <> l <> "." end)
  end

  def part1(input) do
    input
    |> Day3.split_pad(2)
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.flat_map(&Day3.find_numbers/1)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> Day3.split_pad(2)
    |> Enum.chunk_every(5, 1, :discard)
    |> Enum.flat_map(&Day3.find_gears/1)
    |> Enum.map(fn {a, b} -> a * b end)
    |> Enum.sum()
  end
end
