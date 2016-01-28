#ifdef GL_ES
precision mediump float;
#endif

varying vec2 vUV;
varying vec4 fragmentColor;

uniform sampler2D texture;

void kore() {  
	gl_FragColor = fragmentColor * vec4(texture2D(texture, vUV).rgba);
}