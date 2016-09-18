/******************************************************************************\
* Copyright (C) Leap Motion, Inc. 2011-2014.                                   *
* Leap Motion proprietary. Licensed under Apache 2.0                           *
* Available at http://www.apache.org/licenses/LICENSE-2.0.html                 *
\******************************************************************************/

using UnityEngine;
using System.Collections;
using Leap;

// The finger model for our rigid hand made out of various cubes.
public class RigidFinger : SkeletalFinger {

  public float filtering = 0.5f;

  //New args
  private InputManager inputManagerScript;
  private LineRenderer laser;
  private bool debugRaycaster = false;

  void Start() {
    for (int i = 0; i < bones.Length; ++i) {
      if (bones[i] != null)
        bones[i].GetComponent<Rigidbody>().maxAngularVelocity = Mathf.Infinity;
    }
	
	//Input manager
	inputManagerScript = GameObject.Find ("InputManager").GetComponent<InputManager>();
  }

  public override void InitFinger() {
    base.InitFinger();
	
	//Append to track finger cursor
	if (debugRaycaster && laser == null){
		laser = gameObject.AddComponent<LineRenderer>();
		laser.material = new Material (Shader.Find("Diffuse"));
		laser.material.SetColor("_Color", Color.red);
		laser.SetWidth (0.05f, 0.05f);
		laser.SetVertexCount(2);
	}
	if(fingerType == Finger.FingerType.TYPE_INDEX) 
		RaycastIndexSelection();
	////////////////////////////////////////

  }

  public override void UpdateFinger() {

    for (int i = 0; i < bones.Length; ++i) {
      if (bones[i] != null) {
        // Set bone dimensions.
        CapsuleCollider capsule = bones[i].GetComponent<CapsuleCollider>();
        if (capsule != null)
        {
          // Initialization
          capsule.direction = 2;
          bones[i].transform.localScale = new Vector3(1f, 1f, 1f);

          // Update
          capsule.radius = GetBoneWidth(i)/2f;
          capsule.height = GetBoneLength(i) + GetBoneWidth(i);
        }

        // Set velocity.
        Vector3 target_bone_position = GetBoneCenter(i);
        
        bones[i].GetComponent<Rigidbody>().velocity = (target_bone_position - bones[i].transform.position) *
                                      ((1 - filtering) / Time.deltaTime);

        // Set angular velocity.
        Quaternion target_rotation = GetBoneRotation(i);
        Quaternion delta_rotation = target_rotation *
                                    Quaternion.Inverse(bones[i].transform.rotation);
        float angle = 0.0f;
        Vector3 axis = Vector3.zero;
        delta_rotation.ToAngleAxis(out angle, out axis);

        if (angle >= 180) {
          angle = 360 - angle;
          axis  = -axis;
        }

        if (angle != 0) {
          float delta_radians = (1 - filtering) * angle * Mathf.Deg2Rad;
          bones[i].GetComponent<Rigidbody>().angularVelocity = delta_radians * axis / Time.deltaTime;
        }
      }
    }
	//Append to track finger cursor
	if(fingerType == Finger.FingerType.TYPE_INDEX) 
		RaycastIndexSelection();
	////////////////////////////////////////

  }

  //Make global selection based on raycast from index finger
  public void RaycastIndexSelection() {
		Vector3 startPos = Camera.main.transform.position;
		Vector3 endPos = GetRay().origin;
		Vector3 dir = endPos - startPos;

		if( debugRaycaster ) laser.SetPosition(0, startPos);
		
		Ray ray = new Ray( startPos, dir );
		RaycastHit[] results = Physics.RaycastAll( ray );
		//Debug.Log ( results.Length );

		if (results.Length > 0){
			for( int i=0; i<results.Length; i++ ){
				GameObject go = results[i].collider.gameObject;
				if (go != null){
					if ( go.transform.root.tag == "Selectable"){
						if ( inputManagerScript != null ){
						    if( inputManagerScript.currentlySelectedObject != go.transform.root){
								inputManagerScript.SetTarget( go.transform.root );
								Debug.Log ( inputManagerScript.currentlySelectedObject.name );
							}
						}
					}
				}
			}
			
		}
		if( debugRaycaster ) laser.SetPosition(1, startPos + dir*1000);
	}
}
