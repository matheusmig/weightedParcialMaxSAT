class Individual implements Comparable
{
  BitSet  dna;
  int    fitness;
  
  Individual(int _only)
  {    
    dna = new BitSet(variableCount);
    dna.set(_only % variableCount);
    if(_only > variableCount-1)
    {/*adiciona um pouco mais de variedade na população, sem comprometer tamanho do bitset*/
      dna.set(int(random(variableCount)));
      dna.set(int(random(variableCount)));
      dna.set(int(random(variableCount)));
    }
    
    fitness = getFitness();
  }
  
  Individual(BitSet _dna)
  {/*mutação possível*/
    dna = (BitSet) _dna.clone();
    mutate(dna);
    fitness = getFitness();
  }
  
  Individual(Individual base)
  {/*clone*/
    dna = (BitSet) base.dna.clone();
    fitness = base.fitness;
  }
  
  int getFitness()
  {
    int fit = 0;
    
    boolean logic = false;
    
    for(int clausule = 0; clausule < clausuleCount; clausule++)
    {
      
      BitSet check = (BitSet) dna.clone();
      for(int i: negatedVariable[clausule])
      {
        check.flip(i);
      }
      check.and(variableCoeficient[clausule]);
      if(!check.isEmpty())
      {
        fit += clausuleWeight[clausule];
      }
    }
    return fit;
  }
  
  void shove(Individual other)
  {
    if(fitness == other.fitness)
    {
      if(dna.equals(other.dna))
      {/*mesma solução, melhor mutar ela bastante pra não cair em máximo local*/
        int odd;    
        for(int i = 0; i < variableCount; i++)
        {
          odd = int(random(SHOVE));
          if(odd < 1)
          {
            dna.flip(i);
          }
        }
        fitness = getFitness();/*recalcula fitness depois da mutação*/
      }
    }
  }
  
  void mutate(BitSet _dna)/*Tá bem lento*/
  {/*chamar mutate ANTES de calcular fitness*/
    int odd;    
    for(int i = 0; i < variableCount; i++)
    {
      odd = int(random(MUTATION));
      if(odd < 1)
      {
        _dna.flip(i);
      }
    }
  }
  
  Twins crossover(Individual mate)
  {
    int x = int(random(2, variableCount-1));
    BitSet upper = new BitSet(variableCount);
    BitSet lower = new BitSet(variableCount);
    
    BitSet maskUpper = new BitSet(variableCount);
    BitSet maskLower = new BitSet(variableCount);
    maskUpper.flip(0, x);
    maskLower.flip(x, variableCount);
    
    upper = (BitSet) dna.clone();
    upper.and(maskUpper);
    lower = (BitSet) mate.dna.clone();
    lower.and(maskLower);
    upper.or(lower);
    
    Individual first = new Individual(upper);
    
    upper = (BitSet) mate.dna.clone();
    upper.and(maskUpper);
    lower = (BitSet) dna.clone();
    lower.and(maskLower);
    upper.or(lower);
    
    Individual second = new Individual(upper);
    
    Twins offspring = new Twins(first, second);
  
    return offspring;    
  }
  
  int compareTo(Object o)
  {
    Individual other = (Individual) o;
    if(fitness == other.fitness)
    {
      return 0;
    }
    if(fitness < other.fitness)
    {
      return -1;
    }
    else
    {
      return 1;
    }  
  }
  
  void show()
  {
    println(dna);
    println("Fitness =", fitness);
    println();
  }  
}

class Twins
{
  Individual first;
  Individual second;
  
  Twins(Individual _first, Individual _second)
  {/*não precisa clonar aqui pq _first e _second não serão acessíveis depois do crossover*/
    first  = _first;
    second = _second;
  }  
}
