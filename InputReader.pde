
boolean Initialize()
{/*passa as informações do arquivo de entrada para o programa*/
  BufferedReader reader          = createReader("input.txt");
  String         line;
  boolean        gotParameters   = false;
  int            softSum         = 0;
  int            currentClausule = 0;
  int            hardCount       = 0;  
 
  do
  {
    try 
    {
      line = reader.readLine();
    }
    catch (IOException e) 
    {
      e.printStackTrace();
      line = null;
    }
    
    if(line == null)
    {/*fim do arquivo de entrada*/
      break;
    }
    if(line.length() == 0)
    {/*linha em branco*/
      continue;
    }
    
    String[] info = split(line, " ");
    
    switch(info[0].charAt(0))
    {
      case 'c':
        /*comentário*/
        break;
      case 'p':
        /*pegar os dados de entrada: formato p wcnf #v #c #h*/
        /*é possível que não tenha o #h em casos weighted não parcial. dá pra criar um h na mão e fazer só cláusulas soft se for o caso*/
        if(info[1].equals("wcnf"))
        {
          variableCount = int(info[2]);
          clausuleCount = int(info[3]);
          try
          {
            hardWeight = int(info[4]);
          }
          catch(Exception e)
          {
            hardWeight = 0;
          }
          if(!checkParameters())
          {/*checar se os parâmetros estão válidos*/
            return false;
          }
          /*parâmetros ok, inicializar os arrays*/
          clausuleWeight     = new int[clausuleCount];
          variableCoeficient = new BitSet[clausuleCount];
          negatedVariable    = new int[clausuleCount][variableCount];
          maxFitness         = 0;  
          gotParameters      = true;
        }
        else
        {/*não está no formato certo, não é um problema wpm-sat*/
          output.println("Erro no arquivo de entrada. O código 'wcnf' não foi encontrado nos parâmetros. Encontrado '"+info[1]+"'");
          return false;
        }
        break;
      default:
        {
          if(!gotParameters)
          {
            output.println("Erro no arquivo de entrada. Não foram encontrados parâmetros antes das cláusulas");
            return false;
          }
          clausuleWeight[currentClausule] = int(info[0]);
          maxFitness += clausuleWeight[currentClausule];          
          if(clausuleWeight[currentClausule] < 1)
          {
            output.println("Erro no arquivo de entrada. Cláusula #"+(currentClausule+1)+" com peso "+clausuleWeight[currentClausule]);
            return false;
          }
          if(hardWeight == int(info[0]))
          {
            hardCount++;
          }
          else
          {
            softSum += int(info[0]);
          }
          
          variableCoeficient[currentClausule] = new BitSet(variableCount);
          for(int i = 1; i < info.length; i++)
          {
            if(int(info[i]) == 0)
            {/*fim da cláusula*/
              break;
            }
            if(int(info[i]) < 0)
            {
              negatedVariable[currentClausule] = append(negatedVariable[currentClausule], abs(int(info[i]))-1);
              variableCoeficient[currentClausule].set(abs(int(info[i]))-1);
            }
            variableCoeficient[currentClausule].set(abs(int(info[i]))-1);
          }
          currentClausule++;
        }    
    }
    
  }
  while(line != null);
  
  
  if(hardWeight == 0)
  {
    hardWeight = softSum+1;
  }
  
  if(softSum < hardWeight)
  {/*tudo ok*/
    fitnessBar = hardCount*hardWeight;
    return true;
  }
  
  output.println("Erro no arquivo de entrada. Soma dos pesos das cláusulas soft não é inferior ao peso de uma cláusula hard");    
  return false;
}

boolean checkParameters()
{
  boolean ok = true;
  if(variableCount < 1)
  {
    output.println("Erro no arquivo de entrada. Número de variáveis não pode ser menor do que 1. Encontrado "+variableCount);
    ok = false;
  }
  if(clausuleCount < 1)
  {
    output.println("Erro no arquivo de entrada. Número de cláusulas não pode ser menor do que 1. Encontrado "+clausuleCount);
    ok = false;
  }
  if(hardWeight < 0)
  {/*não pode ser < 1 aqui para não quebrar quando não tiver peso máximo, mesmo pq não é dificil converter um wm-sat para wpm-sat*/
    output.println("Erro no arquivo de entrada. Peso máximo não pode ser menor do que 1. Encontrado "+hardWeight);
    ok = false;
  }
  return ok;
}
