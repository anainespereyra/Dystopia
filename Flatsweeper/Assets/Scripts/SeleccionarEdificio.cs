using UnityEngine;
using System.Collections;

public class SeleccionarEdificio : MonoBehaviour {

	public int edificio;
	private bool mover = false;


	private Vector2 pos;
	private Vector3 posInicial, posFinal;
	private float distancia;
	private float startTime;
	private float vel = 50.0F;



	void Update (){

		if (mover == true) {

			Camera.main.transform.position = Vector3.Lerp(posInicial, posFinal,((Time.time - startTime)*vel)/distancia);

			if (Camera.main.transform.position.z == posFinal.z) {
					mover = false;
			}
		}

	}

	void OnMouseUp(){

		//se lee posicion de edificio
		pos = gameObject.transform.position;

		float posEdy = 0f;
		float posEdz = 0f;

		switch (edificio) {
		case 1:
			posEdy = pos.y;
			posEdz = -10.0f;
			break;
		case 2:
			posEdy = -6.43f;
			posEdz = -6.56f;
			break;
		}


		//se situa camara en posicion de edificio
		posFinal = new Vector3(pos.x,posEdy,posEdz);
		posInicial = Camera.main.transform.position;
		distancia = Vector3.Distance(posInicial, posFinal);

		if (GlobalControl.edificioActual == 0 && !CanvasController.instance.panelActivado){

			startTime = Time.time;
			mover = true;

			//se desactiva collider de edificio
			gameObject.GetComponent<BoxCollider2D>().enabled = false;

			// se guarda numero de edificio en variable global
			GlobalControl.edificioActual = edificio;

		}
		CanvasController.instance.botonEdificios.interactable = true;
	}


}
