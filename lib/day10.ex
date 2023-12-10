defmodule Day10 do
  use AOC, day: 10
  require Integer

  @linke_break_pattern ~r{\R}

  def pipe("|", :down), do: :down
  def pipe("|", :up), do: :up
  def pipe("-", :left), do: :left
  def pipe("-", :right), do: :right
  def pipe("L", :down), do: :right
  def pipe("L", :left), do: :up
  def pipe("J", :down), do: :left
  def pipe("J", :right), do: :up
  def pipe("7", :up), do: :left
  def pipe("7", :right), do: :down
  def pipe("F", :up), do: :right
  def pipe("F", :left), do: :down
  def pipe(_, _), do: nil

  def step(:up, {x,y}), do: {x,y-1}
  def step(:down, {x,y}), do: {x,y+1}
  def step(:left, {x,y}), do: {x-1,y}
  def step(:right, {x,y}), do: {x+1,y}
  def step(nil, {x,y}), do: {x,y}

  def goes_down("|", :down), do: 1
  def goes_down("|", :up), do: -1
  def goes_down("-", :left), do: 0
  def goes_down("-", :right), do: 0
  def goes_down("L", :down), do: 1
  def goes_down("L", :left), do: -1
  def goes_down("J", :down), do: 1
  def goes_down("J", :right), do: -1
  def goes_down("7", :up), do: -1
  def goes_down("7", :right), do: 1
  def goes_down("F", :up), do: -1
  def goes_down("F", :left), do: 1
  def goes_down(_, _), do: nil

  def parse_pipes(input) do
    input
    |> String.split(@linke_break_pattern)
    |> Enum.with_index
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.codepoints
      |> Enum.with_index
      |> Enum.map(fn {pipe, x} -> {{x,y}, pipe} end)
    end)
    |> Enum.into(Map.new)
  end

  def walk_on(pipe_map, pos, dir) do
    next_dir = pipe(pipe_map[pos], dir)

    {step(next_dir, pos), next_dir}
  end

  def longest_loop(pipe_map) do
    {start_pos, "S"} = Enum.find(pipe_map, &(elem(&1, 1) == "S"))

    [:up, :right, :left, :down]
    |> Enum.map(fn dir ->
      first_step = step(dir, start_pos)

      {first_step, dir}
      |> Stream.iterate(fn
        {pos, d} -> walk_on(pipe_map, pos, d)
      end)
      |> Stream.take_while(fn {_, d} -> d != nil end)
      |> Stream.take_while(fn {pos, _} -> pos != start_pos end)
      |> Enum.into(MapSet.new())
      |> MapSet.put({start_pos, dir})
    end)
    |> Enum.max_by(&Enum.count/1)
  end

  def part1(input) do
    pipe_map = parse_pipes(input)

    longest_loop(pipe_map) |> Enum.count |> Integer.floor_div(2)
  end

  def grid_ray(start, {dx, dy}, {maxx, maxy}) do
    start
    |> Stream.iterate(fn
      {x,y} -> {x+dx,y+dy}
    end)
    |> Stream.take_while(fn {x,y} -> x <= maxx && y <= maxy && x >= 0 && y >= 0 end)
  end

  def part2(input) do
    pipe_map = parse_pipes(input)
    used_pipes = longest_loop(pipe_map)
    used_positions = used_pipes |> Enum.map(fn {p, _} -> p end) |> Enum.into(MapSet.new())

    {{maxx, maxy}, _} = pipe_map |> Enum.max_by(fn {{x,y}, _} -> x*y end)

    cols = 0..maxx
    rows = 0..maxy

    rows |> Enum.map(fn y ->
      cols |> Enum.count(fn x ->
        (not MapSet.member?(used_positions, {x,y}))
        && (grid_ray({x,y}, {1, 0}, {maxx, maxy})
                |> Enum.filter(&MapSet.member?(used_positions, &1))
                |> Enum.map(&(pipe_map[&1]))
                |> Enum.reduce(0, fn
                  "F", c -> c+1
                  "7", c -> c+1
                  "|", c -> c+1
                  "S", c -> c+1
                  _ , c -> c
                end)) |> Integer.is_odd
      end)
    end) |> Enum.sum
  end
end
