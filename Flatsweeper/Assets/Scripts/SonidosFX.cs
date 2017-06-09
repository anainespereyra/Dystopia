using UnityEngine;
using System.Collections;

public class SonidosFX : MonoBehaviour {

	public static SonidosFX instance;

	public AudioClip sonidoDestapa;
	public AudioClip sonidoBandera;
	public AudioClip sonidoBomba;
	public AudioClip sonidoPerdiste;
	public AudioClip sonidoClick;
	public AudioClip sonidoCompletarEdificio;



	void Start () {
		instance = this;
	}



	public void reproducirSonido(AudioClip sonido){

		gameObject.GetComponent<AudioSource> ().PlayOneShot(sonido);

	}



}
