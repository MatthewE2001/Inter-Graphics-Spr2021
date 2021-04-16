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
	
	passTangentBasis_morph_transform_vs4x.glsl
	Calculate and pass morphed tangent basis.
*/

#version 450

#define MAX_OBJECTS 128

// ****TO-DO: 
//	-> declare morph target attributes
//	-> declare and implement morph target interpolation algorithm
//	-> declare interpolation time/param/keyframe uniform
//	-> perform morph target interpolation using correct attributes
//		(hint: results can be stored in local variables named after the 
//		complete tangent basis attributes provided before any changes)

/*
layout (location = 0) in vec4 aPosition;
layout (location = 2) in vec3 aNormal;
layout (location = 8) in vec4 aTexcoord;
layout (location = 10) in vec3 aTangent;
layout (location = 11) in vec3 aBitangent;
*/

//what is part of a single morph target:
// -> position, normal, tangent
// -> 16 available, 16 / 3 = 5 (int)

//What is not part of a single morph target
// -> texcoord - shared because it's always the same in 2D
// -> bitangent: normal x tangent

struct sMorphTarget
{
	vec4 position;
	vec3 normal;      float nPad;
	vec3 tangent;     float tPad;

};

layout (location = 0) in sMorphTarget aMorphTarget[5];
//texcoord
layout (location = 8) in vec4 aTexcoord;


struct sAnimMorphTeapot
{
	float duration, durationInv;
	float time, param;
	int index, count;
};

uniform sAnimMorphTeapot uAnimMorphTeapot[1];


struct sModelMatrixStack
{
	mat4 modelMat;						// model matrix (object -> world)
	mat4 modelMatInverse;				// model inverse matrix (world -> object)
	mat4 modelMatInverseTranspose;		// model inverse-transpose matrix (object -> world skewed)
	mat4 modelViewMat;					// model-view matrix (object -> viewer)
	mat4 modelViewMatInverse;			// model-view inverse matrix (viewer -> object)
	mat4 modelViewMatInverseTranspose;	// model-view inverse transpose matrix (object -> viewer skewed)
	mat4 modelViewProjectionMat;		// model-view-projection matrix (object -> clip)
	mat4 atlasMat;						// atlas matrix (texture -> cell)
};

uniform ubTransformStack
{
	sModelMatrixStack uModelMatrixStack[MAX_OBJECTS];
};
uniform int uIndex;

out vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
};

flat out int vVertexID;
flat out int vInstanceID;


vec4 interp(vec4 left, vec4 right, float param)
{
	return mix(left,right,param);
}

void main()
{
	// DUMMY OUTPUT: directly assign input position to output position
	//gl_Position = aPosition;
	
	
	int i0 = uAnimMorphTeapot[0].index;
	int i1 = (i0+1)%uAnimMorphTeapot[0].count;
	
	//results of morphing
	vec4 aPosition = interp(aMorphTarget[i0].position, aMorphTarget[i1].position, uAnimMorphTeapot[0].param);
	vec3 aTangent = interp(vec4(aMorphTarget[i0].tangent,aMorphTarget[i0].tPad), vec4(aMorphTarget[i1].tangent,aMorphTarget[i1].tPad), uAnimMorphTeapot[0].param).xyz;
	
	vec3 aNormal = interp(vec4(aMorphTarget[i0].normal,aMorphTarget[i0].nPad), vec4(aMorphTarget[i1].normal,aMorphTarget[i1].nPad), uAnimMorphTeapot[0].param).xyz;
	vec3 aBitangent = aNormal * aTangent;

	//testing: copy the first morph target only

	/*
	vec4 aPosition = aMorphTarget[0].position;
	vec3 aTangent = aMorphTarget[0].tangent;
	vec3 aNormal = aMorphTarget[0].normal;
	vec3 aBitangent = cross(aNormal,aTangent);
	*/
	
	sModelMatrixStack t = uModelMatrixStack[uIndex];
	
	vTangentBasis_view = t.modelViewMatInverseTranspose * mat4(aTangent, 0.0, aBitangent, 0.0, aNormal, 0.0, vec4(0.0));
	vTangentBasis_view[3] = t.modelViewMat * aPosition;
	gl_Position = t.modelViewProjectionMat * aPosition;
	
	vTexcoord_atlas = t.atlasMat * aTexcoord;

	vVertexID = gl_VertexID;
	vInstanceID = gl_InstanceID;
}
