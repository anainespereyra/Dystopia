using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;

public class CanvasController : MonoBehaviour {

	public static CanvasController instance;

	public GameObject canvasPerdiste;
	public GameObject canvasPausa;
	public GameObject canvasGanaste;
	public GameObject canvasFijo;

	public Button botonPausa, botonEdificios;

	public bool panelActivado;
	

	void Start () {
		instance = this;
		panelActivado = false;

	}

	public void activarPanelPerdiste(){
		panelActivado = true;
		canvasFijo.SetActive (false);
		canvasPerdiste.SetActive (true);
	}

	public void activarPanelGanaste(){
		panelActivado = true;
		canvasFijo.SetActive (false);
		canvasGanaste.SetActive (true);
	}

	public void activarPanelPausa(){
		panelActivado = true;
		desactivarBotones ();
		canvasPausa.SetActive (true);
	}

	public void desactivarPanelPausa(){
		panelActivado = false;
		activarBotones();
		canvasPausa.SetActive (false);
	}


	public void desactivarBotones(){
		//desactivar botones de menu
		botonEdificios.interactable = false;
		botonPausa.interactable = false;
	}

	public void activarBotones(){
		botonPausa.interactable = true;
		if (GlobalControl.edificioActual != 0) {
			botonEdificios.interactable = true;
		}
	}
}
