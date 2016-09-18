using UnityEngine;
using System.Collections;

public class Reticle : MonoBehaviour {
	public Camera CameraFacing;
	public GameObject Target;
	private Vector3 originalScale;

	public float SCALING_FACTOR = 1/5.0f;
	public Vector3 RETICLE_TARGET_OFFSET = new Vector3( 0.0f, 5.0f, 0.0f );
	
	// Use this for initialization
	void Start () {
		originalScale = transform.localScale*SCALING_FACTOR;
	}
	
	// Update is called once per frame
	void Update () {

		float distance = CameraFacing.farClipPlane * 0.95f;

		Vector3 heading = Target.transform.position - CameraFacing.transform.position;

		transform.position = CameraFacing.transform.position +
			(heading/heading.magnitude) * distance + RETICLE_TARGET_OFFSET;
		transform.LookAt (CameraFacing.transform.position);
		transform.Rotate (0.0f, 180.0f, 0.0f);


		transform.localScale = originalScale * distance;
	}
}