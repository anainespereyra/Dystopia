using UnityEngine;
using System.Collections;

public class Casilla {


	int _posX, _posY, _numero, _valorPiso;
	
	bool _mina, _click, _bandera;

	GameObject _GO;


	
	
	public Casilla(int posX, int posY) 	{
		_posX = posX;
		_posY = posY;
		_numero = 0;
		_mina = false;
		_click = false;
		_bandera = false;
		_valorPiso = 0;
	}
	
	/*Getters*/
	public int getPosX()
	{
		return this._posX;
	}
	public int getPosY()
	{
		return this._posY;
	}
	public bool getMina()
	{
		return this._mina;
	}
	public bool getClick()
	{
		return this._click;
	}
	public bool getBandera()
	{
		return this._bandera;
	}
	public int getNumero()
	{
		return this._numero;
	}
	public GameObject getGO()
	{
		return this._GO;
	}
	public int getValorPiso()
	{
		return this._valorPiso;
	}
	
	
	/*Setters*/
	public void setMina()
	{
		this._mina = true;
	}
	public void setBandera()
	{
		this._bandera = true;
	}
	public void setClick()
	{
		this._click = true;
	}
	public void setNumero(int n)
	{
		this._numero = n;
	}
	public void setGO(GameObject go)
	{
		this._GO = go;
	}
	public void setValorPiso(int valor)
	{
		this._valorPiso = valor;
	}


}
