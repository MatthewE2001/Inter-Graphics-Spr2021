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
	
	postBlend_fs4x.glsl
	Blending layers, composition.
*/

#version 450

// ****TO-DO:
//	-> declare texture coordinate varying and set of input textures
//	-> implement some sort of blending algorithm that highlights bright areas
//		(hint: research some Photoshop blend modes)

//layout (binding = 0) uniform sampler2D uImage00;
//layout (binding = 0) uniform sampler2D uImage01;
//layout (binding = 0) uniform sampler2D uImage02;
//layout (binding = 0) uniform sampler2D uImage03;


uniform sampler2D fbo_c16x4_d24s8; //scene
uniform sampler2D fbo_c16_szHalf[3]; //half bright
uniform sampler2D fbo_c16_szQuarter[3];
uniform sampler2D fbo_c16_szEighth[3];

uniform vec4 uColor;

//uniform sampler2D uAtlas;
layout (binding = 0) uniform sampler2D image;
layout (binding = 1) uniform sampler2D image1;
layout (binding = 2) uniform sampler2D image2;
layout (binding = 3) uniform sampler2D image3;

uniform vec4 vTexcoord_atlas;

float exposure = 1;
layout (location = 0) out vec4 rtFragColor;

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE PURPLE
	//rtFragColor = vec4(0.5, 0.0, 1.0, 1.0);

	const float gamma = 2.2;
    
	vec3 hdrColor = texture2D(image, vTexcoord_atlas.xy).rgb;      
    vec3 blur2Col = texture2D(image1, vTexcoord_atlas.xy).rgb;
	vec3 blur4Col = texture2D(image2, vTexcoord_atlas.xy).rgb;
	vec3 blur8Col = texture2D(image3, vTexcoord_atlas.xy).rgb;
    
	vec3 color = vec3(1.0);

	color -= (1 - hdrColor) + (1 - blur2Col) + (1 - blur4Col) + (1 - blur8Col);
    
	// tone mapping
    vec3 result = vec3(1.0) - exp(-color);
    
	// also gamma correct while we're at it       
    result = pow(result, vec3(1.0 / gamma));
    rtFragColor = vec4(result, 1.0);

}
