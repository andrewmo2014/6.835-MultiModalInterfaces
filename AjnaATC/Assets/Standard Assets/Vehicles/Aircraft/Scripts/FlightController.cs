using UnityEngine;
using System.Collections;
using Leap;

public class FlightController : MonoBehaviour {
	
	Leap.Controller controller;

	Leap.Hand leftHand;
	Leap.Hand rightHand;

//	HandController handController;
	Vector3 currentEyePos;
	Vector3 currentEyeDirection;

	Vector3 velocityT = Vector3.zero;
	Vector3 rotationXYZ = Vector3.zero;
	Matrix4x4 groundMat = Matrix4x4.identity;

	public Vector3 sumPos = Vector3.zero;
	Vector3 sumRot = Vector3.zero;

	// Use this for initialization
	void Start () 
	{
		controller = new Controller();
//		handController = GetComponent<HandController>();

	}
	
	// Update is called once per frame
	void Update () 
	{

//	    Leap.Vector direction = finger.Direction;
//		Vector3 unityDirection = direction.ToUnityScaled(false);
//		Vector3 worldDirection = handController.transform.TransformPoint(unityDirection);

		//4 Axis [-1,1]
		Frame frame = controller.Frame();
		HandList hands = frame.Hands;

		if (hands.Count > 0){

			sumPos = Vector3.zero;
			sumRot = Vector3.zero;

			//Determine individual directions
			for( int i=0; i < hands.Count; i++ ){

//				float pitch = hands[i].Direction.Pitch;
				float pitch = 0.0f;
				float yaw = hands[i].Direction.Yaw;			//Replace Yaw with better one 
				float roll = hands[i].PalmNormal.Roll;

				sumPos += new Vector3(pitch, yaw, roll);

			}
			sumPos /= Mathf.PI;
		}
	}
}