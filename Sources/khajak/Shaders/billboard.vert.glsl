#ifdef GL_ES
precision highp float;
#endif

attribute vec3 pos;
attribute vec2 uv;

varying vec2 vUV;

uniform mat4 viewMatrix;

uniform vec2 sizeWorldspace;
uniform vec3 centerWorldspace;
uniform vec2 rotData;
uniform mat4 mvpMatrix;

void kore() {
	vec3 CameraRightWorldspace = normalize(vec3(viewMatrix[0][0], viewMatrix[1][0], viewMatrix[2][0]));
	vec3 CameraUpWorldspace = normalize(vec3(viewMatrix[0][1], viewMatrix[1][1], viewMatrix[2][1]));
	
	vec2 rotPos = mat2(rotData.y, -rotData.x, rotData.x, rotData.y) * pos.xy;
	
	vec3 posWorldspace = 
    centerWorldspace
    + CameraRightWorldspace * rotPos.x * sizeWorldspace.x
    + CameraUpWorldspace * rotPos.y * sizeWorldspace.y;
	
	gl_Position = mvpMatrix * vec4(posWorldspace, 1.0);

	vUV = uv;
}