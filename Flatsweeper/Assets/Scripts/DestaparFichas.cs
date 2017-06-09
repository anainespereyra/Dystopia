using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class DestaparFichas : MonoBehaviour {

	public GameObject imgArriba, imgBandera;
	public int edificio;

	private int N, M, minas;
	private int cantidadEdificios, edificiosCompletos;

	private float startTime, endTime, actualTime;
	private bool puseBandera;

	void Start(){

		actualTime = Time.time;
		startTime = actualTime;
		endTime = actualTime;

		puseBandera = false;


	}


	void Update (){

		actualTime =  Time.time;

		//si es un touch, poner bandera
		if (endTime != startTime &&(actualTime - startTime) > 0.5) {
			Bandera();
			actualTime = Time.time;
			startTime = actualTime;
			endTime = actualTime;
			puseBandera = true;
		
		//si es un tap, destapar
		} else if ((endTime - startTime) > 0) {
			Destapa ();
			actualTime = Time.time;
			startTime = actualTime;
			endTime = actualTime;
		}
	}


	void OnMouseDown (){
		startTime = Time.time;
	}
	
	void OnMouseUp(){
		if (puseBandera == false){
			endTime = Time.time;
		}
		puseBandera = false;
	}
	
	
	void cargarVariablesEdificio(){
		
		switch (edificio) {
		case 1:
			N = GlobalControl.xFichasE1N1;
			M = GlobalControl.yFichasE1N1;
			minas = GlobalControl.minasE1N1;
			break;
		case 2:
			N = GlobalControl.xFichasE2N1;
			M = GlobalControl.yFichasE2N1;
			minas = GlobalControl.minasE2N1;
			break;
		case 3:
			N = GlobalControl.xFichasE3N1;
			M = GlobalControl.yFichasE3N1;
			minas = GlobalControl.minasE3N1;
		break;
		}

		switch (GlobalControl.nivelActual) {
		case 1:
			cantidadEdificios = GlobalControl.cantidadEdificiosN1;
			edificiosCompletos = GlobalControl.edificiosCompletosN1;
			break;
		case 2:
			cantidadEdificios = GlobalControl.cantidadEdificiosN2;
			edificiosCompletos = GlobalControl.edificiosCompletosN2;
			break;
		
		}

	}


	void Bandera(){
		//si no hay panel activo
		if (!CanvasController.instance.panelActivado) {
			if (!imgBandera.activeSelf){
				imgBandera.SetActive(true);
				SonidosFX.instance.reproducirSonido(SonidosFX.instance.sonidoBandera);
			} else {
				imgBandera.SetActive(false);
			}

		}
	}


	void Destapa(){

		//si no hay panel activo
		if (!CanvasController.instance.panelActivado) {

			//se descubre ventana
			imgArriba.SetActive(false);
			imgBandera.SetActive(false);
			SonidosFX.instance.reproducirSonido(SonidosFX.instance.sonidoDestapa);

			cargarVariablesEdificio();

			if (comprobarMina ()) {
				Debug.Log ("PERDISTE");
				SonidosFX.instance.reproducirSonido(SonidosFX.instance.sonidoBomba);
				CanvasController.instance.desactivarBotones();
				Invoke("llamarPanelPerdiste", 2);
			} else if (comprobarEdificioCompleto()){

				SonidosFX.instance.reproducirSonido(SonidosFX.instance.sonidoCompletarEdificio);

				switch (GlobalControl.nivelActual) {
				case 1:
					GlobalControl.edificiosCompletosN1++;
					break;
				case 2:
					GlobalControl.edificiosCompletosN2++;
					break;	
				}

				cargarVariablesEdificio();
				VolverABarrio.instance.ZoomOut();
				if (cantidadEdificios == edificiosCompletos) {
					Debug.Log ("GANASTE");
					CanvasController.instance.desactivarBotones();
					Invoke("llamarPanelGanaste", 2);
				}
			} else {

			}
		}

	}

	private void llamarPanelPerdiste (){
		SonidosFX.instance.reproducirSonido(SonidosFX.instance.sonidoPerdiste);
		CanvasController.instance.activarPanelPerdiste();
	}

	private void llamarPanelGanaste (){
		Musica.instance.reproducirMusica(Musica.instance.musicaGanaste);
		CanvasController.instance.activarPanelGanaste();
	}

	public bool comprobarEdificioCompleto(){

		int destapadas = 0;

		for (int i = 0; i < Listas.ListaEdificios [edificio - 1].Count; i++) {
			GameObject gg = Listas.ListaEdificios [edificio - 1] [i].getGO ();
			if (gg.GetComponent<Transform> ().Find ("imgArriba").gameObject.activeSelf == false) {
				destapadas++;
			}
		}
		
		if (M*N == destapadas + minas ){
			return true;
		} else {
			return false;
		}

	}

	public bool comprobarMina(){

		//Para localizar la ficha seleccionada en la lista!!
		for (int i = 0; i < Listas.ListaEdificios[edificio-1].Count; i++) {
			
			GameObject gO = Listas.ListaEdificios[edificio-1][i].getGO();
			
			if (gO == gameObject){

				//se muestra valor del piso
				ValorPiso.instance.EfectoValorPiso(Listas.ListaEdificios[edificio-1][i].getValorPiso());

				//Si la ficha contiene mina
				if (Listas.ListaEdificios[edificio-1][i].getMina()){
					return true;
				} else if (Listas.ListaEdificios[edificio-1][i].getNumero() == 0) {
					DestaparAdyacentes(i);
				}
			}
		}
		return false;
		
		
		/*
		//OTRA FORMA para comprobar que no haya mina
		foreach (Transform t in gameObject.transform){
			if (t.name == "mina" && t.gameObject.activeSelf){
				Debug.Log ("PERDISTE");
			}
		}
		*/

	}


	public void DestaparAdyacentes(int num){


		Casilla cas = Listas.ListaEdificios [edificio - 1] [num];

	
		List<int> ListaVentanasCero = new List<int>();
		List<int> ListaVentanasOtras = new List<int>();
		ListaVentanasCero.Add (num);


		while (ListaVentanasCero.Count > 0) {

			cas = Listas.ListaEdificios [edificio - 1] [ListaVentanasCero[0]];


			int xini = cas.getPosX() - 1; int xfin = cas.getPosX() + 1;
			int yini = cas.getPosY() - 1; int yfin = cas.getPosY() + 1;
			
			if (xini < 0) xini = 0;
			if (xfin > N) xfin = N;
			if (yini < 0) yini = 0;
			if (yfin > M) xfin = M;

			
			for (int i = xini; i <= xfin; i++){
				for (int j = yini; j <= yfin; j++){

					for (int o = 0; o < Listas.ListaEdificios [edificio - 1].Count; o++){

						if (Listas.ListaEdificios [edificio - 1][o].getPosX() == i && 
						    Listas.ListaEdificios [edificio - 1][o].getPosY() == j){

							ListaVentanasOtras.Add (o);

							if (Listas.ListaEdificios [edificio - 1][o].getNumero() == 0){


								GameObject gg = Listas.ListaEdificios [edificio - 1] [o].getGO ();
								if (gg.GetComponent<Transform> ().Find ("imgArriba").gameObject.activeSelf == true) {

									ListaVentanasCero.Add (o);

								}
							}

						}

					}
				}

			}
			cas.getGO().GetComponent<Transform> ().Find ("imgArriba").gameObject.SetActive (false);
			cas.getGO().GetComponent<Transform> ().Find ("bandera").gameObject.SetActive (false);
			ListaVentanasCero.RemoveAt(0);
		}

		for (int k = 0; k < ListaVentanasOtras.Count; k++){

			Listas.ListaEdificios [edificio - 1] [ListaVentanasOtras[k]].getGO().GetComponent<Transform> ().Find ("imgArriba").gameObject.SetActive (false);
			Listas.ListaEdificios [edificio - 1] [ListaVentanasOtras[k]].getGO().GetComponent<Transform> ().Find ("bandera").gameObject.SetActive (false);

		}

	}
	
}
