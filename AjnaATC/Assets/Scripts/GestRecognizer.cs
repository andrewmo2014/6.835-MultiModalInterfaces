using UnityEngine;
using System.Collections;
using Leap;

public class GestRecognizer : MonoBehaviour {
	
	Leap.Controller controller;
//	private bool showWidgets;
//	private GameObject[] toggableWidgets;
	private float VerticalUpThreshold;

//	public GameObject firstLCam;
//	public GameObject firstRCam;
//
//	public GameObject secondLCam;
//	public GameObject secondRCam;
//
//	public GameObject thirdLCam;
//	public GameObject thirdRCam;
//
//	public GameObject planeForSecondCam;


//	public bool recCircle;
//	private int numberCam = 2;

	private bool AllowRecog;

	private Vector3 centerOfCircle;
	private Vector3 normalOfCircle;
	
	// Use this for initialization
	void Start () 
	{
		controller = new Controller();
		controller.EnableGesture(Gesture.GestureType.TYPECIRCLE);
		controller.Config.SetFloat("Gesture.Circle.MinRadius", 10.0f);
		controller.Config.SetFloat("Gesture.Circle.MinArc", .5f);
		controller.Config.Save();


//		showWidgets = true;
//		toggableWidgets = GameObject.FindGameObjectsWithTag( "widget" );
		VerticalUpThreshold = 0.85f;

//		recCircle = false;
		AllowRecog = true;


//		SwitchPlanes( numberCam );

		centerOfCircle = Vector3.zero;
		normalOfCircle = Vector3.zero;


	}
		
	// Update is called once per frame
	void Update () 
	{

//		if (Input.GetKeyDown(KeyCode.Space)){
//			numberCam++;
//			SwitchPlanes(numberCam);
//		}

		if (Input.GetKey( KeyCode.R )){
			AllowRecog = true;
		}

		Frame frame = controller.Frame();
		foreach (Gesture gesture in frame.Gestures())
		{

			switch(gesture.Type)
			{
				case(Gesture.GestureType.TYPECIRCLE):
				{
//					if (frame.Hands.Count == 1 && !recCircle){
//						//numberCam++;
//						//recCircle = true;
//						
//					}

					if (AllowRecog == true){
						AnalyzeCircleGesture( new CircleGesture( gesture ) );
						AllowRecog = true;
					}

					break;
				}
				case(Gesture.GestureType.TYPEINVALID):
				{
					//Debug.Log("Invalid gesture recognized.");
					break;
				}
				case(Gesture.GestureType.TYPEKEYTAP):
				{
					//Debug.Log("Key Tap gesture recognized.");
					break;
				}
				case(Gesture.GestureType.TYPESCREENTAP):
				{
					//Debug.Log("Screen tap gesture recognized.");
					break;
				}
				case(Gesture.GestureType.TYPESWIPE):
				{
					//Debug.Log("Swipe gesture recognized.");
					//AnalyzeSwipeGesture( new SwipeGesture( gesture) ); 
					break;
				}
				default:
				{
					break;
				}
			}
		}
	}


//	public void SwitchPlanes( int numCam ){
//
//		if (numCam%3 == 1){
//			firstLCam.GetComponent<Camera>().enabled =  false;
//			firstLCam.gameObject.tag = "Untagged";
//			firstRCam.GetComponent<Camera>().enabled =  false;
//
//			secondLCam.GetComponent<Camera>().enabled =  true;
//			firstLCam.gameObject.tag = "MainCamera";
//
//			secondRCam.GetComponent<Camera>().enabled =  true;
//
//			planeForSecondCam.GetComponent<LeapFly>().enabled = true;
//
//			secondLCam.GetComponent<Camera>().enabled =  false;
//			firstLCam.gameObject.tag = "Untagged";
//			secondRCam.GetComponent<Camera>().enabled =  false;
//		}
//		if (numCam%3 == 2){
//			firstLCam.GetComponent<Camera>().enabled =  false;
//			firstLCam.gameObject.tag = "Untagged";
//			firstRCam.GetComponent<Camera>().enabled =  false;
//			
//			secondLCam.GetComponent<Camera>().enabled =  false;
//			firstLCam.gameObject.tag = "Untagged";
//			secondRCam.GetComponent<Camera>().enabled =  false;
//			
//			planeForSecondCam.GetComponent<LeapFly>().enabled = false;
//			
//			secondLCam.GetComponent<Camera>().enabled =  true;
//			firstLCam.gameObject.tag = "MainCamera";
//			secondRCam.GetComponent<Camera>().enabled =  true;
//		}
//		if (numCam%3 == 0){
//			firstLCam.GetComponent<Camera>().enabled =  true;
//			firstLCam.gameObject.tag = "MainCamera";
//			firstRCam.GetComponent<Camera>().enabled =  true;
//			
//			secondLCam.GetComponent<Camera>().enabled =  false;
//			firstLCam.gameObject.tag = "Untagged";
//			secondRCam.GetComponent<Camera>().enabled =  false;
//			
//			planeForSecondCam.GetComponent<LeapFly>().enabled = false;
//			
//			secondLCam.GetComponent<Camera>().enabled =  false;
//			firstLCam.gameObject.tag = "Untagged";
//			secondRCam.GetComponent<Camera>().enabled =  false;
//		}
//	}
//

	public void AnalyzeCircleGesture( CircleGesture circle ){

//		if( circle.State == Gesture.GestureState.STATESTOP ){

//			Debug.Log("Circle gesture recognized.");

			centerOfCircle = circle.Center.ToUnity();
			normalOfCircle = circle.Normal.ToUnity();

			string clockwiseness;
			if (circle.Pointable.Direction.AngleTo(circle.Normal) <= Mathf.PI/2) {
				clockwiseness = "clockwise";
			}
			else
			{
				clockwiseness = "counterclockwise";
			}

			Pointable circlePointable = circle.Pointable;
			PointableList pointablesForGesture = circle.Pointables;

			float diameter = 2 * circle.Radius;

			float turns = circle.Progress;

			//Debug.Log ( centerOfCircle );
			//Debug.Log ( normalOfCircle );
			//Debug.Log ( clockwiseness );

//			Debug.Log ("CX: " + centerOfCircle.ToString() + "CN: " + normalOfCircle.ToString () + "CR: " + circle.Radius.ToString() + "CS: " + circle.Duration.ToString());
//			Debug.Log ("turns: " + turns.ToString() );
//			Debug.Log ("pointable: " + circlePointable.ToString() ); 
//			Debug.Log ("pointableList: " + pointablesForGesture.Count.ToString() ); 

			if (normalOfCircle.z >= .85 && circle.Radius >= 60 && turns >= 2){
				Debug.Log ( "completed circle" );
			}


//		}


	}



//	public void AnalyzeSwipeGesture( SwipeGesture swipe ){

//		bool isHorizontal = Mathf.Abs(swipe.Direction.x) > Mathf.Abs(swipe.Direction.y);
//		string swipeDirection;
//		//Classify as right-left or up-down
//		if(isHorizontal){
//			if(swipe.Direction.x > 0){
//				swipeDirection = "right";
//			} else {
//				swipeDirection = "left";
//			}
//		} else { //vertical
//			if(swipe.Direction.z < 0){
//				swipeDirection = "up";
//			} else {
//				swipeDirection = "down";
//			}                  
//		}

//		Debug.Log ( swipe.Direction ); 
//
//		if (showWidgets){
//			if (swipe.Direction.z >= VerticalUpThreshold){
//				showWidgets = !showWidgets;
//				foreach (GameObject gObj in toggableWidgets){
//					gObj.SetActive( showWidgets );
//				}
//			}
//		}
//		else{
//			if (swipe.Direction.z <= -VerticalUpThreshold){
//				showWidgets = !showWidgets;
//				foreach (GameObject gObj in toggableWidgets){
//					gObj.SetActive( showWidgets );
//				}
//			}
//		}
//
//	}


	void OnDrawGizmosSelected() {
		Gizmos.color = Color.red;
		Vector3 direction = transform.TransformDirection(normalOfCircle) * 100;
		Gizmos.DrawRay(transform.position, direction);
	}


}