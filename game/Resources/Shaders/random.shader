shader_type canvas_item;
uniform sampler2D ViewportTexture;

uniform float a = 5;

float rand(vec2 co){
   return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 437.5453);
}

void fragment() {
	float numx = rand(UV) - 0.5;
	float numy = rand(vec2(UV.x * UV.x, UV.y * UV.y)) - 0.5;
	
	vec3 col = texture(TEXTURE, UV + vec2(a * SCREEN_PIXEL_SIZE.x * numx, a * SCREEN_PIXEL_SIZE.x * numy)).xyz;
   	
	COLOR.xyz = col;
}