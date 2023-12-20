defmodule Day9 do
  use AOC, day: 9

  import Enum

  @line_break_pattern ~r{\R}
  @spaces ~r{\s+}

  def predict_prev([head | _] = seq) do
    if all?(seq, &(&1 == 0)) do
      0
    else
      seq
      |> chunk_every(2, 1, :discard)
      |> map(fn [a, b] -> a - b end)
      |> predict_prev
      |> then(&(&1 + head))
    end
  end

  def predict_next(seq) do
    predict_prev(reverse(seq))
  end

  def sum_predicted(input, predictor) do
    input
    |> String.split(@line_break_pattern)
    |> map(&String.split(&1, @spaces))
    |> map(fn l -> map(l, &String.to_integer/1) end)
    |> map(predictor)
    |> sum()
  end

  def part(1, input) do
    input |> sum_predicted(&predict_next/1)
  end

  def part(2, input) do
    input |> sum_predicted(&predict_prev/1)
  end
end
