# My attempt at Advent of Code 2023 in Elixir

![Progress Screenshot](./progress.png)

## Run a single day

```sh
mix run -e 'Day1.all'
```

## Run a single challange

```sh
mix run -e 'Day1.part1_test'
mix run -e 'Day1.part1_prod'
mix run -e 'Day1.part2_test'
mix run -e 'Day1.part2_prod'
```

## Run all challanges at once

```sh
mix run -e 'AOC.all'
```

## Todo

Figure out iterate over all `Day*` modules instead of hardcoding them in `AOC.all`