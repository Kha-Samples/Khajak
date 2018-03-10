#version 450

in vec2 vUV;
in vec3 positionWorldspace;
in vec3 normalCameraspace;
in vec3 eyeDirectionCameraspace;
in vec3 lightDirectionCameraspace1;
in vec3 lightDirectionCameraspace2;
in vec3 lightDirectionCameraspace3;
in vec3 lightDirectionCameraspace4;
//in vec3 lightDirectionCameraspace5;
//in vec3 lightDirectionCameraspace6;
//in vec3 lightDirectionCameraspace7;
//in vec3 lightDirectionCameraspace8;
in vec4 fragmentColor;

out vec4 frag;

uniform sampler2D tex;
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

vec3 calculateLight(vec3 lightColor, float lightPower, vec3 pos, vec3 directionCameraspace, vec3 materialDiffuseColor, vec3 materialSpecularColor);  // declare a function

void main() {
	vec3 materialDiffuseColor = fragmentColor.xyz + texture(tex, vUV).xyz;
	vec3 materialAmbientColor = vec3(0.1, 0.1, 0.1) * materialDiffuseColor;
	vec3 materialSpecularColor = vec3(0.3, 0.3, 0.3);
	
	vec3 result = materialAmbientColor +
	calculateLight(light1Color, light1Power, light1Position, lightDirectionCameraspace1, materialDiffuseColor, materialSpecularColor) +
	calculateLight(light2Color, light2Power, light2Position, lightDirectionCameraspace2, materialDiffuseColor, materialSpecularColor) +
	calculateLight(light3Color, light3Power, light3Position, lightDirectionCameraspace3, materialDiffuseColor, materialSpecularColor) +
	calculateLight(light4Color, light4Power, light4Position, lightDirectionCameraspace4, materialDiffuseColor, materialSpecularColor);
	/*calculateLight(light5Color, light5Power, light5Position, lightDirectionCameraspace5, materialDiffuseColor, materialSpecularColor) +
	calculateLight(light6Color, light6Power, light6Position, lightDirectionCameraspace6, materialDiffuseColor, materialSpecularColor) +
	calculateLight(light7Color, light7Power, light7Position, lightDirectionCameraspace7, materialDiffuseColor, materialSpecularColor) +
	calculateLight(light8Color, light8Power, light8Position, lightDirectionCameraspace8, materialDiffuseColor, materialSpecularColor);*/

	frag = vec4(result, fragmentColor.a);
}

vec3 calculateLight(vec3 lightColor, float lightPower, vec3 pos, vec3 directionCameraspace, vec3 materialDiffuseColor, vec3 materialSpecularColor) {
	// Distance to the light
	float distance = length(pos - positionWorldspace);

	// Normal of the computed fragment, in camera space
	vec3 n = normalize(normalCameraspace);
	// Direction of the light (from the fragment to the light)
	vec3 l = normalize(directionCameraspace);
	// Cosine of the angle between the normal and the light direction, 
	// clamped above 0
	//  - light is at the vertical of the triangle -> 1
	//  - light is perpendicular to the triangle -> 0
	//  - light is behind the triangle -> 0
	float cosTheta = clamp(dot(n, l), 0.0, 1.0);

	// Eye vector (towards the camera)
	vec3 E = normalize(eyeDirectionCameraspace);
	// Direction in which the triangle reflects the light
	vec3 R = (-l) - 2.0 * dot(n, (-l)) * n;
	//vec3 R = reflect(-l,n); // TODO: waiting for krafix fix

	// Cosine of the angle between the Eye vector and the Reflect vector,
	// clamped to 0
	//  - Looking into the reflection - 1
	//  - Looking elsewhere - < 1
	float cosAlpha = clamp(dot(E, R), 0.0, 1.0);

	return vec3(
		// Diffuse: "color" of the object
		materialDiffuseColor * lightColor * lightPower * cosTheta / (distance * distance) +
		// Specular: reflective highlight, like a mirror
		materialSpecularColor * lightColor * lightPower * pow(cosAlpha, 5.0) / (distance * distance)
	);
}
