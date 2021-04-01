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
	
	passColor_interp_tes4x.glsl
	Pass color, outputting result of interpolation.
*/

#version 450

// ****TO-DO: 
//	-> declare uniform block for spline waypoint and handle data
//	-> implement spline interpolation algorithm based on scene object's path
//	-> interpolate along curve using correct inputs and project result

layout (isolines, equal_spacing) in;

uniform mat4 uP;

uniform ubCurve
{
	vec4 curveWaypoint[32];
	vec4 curveTangent[32];
};

uniform int uCount;

out vec4 vColor;

void main()
{
	int i0 = gl_PrimitiveID;
	int i1 = (i0 + 1) % uCount;
	float t = gl_TessCoord.x;

	vec4 point = curveWaypoint[(i0 -1) % uCount];
	vec4 point1 = curveWaypoint[i0];
	vec4 point2 = curveWaypoint[i1];
	vec4 point3 = curveWaypoint[(i1 + 1) % uCount];

	mat4 influence = mat4(point, point1, point2, point3);
	vec4 tVector = vec4(1, t, pow(t, 2), pow(t, 3));

	vec4 test = vec4(-t + 2 * pow(t, 2) - pow(t, 3),
					2 - 5 * pow(t, 2) + 3 * pow(t, 3),
					t + 4 * pow(t, 2) - 3 * pow(t, 3),
					-pow(t, 2) + pow(t, 3));

	vec4 p = 0.5 * (influence * test);

	gl_Position = uP * p;

	vColor = vec4(0.5, 0.5, gl_TessCoord[0], 1.0);
}
