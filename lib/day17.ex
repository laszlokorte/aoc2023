defmodule Day17 do
  use AOC, day: 17

  @line_break_pattern ~r{\R}
  @start_pos {0, 0}
  @min_straight_moves_part1 1
  @max_straight_moves_part1 3
  @min_straight_moves_part2 4
  @max_straight_moves_part2 10
  @dirs [
    {0, +1},
    {0, -1},
    {+1, 0},
    {-1, 0}
  ]

  def step({x, y}, {dx, dy}), do: {x + dx, y + dy}
  def opposite({dx, dy}), do: {-dx, -dy}

  def parse(input) do
    grid =
      input
      |> String.split(@line_break_pattern)
      |> Enum.with_index()
      |> Enum.flat_map(fn
        {line, y} ->
          line
          |> String.codepoints()
          |> Enum.with_index()
          |> Enum.map(fn
            {char, x} -> {{x, y}, String.to_integer(char)}
          end)
      end)
      |> Enum.into(Map.new())

    goal = grid |> Map.keys() |> Enum.max_by(fn {x, y} -> x * y end)

    {grid, goal}
  end

  def bfs_next_children(grid, {min_steps, max_steps}, {loss, {dir, counter}, current_pos}, seen) do
    @dirs
    |> Stream.filter(fn
      # dont allow walking backwards
      d -> opposite(d) != dir
    end)
    |> Stream.filter(fn
      # dont allow the same direction too often in a row
      ^dir -> counter < max_steps
      # dont allow switching deirections too often
      _ -> counter >= min_steps
    end)
    |> Stream.map(fn
      # increment number of same direction
      ^dir -> {dir, step(current_pos, dir), counter + 1}
      # reset same direction counter to 1
      d -> {d, step(current_pos, d), 1}
    end)
    |> Stream.map(fn
      # determine step cost 
      {dir, new_pos, counter} -> {dir, new_pos, counter, Map.get(grid, new_pos)}
    end)
    |> Stream.filter(fn
      # discard nil costs, ie. steps outside the grid
      {_, _, _, nil} -> false
      _ -> true
    end)
    |> Stream.map(fn
      # calculate new total cost
      {dir, new_pos, new_counter, add_loss} -> {loss + add_loss, {dir, new_counter}, new_pos}
    end)
    |> Enum.filter(fn
      # discard all steps onto positions for which a lower cost has already been found
      {new_loss, {dir, new_counter}, new_pos} ->
        case Map.get(seen, {dir, new_counter, new_pos}) do
          nil -> true
          seen_loss -> seen_loss > new_loss
        end
    end)
  end

  # collect the final lost value if the goal has been reached an an acceptable number of steps
  def bfs_collect_current_result({min_steps, _}, {loss, {_, step_counter}, goal}, goal, results)
      when step_counter >= min_steps do
    [loss | results]
  end

  # do not collect current lost value otherwise
  def bfs_collect_current_result(_, _, _, results) do
    results
  end

  def bfs({grid, goal}, step_constraints, queue, seen, results) do
    case :gb_sets.is_empty(queue) do
      true ->
        results

      false ->
        {current, new_queue} = :gb_sets.take_smallest(queue)

        children = bfs_next_children(grid, step_constraints, current, seen)

        new_seen =
          Enum.reduce(children, seen, fn
            {new_loss, {dir, new_counter}, new_pos}, old_seen ->
              Map.put(old_seen, {dir, new_counter, new_pos}, new_loss)
          end)

        new_queue =
          Enum.reduce(children, new_queue, fn child, queue ->
            :gb_sets.insert(child, queue)
          end)

        bfs(
          {grid, goal},
          step_constraints,
          new_queue,
          new_seen,
          bfs_collect_current_result(step_constraints, current, goal, results)
        )
    end
  end

  def part1(input) do
    queue = :gb_sets.new()
    queue = :gb_sets.insert({0, {nil, @min_straight_moves_part1}, @start_pos}, queue)

    input
    |> parse
    |> bfs({@min_straight_moves_part1, @max_straight_moves_part1}, queue, Map.new(), [])
    |> Enum.min()
  end

  def part2(input) do
    queue = :gb_sets.new()
    queue = :gb_sets.insert({0, {nil, @min_straight_moves_part2}, @start_pos}, queue)

    input
    |> parse
    |> bfs({@min_straight_moves_part2, @max_straight_moves_part2}, queue, Map.new(), [])
    |> Enum.min()
  end
end
