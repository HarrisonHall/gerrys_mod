shader_type canvas_item;
uniform sampler2D ViewportTexture;

const float psize = 2.0;

void fragment() {
    vec3 col = -8.0 * texture(TEXTURE, UV).xyz;
    col += texture(TEXTURE, UV + vec2(0.0, psize*SCREEN_PIXEL_SIZE.y)).xyz;
    col += texture(TEXTURE, UV + vec2(0.0, -psize*SCREEN_PIXEL_SIZE.y)).xyz;
    col += texture(TEXTURE, UV + vec2(psize*SCREEN_PIXEL_SIZE.x, 0.0)).xyz;
    col += texture(TEXTURE, UV + vec2(-psize*SCREEN_PIXEL_SIZE.x, 0.0)).xyz;
    col += texture(TEXTURE, UV + psize*SCREEN_PIXEL_SIZE.xy).xyz;
    col += texture(TEXTURE, UV - psize*SCREEN_PIXEL_SIZE.xy).xyz;
    col += texture(TEXTURE, UV + vec2(-psize*SCREEN_PIXEL_SIZE.x, psize*SCREEN_PIXEL_SIZE.y)).xyz;
    col += texture(TEXTURE, UV + vec2(psize*SCREEN_PIXEL_SIZE.x, -psize*SCREEN_PIXEL_SIZE.y)).xyz;
    COLOR.xyz = col;
}