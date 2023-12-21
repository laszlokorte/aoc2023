defmodule Day21 do
  use AOC, day: 21

  @line_break_pattern ~r{\R}
  @dirs [{1, 0}, {-1, 0}, {0, -1}, {0, 1}]
  @wall "#"
  @start "S"
  @step_count 64
  @large_step_count 26_501_365
  @polydegree 2

  def parse(input) do
    input
    |> String.split(@line_break_pattern)
    |> Enum.with_index()
    |> Enum.flat_map(fn
      {line, y} ->
        line
        |> String.codepoints()
        |> Enum.with_index()
        |> Enum.filter(fn
          {c, _} -> c != @wall
        end)
        |> Enum.map(fn {c, x} -> {x, y, c} end)
    end)
    |> Enum.map_reduce({nil, 0, 0}, fn
      {x, y, c}, {start, w, h} ->
        {{x, y}, {if(c == @start, do: {x, y}, else: start), max(x, w), max(y, h)}}
    end)
    |> then(fn {places, {start, w, h}} ->
      {
        MapSet.new(places),
        start,
        {w + 1, h + 1}
      }
    end)
  end

  def mod({x, y}, {xx, yy}) do
    {rem(rem(x + xx, xx) + xx, xx), rem(rem(y + yy, yy) + yy, yy)}
  end

  def lcm(a, b)
  def lcm(0, 0), do: 0
  def lcm(a, b), do: abs(Kernel.div(a * b, gcd(a, b)))

  def gcd(x, 0), do: x
  def gcd(x, y), do: gcd(y, rem(x, y))

  def extrapolate([head | _] = seq, stepsize, depth \\ 0) do
    import Enum

    if all?(seq, &(&1 == head)) do
      head * choices(stepsize, depth)
    else
      seq
      |> chunk_every(2, 1, :discard)
      |> map(fn [a, b] -> b - a end)
      |> extrapolate(stepsize, depth + 1)
      |> then(&(&1 + head * choices(stepsize, depth)))
    end
  end

  def choices(_, 0), do: 1
  def choices(over, over), do: 1
  def choices(over, 1), do: over

  def choices(over, under) do
    div(over, fac(under)) * choices(over - 1, under - 1)
  end

  def fac(1), do: 1
  def fac(a), do: a * fac(a - 1)

  def propagate_wave(start, places, mod, steps) do
    Stream.iterate(MapSet.new([start]), fn
      positions ->
        @dirs
        |> Enum.flat_map(fn
          {dx, dy} ->
            positions
            |> Enum.map(fn {x, y} -> {x + dx, y + dy} end)
            |> Enum.filter(&MapSet.member?(places, mod(&1, mod)))
        end)
        |> Enum.into(MapSet.new())
    end)
    |> Enum.at(steps)
    |> Enum.count()
  end

  def part(1, input) do
    {places, start, mod} = input |> parse

    propagate_wave(start, places, mod, @step_count)
  end

  def part(2, input) do
    {places, start, mod = {wmod, hmod}} = input |> parse

    period = lcm(wmod, hmod)

    for i <- 0..@polydegree do
      propagate_wave(start, places, mod, rem(@large_step_count, period) + i * period)
    end
    |> extrapolate(div(@large_step_count, period))
  end
end
