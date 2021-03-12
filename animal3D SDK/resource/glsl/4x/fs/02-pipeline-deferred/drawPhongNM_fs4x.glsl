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
	
	drawPhongNM_fs4x.glsl
	Output Phong shading with normal mapping.
*/

#version 450

#define MAX_LIGHTS 1024

// ****DONE:
//	-> declare view-space varyings from vertex shader
//	-> declare point light data structure and uniform block
//	-> declare uniform samplers (diffuse, specular & normal maps)
//	-> calculate final normal by transforming normal map sample
//	-> calculate common view vector
//	-> declare lighting sums (diffuse, specular), initialized to zero
//	-> implement loop in main to calculate and accumulate light
//	-> calculate and output final Phong sum

uniform int uCount;

layout (location = 0) out vec4 rtFragColor;



uniform sampler2D uImage00; // Diffuse Atlas
uniform sampler2D uImage01; // Specular Atlas
uniform sampler2D uImage02; //nrm
uniform sampler2D uAtlas;

// location of viewer in its own space is the origin
const vec4 kEyePos_view = vec4(0.0, 0.0, 0.0, 1.0);

// declaration of Phong shading model
//	(implementation in "utilCommon_fs4x.glsl")
//		param diffuseColor: resulting diffuse color (function writes value)
//		param specularColor: resulting specular color (function writes value)
//		param eyeVec: unit direction from surface to eye
//		param fragPos: location of fragment in target space
//		param fragNrm: unit normal vector at fragment in target space
//		param fragColor: solid surface color at fragment or of object
//		param lightPos: location of light in target space
//		param lightRadiusInfo: description of light size from struct
//		param lightColor: solid light color
void calcPhongPoint(
	out vec4 diffuseColor, out vec4 specularColor,
	in vec4 eyeVec, in vec4 fragPos, in vec4 fragNrm, in vec4 fragColor,
	in vec4 lightPos, in vec4 lightRadiusInfo, in vec4 lightColor
);

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

in vec4 vPosition;
in vec4 vNormal;
in vec4 vTexcoord;

in vec4 vPosition_screen;


void main()
{
	vec4 N = normalize(texture(uImage02, vTexcoord.xy) * 2.0);

	

	vec4 diffuseColor, specularColor;
	vec4 finalDiff, finalSpec = vec4(0.0f);
	vec4 color = texture(uAtlas, vTexcoord.xy);

	for(int i = 0; i < uCount; i++)
	{
		vec4 radiusInfo = vec4(uPointLightData[i].radius, uPointLightData[i].radiusSq, uPointLightData[i].radiusInv, uPointLightData[i].radiusInvSq);

		calcPhongPoint(diffuseColor,specularColor,kEyePos_view, vPosition, N, color, uPointLightData[i].position, radiusInfo, uPointLightData[i].color);
		finalDiff += diffuseColor;
		finalSpec += specularColor;
	}

	rtFragColor = vec4((finalDiff+finalSpec).xyz,1.0);

	// DUMMY OUTPUT: all fragments are OPAQUE MAGENTA
	//rtFragColor = vec4(1.0, 0.0, 1.0, 1.0);
}
