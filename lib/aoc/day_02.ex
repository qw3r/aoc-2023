defmodule AoC.Day02 do
  defmodule GameSet do
    defstruct blue: 0, red: 0, green: 0

    def create_from_string(line) do
      line
      |> String.split(", ", trim: true)
      |> Enum.map(&Regex.named_captures(~r/(?<count>\d+) (?<color>\w+)/, &1))
      |> Enum.reduce(
        %{},
        fn set, acc ->
          Map.put(acc, set["color"], set["count"])
        end
      )
      |> build()
    end

    defp build(set) do
      struct(GameSet, Map.new(set, fn {k, v} -> {String.to_atom(k), String.to_integer(v)} end))
    end
  end

  defmodule Game do
    defstruct [:id, :sets, cubes_seen: %{blue: 0, red: 0, green: 0}]

    def create_from_string(line) do
      Regex.named_captures(~r/Game (?<id>\d+): (?<sets>.+)/, line)
      |> build_game_sets()
      |> build()
    end

    defp build_game_sets(%{"sets" => sets} = m) do
      %{
        m
        | "sets" =>
            String.split(sets, "; ", trim: true) |> Enum.map(&GameSet.create_from_string/1)
      }
    end

    defp build(%{"id" => id, "sets" => sets}) do
      game = %Game{id: String.to_integer(id), sets: sets}
      %Game{game | cubes_seen: cubes_seen(game)}
    end

    def cubes_seen(%Game{} = game) do
      game.sets
      |> Enum.reduce(game.cubes_seen, fn set, acc ->
        %{
          acc
          | blue: Enum.max([acc.blue, set.blue]),
            green: Enum.max([acc.green, set.green]),
            red: Enum.max([acc.red, set.red])
        }
      end)
    end
  end

  def part1(input) do
    build_games(input)
    |> Enum.filter(fn game ->
      game.cubes_seen.blue <= 14 && game.cubes_seen.red <= 12 && game.cubes_seen.green <= 13
    end)
    |> Enum.map(& &1.id)
    |> Enum.sum()
  end

  def part2(input) do
    build_games(input)
    |> Enum.map(fn game -> game.cubes_seen.blue * game.cubes_seen.red * game.cubes_seen.green end)
    |> Enum.sum()
  end

  def build_games(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&Game.create_from_string/1)
  end
end
