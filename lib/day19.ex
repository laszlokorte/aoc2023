defmodule Day19 do
  use AOC, day: 19

  @empty_line_pattern ~r{\R\R}
  @workflow_pattern ~r"(?<name>\w+)\{(?<rules>[^}]+)\}"
  @rule_pattern ~r"(?:(?<field>\w+)(?<comp>[<>])(?<val>\d+):)?(?<target>\w+)"
  @part_pattern ~r"\{(?<values>[^}]+)\}"

  def parse_category("x"), do: :x
  def parse_category("m"), do: :m
  def parse_category("a"), do: :a
  def parse_category("s"), do: :s

  def parse_rule(rule) do
    Regex.run(@rule_pattern, rule, capture: [:field, :comp, :val, :target])
    |> case do
      ["", "", "", default] -> {:default, default}
      [field, "<", val, default] -> {{parse_category(field), :<, String.to_integer(val)}, default}
      [field, ">", val, default] -> {{parse_category(field), :>, String.to_integer(val)}, default}
    end
  end

  def parse_workflow([name, rules]) do
    rules = rules |> String.split(",") |> Enum.map(&parse_rule/1)

    {name, rules}
  end

  def parse_parts([part]) do
    part
    |> String.split(",")
    |> Enum.map(&String.split(&1, "=", parts: 2))
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

  def process_step(part, workflow) do
    workflow
    |> Enum.find_value(fn
      {:default, r} -> r
      {{field, :>, comp}, r} -> if part[field] > comp, do: r
      {{field, :<, comp}, r} -> if part[field] < comp, do: r
      _ -> nil
    end)
  end

  def process(part, workflows) do
    Stream.iterate("in", fn
      "R" -> :rejected
      "A" -> :accepted
      wf -> process_step(part, Map.get(workflows, wf))
    end)
    |> Enum.find(fn
      :rejected -> true
      :accepted -> true
      _ -> false
    end)
  end

  def sum_categories(part) do
    Enum.sum(for {_, v} <- part, do: v)
  end

  def part(1, input) do
    {workflows, parts} = input |> parse

    parts
    |> Enum.filter(&(:accepted == process(&1, workflows)))
    |> Enum.map(&sum_categories/1)
    |> Enum.sum()
  end

  def part(2, input) do
    input
  end
end
