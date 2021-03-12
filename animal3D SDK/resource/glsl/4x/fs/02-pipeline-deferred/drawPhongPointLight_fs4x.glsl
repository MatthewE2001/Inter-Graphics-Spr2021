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
	
	drawPhongPointLight_fs4x.glsl
	Output Phong shading components while drawing point light volume.
*/

#version 450

#define MAX_LIGHTS 1024

// ****TO-DO:
//	-> declare biased clip coordinate varying from vertex shader
//	-> declare point light data structure and uniform block
//	-> declare pertinent samplers with geometry data ("g-buffers")
//	-> calculate screen-space coordinate from biased clip coord
//		(hint: perspective divide)
//	-> use screen-space coord to sample g-buffers
//	-> calculate view-space fragment position using depth sample
//		(hint: same as deferred shading)
//	-> calculate final diffuse and specular shading for current light only

flat in int vInstanceID; //which light this is

uniform sampler2D uImage00; // Diffuse Atlas
uniform sampler2D uImage01; // Specular Atlas
uniform sampler2D uImage04; // texCoords g-buffer
uniform sampler2D uImage05; // normals  g-buffer
//uniform sampler2D uImage06; // position g-buffer
uniform sampler2D uImage07; // depth g-buffer




//NOT A LOOP WORTH OF LIGHTS, JUST 1 LIGHT

in vec4 vBiasedClipSpacePos;

layout (location = 0) out vec4 rtDiffuseLight;
layout (location = 1) out vec4 rtSpecularLight;

struct sPointLightData
{
	vec4 position;					// position in rendering target space
	vec4 worldPos;					// original position in world space
	vec4 color;						// RGB color with padding
	float radius;						// radius (distance of effect from center)
	float radiusSq;					// radius squared (if needed)
	float radiusInv;					// radius inverse (attenuation factor)
	float radiusInvSq;					// radius inverse squared (attenuation factor)
};
uniform ubLight
{
	sPointLightData uPointLightData[MAX_LIGHTS];
};
uniform mat4 uPB_inv; //inverse bias projection
void calcPhongPoint(
	out vec4 diffuseColor, out vec4 specularColor,
	in vec4 eyeVec, in vec4 fragPos, in vec4 fragNrm, in vec4 fragColor,
	in vec4 lightPos, in vec4 lightRadiusInfo, in vec4 lightColor
);
void main()
{

	vec4 screenSpaceCoord = vBiasedClipSpacePos / vBiasedClipSpacePos.w;
	vec4 diffuseSample = texture(uImage00, screenSpaceCoord.xy);
	vec4 specularSample = texture(uImage01, screenSpaceCoord.xy);
	vec4 texCoords = texture(uImage04, screenSpaceCoord.xy);
	vec4 normal = texture(uImage05, screenSpaceCoord.xy);
	vec4 depth = texture(uImage07, screenSpaceCoord.xy);


	vec4 position_screen = screenSpaceCoord;
	position_screen.z = depth.r;

	vec4 position_view = uPB_inv * position_screen;
	position_view /= position_view.w; //reverse perspective divide
	//from view to bias clip we need a projection bias
	//to get back to view we need to get the inverse

	vec4 diffuseColor, specularColor = vec4(0);
	vec4 radiusInfo = vec4(uPointLightData[vInstanceID].radius, uPointLightData[vInstanceID].radiusSq, uPointLightData[vInstanceID].radiusInv, uPointLightData[vInstanceID].radiusInvSq);
	calcPhongPoint(diffuseColor, specularColor, normalize(position_view), position_screen, normalize(normal), diffuseSample, uPointLightData[vInstanceID].position, radiusInfo, uPointLightData[vInstanceID].color);

	rtDiffuseLight = diffuseColor;
	rtSpecularLight = specularColor;

	// DUMMY OUTPUT: all fragments are OPAQUE MAGENTA
	//rtFragColor = vec4(1.0, 0.0, 1.0, 1.0);
}
