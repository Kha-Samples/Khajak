in vec3 pos;
in vec2 uv;

out vec2 vUV;
out vec4 fragmentColor;

uniform mat4 viewMatrix;

attributeOrUniform vec2 sizeWorldspace;
attributeOrUniform vec3 centerWorldspace;
attributeOrUniform vec2 rotData;
attributeOrUniform vec4 baseColor;
attributeOrUniform mat4 mvpMatrix;

void main() {
	vec3 CameraRightWorldspace = normalize(vec3(viewMatrix[0][0], viewMatrix[1][0], viewMatrix[2][0]));
	vec3 CameraUpWorldspace = normalize(vec3(viewMatrix[0][1], viewMatrix[1][1], viewMatrix[2][1]));
	
	vec2 rotPos = mat2(rotData.y, -rotData.x, rotData.x, rotData.y) * pos.xy;
	
	vec3 posWorldspace = 
    centerWorldspace
    + CameraRightWorldspace * rotPos.x * sizeWorldspace.x
    + CameraUpWorldspace * rotPos.y * sizeWorldspace.y;
	
	gl_Position = mvpMatrix * vec4(posWorldspace, 1.0);

	vUV = uv;
	fragmentColor = baseColor;
}
