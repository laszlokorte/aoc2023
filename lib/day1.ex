defmodule Day1 do
  use AOC, day: 1

  @line_break_pattern ~r{\R}
  @part1pattern ~r/(?=(\d))/
  @part2words ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
  @part2pattern ~r/(?=(\d|#{@part2words |> Enum.join("|")}))/

  def first_and_last(a) do
    [Enum.at(a, 0), Enum.at(a, -1)]
  end

  def find_matches(line, pattern) do
    pattern
    |> Regex.scan(line, capture: :all_but_first)
    |> List.flatten()
  end

  def places_to_number(places) do
    places
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {d, i}, acc -> acc + 10 ** i * d end)
  end

  def single_digit_to_int(d, fallback_words) do
    case Integer.parse(d) do
      {i, _} -> i
      _ -> Enum.find_index(fallback_words, &(&1 == d)) + 1
    end
  end

  def all_digits_to_int(digits, fallback_words \\ []) do
    Enum.map(digits, &single_digit_to_int(&1, fallback_words))
  end

  def part(1, input) do
    input
    |> String.split(@line_break_pattern, trim: true)
    |> Enum.map(&Day1.find_matches(&1, @part1pattern))
    |> Enum.map(&Day1.first_and_last/1)
    |> Enum.map(&Day1.all_digits_to_int(&1))
    |> Enum.map(&Day1.places_to_number/1)
    |> Enum.sum()
  end

  def part(2, input) do
    input
    |> String.split(@line_break_pattern, trim: true)
    |> Enum.map(&Day1.find_matches(&1, @part2pattern))
    |> Enum.map(&Day1.first_and_last/1)
    |> Enum.map(&Day1.all_digits_to_int(&1, @part2words))
    |> Enum.map(&Day1.places_to_number/1)
    |> Enum.sum()
  end
end
