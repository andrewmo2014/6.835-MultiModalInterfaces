using UnityEngine;
using System.Collections;
using LMWidgets;

public class SliderDataBinder : DataBinderSlider {

	public Camera playerCamL;
	public Camera playerCamR;

	private float minFOV = 100.0f;
	private float maxFOV = 110.0f;
	
	override protected void setDataModel(float value) { 

		Debug.Log ( value );

		playerCamL.fieldOfView = minFOV + value*(maxFOV-minFOV);
		playerCamR.fieldOfView = minFOV + value*(maxFOV-minFOV);

	}

	override public float GetCurrentData() {
		return playerCamL.fieldOfView;

	}
}
