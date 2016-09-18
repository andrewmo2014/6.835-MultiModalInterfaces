using UnityEngine;
using System.Collections;

public class ChangeMaterial : MonoBehaviour {

	// Use this for initialization
	public Material[] originalMat;
	public Material[] selectedMat;

	private Renderer[] childRenderers; 
	private Material[] currentMaterials;

	void Start () {

		childRenderers = GetComponentsInChildren<Renderer>() as Renderer[];
		currentMaterials = GetComponentInChildren<Renderer>().materials as Material[];
	
	}
	
	// Update is called once per frame
	void Update () {
			
	}

	public void ToggleMaterial( bool isSelected ){

		if(isSelected){
			for( int i=0; i<childRenderers.Length; i++ ){
				childRenderers[i].materials = selectedMat;
			}
		}
		else{
			for( int i=0; i<childRenderers.Length; i++ ){
				childRenderers[i].materials = originalMat;
			}
		}
	}

}
