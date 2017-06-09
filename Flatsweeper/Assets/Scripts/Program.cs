using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

public class Program : MonoBehaviour {


	public static List<Casilla> GenerarTablero(int N, int M, int Nminas){

		List<Casilla> ListaCasillas = initGame(N, M);

		List<int> getInitListaMinas = initMinas(Nminas, N, M, ListaCasillas);

		ponNumeros(ListaCasillas, getInitListaMinas, N, M);

		return ListaCasillas;

	}

		
	//
	public static List<Casilla> initGame(int N, int M)
	{
		List<Casilla> LC = new List<Casilla>();
		//int f = 0;
		for (int i = 0; i <N; i++)
		{
			for (int j = 0; j < M; j++)
			{
				LC.Add(new Casilla(i, j));
				//Debug.Log("x? " + i + " y? " + j);
			}
		}

		return LC;
	}


	//Genera minas en posiciones random
	public static List<int> initMinas(int Nminas, int N, int M, List<Casilla> ListaCasillas)
	{
		List<int> ListaMinas = new List<int>();

		bool repite = false;


		for (int r = 0; r < Nminas; r++){

			repite = false;
			int posMina = Random.Range(0, (N * M)-1);


			//comprueba que el valor aun no este en la lista 
			for (int t = 0; t < ListaMinas.Count; t++){
				//si se repite
				if (posMina == ListaMinas[t]){
					repite = true;
					r--;
					break;
				}
			}

			//si no se repite, se guarda valor
			if (!repite) {
				ListaMinas.Add(posMina);
				ListaCasillas[posMina].setMina();
				ListaCasillas[posMina].setNumero(1000); //Si la posicion tiene mina, numero = 1000, tiene este valor para diferenciarse
			

				//se guarda valor del piso
				int precioBarrio = 0;
				switch (GlobalControl.nivelActual){
				case 1:
					precioBarrio = GlobalControl.precioN1;
					break;
				}

				float temp = Random.Range(precioBarrio*1.45f, precioBarrio*1.65f);
				ListaCasillas[posMina].setValorPiso((int)temp);

			}
		}

		return ListaMinas;
		
	}


	//
	public static List<int> minasAlrededor(int pos_click, List<int> LMinas, List<Casilla> ListaCasillas, int N, int M)
	{
		List<int> ListaMinasAlrededor = new List<int>();
		List<int> ListaMinasAlrededor2 = new List<int>();

		
		int posClick_x = ListaCasillas[pos_click].getPosX();
		int posClick_y = ListaCasillas[pos_click].getPosY();
		
		for (int c = 0; c < ListaCasillas.Count; c++)
		{
			int xini = posClick_x - 1; int xfin = posClick_x + 1;
			int yini = posClick_y - 1; int yfin = posClick_y + 1;
			
			if (xini < 0) xini = 0;
			if (xfin > N) xfin = N;
			if (yini < 0) yini = 0;
			if (yfin > M) xfin = M;
			
			for (int i = 0; i < LMinas.Count; i++)
			{
				int minaX = ListaCasillas[LMinas[i]].getPosX();
				int minaY = ListaCasillas[LMinas[i]].getPosY();
				
				if (minaX >= xini && minaX <= xfin && minaY >= yini && minaY <= yfin)
				{
					ListaMinasAlrededor.Add(LMinas[i]);
				}
			}
			
		}
		
		foreach (var temp in ListaMinasAlrededor)
		{
			ListaMinasAlrededor2.Add(temp);
		}
		
		if (ListaMinasAlrededor.Count == 0)
		{
			return null;
		}
		else
		{
			return ListaMinasAlrededor = ListaMinasAlrededor2.Distinct().ToList();
		}
	}
	



	//Poner numeros
	public static void ponNumeros(List<Casilla> ListaCasillas, List<int> getInitListaMinas, int N, int M)
	{
		
		List<int> getListaMinasAlrededor = new List<int>();
		
		for (int l = 0; l < ListaCasillas.Count; l++)
		{
			getListaMinasAlrededor = minasAlrededor(l, getInitListaMinas, ListaCasillas, N, M);

			//Si la posicion casilla no es una mina
			if (!ListaCasillas[l].getMina())
			{
				//se guarda valor del piso
				int precioBarrio = 0;
				switch (GlobalControl.nivelActual){
				case 1:
					precioBarrio = GlobalControl.precioN1;
					break;
				}

				float temp = Random.Range(precioBarrio - precioBarrio*0.2f, precioBarrio*1.2f);
				ListaCasillas[l].setValorPiso((int)temp);

				//se ponen numeros 0,1,2,3...
				if (getListaMinasAlrededor != null)
				{
					ListaCasillas[l].setNumero(getListaMinasAlrededor.Count);
				}
				else
				{
					ListaCasillas[l].setNumero(0);
				}
			}
		}
	}

}
