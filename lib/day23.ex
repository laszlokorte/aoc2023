defmodule Day23 do
  use AOC, day: 23

  @line_break_pattern ~r{\R}
  @wall "#"
  @dirs [
    {:v, 0, +1},
    {:^, 0, -1},
    {:>, +1, 0},
    {:<, -1, 0}
  ]

  def parse(input) do
    fields =
      input
      |> String.split(@line_break_pattern)
      |> Enum.with_index()
      |> Enum.flat_map(fn
        {line, y} ->
          line
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.filter(fn
            {@wall, _} -> false
            _ -> true
          end)
          |> Enum.map(fn
            {".", x} -> {{x, y}, :free}
            {">", x} -> {{x, y}, :>}
            {"<", x} -> {{x, y}, :<}
            {"v", x} -> {{x, y}, :v}
            {"^", x} -> {{x, y}, :^}
          end)
      end)
      |> Enum.into(Map.new())

    start = Map.keys(fields) |> Enum.min_by(&elem(&1, 1))
    goal = Map.keys(fields) |> Enum.max_by(&elem(&1, 1))
    {fields, start, goal}
  end

  def dijkstra_children(fields, {cost, {cx, cy}, preds}) do
    field_type = Map.get(fields, {cx, cy})

    @dirs
    |> Enum.filter(fn
      {^field_type, _, _} -> true
      _ -> field_type == :free
    end)
    |> Enum.map(fn
      {_, dx, dy} -> {cost + 1, {cx + dx, cy + dy}}
    end)
    |> Enum.filter(&Map.has_key?(fields, elem(&1, 1)))
    |> Enum.filter(&(not MapSet.member?(preds, elem(&1, 1))))
    |> Enum.map(fn
      {c, pos} -> {c, pos, MapSet.put(preds, pos)}
    end)
  end

  def dijkstra(queue, child_gen, collector, goal, results, seen \\ MapSet.new()) do
    if :gb_sets.is_empty(queue) do
      results
    else
      {current, new_queue} = :gb_sets.take_largest(queue)

      children = child_gen.(current)

      new_seen =
        Enum.reduce(children, seen, fn
          {cost, new_pos, _}, old_seen ->
            Map.put(old_seen, new_pos, cost)
        end)

      children
      |> Enum.reduce(new_queue, &:gb_sets.insert(&1, &2))
      |> dijkstra(
        child_gen,
        collector,
        goal,
        collector.(current, goal, results),
        new_seen
      )
    end
  end

  def find_longest(fields, start, goal) do
    queue = :gb_sets.new()
    queue = :gb_sets.insert({0, start, MapSet.new()}, queue)

    queue
    |> dijkstra(
      &dijkstra_children(fields, &1),
      fn
        {loss, goal, _preds}, goal, results -> [loss | results]
        _, _, results -> results
      end,
      goal,
      []
    )
    |> Enum.max()
  end

  def find_crossings(fields) do
    fields
    |> Map.keys()
    |> Enum.filter(fn
      {x, y} ->
        Enum.count(@dirs, fn
          {_, dx, dy} -> Map.has_key?(fields, {x + dx, y + dy})
        end) > 2
    end)
    |> Enum.into(MapSet.new())
  end

  def reduce_graph(fields, start, goal) do
    crossings =
      fields
      |> find_crossings
      |> MapSet.put(start)
      |> MapSet.put(goal)

    for cr <- crossings do
      queue = :gb_sets.new()
      queue = :gb_sets.insert({0, cr}, queue)
      {cr, bfs(queue, fields, crossings, MapSet.new([cr]), [])}
    end
    |> Enum.into(Map.new())
  end

  def bfs_children(fields, {cost, {cx, cy}}, seen) do
    @dirs
    |> Enum.map(fn
      {_, dx, dy} -> {cost + 1, {cx + dx, cy + dy}}
    end)
    |> Enum.filter(&Map.has_key?(fields, elem(&1, 1)))
    |> Enum.filter(&(not MapSet.member?(seen, elem(&1, 1))))
  end

  def bfs(queue, fields, goals, seen, results) do
    if :gb_sets.is_empty(queue) do
      results
      |> Enum.filter(fn
        {0, _} -> false
        _ -> true
      end)
    else
      {{current_cost, current_pos}, new_queue} = :gb_sets.take_smallest(queue)

      children =
        bfs_children(fields, {current_cost, current_pos}, seen)
        |> then(&if Enum.count(&1) > 1 and current_cost > 0, do: [], else: &1)

      new_seen =
        Enum.reduce(children, seen, fn
          {_, new_pos}, old_seen ->
            MapSet.put(old_seen, new_pos)
        end)

      new_queue =
        Enum.reduce(children, new_queue, fn child, queue ->
          :gb_sets.insert(child, queue)
        end)

      new_result =
        if MapSet.member?(goals, current_pos) do
          [{current_cost, current_pos} | results]
        else
          results
        end

      bfs(new_queue, fields, goals, new_seen, new_result)
    end
  end

  def part(1, input) do
    {fields, start, goal} = input |> parse

    find_longest(fields, start, goal)
  end

  def part(2, input) do
    {fields, start, goal} = input |> parse

    reduced = reduce_graph(fields, start, goal)

    queue = :gb_sets.new()
    queue = :gb_sets.insert({0, start, MapSet.new()}, queue)

    queue
    |> dijkstra(
      fn
        {cost, current, preds} ->
          Map.get(reduced, current, [])
          |> Enum.filter(&(not MapSet.member?(preds, elem(&1, 1))))
          |> Enum.map(fn
            {c, pos} -> {c, pos, MapSet.put(preds, pos)}
          end)
          |> Enum.map(fn
            {dist, pos, preds} -> {dist + cost, pos, preds}
          end)
      end,
      fn
        {loss, goal, _}, goal, results -> [loss | results]
        _, _, results -> results
      end,
      goal,
      []
    )
    |> Enum.max()
  end
end
