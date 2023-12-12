defmodule Day12 do
  use AOC, day: 12

  use Memoize

  @linke_break_pattern ~r{\R}
  @comma ","
  @space " "
  @space_between_reps "?"
  @part2_multiplier 5

  @spring_operational "."
  @spring_damaged "#"
  @spring_unknown "?"

  def parse_line(line, multiplier \\ 1) do
    [pattern, counts] = String.split(line, @space, parts: 2)

    springs =
      pattern
      |> List.duplicate(multiplier)
      |> Enum.join(@space_between_reps)
      |> String.codepoints()

    damage_counts =
      counts
      |> List.duplicate(multiplier)
      |> Enum.join(@comma)
      |> String.split(@comma)
      |> Enum.map(&String.to_integer/1)

    {springs, damage_counts}
  end

  defmemo ramaining_combos(springs, counts, in_seq) do
    case {springs, counts, in_seq} do
      {[], [], false} ->
        1

      {[], [0], true} ->
        1

      {[@spring_operational | rest], [0 | counts], true} ->
        ramaining_combos(rest, counts, false)

      {[@spring_operational | rest], counts, false} ->
        ramaining_combos(rest, counts, false)

      {[@spring_damaged | rest], [count_head | count_rst], _} ->
        ramaining_combos(rest, [count_head - 1 | count_rst], true)

      {[@spring_unknown | rest], [count_head | count_rst], inseq} ->
        ramaining_combos(["." | rest], [count_head | count_rst], inseq) +
          ramaining_combos([@spring_damaged | rest], [count_head | count_rst], inseq)

      {[@spring_unknown | rest], [], false} ->
        ramaining_combos(rest, [], false)

      {_, _, _} ->
        0
    end
  end

  def count_combinations(a, b) do
    ramaining_combos(a, b, false)
  end

  def part1(input) do
    input
    |> String.split(@linke_break_pattern)
    |> Enum.map(&parse_line(&1))
    |> Enum.map(fn {s, c} -> count_combinations(s, c) end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split(@linke_break_pattern)
    |> Enum.map(&parse_line(&1, @part2_multiplier))
    |> Enum.map(fn {s, c} -> count_combinations(s, c) end)
    |> Enum.sum()
  end
end
