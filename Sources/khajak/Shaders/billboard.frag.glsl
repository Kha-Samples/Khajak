#ifdef GL_ES
precision mediump float;
#endif

varying vec2 vUV;

uniform sampler2D texture;

void kore() {  
	gl_FragColor = vec4(texture2D(texture, vUV).rgba);
}