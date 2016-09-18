using UnityEngine;
using System.Collections;
using UnityStandardAssets.Cameras;

public class InputManager : MonoBehaviour {

	public Transform currentlySelectedObject;
	public GameObject pilotAutoCam;

	// Use this for initialization
	void Start () {

	}
	
	// Update is called once per frame
	void Update () {
	
	}

	public void SetTarget( Transform obj ){
		currentlySelectedObject = obj;
		//pilotAutoCam.GetComponent<AutoCam>().SetTarget( currentlySelectedObject );

		//
		currentlySelectedObject.gameObject.GetComponent<ChangeMaterial>().ToggleMaterial( true );
	}
}
