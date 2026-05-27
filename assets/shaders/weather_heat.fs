extern number time;
extern number strength;

number hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

vec4 effect(vec4 colour, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = texture_coords;
    number wave = sin((uv.y * 18.0) + time * 2.0) * 0.0008 * strength;
    vec4 pixel = Texel(tex, vec2(uv.x + wave, uv.y));
    vec3 warm = vec3(1.0, 0.36, 0.06);
    pixel.rgb = mix(pixel.rgb, warm, 0.055 * strength);

    vec3 ember = vec3(1.0, 0.48, 0.08);
    number glow = 0.0;
    for (int idx = 0; idx < 10; idx++) {
        number i = float(idx);
        vec2 cell_count = vec2(3.0 + mod(i, 4.0), 5.0);
        vec2 id = floor(vec2(uv.x * cell_count.x, uv.y * cell_count.y + time * (0.035 + i * 0.006) + i * 8.13));
        number seed = hash(id + i);
        vec2 origin = vec2((id.x + hash(id + 1.7)) / cell_count.x, fract((id.y + hash(id + 4.1)) / cell_count.y));
        origin.y = fract(origin.y - time * (0.025 + seed * 0.03));
        origin.x += sin(time * 0.4 + seed * 6.28) * 0.025;
        number radius = 0.010 + seed * 0.012;
        number fade_in = smoothstep(0.0, 0.22, origin.y);
        number fade_out = 1.0 - smoothstep(0.72, 1.0, origin.y);
        number dot = 1.0 - smoothstep(radius * 0.35, radius, distance(uv, origin));
        glow += dot * fade_in * fade_out * (0.06 + seed * 0.05);
    }

    pixel.rgb += ember * min(glow, 0.16) * strength;
    return pixel * colour;
}
