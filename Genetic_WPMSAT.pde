import java.util.BitSet;
import java.util.Arrays;

/*CONSTANTES DE ALGORITMO GENÉTICO*/
final int  POPULATIONSIZE  =  100;
final int  MUTATION        =  10000;/*em odds 1 : MUTATION*/
final int  SHOVE           =  2;/*em odds*/
final int  CROSSOVER       =  2;/*em odds*/
final long TIMEOUT         =  60;//000;//1 min

/*CONSTANTES DO WEIGHTED PARTIAL MAX-SAT*/
int      clausuleCount;
int      variableCount;
int      hardWeight;
int      fitnessBar;
int      maxFitness;
int[]    clausuleWeight;
BitSet[] variableCoeficient;
int[][]  negatedVariable;

/*OTHER*/
PrintWriter    output;
Individual     best;


void setup()
{
  int start = millis();
  output  = createWriter("output.txt");
  output.println("c --------------------------");
  output.println("c My Weighted Max-SAT Solver");
  output.println("c --------------------------");
  
  Individual[]  population = new Individual[POPULATIONSIZE];
  Individual[]  offspring  = new Individual[POPULATIONSIZE];
  
  if(Initialize()) //lê a entrada e passa as configuracões para nosso algoritmo genético funcionar.
  {
    int bestFit = 0;
    int unsatisfatedClausules = 0;
    
    for(int i = 0; i < POPULATIONSIZE; i++)
    {/*população inicial*/      
      offspring[i] = new Individual(i);
      if(offspring[i].fitness > bestFit)  //verifica o individuo que tem o melhor fitnessda geracao
      {
        best = new Individual(offspring[i]);
        bestFit = best.fitness;
        unsatisfatedClausules = best.weightUnsatisfatedClausules;
      }   

    }
    best.show();
    println(maxFitness);
    println("--------------------------------\n\n");
    output.println("o "+best.weightUnsatisfatedClausules); 
    int  generation = 0;
    start = millis();
    while(millis()-start < TIMEOUT && bestFit < maxFitness)
    {/*se já consegue satisfazer tudo, salta fora, não pode ficar melhor que 100% de satisfação*/
      arrayCopy(offspring, population);
      
      int fitSum = 0;
      for(Individual i : population)
      {/*pega a soma dos fitness*/
        fitSum += i.fitness;
      }
      println(fitSum/POPULATIONSIZE);
      
      offspring[0] = new Individual(best);/*elitismo*/
      population[2].crossover(population[3]);
      for(int o = 1; o < POPULATIONSIZE; o++)
      {
        int mate = int(random(CROSSOVER));
        if(mate < 1)
        {
          o++;
          o--;
        }
        
        int selected = int(random(fitSum));
        for(int i = 0; i < POPULATIONSIZE; i++)
        {
          selected -= population[i].fitness;
          if(selected < 1)
          {
            selected = i;
            break;
          }
        }
        offspring[o] = new Individual(population[selected].dna);/*habilita mutação*/
        offspring[o].shove(best);
        
        if(offspring[o].fitness > bestFit)
        {
          best = new Individual(offspring[o]);
          bestFit = best.fitness;
          unsatisfatedClausules = best.weightUnsatisfatedClausules;
        }
        
      }      
      
      output.println("o "+unsatisfatedClausules);
      generation++;
    }
    println("\nSolution:");
    best.show();
    println(maxFitness);
    println("in", generation, "generations"); 
    output.println("s OPTIMUM FOUND"); 
    output.println("v"+best.dna);
  }
  else
  {
    println("Problemas na Entrada");
  }

  endProgram();
}

void endProgram()
{
  output.flush();
  output.close();
  exit();
}
