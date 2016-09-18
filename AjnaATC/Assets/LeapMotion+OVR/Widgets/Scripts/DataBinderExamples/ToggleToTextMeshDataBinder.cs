using UnityEngine;
using System.Collections;
using LMWidgets;

public class ToggleToTextMeshDataBinder : DataBinderToggle {
	[SerializeField] 
	public TextMesh uiText;
	public GameObject player;
	
	override public bool GetCurrentData() {
		if ( uiText.text == "Camera 1" ) {
			return true;
		}
		else {
			return false;
		}
	}
	
	override protected void setDataModel(bool value) { 
		if ( value == true ) { 
			uiText.text = "Camera 1";
			player.GetComponent<LocSwitch>().ToggleLoc();
		}
		else {
			uiText.text = "Camera 2";
			player.GetComponent<LocSwitch>().ToggleLoc();
		}
	}
}
