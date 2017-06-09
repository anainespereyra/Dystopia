using UnityEngine;
using System.Collections;

public class VolverABarrio : MonoBehaviour {


	private bool mover = false;
	private Vector3 posInicial, posFinal;
	private float distancia;
	private float startTime;
	private float vel = 50.0F;

	public static VolverABarrio instance;

	void Start(){
		instance = this;
	}


	void Update (){
		
		if (mover == true) {

			Camera.main.transform.position = Vector3.Lerp(posInicial, posFinal,((Time.time - startTime)*vel)/distancia);
			
			if (Camera.main.transform.position.z == posFinal.z) {
				mover = false;

			}
		}
		
	}


	public void ZoomOut(){


		posInicial = Camera.main.transform.position;
		posFinal = new Vector3(0.0f,0.0f,-17.7f);
		distancia = Vector3.Distance(posInicial, posFinal);
		startTime = Time.time;
		mover = true;

		//se vuelve a habilitar box collider de edificio correspondiente
		GameObject.Find("Edificio" + GlobalControl.edificioActual).GetComponent<BoxCollider2D>().enabled = true;

		//En este momento no estamos en ningun edificio
		GlobalControl.edificioActual = 0;

		CanvasController.instance.botonEdificios.interactable = false;

	}


}
