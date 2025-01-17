shader_type canvas_item;
uniform sampler2D ViewportTexture;

uniform float a = 0.5;

void fragment() {
    vec3 col = -8.0 * texture(TEXTURE, UV).xyz;
    col += texture(TEXTURE, UV + a*vec2(0.0, SCREEN_PIXEL_SIZE.y)).xyz;
    col += texture(TEXTURE, UV + a*vec2(0.0, -SCREEN_PIXEL_SIZE.y)).xyz;
    col += texture(TEXTURE, UV + a*vec2(SCREEN_PIXEL_SIZE.x, 0.0)).xyz;
    col += texture(TEXTURE, UV + a*vec2(-SCREEN_PIXEL_SIZE.x, 0.0)).xyz;
    col += texture(TEXTURE, UV + a*SCREEN_PIXEL_SIZE.xy).xyz;
    col += texture(TEXTURE, UV - a*SCREEN_PIXEL_SIZE.xy).xyz;
    col += texture(TEXTURE, UV + a*vec2(-SCREEN_PIXEL_SIZE.x, SCREEN_PIXEL_SIZE.y)).xyz;
    col += texture(TEXTURE, UV + a*vec2(SCREEN_PIXEL_SIZE.x, -SCREEN_PIXEL_SIZE.y)).xyz;
    COLOR.xyz = col;
}