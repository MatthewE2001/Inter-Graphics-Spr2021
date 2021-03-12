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
uniform sampler2D uImage00;
uniform sampler2D uImage01;

uniform sampler2D uImage04; //texcoords gbuffer
uniform sampler2D uImage05; //normal	gbuffer
uniform sampler2D uImage06; //position	gbuffer //we also do not ever really use position
uniform sampler2D uImage07; //depth		gbuffer

uniform mat4 uPB_inv;
uniform mat4 ubo_light; //idk if I need this as well?

layout (location = 0) out vec4 rtFragColor;

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE ORANGE
	//rtFragColor = vec4(1.0, 0.5, 0.0, 1.0);

	vec4 sceneTexcoord = texture(uImage04, vTexcoord_atlas.xy);
	vec4 diffuseSample = texture(uImage00, sceneTexcoord.xy);
	vec4 specularSample = texture(uImage01, sceneTexcoord.xy);
	vec4 diffuseLighting = vec4(1.0); //just temporary values for these two I think
	vec4 specularLighting = vec4(1.0);
	//rtFragColor = diffuseSample;
	vec4 ambient;

	vec4 position_screen = vTexcoord_atlas;
	position_screen.z = texture(uImage07, vTexcoord_atlas.xy).r;

	vec4 position_view = uPB_inv * position_screen;
	position_view /= position_view.w;

	vec4 normal = texture(uImage05, vTexcoord_atlas.xy);
	normal = (normal * 0.5) + vec4(2.0);

	//rtFragColor = position_view;

	//Phong shading
		//ambient
		//+ diffuseColor * diffuseLight
		//+ specularColor * specularLight
	//currently we have the colors above (diffuseSample and specularSample)
	//need the light data from the light data struct
		//which is found in ubo light
		//also need normals, position->??
	ambient += diffuseSample * diffuseLighting;
	ambient += specularSample * specularLighting;
	rtFragColor = ambient;

	//Debugging
	//rtFragColor = vTexcoord_atlas;
}
