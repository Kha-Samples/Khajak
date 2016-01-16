#ifdef GL_ES
precision highp float;
#endif

attribute vec3 pos;
attribute vec2 uv;
attribute vec3 nor;

uniform mat4 viewMatrix;
uniform vec3 light1Color;
uniform float light1Power;
uniform vec3 light1Position;
uniform vec3 light2Color;
uniform float light2Power;
uniform vec3 light2Position;
uniform vec3 light3Color;
uniform float light3Power;
uniform vec3 light3Position;
uniform vec3 light4Color;
uniform float light4Power;
uniform vec3 light4Position;
uniform vec3 light5Color;
uniform float light5Power;
uniform vec3 light5Position;
uniform vec3 light6Color;
uniform float light6Power;
uniform vec3 light6Position;
uniform vec3 light7Color;
uniform float light7Power;
uniform vec3 light7Position;
uniform vec3 light8Color;
uniform float light8Power;
uniform vec3 light8Position;

uniform vec3 color;
uniform mat4 modelMatrix;
uniform mat4 mvpMatrix;

varying vec2 vUV;
varying vec3 positionWorldspace;
varying vec3 normalCameraspace;
varying vec3 eyeDirectionCameraspace;
varying vec3 lightDirectionCameraspace1;
varying vec3 lightDirectionCameraspace2;
varying vec3 lightDirectionCameraspace3;
varying vec3 lightDirectionCameraspace4;
varying vec3 lightDirectionCameraspace5;
varying vec3 lightDirectionCameraspace6;
varying vec3 lightDirectionCameraspace7;
varying vec3 lightDirectionCameraspace8;
varying vec4 fragmentColor;

void kore() {
	gl_Position = mvpMatrix * vec4(pos, 1.0);

	// Position of the vertex, in worldspace : M * position
	positionWorldspace = (modelMatrix * vec4(pos, 1.0)).xyz;

	// Vector that goes from the vertex to the camera, in camera space.
	// In camera space, the camera is at the origin (0,0,0).
	vec3 vertexPositionCameraspace = (viewMatrix * modelMatrix * vec4(pos, 1.0)).xyz;
	eyeDirectionCameraspace = vec3(0.0, 0.0, 0.0) - vertexPositionCameraspace;

	// Vector that goes from the vertex to the light, in camera space. M is ommited because it's identity.
	vec3 lightPositionCameraspace1 = (viewMatrix * vec4(light1Position, 1.0)).xyz;
	lightDirectionCameraspace1 = lightPositionCameraspace1 + eyeDirectionCameraspace;
	vec3 lightPositionCameraspace2 = (viewMatrix * vec4(light2Position, 1.0)).xyz;
	lightDirectionCameraspace2 = lightPositionCameraspace2 + eyeDirectionCameraspace;
	vec3 lightPositionCameraspace3 = (viewMatrix * vec4(light3Position, 1.0)).xyz;
	lightDirectionCameraspace3 = lightPositionCameraspace3 + eyeDirectionCameraspace;
	vec3 lightPositionCameraspace4 = (viewMatrix * vec4(light4Position, 1.0)).xyz;
	lightDirectionCameraspace4 = lightPositionCameraspace4 + eyeDirectionCameraspace;
	vec3 lightPositionCameraspace5 = (viewMatrix * vec4(light5Position, 1.0)).xyz;
	lightDirectionCameraspace5 = lightPositionCameraspace5 + eyeDirectionCameraspace;
	vec3 lightPositionCameraspace6 = (viewMatrix * vec4(light6Position, 1.0)).xyz;
	lightDirectionCameraspace6 = lightPositionCameraspace6 + eyeDirectionCameraspace;
	vec3 lightPositionCameraspace7 = (viewMatrix * vec4(light7Position, 1.0)).xyz;
	lightDirectionCameraspace7 = lightPositionCameraspace7 + eyeDirectionCameraspace;
	vec3 lightPositionCameraspace8 = (viewMatrix * vec4(light8Position, 1.0)).xyz;
	lightDirectionCameraspace8 = lightPositionCameraspace8 + eyeDirectionCameraspace;
	
	// Normal of the the vertex, in camera space
	normalCameraspace = (viewMatrix * modelMatrix * vec4(nor, 0.0)).xyz; // Only correct if modelMatrix does not scale the model! Use its inverse transpose if not.
	
	vUV = uv;
	fragmentColor = vec4(color, 1.0);
}