defmodule Day1 do
  use AOC, day: 1

  def first_and_last(line, pattern) do
    {
      pattern |> Regex.run(line, capture: :all_but_first) |> List.first(), 
      0..String.length(line) |> Enum.reduce("0", fn x, acc -> 
        case pattern |> Regex.run(line, offset: x, capture: :all_but_first) do
          [a] -> a
          nil -> acc
        end
      end)
    }
  end

  def pair_to_number({a,b}, converter) do
    10 * converter.(a) + converter.(b)
  end

  def digit_to_int(d) do
    case Integer.parse(d) do
      {i, _} -> i
    end
  end

  def digit_to_int(d, words) do
    case Integer.parse(d) do
      {i, _} -> i
      _ -> Enum.find_index(words, & &1 == d) + 1
    end
  end
  
  @part1pattern ~r/(\d)/
  def part1(input) do
    input 
    |> String.split("\n")
    |> Enum.map(&Day1.first_and_last(&1, @part1pattern))
    |> Enum.map(fn p -> Day1.pair_to_number(p, &Day1.digit_to_int(&1)) end)
    |> Enum.sum
  end

  @part2words ["one","two","three","four","five","six","seven","eight","nine"]
  @part2pattern ~r/(\d|#{@part2words |> Enum.join("|")})/

  def part2(input) do
    input 
    |> String.split("\n")
    |> Enum.map(&Day1.first_and_last(&1, @part2pattern))
    |> Enum.map(fn p -> Day1.pair_to_number(p, &Day1.digit_to_int(&1, @part2words)) end)
    |> Enum.sum
  end
end
