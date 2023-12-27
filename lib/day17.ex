defmodule Day17 do
  use AOC, day: 17

  import Enum

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
      |> String.split(@line_break_pattern, trim: true)
      |> with_index()
      |> flat_map(fn
        {line, y} ->
          line
          |> String.codepoints()
          |> with_index()
          |> map(fn
            {char, x} -> {{x, y}, String.to_integer(char)}
          end)
      end)
      |> into(Map.new())

    goal = grid |> Map.keys() |> max_by(fn {x, y} -> x * y end)

    {grid, goal}
  end

  def bfs_next_children(grid, {min_steps, max_steps}, {loss, {dir, counter}, current_pos}, seen) do
    alias Stream, as: S

    @dirs
    |> S.filter(fn
      # dont allow walking backwards
      d -> opposite(d) != dir
    end)
    |> S.filter(fn
      # dont allow the same direction too often in a row
      ^dir -> counter < max_steps
      # dont allow switching deirections too often
      _ -> counter >= min_steps
    end)
    |> S.map(fn
      # increment number of same direction
      ^dir -> {dir, step(current_pos, dir), counter + 1}
      # reset same direction counter to 1
      d -> {d, step(current_pos, d), 1}
    end)
    |> S.map(fn
      # determine step cost 
      {dir, new_pos, counter} -> {dir, new_pos, counter, Map.get(grid, new_pos)}
    end)
    |> S.filter(fn
      # discard nil costs, ie. steps outside the grid
      {_, _, _, nil} -> false
      _ -> true
    end)
    |> S.map(fn
      # calculate new total cost
      {dir, new_pos, new_counter, add_loss} -> {loss + add_loss, {dir, new_counter}, new_pos}
    end)
    |> S.filter(fn
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
    if :gb_sets.is_empty(queue) do
      results
    else
      {current, new_queue} = :gb_sets.take_smallest(queue)

      children = bfs_next_children(grid, step_constraints, current, seen)

      new_seen =
        reduce(children, seen, fn
          {new_loss, {dir, new_counter}, new_pos}, old_seen ->
            Map.put(old_seen, {dir, new_counter, new_pos}, new_loss)
        end)

      new_queue =
        reduce(children, new_queue, fn child, queue ->
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

  def find_shortest(grid, {min_steps, max_steps}, start) do
    queue = :gb_sets.new()
    queue = :gb_sets.insert({0, {nil, min_steps}, start}, queue)

    grid
    |> bfs({min_steps, max_steps}, queue, Map.new(), [])
    |> min()
  end

  def part(1, input, _env) do
    input
    |> parse
    |> find_shortest({@min_straight_moves_part1, @max_straight_moves_part1}, @start_pos)
  end

  def part(2, input, _env) do
    input
    |> parse
    |> find_shortest({@min_straight_moves_part2, @max_straight_moves_part2}, @start_pos)
  end
end
