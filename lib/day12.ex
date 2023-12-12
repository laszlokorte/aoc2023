defmodule Day12 do
  use AOC, day: 12

  @linke_break_pattern ~r{\R}
  @comma ","
  @space " "
  @space_between_reps "?"
  @part2_multiplier 5

  defmodule IterativeSolutuon do
    @spring_state_damaged "#"
    @spring_state_operational "."
    @spring_state_unknown "?"

    def apply_assignment(counted_springs, counted_unknowns, assignment_index) do
      choosen_unknown =
        counted_unknowns
        |> Enum.filter(fn {_, binary} -> Bitwise.band(binary, assignment_index) == binary end)
        |> Enum.map(&elem(&1, 0))
        |> Enum.into(MapSet.new())

      counted_springs
      |> Enum.map(fn
        {@spring_state_damaged, _} -> true
        {@spring_state_operational, _} -> false
        {@spring_state_unknown, i} -> MapSet.member?(choosen_unknown, i)
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

    def count_combinations(springs, spring_counts) do
      counted_springs = springs |> Enum.with_index()

      counted_unknowns =
        counted_springs
        |> Enum.filter(fn {p, _} -> p == @spring_state_unknown end)
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
  end

  defmodule RecursiveSolution do
    use Memoize

    @spring_state_damaged "#"
    @spring_state_operational "."
    @spring_state_unknown "?"

    defmemo(count_combinations([], []), do: 1)
    defmemo(count_combinations([], [_ | _]), do: 0)

    defmemo count_combinations(pattern, []) do
      if Enum.member?(pattern, @spring_state_damaged) do
        0
      else
        1
      end
    end

    defmemo count_combinations(pattern, nums) do
      count_combinations_skip(pattern, nums) + count_combinations_take(pattern, nums)
    end

    def count_combinations_skip([@spring_state_operational | rest], nums), do: count_combinations(rest, nums)
    def count_combinations_skip([@spring_state_unknown | rest], nums), do: count_combinations(rest, nums)
    def count_combinations_skip(_, _), do: 0

    def count_combinations_take([@spring_state_operational, _], _), do: 0

    def count_combinations_take(pattern, nums) do
      [_ | rest_pattern] = pattern
      [headn | rest_nums] = nums

      if still_valid(pattern, headn) do
        count_combinations(Enum.slice(rest_pattern, headn..Enum.count(rest_pattern)), rest_nums)
      else
        0
      end
    end

    def still_valid(pattern, headn) do
      headn <= Enum.count(pattern) and
        not Enum.member?(Enum.slice(pattern, 0..(headn - 1)), @spring_state_operational) and
        (headn == Enum.count(pattern) or Enum.at(pattern, headn) != @spring_state_damaged)
    end
  end

  def parse_line(line, multiplier \\ 1) do
    [pattern, counts] = String.split(line, @space, parts: 2)

    counted_springs =
      pattern
      |> List.duplicate(multiplier)
      |> Enum.join(@space_between_reps)
      |> String.codepoints()

    spring_counts =
      counts
      |> List.duplicate(multiplier)
      |> Enum.join(@comma)
      |> String.split(@comma)
      |> Enum.map(&String.to_integer/1)

    {counted_springs, spring_counts}
  end

  def part1(input) do
    input
    |> String.split(@linke_break_pattern)
    |> Enum.map(&parse_line(&1))
    |> Enum.map(fn {s, c} -> IterativeSolutuon.count_combinations(s, c) end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split(@linke_break_pattern)
    |> Enum.map(&parse_line(&1, @part2_multiplier))
    |> Enum.map(fn {s, c} -> RecursiveSolution.count_combinations(s, c) end)
    |> Enum.sum()
  end
end
