defmodule Day10 do
  use AOC, day: 10
  require Integer

  @linke_break_pattern ~r{\R}
  @biased_vertical_pipes ["F", "J", "|", "-"]
  @ray_direction {1, 1}

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

  def step(:up, {x, y}), do: {x, y - 1}
  def step(:down, {x, y}), do: {x, y + 1}
  def step(:left, {x, y}), do: {x - 1, y}
  def step(:right, {x, y}), do: {x + 1, y}
  def step(nil, {x, y}), do: {x, y}

  def bending_piece(:up, :up), do: "|"
  def bending_piece(:up, :left), do: "7"
  def bending_piece(:up, :right), do: "F"
  def bending_piece(:down, :down), do: "|"
  def bending_piece(:down, :left), do: "J"
  def bending_piece(:down, :right), do: "L"
  def bending_piece(:left, :left), do: "-"
  def bending_piece(:left, :up), do: "L"
  def bending_piece(:left, :down), do: "F"
  def bending_piece(:right, :right), do: "-"
  def bending_piece(:right, :down), do: "7"
  def bending_piece(:right, :up), do: "J"

  def parse_pipes(input) do
    input
    |> String.split(@linke_break_pattern)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.map(fn {pipe, x} -> {{x, y}, pipe} end)
    end)
    |> Enum.into(Map.new())
  end

  def walk_on(pipe_map, {pos, dir}) do
    next_dir = pipe(pipe_map[pos], dir)

    {step(next_dir, pos), next_dir}
  end

  def find_start(pipe_map) do
    pipe_map
    |> Enum.find(&(elem(&1, 1) == "S"))
    |> elem(0)
  end

  def follow_pipe_from(pipe_map, start_pos, dir) do
    {step(dir, start_pos), dir}
    |> Stream.iterate(&walk_on(pipe_map, &1))
    |> Stream.take_while(fn {_, d} -> d != nil end)
    |> Stream.take_while(fn {pos, _} -> pos != start_pos end)
    |> Enum.concat([{start_pos, dir}])
  end

  def longest_loop(pipe_map) do
    start_pos = find_start(pipe_map)

    [:up, :right, :left, :down]
    |> Enum.map(&follow_pipe_from(pipe_map, start_pos, &1))
    |> Enum.max_by(&Enum.count/1)
  end

  def fillin_start(pipe_map, loop) do
    {_, first_direction} = Enum.at(loop, 0)
    {_, last_direction} = Enum.at(loop, -2)

    start_piece = bending_piece(first_direction, last_direction)

    Map.put(pipe_map, find_start(pipe_map), start_piece)
  end

  def is_in_bounds({x, y}, {maxx, maxy}) do
    x in 0..maxx && y in 0..maxy
  end

  def ray_step({x, y}, {dx, dy}) do
    {x + dx, y + dy}
  end

  def cast_grid_ray(start, direction, bounds) do
    start
    |> Stream.iterate(&ray_step(&1, direction))
    |> Stream.take_while(&is_in_bounds(&1, bounds))
  end

  def grid_size(pipe_map) do
    pipe_map
    |> Enum.max_by(fn {{x, y}, _} -> x * y end)
    |> elem(0)
  end

  def ray_count_hits(pipe_map, used_positions, ray) do
    ray
    |> Enum.filter(&MapSet.member?(used_positions, &1))
    |> Enum.map(&pipe_map[&1])
    |> Enum.count(&(&1 in @biased_vertical_pipes))
  end

  def part1(input) do
    parse_pipes(input)
    |> longest_loop
    |> Enum.count()
    |> Integer.floor_div(2)
  end

  def part2(input) do
    pipe_map = parse_pipes(input)
    loop = longest_loop(pipe_map)
    pipe_map = fillin_start(pipe_map, loop)

    used_positions =
      loop
      |> Enum.map(fn {p, _} -> p end)
      |> Enum.into(MapSet.new())

    {maxx, maxy} = size = grid_size(pipe_map)

    test_candiates =
      for x <- 0..maxx, y <- 0..maxy, not MapSet.member?(used_positions, {x, y}), do: {x, y}

    test_candiates
    |> Enum.count(fn {x, y} ->
      cast_grid_ray({x, y}, @ray_direction, size)
      |> (&ray_count_hits(pipe_map, used_positions, &1)).()
      |> Integer.is_odd()
    end)
  end
end
