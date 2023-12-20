defmodule Day20 do
  use AOC, day: 20

  @line_break_pattern ~r{\R}
  @stop_register "rx"
  @flipflop ?%
  @nand ?&
  @wire_edge "->"
  @comma ","
  @broadcaster "broadcaster"
  @initial_pulse [{"button", @broadcaster, false}]

  def parse_source(<<@flipflop, name::binary>>), do: {:flipflop, name}
  def parse_source(<<@nand, name::binary>>), do: {:nand, name}
  def parse_source(name = @broadcaster), do: {:broadcast, name}

  def parse_line(line) do
    [source, sink] =
      line |> String.split(@wire_edge, trim: true, parts: 2) |> Enum.map(&String.trim/1)

    {kind, name} = source |> parse_source
    out = sink |> String.split(@comma) |> Enum.map(&String.trim/1)

    {name, {kind, out}}
  end

  def parse(input) do
    input
    |> String.split(@line_break_pattern)
    |> Enum.map(&parse_line/1)
    |> Enum.into(Map.new())
  end

  def transfere_local_pulse({:flipflop, _outs}, _mem, true), do: []

  def transfere_local_pulse({:flipflop, outs}, mem, false),
    do: Enum.map(outs, fn out -> {out, mem} end)

  def transfere_local_pulse({:nand, outs}, mem, _pulse) do
    outs |> Enum.map(fn out -> {out, not Enum.all?(mem, &elem(&1, 1))} end)
  end

  def transfere_local_pulse({:broadcast, outs}, _mem, pulse) do
    outs |> Enum.map(fn out -> {out, pulse} end)
  end

  def update_local_memory(:flipflop, mem, {_from, true}), do: mem
  def update_local_memory(:flipflop, mem, {_from, false}), do: not mem
  def update_local_memory(:nand, mem, {from, pulse}), do: Map.put(mem, from, pulse)
  def update_local_memory(:broadcast, mem, {_from, _pulse}), do: mem

  def propagate_pulse(circuit, memory, {_from, to, value}) do
    case {Map.get(circuit, to), Map.get(memory, to)} do
      {nil, _} ->
        []

      {el, mem} ->
        transfere_local_pulse(el, mem, value)
        |> Enum.map(fn
          {new_to, out_val} -> {to, new_to, out_val}
        end)
    end
  end

  def propagate_pulses(circuit, memory, active_pulses) do
    active_pulses |> Enum.flat_map(&propagate_pulse(circuit, memory, &1))
  end

  def update_memory(circuit, memory, active_pulses) do
    active_pulses
    |> Enum.reduce(memory, fn
      {from, to, v}, mem ->
        Map.get(circuit, to)
        |> case do
          nil ->
            mem

          {kind, _outs} ->
            Map.put(mem, to, update_local_memory(kind, Map.get(mem, to), {from, v}))
        end
    end)
  end

  def simulate_step(circuit, {memory, active_pulses}) do
    new_memory = update_memory(circuit, memory, active_pulses)
    new_pulses = propagate_pulses(circuit, new_memory, active_pulses)

    {new_memory, new_pulses}
  end

  def init_local_memory(:flipflop, _name, _circuit) do
    false
  end

  def init_local_memory(:nand, name, circuit) do
    circuit
    |> Enum.filter(fn
      {_from, {_, tos}} -> Enum.any?(tos, &(&1 == name))
    end)
    |> Enum.map(fn {from, _} -> {from, false} end)
    |> Enum.into(Map.new())
  end

  def init_local_memory(_kind, _name, _circuit) do
    nil
  end

  def init_memory(circuit) do
    circuit
    |> Enum.map(fn {name, {kind, _}} -> {name, init_local_memory(kind, name, circuit)} end)
    |> Enum.filter(fn {_, mem} -> not is_nil(mem) end)
    |> Enum.into(Map.new())
  end

  def simulate_until_stable_or_stop(circuit, memory, pulses, stop_when \\ nil) do
    {memory, pulses}
    |> Stream.iterate(&simulate_step(circuit, &1))
    |> Stream.map(fn
      {mem, active_pulses} ->
        {
          mem,
          Enum.count(active_pulses, fn
            {_, _, val} -> val
          end),
          Enum.count(active_pulses, fn
            {_, _, val} -> not val
          end),
          not is_nil(Enum.find(active_pulses, fn {_from, to, val} -> stop_when == {to, val} end))
        }
    end)
    |> Stream.take_while(fn
      {_, a, b, stop_now} -> a != 0 or b != 0 or stop_now
    end)
    |> Enum.reduce(fn
      {mem, high_pulse_count, low_pulse_count, stop_now},
      {_, high_pulse_sum, low_pulse_sum, stopped} ->
        {mem, high_pulse_sum + high_pulse_count, low_pulse_sum + low_pulse_count,
         stop_now or stopped}
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

  def trigger_pulses_until(circuit, memory, pulses, stop \\ nil) do
    Stream.iterate({memory, false, 0, 0}, fn
      {mem, false, low_sum, high_sum} ->
        with {new_mem, low, high, stopped} =
               simulate_until_stable_or_stop(circuit, mem, pulses, stop) do
          {new_mem, stopped, low_sum + low, high_sum + high}
        end

      keep -> keep
    end)
  end

  def part(1, input) do
    circuit = input |> parse
    memory = init_memory(circuit)

    trigger_pulses_until(circuit, memory, @initial_pulse)
    |> Enum.at(1000)
    |> then(fn {_, _, l, h} -> {l, h} end)
    |> Tuple.product()
  end

  def part(2, input) do
    circuit = input |> parse
    memory = init_memory(circuit)

    find_multiple_predecessors(circuit, @stop_register)
    |> Enum.map(&trigger_pulses_until(circuit, memory, @initial_pulse, {&1, false}))
    |> Enum.map(&Enum.find_index(&1, fn {_, stopped, _, _} -> stopped end))
    |> Enum.reduce(1, &lcm/2)
  end
end
