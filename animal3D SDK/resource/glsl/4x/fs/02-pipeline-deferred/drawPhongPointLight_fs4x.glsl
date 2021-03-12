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

flat in int vInstanceID;

//layout (location = 0) out vec4 rtFragColor;
layout (location = 0) out vec4 rtDiffuseLight;
layout (location = 1) out vec4 rtSpecularLight;

//not doing a loop of lights only one
	//calculate the phong component of light for one light
varying vec4 vBiasClipPosition; //maybe I need to bring it in as well

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
	pointLightData uLightData; //made it an array for max lights (maybe should be ucount?)
};

uniform sampler2D uImage00; //diffuse?
uniform sampler2D uImage01; //specular?
uniform sampler2D uImage07; //depth

float attenuation(in float dist, in float distSq, in float lightRadiusInv, in float lightRadiusInvSq);

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE MAGENTA
	//rtFragColor = vec4(1.0, 0.0, 1.0, 1.0);
	vec4 screen_space = vec4(vBiasClipPosition.x / vBiasClipPosition.w, vBiasClipPosition.y / vBiasClipPosition.w, 
	vBiasClipPosition.z / vBiasClipPosition.w, 1.0);
	vec4 diffuse = texture(uImage00, screen_space.xy);
	vec4 specular = texture(uImage01, screen_space.xy);
	vec4 depth = texture(uImage07, screen_space.xy); //screen_space here?
	vec4 finalColor;
	float attentuate;
	float dist;
	vec3 L = uLightData.position.xyz - vBiasClipPosition.xyz;

	dist = length(L);
	attentuate = attenuation(dist, pow(dist,2), uLightData.radiusInv, uLightData.radiusInvSq);
	diffuse += uLightData.color * diffuse * attentuate;
	specular += uLightData.color * specular * attentuate;
	finalColor += vec4(diffuse.xyz + specular.xyz, 0.0);
	
	rtDiffuseLight = diffuse;
	rtSpecularLight = specular;
