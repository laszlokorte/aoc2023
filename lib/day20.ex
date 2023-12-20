defmodule Day20 do
  use AOC, day: 20

  @line_break_pattern ~r{\R}
  @stop_register "rx"

  def parse_from(<<?%, name::binary>>), do: {:flipflop, name}
  def parse_from(<<?&, name::binary>>), do: {:nand, name}
  def parse_from(name = "broadcaster"), do: {:broadcast, name}

  def parse_line(line) do
    [from, to] = line |> String.split("->", trim: true, parts: 2) |> Enum.map(&String.trim/1)
    {kind, name} = from |> parse_from
    out = to |> String.split(",") |> Enum.map(&String.trim/1)

    {name, {kind, out}}
  end

  def parse(input) do
    input
    |> String.split(@line_break_pattern)
    |> Enum.map(&parse_line/1)
    |> Enum.into(Map.new())
  end

  def transfere_local_pulse({:flipflop, _outs}, _mem, true) do
    []
  end

  def transfere_local_pulse({:flipflop, outs}, mem, false) do
    outs |> Enum.map(fn out -> {out, mem} end)
  end

  def transfere_local_pulse({:nand, outs}, mem, _pulse) do
    all_on = mem |> Enum.all?(&elem(&1, 1))

    outs |> Enum.map(fn out -> {out, not all_on} end)
  end

  def transfere_local_pulse({:broadcast, outs}, _mem, pulse) do
    outs |> Enum.map(fn out -> {out, pulse} end)
  end

  def transfere_local_pulse(nil, _mem, _pulse) do
    []
  end

  def update_local_memory({:flipflop, _outs}, mem, {_from, true}) do
    mem
  end

  def update_local_memory({:flipflop, _outs}, mem, {_from, false}) do
    not mem
  end

  def update_local_memory({:nand, _outs}, mem, {from, pulse}) do
    mem |> Map.put(from, pulse)
  end

  def update_local_memory({:broadcast, _outs}, mem, {_from, _pulse}) do
    mem
  end

  def update_local_memory(nil, mem, _pulse) do
    mem
  end

  def propagate_pulse(circuit, memory, {_from, to, value}) do
    element = Map.get(circuit, to)
    mem = Map.get(memory, to)

    transfere_local_pulse(element, mem, value)
    |> Enum.map(fn
      {new_to, out_val} -> {to, new_to, out_val}
    end)
  end

  def propagate_pulses(circuit, memory, active_pulses) do
    active_pulses |> Enum.flat_map(&propagate_pulse(circuit, memory, &1))
  end

  def update_memory(circuit, memory, active_pulses) do
    active_pulses
    |> Enum.reduce(memory, fn
      {from, to, v}, mem ->
        Map.put(mem, to, update_local_memory(Map.get(circuit, to), Map.get(mem, to), {from, v}))
    end)
  end

  def simulate_step(circuit, {memory, active_pulses}) do
    new_memory = update_memory(circuit, memory, active_pulses)
    new_pulses = propagate_pulses(circuit, new_memory, active_pulses)

    {new_memory, new_pulses}
  end

  def init_memory(_circuit, :flipflop, _name) do
    false
  end

  def init_memory(circuit, :nand, name) do
    circuit
    |> Enum.filter(fn
      {_from, {_, tos}} -> Enum.any?(tos, &(&1 == name))
    end)
    |> Enum.map(fn {from, _} -> {from, false} end)
    |> Enum.into(Map.new())
  end

  def init_memory(_circuit, _kind, _name) do
    nil
  end

  def init_memory(circuit) do
    circuit
    |> Enum.map(fn {name, {kind, _}} -> {name, init_memory(circuit, kind, name)} end)
    |> Enum.filter(fn {_, mem} -> not is_nil(mem) end)
    |> Enum.into(Map.new())
  end

  def simulate_until_stable(circuit, memory, pulses, stop_when \\ nil) do
    {memory, pulses}
    |> Stream.iterate(&simulate_step(circuit, &1))
    |> Stream.map(fn
      {mem, actives} ->
        {
          mem,
          Enum.count(actives, fn
            {_, _, val} -> val
          end),
          Enum.count(actives, fn
            {_, _, val} -> not val
          end),
          Enum.find(actives, fn {_from, to, val} -> stop_when == {to, val} end)
        }
    end)
    |> Stream.take_while(fn
      {_, a, b, stop_now} -> a != 0 or b != 0 or not is_nil(stop_now)
    end)
    |> Enum.reduce({nil, 0, 0, false}, fn
      {mem, h, l, stop_now}, {_, hs, ls, stopped} ->
        {mem, h + hs, l + ls, not is_nil(stop_now) or stopped}
    end)
  end

  def lcm(a, b)
  def lcm(0, 0), do: 0
  def lcm(a, b), do: abs(Kernel.div(a * b, gcd(a, b)))

  def gcd(x, 0), do: x
  def gcd(x, y), do: gcd(y, rem(x, y))

  def find_multiple_predecessors(circuit, names) do
    Stream.iterate(MapSet.new([names]), fn nameset ->
      circuit
      |> Enum.filter(fn
        {_from, {_, tos}} -> Enum.any?(tos, &MapSet.member?(nameset, &1))
      end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.into(MapSet.new())
    end)
    |> Enum.find(fn nameset -> MapSet.size(nameset) > 1 end)
  end

  def part(1, input) do
    circuit = input |> parse
    memory = init_memory(circuit)

    1..1000
    |> Enum.reduce({memory, 0, 0}, fn
      _, {mem, low, high} ->
        with {new_mem, h, l, _} =
               simulate_until_stable(circuit, mem, [{"button", "broadcaster", false}]) do
          {new_mem, low + l, high + h}
        end
    end)
    |> then(fn {_, l, h} -> {l, h} end)
    |> Tuple.product()
  end

  def part(2, input) do
    circuit = input |> parse
    memory = init_memory(circuit)

    find_multiple_predecessors(circuit, @stop_register)
    |> Enum.map(fn gate ->
      Stream.iterate({memory, false}, fn
        {mem, false} ->
          simulate_until_stable(circuit, mem, [{"button", "broadcaster", false}], {gate, false})
          |> case do
            {new_mem, _, _, stopped} -> {new_mem, stopped}
            {mem, true} -> {mem, false}
          end
      end)
      |> Enum.take_while(fn {_, stopped} -> not stopped end)
      |> Enum.count()
    end)
    |> Enum.reduce(1, &lcm/2)
  end
end
