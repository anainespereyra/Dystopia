using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class ValorPiso : MonoBehaviour {

	public int valor;
	public GameObject objetoValorPiso;

	public Color bajo, normal, alto;

	public static ValorPiso instance;

	private float growVel;
	private Vector3 tmpS;
	private Color tmpC;
	

	void Start () {

		instance = this;
		valor = 10;
		growVel = 5;

		tmpS = objetoValorPiso.transform.localScale;
		tmpC = objetoValorPiso.GetComponent<Text> ().color;
		tmpC.a = 0.0f;
		objetoValorPiso.GetComponent<Text> ().color = tmpC;
	}


	public void EfectoValorPiso (int valor) {

		int precioBarrio = 0;
		switch (GlobalControl.nivelActual){
		case 1:
			precioBarrio = GlobalControl.precioN1;
			break;
		}

		Contador.instance.promedioContador (valor);


		//pintar valores de colores segun el precio
		//Hay un problema con la opacidad, solucionar
		if (valor >= (int)(precioBarrio * 1.3f)) {
			objetoValorPiso.GetComponent<Text> ().color = alto;
		}

		objetoValorPiso.GetComponent<Text> ().text = "€ " + valor.ToString();
		StartCoroutine(Effect());

	}

	IEnumerator Effect(){

		//se resetean variables
		objetoValorPiso.transform.localScale = tmpS;
		tmpC.a = 1.0f;
		objetoValorPiso.GetComponent<Text> ().color = tmpC;

		while(tmpC.a > 0){
			objetoValorPiso.transform.localScale += new Vector3(1, 1, 0) * Time.deltaTime * growVel;

			tmpC.a -= 0.05f;
			objetoValorPiso.GetComponent<Text> ().color = tmpC;

			yield return null;
		}

	}
}
