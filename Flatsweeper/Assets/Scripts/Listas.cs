using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class Listas : MonoBehaviour {

	private int cantidadEdificios;

	public static List<List<Casilla>> ListaEdificios = new List<List<Casilla>>();

	void Awake ()   
	{

		cantidadEdificios = GlobalControl.cantidadEdificiosN1;

		for (int i = 0; i < cantidadEdificios; i++) {

			List<Casilla> LC = new List<Casilla>();
			ListaEdificios.Add (LC);
		}
	}

}
