#version 450

in vec2 vUV;
in vec4 fragmentColor;

out vec4 frag;

uniform sampler2D tex;

void main() {  
	frag = fragmentColor * vec4(texture(tex, vUV).rgba);
}
