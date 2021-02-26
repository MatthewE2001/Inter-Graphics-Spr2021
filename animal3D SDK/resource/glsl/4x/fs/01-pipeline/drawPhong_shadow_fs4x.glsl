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

// ****TO-DO:
// 1) Phong shading
//	-> identical to outcome of last project
// 2) shadow mapping
//	-> declare shadow map texture
//	-> declare shadow coordinate varying
//	-> perform manual "perspective divide" on shadow coordinate
//	-> perform "shadow test" (explained in class)

/*
I made changes within this file - Matthew Esslie

They are heavily based on the blue book code pg. 622 of the pdf
*/

layout (location = 0) out vec4 rtFragColor;

uniform int uCount;

in vec4 vShadowcoord;
in vec4 vNormal;
in vec4 vView;
in vec2 vTexcoord;
in vec4 vPosition;

float shine = 120.0;

uniform sampler2D uAtlas;
uniform sampler2D uTex_shadow;

layout (binding = 0) uniform sampler2D image;


struct sPointLightData
{
	vec4 position;
	vec4 worldPos;
	vec4 color;
	float radius;
	float radiusSq;
	float radiusinv;
	float radiusinvSq;
};

uniform ubLight
{
	sPointLightData uLightData[4];
};

//declare shadow map texture here

void main()
{
	vec4 nView = normalize(vView);
	vec4 nNormal = normalize(vNormal); //I have it set to nNormal, nLight, nView so I know they are the normalized ones
	vec4 materialColor = texture2D(uAtlas, vTexcoord);
	vec3 shadowColor = textureProj(uTex_shadow, vShadowcoord).rgb; 
	rtFragColor = vec4(0.0);
	// DUMMY OUTPUT: all fragments are OPAQUE MAGENTA
	
	for (int i = 0; i < uCount; i++)
	{
		vec4 nLight = normalize(uLightData[i].position - vPosition); //to get light to model location

		float lightDistance = length(nLight);

		vec4 reflection = reflect(-nLight, nNormal);

		vec4 diffuse = max(dot(nNormal, nLight), 0.0) * materialColor;
		vec4 specular = pow(max(dot(reflection, nView), 0.0), shine) * materialColor;

		vec4 specularColor = uLightData[i].color * specular;
		vec4 diffuseColor = uLightData[i].color * diffuse;

		vec4 phong = diffuseColor + specularColor;

		//rtFragColor = vec4(1.0, 0.0, 1.0, 1.0);
		rtFragColor += phong;
	}

	rtFragColor *= vec4(shadowColor, 1.0);
}
