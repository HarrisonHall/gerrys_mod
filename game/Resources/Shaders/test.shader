shader_type canvas_item;
uniform sampler2D ViewportTexture;

uniform float a = 0.5;

void fragment() {
    vec2 ruv = SCREEN_UV - vec2(0.5, 0.5);
    vec2 dir = normalize(ruv);
    float len = length(ruv);
    
    len = pow(len * 2.0, 1.0 + a / 10.0) * 0.5;
    ruv = len * dir;
    
    vec3 col = texture(TEXTURE, vec2(0.5, 0.5) + ruv).xyz;
    
    COLOR.xyz = col;
}