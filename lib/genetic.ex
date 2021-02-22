defmodule Genetic do
  @moduledoc """
  Documentation for `Genetic`.
  """

  alias Types.Chromosome
  alias Toolbox.Selection

  # def run(fitness_function, genotype, max_fitness, opts \\ []) do
  #   population = initialize(genotype)
  #   population
  #   |> evolve(fitness_function, genotype, max_fitness, opts)
  # end

  def run(problem, opts \\ []) do
    population = initialize(&problem.genotype/0)
    first_generation = 0
    population
    |> evolve(problem, first_generation, opts)
  end

  # def evolve(population, fitness_function, genotype, max_fitness, opts \\ []) do
  #   population = evaluate(population, fitness_function, opts)
  #   best = hd(population)
  #   IO.write("\rCurrent Best: #{fitness_function.(best)}")
  #   if fitness_function.(best) == max_fitness do
  #     best
  #   else
  #     population
  #     |> select(opts)
  #     |> crossover(opts)
  #     |> mutation(opts)
  #     |> evolve(fitness_function, genotype, max_fitness, opts)
  #   end
  # end

  # def evolve(population, problem, generation, opts \\ []) do
  #   population = evaluate(population, &problem.fitness_function/1, opts)
  #   best = hd(population)
  #   IO.write("\rCurrent Best: #{best.fitness}")
  #   if problem.terminate?(population, generation) do
  #     best
  #   else
  #     generation = generation + 1
  #     population
  #     |> select(opts)
  #     |> crossover(opts)
  #     |> mutation(opts)
  #     |> evolve(problem, generation, opts)
  #   end
  # end

  def evolve(population, problem, generation, opts \\ []) do
    population = evaluate(population, &problem.fitness_function/1, opts)
    best = hd(population)
    IO.write("\rCurrent Best: #{best.fitness}")
    if problem.terminate?(population, generation) do
      best
    else
      {parents, left_over} = select(population, opts)
      children = crossover(parents, opts)
      children ++ left_over
      |> mutation(opts)
      |> evolve(problem, generation + 1, opts)
    end
  end

  def initialize(genotype, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)
    for _ <- 1..population_size, do: genotype.()
  end

  # def evaluate(population, fitness_function, opts \\ []) do
  #   population
  #   |> Enum.sort_by(fitness_function, &>=/2)
  # end

  def evaluate(population, fitness_function, _opts \\ []) do
    population
    |> Enum.map(fn chromosome ->
      fitness = fitness_function.(chromosome)
      age = chromosome.age + 1
      %Chromosome{chromosome | fitness: fitness, age: age}
    end)
    |> Enum.sort_by(& &1.fitness, &>=/2)
  end

  # def select(population, _opts \\ []) do
  #   population
  #   |> Enum.chunk_every(2)
  #   |> Enum.map(&List.to_tuple(&1))
  # end

  def select(population, opts \\ []) do
    select_fn = Keyword.get(opts, :selection_type, &Selection.elite/2)
    select_rate = Keyword.get(opts, :selection_rate, 0.8)
    n = round(length(population) * select_rate)
    n = if rem(n, 2) == 0, do: n, else: n + 1
    parents =
      apply(select_fn, [population, n])
    left_over =
      population
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(parents))
    parents =
      parents
      |>  Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple(&1))
    {parents, MapSet.to_list(left_over)}
  end

  # def crossover(population, _opts \\ []) do
  #   population
  #   |> Enum.reduce([], fn {p1, p2}, acc ->
  #     cx_point = :rand.uniform(length(p1))
  #     {{h1, t1}, {h2, t2}} = {
  #       Enum.split(p1, cx_point),
  #       Enum.split(p2, cx_point)
  #     }
  #     {c1, c2} = {h1 ++ t2, h2 ++ t1}
  #     [c1, c2 | acc]
  #   end)
  # end

  def crossover(population, _opts \\ []) do
    population
    |> Enum.reduce([], fn {p1, p2}, acc ->
      cx_point = :rand.uniform(length(p1.genes))
      {{h1, t1}, {h2, t2}} = {
        Enum.split(p1.genes, cx_point),
        Enum.split(p2.genes, cx_point)
      }
      {c1, c2} = {
        %Chromosome{p1 | genes: h1 ++ t2},
        %Chromosome{p2 | genes: h2 ++ t1}
      }
      [c1, c2 | acc]
    end)
  end

  # def mutation(population, _opts \\ []) do
  #   population
  #   |> Enum.map(fn chromosome ->
  #     if :rand.uniform() < 0.05 do
  #       Enum.shuffle(chromosome)
  #     else
  #       chromosome
  #     end
  #   end)
  # end

  def mutation(population, _opts \\ []) do
    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() < 0.05 do
        %Chromosome{chromosome | genes: Enum.shuffle(chromosome.genes)}
      else
        chromosome
      end
    end)
  end
end
