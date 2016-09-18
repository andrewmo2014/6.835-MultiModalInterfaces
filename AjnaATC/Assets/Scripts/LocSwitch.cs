using UnityEngine;
using System.Collections;

public class LocSwitch : MonoBehaviour {

	private Vector3 originalPos;
	public GameObject alternatePos;
	private bool toggleSwitch;
	private bool activateSwitch;

	void Awake(){
		toggleSwitch = false;
		activateSwitch = false;
	}

	// Use this for initialization
	void Start () {
		originalPos = transform.position;
	}
	
	// Update is called once per frame
	void Update () {

		if (Input.GetKeyDown(KeyCode.Space) || activateSwitch){
			toggleSwitch = !toggleSwitch;
			SwitchLocs();
			activateSwitch = false;
		}
	}

	public void ToggleLoc(){
		activateSwitch = true;
	}

	private void SwitchLocs(){
		transform.position = (toggleSwitch) ? alternatePos.transform.position : originalPos;
	}
}
