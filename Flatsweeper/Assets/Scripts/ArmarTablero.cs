using UnityEngine;
using System.Collections;
using System.Collections.Generic;


public class ArmarTablero : MonoBehaviour {

	//Se carga prefab de ventana e imagen para conseguir tamaño
	public GameObject ventanaPref;
	public GameObject imagen;
	public int edificio;

	//se definen cantidad de filas y columnas de edificio
	private int xFichas;
	private int yFichas;
	private int cantidadMinas;

	float tamañoVentanaX, tamañoVentanaY;
	float xOffset, yOffset;
	float tamañoEdificioX, tamañoEdificioY;

	void Start () {

		switch (edificio) {

		case 1:
			xFichas = GlobalControl.xFichasE1N1;
			yFichas = GlobalControl.yFichasE1N1;
			cantidadMinas = GlobalControl.minasE1N1;
			break;
		case 2:
			xFichas = GlobalControl.xFichasE2N1;
			yFichas = GlobalControl.yFichasE2N1;
			cantidadMinas = GlobalControl.minasE2N1;
			break;
		case 3:
			Debug.Log("");
			xFichas = GlobalControl.xFichasE3N1;
			yFichas = GlobalControl.yFichasE3N1;
			cantidadMinas = GlobalControl.minasE3N1;
		break;
		}


		//se mide tamaño de ventana
		tamañoVentanaX = imagen.gameObject.GetComponent<SpriteRenderer> ().bounds.size.x;
		tamañoVentanaY = imagen.gameObject.GetComponent<SpriteRenderer> ().bounds.size.y;

		//se calcula tamaño de edificio
		tamañoEdificioX = tamañoVentanaX * xFichas;
		tamañoEdificioY = tamañoVentanaY * yFichas;

		if (cantidadMinas > xFichas*yFichas) {
			cantidadMinas = xFichas*yFichas;
		}


		//se colocan ventanas
		ColocarFichas ();

		//Se agrega box collider al edificio del tamaño correspondiente
		BoxCollider2D bc =  gameObject.AddComponent<BoxCollider2D>();
		bc.size = new Vector2(tamañoEdificioX, tamañoEdificioY);

	}


	void ColocarFichas(){

		//se establece donde empezaran a posicionarse las ventanas
		xOffset = - tamañoEdificioX/2 + tamañoVentanaX/2;
		yOffset = tamañoEdificioY/2 - tamañoVentanaY/2;

		int f = 0;

		Listas.ListaEdificios[edificio-1] = Program.GenerarTablero(xFichas, yFichas, cantidadMinas );

		for(int i = 0; i < xFichas; i++) {
			for(int j = 0; j < yFichas; j++) {

				//Se crea ventana
				GameObject ventana = Instantiate(ventanaPref, new Vector3(transform.position.x + xOffset, transform.position.y + yOffset, transform.position.z), transform.rotation) as GameObject;
				//Se situa ventana como hija del edificio
				ventana.transform.parent = gameObject.transform;

				//Se agrega box collider a ventana del tamaño correspondiente
				BoxCollider2D bc2 =  ventana.gameObject.AddComponent<BoxCollider2D>();
				bc2.size = new Vector2(tamañoVentanaX, tamañoVentanaY);

				//Colocar ventanaObject en ListaCasillas
				Listas.ListaEdificios[edificio-1][f].setGO(ventana);

				//se colocan imagenes aleatorias
				int rand = Random.Range (1,4);

				//Debug.Log ("num " + ListaCasillas[f].getNumero());

				//se selecciona imagen a mostrar
				foreach (Transform t in ventana.transform){
					if(t.name == "imgAbajo"+rand){
						t.gameObject.SetActive(true);
					}
					if (t.name == "numero"+ Listas.ListaEdificios[edificio-1][f].getNumero() && !Listas.ListaEdificios[edificio-1][f].getMina()){
						t.gameObject.SetActive(true);
					}
					if (t.name == "mina" && Listas.ListaEdificios[edificio-1][f].getMina()){
						t.gameObject.SetActive(true);
					}
					if (t.name == "imgArriba"){
						foreach (Transform p in t.transform){
							if (p.name == "imgArriba"+rand){
								p.gameObject.SetActive(true);
							}
						}
					}
				}
				yOffset -= tamañoVentanaY;
				f ++;
			}

			xOffset += tamañoVentanaX;
			yOffset = tamañoEdificioY/2 - tamañoVentanaY/2; //tiene que ser igual que el yOffset definido al comienzo
		}
	}

}
