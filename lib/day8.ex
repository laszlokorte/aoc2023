defmodule Day8 do
  use AOC, day: 8

  @linke_break_pattern ~r{\R}
  @blank_line_pattern ~r{\R\R}
  @network_pattern ~r{(?<current>\w+) = \((?<left>\w+), (?<right>\w+)\)}
  @single_start "AAA"
  @start_suffix "A"
  @goal_suffix "Z"
  @dir_left "L"
  @dir_right "R"

  def parse_network_line(line) do
    [c, l, r] = Regex.run(@network_pattern, line, capture: [:current, :left, :right])
    {c, {l, r}}
  end

  def parse_network(lines) do
    lines 
    |> String.split(@linke_break_pattern)
    |> Enum.map(&parse_network_line/1)
    |> Map.new
  end

  def walk(network, @dir_left, current) do
    network[current] |> elem(0)
  end

  def walk(network, @dir_right, current) do
    network[current] |> elem(1)
  end

  def walk_with_counter(network, {dir, dir_index}, {current, seen, _}) do
    {
      walk(network, dir, current),
      MapSet.put(seen, {dir_index, current}),
      dir_index + 1
    }
  end

  def find_start_nodes(network, start_suffix) do
    Map.keys(network) 
    |> Enum.filter(&String.ends_with?(&1, start_suffix))
    |> MapSet.new()
  end

  def contains_cycle?({current, seen, dir_index}) do
    MapSet.member?(seen, {dir_index, current})
  end

  def cycle_length(network, directions, start) do
    [{_, seen, dir_index}] = 
    directions 
    |> Stream.with_index 
    |> Stream.cycle
    |> Stream.scan({start, MapSet.new(), 0}, &walk_with_counter(network, &1, &2))
    |> Stream.filter(&contains_cycle?/1)
    |> Enum.take(1)

    Enum.count(seen) - dir_index
  end

  def steps_to_goal(network, directions, start, goal_suffix) do
    repeated_directions = directions |> Stream.cycle   

    steps = repeated_directions
    |> Stream.scan(start, &walk(network, &1, &2))
    |> Stream.take_while(&(not String.ends_with?(&1, goal_suffix)))
    |> Enum.count

    steps + 1
  end

  def lcm(a, b)
  def lcm(0, 0), do: 0
  def lcm(a, b), do: abs(Kernel.div(a * b, gcd(a, b)))

  def gcd(x, 0), do: x
  def gcd(x, y), do: gcd(y, rem(x,y))

  def part1(input) do
    [direction_line, network_lines] = input |> String.split(@blank_line_pattern, parts: 2)
    
    directions = direction_line |> String.codepoints
    network = network_lines |> parse_network

    steps_to_goal(network, directions, @single_start, @goal_suffix)
  end

  def part2(input) do
    [direction_line, network_lines] = input |> String.split(@blank_line_pattern, parts: 2)
    
    directions = direction_line |> String.codepoints
    network = network_lines |> parse_network
    all_starts = find_start_nodes(network, @start_suffix)

    all_cycles = all_starts |> Enum.map(&cycle_length(network, directions, &1))
    all_steps_to_goal = all_starts |> Enum.map(&steps_to_goal(network, directions, &1, @goal_suffix))
    common_cycle = all_cycles |> Enum.reduce(1, &lcm/2)

    [first_cycle|_] = all_cycles
    [first_offset|_] = all_steps_to_goal

    (first_cycle - first_offset) + common_cycle
  end
end
