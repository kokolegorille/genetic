defmodule Speller do
  @behaviour Problem
  alias Types.Chromosome

  @impl true
  def genotype() do
    genes =
      Stream.repeatedly(fn -> Enum.random(?a..?z) end)
      |> Enum.take(34)
    %Chromosome{genes: genes, size: 34}
  end

  @impl true
  def fitness_function(chromosome) do
    target = 'supercalifragilisticexpialidocious' |> to_string()
    guess = chromosome.genes |> to_string()
    String.jaro_distance(target, guess)
  end

  @impl true
  def terminate?([best | _], _generation) do
    best.fitness == 1
  end
end

soln = Genetic.run(Speller)

IO.write("\n")
IO.inspect soln
