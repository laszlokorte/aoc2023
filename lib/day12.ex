defmodule Day12 do
  use AOC, day: 12

  @linke_break_pattern ~r{\R}
  @comma ","
  @space " "
  @damaged "#"
  @operational "."
  @unknown "?"

  def apply_assignment(counted_springs, counted_unknowns, assignment_index) do
    choosen_unknown =
      counted_unknowns
      |> Enum.filter(fn {_, binary} -> Bitwise.band(binary, assignment_index) == binary end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.into(MapSet.new())

    counted_springs
    |> Enum.map(fn
      {@damaged, _} -> true
      {@operational, _} -> false
      {@unknown, i} -> MapSet.member?(choosen_unknown, i)
    end)
  end

  def chunk_damaged(false, acc) do
    {:cont, acc, 0}
  end

  def chunk_damaged(true, acc) do
    {:cont, acc + 1}
  end

  def finish_chunk(0), do: {:cont, []}
  def finish_chunk(acc), do: {:cont, acc, []}

  def count_consecutive(springs) do
    springs
    |> Enum.chunk_while(0, &chunk_damaged/2, &finish_chunk/1)
    |> Enum.filter(&(&1 != 0))
  end

  def count_combinations(line) do
    [pattern, counts] = String.split(line, @space, parts: 2)

    counted_springs =
      pattern
      |> String.codepoints()
      |> Enum.with_index()

    spring_counts =
      counts
      |> String.split(@comma)
      |> Enum.map(&String.to_integer/1)

    counted_unknowns =
      counted_springs
      |> Enum.filter(fn {p, _} -> p == @unknown end)
      |> Enum.with_index()
      |> Enum.map(fn {{_, pos}, number} -> {pos, Bitwise.bsl(1, number)} end)

    total_unknowns = Enum.count(counted_unknowns)
    combinations = Bitwise.bsl(1, total_unknowns)

    1..combinations
    |> Enum.map(&apply_assignment(counted_springs, counted_unknowns, &1))
    |> Enum.map(&count_consecutive/1)
    |> Enum.filter(&(&1 == spring_counts))
    |> Enum.count()
  end

  def part1(input) do
    input
    |> String.split(@linke_break_pattern)
    |> Enum.map(&count_combinations/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
  end
end
