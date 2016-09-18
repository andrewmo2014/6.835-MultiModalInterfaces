using UnityEngine;
using System.Collections;

public class ReticleText : MonoBehaviour {
	public GameObject CameraFacing;
	public GameObject Target;
	public GameObject Reticle;
	public TextMesh planeInfo;
	private Vector3 originalScale;

	public string planeName;

	public float SCALING_FACTOR = 1.0f;
	public float ROT_Y = 1.0f;
	public float distance = 1.0f;

	
	// Use this for initialization
	void Start () {
		originalScale = transform.localScale*SCALING_FACTOR;
//		CameraFacing = Camera.main;
	}
	
	// Update is called once per frame
	void Update () {

		Vector3 heading = (Target.transform.position) - CameraFacing.transform.position;
		Vector3 direction = heading/heading.magnitude;
		Quaternion rotOffset = Quaternion.AngleAxis(ROT_Y, Vector3.up);

		transform.position = CameraFacing.transform.position +
			rotOffset*direction*distance;
		transform.LookAt (CameraFacing.transform.position);
		transform.Rotate (0.0f, 180.0f, 0.0f);

		transform.localScale = originalScale * SCALING_FACTOR;

		planeInfo.text = "Airline: " + planeName + "\nDest: KSFO\nLon: " +
			Target.transform.position.x.ToString("F2") + 
				"\nLat: " +  Target.transform.position.y.ToString("F2");
	}
}