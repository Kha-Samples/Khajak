#ifdef GL_ES
precision mediump float;
#endif

varying vec2 vUV;

uniform vec4 baseColor;
uniform sampler2D texture;

void kore() {  
	gl_FragColor = baseColor * vec4(texture2D(texture, vUV).rgba);
}