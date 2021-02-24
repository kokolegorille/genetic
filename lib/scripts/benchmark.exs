defmodule Cargo do
  @behaviour Problem
  alias Types.Chromosome

  @impl true
  def genotype() do
    genes = for _ <- 1..10, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: 10}
  end

  @impl true
  def fitness_function(chromosome) do
    profits = [6, 5, 8, 9, 6, 7, 3, 1, 2, 6]
    weights = [10, 6, 8, 7, 10, 9, 7, 11, 6, 8]
    weight_limit = 40

    potential_profits =
      chromosome.genes
      |> Enum.zip(profits)
      |> Enum.map(fn {c, p} -> c * p end)
      |> Enum.sum()

    over_limit? =
      chromosome.genes
      |> Enum.zip(weights)
      |> Enum.map(fn {c, w} -> c * w end)
      |> Enum.sum()
      |> Kernel.>(weight_limit)


    profits = if over_limit?, do: 0, else: potential_profits
    profits
  end

  @impl true
  # def terminate?(population, _generation) do
  #   Enum.max_by(population, &Cargo.fitness_function/1).fitness == 53
  # end
  def terminate?(_population, generation) do
    generation == 1_000
  end
end

dummy_population = Genetic.initialize(&Cargo.genotype/0, population_size: 100)
{dummy_selected_population, _} = Genetic.select(dummy_population, selection_rate: 1.0)

Benchee.run(
  %{
    "initialize" => fn -> Genetic.initialize(&Cargo.genotype/0) end,
    "evaluate" => fn -> Genetic.evaluate(dummy_population, &Cargo.fitness_function/1) end,
    "select" => fn -> Genetic.select(dummy_population) end,
    "crossover" => fn -> Genetic.crossover(dummy_selected_population) end,
    "mutation" => fn -> Genetic.mutation(dummy_population) end,
    "evolve" => fn -> Genetic.evolve(dummy_population, Cargo, 0) end
  },
  memory_time: 2
)
