defmodule Day19 do
  use AOC, day: 19

  import Enum

  @empty_line_pattern ~r{\R\R}
  @line_break_pattern ~r{\R}
  @workflow_pattern ~r"(?<name>\w+)\{(?<rules>[^}]+)\}"
  @rule_pattern ~r"(?:(?<field>\w+)(?<comp>[<>])(?<val>\d+):)?(?<target>\w+)"
  @comma ","
  @eq "="
  @workflow_start "in"
  @accepted "A"
  @rejected "R"
  @max_cat_range 1..4000
  @max_range_part [x: @max_cat_range, m: @max_cat_range, a: @max_cat_range, s: @max_cat_range]

  def parse_category("x"), do: :x
  def parse_category("m"), do: :m
  def parse_category("a"), do: :a
  def parse_category("s"), do: :s

  def parse_op("<"), do: :<
  def parse_op(">"), do: :>

  def parse_workflow_name(@accepted), do: true
  def parse_workflow_name(@rejected), do: false
  def parse_workflow_name(n), do: n

  def parse_rule(rule) do
    @rule_pattern
    |> Regex.run(rule, capture: [:field, :comp, :val, :target])
    |> case do
      ["", "", "", default] ->
        {:default, parse_workflow_name(default)}

      [field, op, val, target] ->
        {{parse_category(field), parse_op(op), String.to_integer(val)},
         parse_workflow_name(target)}
    end
  end

  def parse_workflow([name, rules]) do
    {name, rules |> String.split(@comma) |> map(&parse_rule/1)}
  end

  def parse_parts(part) do
    part
    |> String.split(@comma)
    |> map(&String.split(&1, @eq, parts: 2))
    |> map(fn
      [p, v] -> {parse_category(p), String.to_integer(v)}
    end)
  end

  def parse(input) do
    [workflows_string, parts_string] = input |> String.split(@empty_line_pattern, parts: 2)

    workflows =
      @workflow_pattern
      |> Regex.scan(workflows_string, capture: [:name, :rules])
      |> map(&parse_workflow/1)
      |> into(Map.new())

    parts =
      parts_string
      |> String.split(@line_break_pattern)
      |> map(&String.trim_leading(&1, "{"))
      |> map(&String.trim_trailing(&1, "}"))
      |> map(&parse_parts/1)

    {workflows, parts}
  end

  def process_single_part_step(part, workflow) do
    workflow
    |> find_value(fn
      {:default, r} -> {:ok, r}
      {{field, :>, comp}, r} -> if part[field] > comp, do: {:ok, r}
      {{field, :<, comp}, r} -> if part[field] < comp, do: {:ok, r}
    end)
    |> elem(1)
  end

  def process_single_part(part, workflows) do
    Stream.iterate(@workflow_start, fn
      r when is_boolean(r) -> r
      wf -> process_single_part_step(part, Map.get(workflows, wf))
    end)
    |> find(&is_boolean/1)
  end

  def split_range(range, comp_op, comp_val) do
    min..max = range

    case {comp_op, max < comp_val, min > comp_val} do
      {:<, true, false} -> {range, nil}
      {:<, false, true} -> {nil, range}
      {:<, _, _} -> {min..(comp_val - 1), comp_val..max}
      {:>, true, false} -> {nil, range}
      {:>, false, true} -> {range, nil}
      {:>, _, _} -> {(comp_val + 1)..max, min..comp_val}
    end
  end

  def split_range_part(range_part, parts_field, comp_op, comp_val) do
    Keyword.get(range_part, parts_field)
    |> split_range(comp_op, comp_val)
    |> case do
      {nil, nil} -> {nil, nil}
      {nil, a} -> {nil, Keyword.put(range_part, parts_field, a)}
      {a, nil} -> {Keyword.put(range_part, parts_field, a), nil}
      {a, b} -> {Keyword.put(range_part, parts_field, a), Keyword.put(range_part, parts_field, b)}
    end
  end

  def process_range_part_step(range_part, workflow) do
    workflow
    |> scan({nil, range_part}, fn
      _, {_, nil} ->
        {nil, nil}

      {:default, matching_workflow}, {_, current_range} ->
        {{matching_workflow, current_range}, nil}

      {{field, op, comp_val}, matching_workflow}, {_, current_range} ->
        with {matching_range, rem_range} = split_range_part(current_range, field, op, comp_val) do
          {{matching_workflow, matching_range}, rem_range}
        end
    end)
    |> map(&elem(&1, 0))
    |> filter(&(not is_nil(&1)))
  end

  def process_range_part_branches(branches, workflows) do
    branches
    |> flat_map(fn
      {false, _} -> []
      {true, rem} -> [{true, rem}]
      {wf, p} -> process_range_part_step(p, Map.get(workflows, wf))
    end)
  end

  def process_range_part(range_part, workflows) do
    Stream.iterate([{@workflow_start, range_part}], &process_range_part_branches(&1, workflows))
  end

  def find_branch_leafs(workflow_steps) do
    workflow_steps
    |> find_value(fn
      b ->
        if all?(b, &(elem(&1, 0) == true)) do
          map(b, fn {true, range_part} -> range_part end)
        end
    end)
  end

  def count_range_part_combinations(range_part) do
    range_part |> map(fn {_, min..max} -> max - min + 1 end) |> product()
  end

  def sum_single_part_categories(part) do
    sum(for {_, v} <- part, do: v)
  end

  def part(1, input) do
    {workflows, parts} = input |> parse

    parts
    |> filter(&process_single_part(&1, workflows))
    |> map(&sum_single_part_categories/1)
    |> sum()
  end

  def part(2, input) do
    {workflows, _} = input |> parse

    @max_range_part
    |> process_range_part(workflows)
    |> find_branch_leafs
    |> map(&count_range_part_combinations/1)
    |> sum()
  end
end
