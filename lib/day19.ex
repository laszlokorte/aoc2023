defmodule Day19 do
  use AOC, day: 19

  @empty_line_pattern ~r{\R\R}
  @workflow_pattern ~r"(?<name>\w+)\{(?<rules>[^}]+)\}"
  @rule_pattern ~r"(?:(?<field>\w+)(?<comp>[<>])(?<val>\d+):)?(?<target>\w+)"
  @part_pattern ~r"\{(?<values>[^}]+)\}"
  @comma ","
  @eq "="
  @workflow_start "in"
  @accepted "A"
  @rejected "R"
  @max_part_range [x: 1..4000, m: 1..4000, a: 1..4000, s: 1..4000]

  def parse_category("x"), do: :x
  def parse_category("m"), do: :m
  def parse_category("a"), do: :a
  def parse_category("s"), do: :s

  def parse_rule(rule) do
    @rule_pattern
    |> Regex.run(rule, capture: [:field, :comp, :val, :target])
    |> case do
      ["", "", "", default] -> {:default, default}
      [field, "<", val, default] -> {{parse_category(field), :<, String.to_integer(val)}, default}
      [field, ">", val, default] -> {{parse_category(field), :>, String.to_integer(val)}, default}
    end
  end

  def parse_workflow([name, rules]) do
    {name, rules |> String.split(@comma) |> Enum.map(&parse_rule/1)}
  end

  def parse_parts([part]) do
    part
    |> String.split(@comma)
    |> Enum.map(&String.split(&1, @eq, parts: 2))
    |> Enum.map(fn
      [p, v] -> {parse_category(p), String.to_integer(v)}
    end)
  end

  def parse(input) do
    [workflows, parts] = input |> String.split(@empty_line_pattern, parts: 2)

    workflows =
      @workflow_pattern
      |> Regex.scan(workflows, capture: [:name, :rules])
      |> Enum.map(&parse_workflow/1)
      |> Enum.into(Map.new())

    parts =
      @part_pattern
      |> Regex.scan(parts, capture: [:values])
      |> Enum.map(&parse_parts/1)

    {workflows, parts}
  end

  def process_single_part_step(part, workflow) do
    workflow
    |> Enum.find_value(fn
      {:default, r} -> r
      {{field, :>, comp}, r} -> if part[field] > comp, do: r
      {{field, :<, comp}, r} -> if part[field] < comp, do: r
      _ -> nil
    end)
  end

  def process_single_part(part, workflows) do
    Stream.iterate(@workflow_start, fn
      @rejected -> @rejected
      @accepted -> @accepted
      wf -> process_single_part_step(part, Map.get(workflows, wf))
    end)
    |> Enum.find(fn
      @rejected -> true
      @accepted -> true
      _ -> false
    end)
  end

  def sum_part_categories(part) do
    Enum.sum(for {_, v} <- part, do: v)
  end

  def split_range_part(range_part, parts_field, comp_op, comp_val) do
    min..max = Keyword.get(range_part, parts_field)

    case {comp_op, max < comp_val, min > comp_val} do
      {:<, true, false} ->
        {range_part, nil}

      {:<, false, true} ->
        {nil, range_part}

      {:<, _, _} ->
        {
          Keyword.put(range_part, parts_field, min..(comp_val - 1)),
          Keyword.put(range_part, parts_field, comp_val..max)
        }

      {:>, true, false} ->
        {nil, range_part}

      {:>, false, true} ->
        {range_part, nil}

      {:>, _, _} ->
        {
          Keyword.put(range_part, parts_field, (comp_val + 1)..max),
          Keyword.put(range_part, parts_field, min..comp_val)
        }
    end
  end

  def process_range_step(range_part, workflow) do
    workflow
    |> Enum.scan({nil, range_part}, fn
      _, {_, nil} ->
        {nil, nil}

      {:default, r}, {_, p} ->
        {{r, p}, nil}

      {{field, op, comp_val}, r}, {_, p} ->
        case split_range_part(p, field, op, comp_val) do
          {nil, b} -> {nil, b}
          {a, b} -> {{r, a}, b}
        end
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.filter(fn
      nil -> false
      _ -> true
    end)
  end

  def process_range(part, workflows) do
    Stream.iterate([{@workflow_start, part}], fn
      [] ->
        []

      branches ->
        Enum.flat_map(branches, fn
          {@rejected, _} -> []
          {@accepted, rem} -> [{@accepted, rem}]
          {wf, p} -> process_range_step(p, Map.get(workflows, wf))
        end)
    end)
    |> Stream.chunk_every(2, 1)
    |> Enum.find_value(fn
      [a, b] -> if a == b, do: b |> Enum.map(fn {@accepted, range_part} -> range_part end)
    end)
  end

  def count_range_part_combinations(range_part) do
    range_part |> Enum.map(fn {_, min..max} -> max - min + 1 end) |> Enum.product()
  end

  def part(1, input) do
    {workflows, parts} = input |> parse

    parts
    |> Enum.filter(&(@accepted == process_single_part(&1, workflows)))
    |> Enum.map(&sum_part_categories/1)
    |> Enum.sum()
  end

  def part(2, input) do
    {workflows, _} = input |> parse

    @max_part_range
    |> process_range(workflows)
    |> Enum.map(&count_range_part_combinations/1)
    |> Enum.sum()
  end
end
