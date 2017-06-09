using UnityEngine;
using System.Collections;

public class Musica : MonoBehaviour {

	public static Musica instance;
	
	public AudioClip musicaMenu;
	public AudioClip musicaJuego;
	public AudioClip musicaGanaste;
	
	
	void Start () {
		instance = this;
	}
	
	
	
	public void reproducirMusica(AudioClip musica){
		
		gameObject.GetComponent<AudioSource> ().clip = musica;
		if (!gameObject.GetComponent<AudioSource> ().isPlaying) {
			gameObject.GetComponent<AudioSource> ().Play ();
		}

		
	}
}
