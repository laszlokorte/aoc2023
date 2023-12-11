defmodule Day9 do
  use AOC, day: 9

  @linke_break_pattern ~r{\R}
  @spaces ~r{\s+}

  def predict_next(seq) do
    if Enum.all?(seq, &(&1 == 0)) do
      0
    else
      diff =
        seq
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.map(fn [a, b] -> b - a end)
        |> predict_next

      List.last(seq) + diff
    end
  end

  def predict_prev(seq) do
    predict_next(Enum.reverse(seq))
  end

  def sum_predicted(input, predictor) do
    input
    |> String.split(@linke_break_pattern)
    |> Enum.map(&String.split(&1, @spaces))
    |> Enum.map(fn l -> Enum.map(l, &String.to_integer/1) end)
    |> Enum.map(predictor)
    |> Enum.sum()
  end

  def part1(input) do
    input |> sum_predicted(&predict_next/1)
  end

  def part2(input) do
    input |> sum_predicted(&predict_prev/1)
  end
end