extern vec2 tilt;
extern vec2 uv_offset;

vec4 effect(vec4 colour, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = texture_coords;
    vec2 offset = (uv_offset.y > 0.0) ? uv_offset : vec2(0.0, 0.5);
    
    vec4 back = Texel(tex, uv);
    
    vec4 fore = Texel(tex, uv + offset);
    
    vec3 final_rgb = mix(back.rgb, fore.rgb, fore.a);
    
    return vec4(final_rgb, max(back.a, fore.a)) * colour;
}
