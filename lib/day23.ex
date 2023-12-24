defmodule Day23 do
  use AOC, day: 23

  @line_break_pattern ~r{\R}
  @dirs [
    {:v, 0, +1},
    {:^, 0, -1},
    {:>, +1, 0},
    {:<, -1, 0}
  ]

  def parse_field("."), do: :free
  def parse_field(">"), do: :>
  def parse_field("<"), do: :<
  def parse_field("v"), do: :v
  def parse_field("^"), do: :^
  def parse_field("#"), do: nil

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
          |> Enum.map(fn
            {s, x} -> {{x, y}, parse_field(s)}
          end)
          |> Enum.filter(fn
            {_, d} -> d != nil
          end)
      end)
      |> Enum.into(Map.new())

    start = Map.keys(fields) |> Enum.min_by(&elem(&1, 1))
    goal = Map.keys(fields) |> Enum.max_by(&elem(&1, 1))

    {fields, start, goal}
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
      {cr,
       dfs(
         [{0, {cr, MapSet.new()}}],
         fn
           {cost, {{cx, cy}, preds}} ->
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
               {cost, pos} -> {cost, {pos, MapSet.put(preds, {cx, cy})}}
             end)
             |> then(&if Enum.count(&1) > 1 and cost > 0, do: [], else: &1)
         end,
         fn
           {cost, {current_pos, _}}, results ->
             if MapSet.member?(crossings, current_pos) do
               [{cost, current_pos} | results]
             else
               results
             end
         end,
         []
       )
       |> Enum.filter(&(elem(&1, 0) != 0))}
    end
    |> Enum.into(Map.new())
  end

  def dfs([], _child_gen, _collect, results), do: results

  def dfs([{current_cost, current_pos} | rest_stack], child_gen, collect, results) do
    child_gen.({current_cost, current_pos})
    |> Enum.reduce(rest_stack, &[&1 | &2])
    |> dfs(child_gen, collect, collect.({current_cost, current_pos}, results))
  end

  def find_longest(edges, start, goal) do
    dfs(
      [{0, {start, MapSet.new()}}],
      fn
        {cost, {{cx, cy}, preds}} ->
          edges
          |> Map.get({cx, cy}, [])
          |> Enum.map(fn
            {new_cost, new_pos} -> {cost + new_cost, new_pos}
          end)
          |> Enum.filter(&(not MapSet.member?(preds, elem(&1, 1))))
          |> Enum.map(fn
            {cost, pos} -> {cost, {pos, MapSet.put(preds, {cx, cy})}}
          end)
      end,
      fn
        {cost, {^goal, _}}, longest -> max(cost, longest)
        _, longest -> longest
      end,
      0
    )
  end

  def part(1, input) do
    {fields, start, goal} = input |> parse

    fields
    |> Enum.into(Map.new())
    |> reduce_graph(start, goal)
    |> find_longest(start, goal)
  end

  def part(2, input) do
    {fields, start, goal} = input |> parse

    fields
    |> Enum.map(fn {pos, _} -> {pos, :free} end)
    |> Enum.into(Map.new())
    |> reduce_graph(start, goal)
    |> find_longest(start, goal)
  end
end
