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
	
	passTangentBasis_transform_vs4x.glsl
	Calculate and pass tangent basis.
*/

#version 450

// ****TO-DO: 
//	-> declare matrices
//		(hint: not MVP this time, made up of multiple; see render code)
//	-> transform input position correctly, assign to output
//		(hint: this may be done in one or more steps)
//	-> declare attributes for lighting and shading
//		(hint: normal and texture coordinate locations are 2 and 8)
//	-> declare additional matrix for transforming normal
//	-> declare varyings for lighting and shading
//	-> calculate final normal and assign to varying
//	-> assign texture coordinate to varying

layout (location = 0) in vec4 aPosition;
layout (location = 2) in vec3 aNormal;
layout (location = 8) in vec4 aTexture;

flat out int vVertexID;
flat out int vInstanceID;

uniform mat4 uMV, uP, uMV_nrm;

out vec4 vNormal;
out vec4 vPosition;
out vec4 vTexture; //maybe?

void main()
{
	// DUMMY OUTPUT: directly assign input position to output position
	//gl_Position = aPosition;

	//vNormal = aNormal;
	//vPosition = aPosition;
	vPosition = uMV * aPosition; //camera space 
	vNormal = uMV_nrm * vec4(aNormal, 0.0); //camera space
	vTexture = aTexture; //this might need to be different

	gl_Position = uP * aPosition;

	vVertexID = gl_VertexID;
	vInstanceID = gl_InstanceID;
}
