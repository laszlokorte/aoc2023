defmodule Day3 do
  use AOC, day: 3

  @symbols ~r{[^\d\.]}
  @digits ~r{\d+}
  @gears ~r{\*}
  @spacer "."

  def is_symbol(s) do
    s |> String.match?(@symbols)
  end

  def has_neighbour_symbol(start..e, prev, current, next) do
    len = e - start + 1

    [
      prev |> String.slice(start - 1, len + 2),
      next |> String.slice(start - 1, len + 2),
      current |> String.slice(start - 1, 1),
      current |> String.slice(start + len, 1)
    ]
    |> Enum.any?(&Day3.is_symbol/1)
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

  def ranges_touching?(range_one, two_start..two_end) do
    !Range.disjoint?(range_one, Range.new(two_start - 1, two_end + 1))
  end

  def find_gears(line_chunk) do
    [_, _, current, _, _] = line_chunk

    surrounding_numbers =
      line_chunk
      |> Enum.chunk_every(3, 1, :discard)
      |> Enum.flat_map(&find_numbers/1)

    current
    |> Day3.find_ranges(@gears)
    |> Enum.map(fn g ->
      Enum.filter(surrounding_numbers, fn
        {r, _} -> ranges_touching?(g, r)
        _ -> false
      end)
    end)
    |> Enum.map(fn
      [{_, a}, {_, b}] -> a * b
      _ -> 0
    end)
  end

  def split_pad(str, padding \\ 1) do
    str
    |> String.split(~r{\R}, trim: true)
    |> Enum.concat(List.duplicate(@spacer, padding))
    |> Enum.reverse()
    |> Enum.concat(List.duplicate(@spacer, padding))
    |> Enum.reverse()
    |> Enum.map(fn l -> @spacer <> l <> @spacer end)
  end

  def part(1, input) do
    input
    |> Day3.split_pad(2)
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.flat_map(&Day3.find_numbers/1)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def part(2, input) do
    input
    |> Day3.split_pad(2)
    |> Enum.chunk_every(5, 1, :discard)
    |> Enum.flat_map(&Day3.find_gears/1)
    |> Enum.sum()
  end
end
