extern number time;
extern number strength;

number hash(vec2 p) {
    return fract(sin(dot(p, vec2(41.7, 289.3))) * 23634.6345);
}

vec4 effect(vec4 colour, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = texture_coords;
    vec4 pixel = Texel(tex, uv);
    vec3 cold = vec3(0.35, 0.78, 1.0);
    vec2 centered = uv - vec2(0.5);
    vec2 edge_dist = min(uv, 1.0 - uv);
    number edge = 1.0 - smoothstep(0.00, 0.19, min(edge_dist.x, edge_dist.y));
    number corner = smoothstep(0.36, 0.74, length(centered));
    number frost_noise = hash(floor(uv * 44.0)) * 0.08 + 0.04 * sin(time * 0.6 + uv.x * 62.0 + uv.y * 31.0);
    number frost = clamp(edge * 0.34 + corner * 0.18 + frost_noise * edge, 0.0, 0.5);
    number crack_a = 1.0 - smoothstep(0.006, 0.018, abs(fract(uv.x * 3.0 + uv.y * 2.0 + 0.18) - 0.5));
    number crack_b = 1.0 - smoothstep(0.004, 0.016, abs(fract(uv.x * -2.0 + uv.y * 3.5 + 0.61) - 0.5));
    number cracks = (crack_a + crack_b) * edge * 0.035;

    pixel.rgb = mix(pixel.rgb, cold, 0.08 * strength);
    pixel.rgb = mix(pixel.rgb, vec3(0.82, 0.95, 1.0), frost * strength);
    pixel.rgb += vec3(0.65, 0.9, 1.0) * cracks * strength;
    return pixel * colour;
}
