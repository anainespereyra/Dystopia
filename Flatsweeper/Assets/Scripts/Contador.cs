using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class Contador : MonoBehaviour {
	

	public static Contador instance;

	private int promedio;

	void Start(){
	
		instance = this;
		promedio = 0;
		gameObject.GetComponent<Text> ().text = promedio.ToString();
	}


	public void promedioContador(int num){

		if (promedio == 0) {
			promedio = num;
		} else {
			promedio = (promedio + num) / 2;		
		}


		gameObject.GetComponent<Text>().text = "€ " + promedio.ToString();

	}


}
