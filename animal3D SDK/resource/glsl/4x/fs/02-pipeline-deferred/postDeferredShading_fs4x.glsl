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
	
	postDeferredShading_fs4x.glsl
	Calculate full-screen deferred Phong shading.
*/

#version 450

#define MAX_LIGHTS 1024

// ****TO-DO:
//	-> this one is pretty similar to the forward shading algorithm (Phong NM) 
//		except it happens on a plane, given images of the scene's geometric 
//		data (the "g-buffers"); all of the information about the scene comes 
//		from screen-sized textures, so use the texcoord varying as the UV
//	-> declare point light data structure and uniform block
//	-> declare pertinent samplers with geometry data ("g-buffers")
//	-> use screen-space coord (the inbound UV) to sample g-buffers
//	-> calculate view-space fragment position using depth sample
//		(hint: modify screen-space coord, use appropriate matrix to get it 
//		back to view-space, perspective divide)
//	-> calculate and accumulate final diffuse and specular shading

in vec4 vTexcoord_atlas;

uniform int uCount;

uniform sampler2D uImage00; // Diffuse Atlas
uniform sampler2D uImage01; // Specular Atlas
uniform sampler2D uImage04; // texCoords g-buffer
uniform sampler2D uImage05; // normals  g-buffer
//uniform sampler2D uImage06; // position g-buffer
uniform sampler2D uImage07; // depth g-buffer
uniform sampler2D uTex_dm;
uniform vec4 uColor;
//Testing
//uniform sampler2D uImage02, uImage03; //nrm, ht

uniform mat4 uPB_inv; //inverse bias projection

layout (location = 0) out vec4 rtFragColor;



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

float attenuation(in float dist, in float distSq, in float lightRadiusInv, in float lightRadiusInvSq);


void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE ORANGE
	//rtFragColor = vec4(1.0, 0.5, 0.0, 1.0);

	vec4 sceneTexcoord = texture(uImage04, vTexcoord_atlas.xy);
	vec4 diffuseSample = texture(uImage00,  sceneTexcoord.xy);
	vec4 specularSample = texture(uImage01,  sceneTexcoord.xy);

	vec4 position_screen = vTexcoord_atlas;
	position_screen.z = texture(uImage07, vTexcoord_atlas.xy).r;

	vec4 position_view = uPB_inv * position_screen;
	position_view /= position_view.w; //reverse perspective divide
	//from view to bias clip we need a projection bias
	//to get back to view we need to get the inverse


	vec4 normal = texture(uImage05, vTexcoord_atlas.xy);
	normal = (normal - 0.5) * 2.0; //Still in camera space

	// Phong shading:
	// ambient
	// + diffuse color * diffuse light
	// + specular color * specular light
	//have:
	// -> diffuse/specular colors
	// have not:
	// -> light stuff
	//		-> light data -> light data struct -> uniform buffer
	//		-> normals, position, depth -> geometry buffers!!!
	//	-> texture coords -> g-buffer
	//		
	
	vec4 finalColor = vec4(0.0,0.0,0.0,1.0);
	vec4 finalDiff = vec4(0.0);
	vec4 finalSpec = vec4(0.0);
	
	for(int i = 0; i < uCount; i++)
	{
		
		vec3 L = uPointLightData[i].position.xyz - position_view.xyz;
		float dist = length(L);
		L = normalize(L);
		vec3 N = normalize(normal.xyz);
		vec3 R = reflect(-L, N);
		


		vec3 diffuse = (max(0.0,dot(N,L))*0.9+0.1) * diffuseSample.xyz;
		vec3 specular = pow(max(dot(R, normalize(position_screen).xyz),0.0),specularSample.w) * specularSample.xyz;

		float A = attenuation(dist, dist*dist, uPointLightData[i].radiusInv, uPointLightData[i].radiusInvSq);
		vec3 diffuse_color = uPointLightData[i].color.xyz * diffuse * A;
		vec3 specular_color = uPointLightData[i].color.xyz * specular * A;
		finalDiff += vec4(diffuse_color.xyz, 0.0);
		finalSpec += vec4(specular_color,1.0);
	}

	rtFragColor = vec4(finalDiff.xyz + finalSpec.xyz,diffuseSample.a);
	


	//final transparency
	//rtFragColor.a = diffuseSample.a;
}
