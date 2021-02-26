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
	
	drawPhong_shadow_fs4x.glsl
	Output Phong shading with shadow mapping.
*/

#version 450

// ****DONE?:
// 1) Phong shading
//	-> identical to outcome of last project
// 2) shadow mapping
//	-> declare shadow map texture
//	-> declare shadow coordinate varying
//	-> perform manual "perspective divide" on shadow coordinate
//	-> perform "shadow test" (explained in class)

layout (location = 0) out vec4 rtFragColor;
layout (binding = 0) uniform sampler2D image;
uniform int uCount;

uniform sampler2D uTex_shadow;


in vec4 vShadowcoord;
in vec4 vPosition;
in vec4 vNormal;
in vec2 vTexcoord;
in vec4 vView;

uniform sampler2D uAtlas;

float shininess = 128.0;

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
	sPointLightData uLightData[4];
};


void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE LIME
	rtFragColor = vec4(0.0);

	// diffuse coeff = dot(unit surface normal,
	//                     unit light vector)

	vec4 V = normalize(vView);
	vec4 N = normalize(vNormal);
	vec4 materialColor = texture2D(image, vTexcoord); //Getting the pixelColor from the sampler
	vec3 shadowColor = textureProj(uTex_shadow, vShadowcoord).rgb;
	for(int i = 0; i < uCount; i++)
	{
		vec4 L = normalize(uLightData[i].position - vPosition);

		float lightDistance = length(L);

		vec4 reflection = reflect(-L, N); //The reflection for the specular calculation

		vec4 diffuse = max(dot(N, L), 0.0) * materialColor;

		vec4 specular = pow(max(dot(reflection, V), 0.0), shininess) * materialColor;

		vec4 specularColor = uLightData[i].color * specular; //The specular color

		vec4 diffuseColor =uLightData[i].color * diffuse; //the diffuse color

		vec4 phong = diffuseColor + specularColor;

		rtFragColor += phong;
	}
	rtFragColor *=  vec4(shadowColor, 1.0);
	// DEBUGGING
	//rtFragColor = vec4(kd,kd,kd,1.0);
}

