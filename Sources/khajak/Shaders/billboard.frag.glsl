#ifdef GL_ES
precision mediump float;
#endif

varying vec2 vUV;
varying vec4 fragmentColor;

uniform sampler2D tex;

void kore() {  
	gl_FragColor = fragmentColor * vec4(texture2D(tex, vUV).rgba);
}