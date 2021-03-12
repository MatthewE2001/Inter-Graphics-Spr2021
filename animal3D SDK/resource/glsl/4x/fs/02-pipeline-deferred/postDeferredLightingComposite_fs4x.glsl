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
	
	postDeferredLightingComposite_fs4x.glsl
	Composite results of light pre-pass in deferred pipeline.
*/

#version 450

// ****TO-DO:
//	-> declare samplers containing results of light pre-pass
//	-> declare samplers for texcoords, diffuse and specular maps
//	-> implement Phong sum with samples from the above
//		(hint: this entire shader is about sampling textures)

in vec4 vTexcoord_atlas;

layout (location = 0) out vec4 rtFragColor;


uniform sampler2D uImage00;
uniform sampler2D uImage01;
uniform sampler2D uImage04;
uniform sampler2D uImage07;

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE AQUA
	//rtFragColor = vec4(0.0, 1.0, 0.5, 1.0);

	vec4 sceneTexcoords;
	vec4 value; //I might sample and texture through this function to then put it into rtFragColor
	//this is just a test so far to see if I wanna work stuff like this
	sceneTexcoords = texture(uImage04, vTexcoord_atlas.xy);
	value = texture(uImage00, sceneTexcoords.xy);
	value *= texture(uImage01, sceneTexcoords.xy);
	value *= texture(uImage07, sceneTexcoords.xy);

	rtFragColor = value;
}
