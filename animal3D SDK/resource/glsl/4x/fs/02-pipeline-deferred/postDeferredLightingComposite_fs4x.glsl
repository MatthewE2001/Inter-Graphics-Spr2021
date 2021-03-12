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
layout (binding = 1) uniform sampler2D diffuse;
layout (binding = 2) uniform sampler2D specular;

uniform sampler2D uImage00; // Diffuse Atlas
uniform sampler2D uImage01; // Specular Atlas
uniform sampler2D uImage04; // texCoords g-buffer


void main()
{

	vec4 screenTexcoord = texture(uImage04, vTexcoord_atlas.xy);

	vec4 diffuseSample = texture(uImage00, screenTexcoord.xy);
	vec4 specSample = texture(uImage01, screenTexcoord.xy);

	vec4 diffColor = texture(diffuse,screenTexcoord.xy);
	vec4 specColor = texture(specular, screenTexcoord.xy);

	rtFragColor = diffuseSample;

	// DUMMY OUTPUT: all fragments are OPAQUE AQUA
	//rtFragColor = vec4(0.0, 1.0, 0.5, 1.0);
}
