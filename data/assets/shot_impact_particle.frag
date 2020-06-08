//Built-ins
varying vec4 vertColor;
varying vec2 texCoord;
//----

uniform sampler2D tex;

void main() {
	float base = texture2D(tex, texCoord).r;
	vec4 col = base * vertColor;
	gl_FragColor = vec4(col.rgb, base); 
	//gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}