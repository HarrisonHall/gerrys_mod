shader_type canvas_item;
uniform sampler2D ViewportTexture;

uniform float a = 0.5;

void fragment() {
	vec3 test = -8.0 * texture(TEXTURE, UV).xyz;
   
	test += texture(TEXTURE, UV + vec2(0.0, a*SCREEN_PIXEL_SIZE.y)).xyz;
	test += texture(TEXTURE, UV + vec2(0.0, -a*SCREEN_PIXEL_SIZE.y)).xyz;
    test += texture(TEXTURE, UV + vec2(a*SCREEN_PIXEL_SIZE.x, 0.0)).xyz;
    test += texture(TEXTURE, UV + vec2(-a*SCREEN_PIXEL_SIZE.x, 0.0)).xyz;
    test += texture(TEXTURE, UV + a*SCREEN_PIXEL_SIZE.xy).xyz;
    test += texture(TEXTURE, UV - a*SCREEN_PIXEL_SIZE.xy).xyz;
    test += texture(TEXTURE, UV + a*vec2(-SCREEN_PIXEL_SIZE.x, SCREEN_PIXEL_SIZE.y)).xyz;
    test += texture(TEXTURE, UV + a*vec2(SCREEN_PIXEL_SIZE.x, -SCREEN_PIXEL_SIZE.y)).xyz;
	
	if(test.x > 0.2 || test.y > 0.2 || test.z > 0.2) {
		COLOR = vec4(0, 0, 0, 0.7);
	} else {
		COLOR = texture(TEXTURE, UV);
	}
}