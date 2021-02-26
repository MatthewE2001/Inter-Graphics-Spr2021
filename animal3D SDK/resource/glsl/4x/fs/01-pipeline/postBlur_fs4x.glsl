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
	
	postBlur_fs4x.glsl
	Gaussian blur.
*/

#version 450

// ****TO-DO:
//	-> declare texture coordinate varying and input texture
//	-> declare sampling axis uniform (see render code for clue)
//	-> declare Gaussian blur function that samples along one axis
//		(hint: the efficiency of this is described in class)

/*
I worked to make changes to this code

Based heavily on blue book pdf page 489 
*/

in vec4 vTexcoord_atlas; //whatever name i set in tangentBasis

uniform vec2 uAxis;

layout (binding = 0) uniform sampler2D uImage00;

layout (location = 0) out vec4 rtFragColor;


//Weights and code referenced from https://learnopengl.com/Advanced-Lighting/Bloom
float weight[5] = float[] (0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216);

void main()
{
	//vec4 color = texture(uAtlas, vTexcoord);
	// DUMMY OUTPUT: all fragments are OPAQUE AQUA
	//rtFragColor = vec4(0.0, 1.0, 0.5, 1.0); 
	vec3 c = texture2D(uImage00, vTexcoord_atlas.xy).rgb * weight[0];
	
	

	for (int i = 1; i < weight.length(); i++)
	{
		c += texture(uImage00, vTexcoord_atlas.xy + vec2(uAxis * i)).rgb * weight[i];
        c += texture(uImage00, vTexcoord_atlas.xy - vec2(uAxis * i)).rgb * weight[i];
	}
	
	rtFragColor = vec4(c, 1.0);
}
