extern number time;
extern number strength;

number hash(vec2 p) {
    return fract(sin(dot(p, vec2(91.7, 237.4))) * 41923.381);
}

vec4 effect(vec4 colour, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = texture_coords;
    vec4 pixel = Texel(tex, uv);

    vec3 sunrise = vec3(1.0, 0.56, 0.18);
    vec3 clear_sky = vec3(0.35, 0.86, 1.0);
    vec3 middle = mix(sunrise, clear_sky, smoothstep(0.15, 0.85, uv.y));
    pixel.rgb = mix(pixel.rgb, middle, 0.085 * strength);

    number glow = 0.0;
    for (int idx = 0; idx < 12; idx++) {
        number i = float(idx);
        vec2 grid = vec2(4.0 + mod(i, 3.0), 4.0);
        vec2 id = floor(vec2(uv.x * grid.x, uv.y * grid.y + time * (0.018 + i * 0.002)));
        number seed = hash(id + i * 2.13);
        vec2 p = vec2((id.x + hash(id + 0.7)) / grid.x, fract((id.y + hash(id + 3.9)) / grid.y));
        p.y = fract(p.y - time * (0.015 + seed * 0.018));
        p.x += sin(time * 0.25 + seed * 6.28) * 0.018;
        number radius = 0.012 + seed * 0.018;
        number sparkle = 1.0 - smoothstep(radius * 0.35, radius, distance(uv, p));
        number fade = smoothstep(0.03, 0.22, p.y) * (1.0 - smoothstep(0.82, 1.0, p.y));
        glow += sparkle * fade * (0.035 + seed * 0.035);
    }

    vec3 pearl = mix(vec3(1.0, 0.74, 0.32), vec3(0.72, 0.95, 1.0), uv.y);
    pixel.rgb += pearl * min(glow, 0.18) * strength;
    return pixel * colour;
}
