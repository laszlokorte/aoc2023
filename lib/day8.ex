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
    |> Map.new()
  end

  def parse_input(input) do
    [direction_line, network_lines] = String.split(input, @blank_line_pattern, parts: 2)

    {String.codepoints(direction_line), parse_network(network_lines)}
  end

  def walk(network, @dir_left, current) do
    network[current] |> elem(0)
  end

  def walk(network, @dir_right, current) do
    network[current] |> elem(1)
  end

  def find_start_nodes(network, start_suffix) do
    Map.keys(network)
    |> Enum.filter(&String.ends_with?(&1, start_suffix))
    |> MapSet.new()
  end

  defmodule WalkStep do
    defstruct [:current, :seen, :step_count]

    def new(start) do
      %WalkStep{
        current: start,
        seen: MapSet.new(),
        step_count: 0
      }
    end

    def cycle_length(%WalkStep{seen: seen, step_count: step_count}) do
      Enum.count(seen) - step_count
    end

    def walk_with_counter(
          %WalkStep{current: current, seen: seen, step_count: steps},
          network,
          {dir, dir_index}
        ) do
      %WalkStep{
        current: Day8.walk(network, dir, current),
        seen: MapSet.put(seen, {dir_index, current}),
        step_count: min(dir_index, steps) + 1
      }
    end

    def contains_cycle?(%WalkStep{current: c, seen: s, step_count: n}) do
      MapSet.member?(s, {n, c})
    end
  end

  def cycle_length(network, directions, start) do
    directions
    |> Stream.with_index()
    |> Stream.cycle()
    |> Stream.scan(WalkStep.new(start), &WalkStep.walk_with_counter(&2, network, &1))
    |> Enum.find(&WalkStep.contains_cycle?/1)
    |> WalkStep.cycle_length()
  end

  def steps_to_goal(network, directions, start, goal_suffix) do
    repeated_directions = directions |> Stream.cycle()

    steps =
      repeated_directions
      |> Stream.scan(start, &walk(network, &1, &2))
      |> Stream.take_while(&(not String.ends_with?(&1, goal_suffix)))
      |> Enum.count()

    steps + 1
  end

  def lcm(a, b)
  def lcm(0, 0), do: 0
  def lcm(a, b), do: abs(Kernel.div(a * b, gcd(a, b)))

  def gcd(x, 0), do: x
  def gcd(x, y), do: gcd(y, rem(x, y))

  def part1(input) do
    {directions, network} = parse_input(input)

    steps_to_goal(network, directions, @single_start, @goal_suffix)
  end

  def part2(input) do
    {directions, network} = parse_input(input)

    find_start_nodes(network, @start_suffix)
    |> Enum.map(&cycle_length(network, directions, &1))
    |> Enum.reduce(1, &lcm/2)
  end
end
