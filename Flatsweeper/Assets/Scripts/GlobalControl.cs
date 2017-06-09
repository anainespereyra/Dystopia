using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class GlobalControl : MonoBehaviour {

	public static GlobalControl Instance;

	//Se definen variables publicas
	public static int nivelesDesbloqueados = 1; //esto habra que guardarlo en playerpref

	public static int xFichasE1N1 = 6;
	public static int yFichasE1N1 = 11;
	public static int minasE1N1 = 10;

	public static int xFichasE2N1 = 4;
	public static int yFichasE2N1 = 10;
	public static int minasE2N1 = 6;

	public static int xFichasE3N1 = 4;
	public static int yFichasE3N1 = 10;
	public static int minasE3N1 = 5;

	public static int cantidadEdificiosN1 = 2;
	public static int cantidadEdificiosN2 = 0;

	public static int edificiosCompletosN1 = 0;
	public static int edificiosCompletosN2 = 0;

	public static int nivelActual = 0; //ESTO HAY QUE CAMBIARLO A 0!! ESTA EN 1 PARA EL DEBUG
	public static int edificioActual = 0;

	public static int precioN1 = 899;





	
	void Awake ()   
	{
		//esto es para que no se eliminen cuando se cambia de escena
		if (Instance == null)
		{
			DontDestroyOnLoad(gameObject);
			Instance = this;
		}
		else if (Instance != this)
		{
			Destroy (gameObject);
		}

	}
}