defmodule Day1 do
  use AOC, day: 1
  import Enum

  @line_break_pattern ~r{\R}
  @part1pattern ~r/(?=(\d))/
  @part2words ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
  @part2pattern ~r/(?=(\d|#{@part2words |> join("|")}))/

  def first_and_last(a) do
    [at(a, 0), at(a, -1)]
  end

  def find_matches(line, pattern) do
    pattern
    |> Regex.scan(line, capture: :all_but_first)
    |> List.flatten()
  end

  def places_to_number(places) do
    places
    |> reverse()
    |> with_index()
    |> reduce(0, fn {d, i}, acc -> acc + 10 ** i * d end)
  end

  def single_digit_to_int(d, fallback_words) do
    case Integer.parse(d) do
      {i, _} -> i
      _ -> find_index(fallback_words, &(&1 == d)) + 1
    end
  end

  def all_digits_to_int(digits, fallback_words \\ []) do
    map(digits, &single_digit_to_int(&1, fallback_words))
  end

  def part(1, input) do
    input
    |> String.split(@line_break_pattern, trim: true)
    |> map(&Day1.find_matches(&1, @part1pattern))
    |> map(&Day1.first_and_last/1)
    |> map(&Day1.all_digits_to_int(&1))
    |> map(&Day1.places_to_number/1)
    |> sum()
  end

  def part(2, input) do
    input
    |> String.split(@line_break_pattern, trim: true)
    |> map(&Day1.find_matches(&1, @part2pattern))
    |> map(&Day1.first_and_last/1)
    |> map(&Day1.all_digits_to_int(&1, @part2words))
    |> map(&Day1.places_to_number/1)
    |> sum()
  end
end
