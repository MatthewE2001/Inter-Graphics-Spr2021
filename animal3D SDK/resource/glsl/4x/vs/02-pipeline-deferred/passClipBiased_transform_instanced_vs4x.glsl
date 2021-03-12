/*
	Copyright 2011-2021 Daniel S. Buckstein

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

/*
	animal3D SDK: Minimal 3D Animation Framework
	By Daniel S. Buckstein
	
	passClipBiased_transform_instanced_vs4x.glsl
	Calculate and biased clip coordinate with instancing.
*/

#version 450

#define MAX_INSTANCES 1024

// ****TO-DO: 
//	-> declare uniform block containing MVP for all lights
//	-> calculate final clip-space position
//	-> declare varying for biased clip-space position
//	-> calculate and copy biased clip to varying
//		(hint: bias matrix is provided as a constant)

layout (location = 0) in vec4 aPosition;

flat out int vVertexID;
flat out int vInstanceID;

// bias matrix
const mat4 bias = mat4(
	0.5, 0.0, 0.0, 0.0,
	0.0, 0.5, 0.0, 0.0,
	0.0, 0.0, 0.5, 0.0,
	0.5, 0.5, 0.5, 1.0
);

struct pointLightData
{
	vec4 position;					// position in rendering target space
	vec4 worldPos;					// original position in world space
	vec4 color;						// RGB color with padding
	float radius;						// radius (distance of effect from center)
	float radiusSq;					// radius squared (if needed)
	float radiusInv;					// radius inverse (attenuation factor)
	float radiusInvSq;					// radius inverse squared (attenuation factor)
};
//uniform block
uniform uPointLightData
{
	pointLightData uLightData[MAX_INSTANCES]; //made it an array for max lights (maybe should be ucount?)
};

out vec4 vBiasClipPosition;

void main()
{
	// DUMMY OUTPUT: directly assign input position to output position
	//gl_Position = aPosition;
	for (int i = 0; i < MAX_INSTANCES; i++)
	{
		vec4 finalClipSpace = uLightData[i].position - aPosition;
		vBiasClipPosition = bias * finalClipSpace;

		gl_Position = vBiasClipPosition;
	}

	vBiasClipPosition = bias * aPosition; //I might need to come back to this? 
	gl_Position = vBiasClipPosition;

	vVertexID = gl_VertexID;
	vInstanceID = gl_InstanceID;
}
