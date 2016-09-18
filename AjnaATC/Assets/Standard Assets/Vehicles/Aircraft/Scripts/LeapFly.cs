using UnityEngine;
using System.Collections;
using System;
using Leap;
using UnityStandardAssets.Vehicles.Aeroplane;

public class LeapFly : MonoBehaviour {
	
	Leap.Controller m_leapController;
	private float threshholdValue = 0.5f;
	public bool makingFist = false;


	public float rollThreshold = 200.0f;
	public float yawThreshold = 200.0f;
	public float pitchThreshold = 200.0f;
	public float thrustThreshold = 200.0f;

	public float rollVal;
	public float yawVal;
	public float pitchVal;
	public float thrustVal;
	public bool twoHands;

	private bool changedToHands;
	
	// Use this for initialization
	void Start () {
		m_leapController = new Controller();
		changedToHands = false;
		twoHands = false;
	}

	void FixedUpdate () {

			Frame frame = m_leapController.Frame();
			
			if (frame.Hands.Count >= 2) {
				twoHands = true;
				Hand leftHand = frame.Hands.Leftmost;
				Hand rightHand = frame.Hands.Rightmost;
				
				// takes the average vector of the forward vector of the hands, used for the
				// pitch of the plane.
	//			Vector3 avgPalmForward = (frame.Hands[0].Direction.ToUnity() + frame.Hands[1].Direction.ToUnity()) * 0.5f;
				
	//			Vector3 handDiff = leftHand.PalmPosition.ToUnityScaled() - rightHand.PalmPosition.ToUnityScaled();
	//			
	//			Vector3 newRot = transform.localRotation.eulerAngles;
	//			newRot.z = -handDiff.y * 200.0f;

				//Position in millimeters for precision
				Vector3 leftHandPos = leftHand.PalmPosition.ToUnity();
				Vector3 rightHandPos = rightHand.PalmPosition.ToUnity();

				//Direction from right to left
				Vector3 handDiff = leftHandPos - rightHandPos;
				Vector3 avgLoc = (leftHandPos + rightHandPos)*0.5f;

				//Perpendicular vector
				Vector3 rot = Quaternion.Euler(0, -90, 0) * handDiff;

				rollVal = rot.x/rollThreshold;
				yawVal = -rot.y/yawThreshold;
				pitchVal = -avgLoc.z/pitchThreshold;

				Vector3 passing = new Vector3( rollVal, pitchVal, yawVal );
				Debug.Log ( passing );


				//rot.x 200
				//rot.y 200

				//Yaw avg.z 200
				//Debug.Log (avgLoc);

				//150-300


				//Vector3 heading = avgLoc - Camera.main.transform.position;
				//Vector3 direction = heading/heading.magnitude;


				//loat forW = Vector3.Dot(Camera.main.transform.forward, direction);

	//			Debug.Log (forW);

	//			
	//			// adding the rot.z as a way to use banking (rolling) to turn.
	//			newRot.y -= handDiff.z * 3.0f - newRot.z * 0.03f * transform.GetComponent<Rigidbody>().velocity.magnitude;
	//			newRot.x = -(avgPalmForward.y - 0.1f) * 100.0f;
	//			
	//			float forceMult = 30.0f;



				// if closed fist, then stop the plane and slowly go backwards.
				if (checkFist(leftHand) || checkFist(rightHand)) {
	//				Debug.Log ( "making fist" );
					makingFist = true;
	//				forceMult = -3.0f;
				}
				else{
					makingFist = false;
				}
				//			Debug.Log ( rot );
				
				if(!changedToHands){
					GetComponent<ChangeMaterial>().ToggleMaterial(true);
					changedToHands = true;
				}
				
			}
			else{
				twoHands = false;
				rollVal = 0;
				yawVal = 0;
				pitchVal = 0;
				makingFist = false;
				
				if(changedToHands){
					GetComponent<ChangeMaterial>().ToggleMaterial(false);
					changedToHands = false;
				}
				
			}

	}
	
	public int getExtendedFingers(Hand hand){

//			Quaternion rot = Quaternion.Slerp(transform.localRotation, Quaternion.Euler(newRot), 0.1f);
//			transform.GetComponent<Rigidbody>().velocity = transform.forward * forceMult;


		int f = 0;
		for(var i=0;i<hand.Fingers.Count;i++){
			if(hand.Fingers[i].IsExtended){
				f++;
			}
		}
		return f;
	}
	
	public bool checkFist(Hand hand){
		FingerList fingers = hand.Fingers;
		int sum=0;
		foreach(Finger finger in fingers){
			Bone bone;
			Vector meta = Vector.Zero;
			Vector proxi = Vector.Zero;
			Vector inter = Vector.Zero;
			foreach (Bone.BoneType boneType in (Bone.BoneType[]) Enum.GetValues(typeof(Bone.BoneType)))
			{
				switch( boneType  ){
					case Bone.BoneType.TYPE_METACARPAL:
						meta = finger.Bone(boneType).Direction;
						break;
					case Bone.BoneType.TYPE_PROXIMAL:
						proxi = finger.Bone(boneType).Direction;
						break;
					case Bone.BoneType.TYPE_INTERMEDIATE:
						inter = finger.Bone(boneType).Direction;
						break;
					default:
						break;
				}
			}

			float dMetaProxi = meta.Dot(proxi);
			float dProxiInter = proxi.Dot(inter);
			sum += (int)dMetaProxi;
			sum += (int)dProxiInter;
		}
		sum = sum/10;


		if(sum<=threshholdValue && getExtendedFingers(hand)==0){
			return true;
		}else{
			return false;
		}

	}


}