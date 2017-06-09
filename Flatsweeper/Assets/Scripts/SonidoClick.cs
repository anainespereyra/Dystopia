using UnityEngine;
using System.Collections;

public class SonidoClick : MonoBehaviour {


	public void Click () {
		SonidosFX.instance.reproducirSonido(SonidosFX.instance.sonidoClick);
	}
}
