using UnityEngine;
using System.Collections;


public class CambiarEscena : MonoBehaviour {

	public string escena;
	

	public void ChangeToScene() {
		Debug.Log ("Cambio a escena: " + escena);
		GlobalControl.edificioActual = 0;
		GlobalControl.edificiosCompletosN1 = 0;
		GlobalControl.edificiosCompletosN2 = 0;
		Application.LoadLevel (escena);

		switch (escena) {
		case "Nivel1":
			GlobalControl.nivelActual = 1;
			Musica.instance.reproducirMusica(Musica.instance.musicaJuego);
			break;
		case "Nivel2":
			GlobalControl.nivelActual = 2;
			Musica.instance.reproducirMusica(Musica.instance.musicaJuego);
			break;
		default:
			GlobalControl.nivelActual = 0;
			Musica.instance.reproducirMusica(Musica.instance.musicaMenu);
			break;
		}

	}
}
