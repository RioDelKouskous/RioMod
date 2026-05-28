extern number time;
extern number strength;
extern number dissolve;
extern vec4 texture_details;
extern vec2 image_details;
extern vec4 burn_colour_1;
extern vec4 burn_colour_2;
extern vec2 mouse_screen_pos;
extern number screen_scale;
extern number hovering;
extern bool shadow;
extern number aura_mode;

number hash(vec2 p) {
    return fract(sin(dot(p, vec2(41.7, 289.3))) * 23634.6345);
}

number line_band(number value, number width) {
    return 1.0 - smoothstep(0.0, width, abs(value));
}

number flake(vec2 uv, vec2 p, number r) {
    vec2 d = uv - p;
    number core = 1.0 - smoothstep(r * 0.15, r, length(d));
    number arm_a = line_band(d.y, r * 0.16) * (1.0 - smoothstep(r * 0.15, r, abs(d.x)));
    number arm_b = line_band(d.x * 0.72 + d.y * 0.72, r * 0.16) * (1.0 - smoothstep(r * 0.15, r, length(d)));
    number arm_c = line_band(d.x * 0.72 - d.y * 0.72, r * 0.16) * (1.0 - smoothstep(r * 0.15, r, length(d)));
    return max(core, max(arm_a, max(arm_b, arm_c)));
}

vec4 effect(vec4 colour, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = texture_coords;
    number gust = sin((uv.x + uv.y) * 18.0 + time * 5.2) * 0.0035 * strength;
    vec4 pixel = Texel(tex, vec2(uv.x + gust, uv.y - gust * 0.7));
    number shadow_flag = 0.0;
    if (shadow) {
        shadow_flag = 1.0;
    }
    number balatro_uniforms = (dissolve + texture_details.x + image_details.x + burn_colour_1.a + burn_colour_2.a + length(mouse_screen_pos) / max(screen_scale, 1.0) + hovering + shadow_flag + aura_mode) * 0.000001;

    vec2 edge_dist = min(uv, 1.0 - uv);
    number edge = 1.0 - smoothstep(0.01, 0.24, min(edge_dist.x, edge_dist.y));
    number frost_noise = hash(floor(uv * 72.0 + time * 2.0));
    number frost = clamp(edge * 0.52 + frost_noise * edge * 0.22, 0.0, 0.78);
    pixel.rgb = mix(pixel.rgb, vec3(0.18, 0.55, 0.95), 0.18 * strength);
    pixel.rgb = mix(pixel.rgb, vec3(0.83, 0.97, 1.0), frost * strength);

    number blizzard = 0.0;
    for (int idx = 0; idx < 18; idx++) {
        number i = float(idx);
        number lane = fract((uv.x * 1.85 + uv.y * 3.35) + time * (0.52 + i * 0.018) + i * 0.173);
        number width = 0.010 + hash(vec2(i, 3.1)) * 0.014;
        number pulse = 0.50 + 0.50 * sin(time * 2.0 + i * 2.4);
        blizzard += line_band(lane - 0.5, width) * (0.045 + pulse * 0.035);
    }
    pixel.rgb += vec3(0.76, 0.93, 1.0) * min(blizzard, 0.36) * strength;

    number snow = 0.0;
    for (int idx = 0; idx < 12; idx++) {
        number i = float(idx);
        vec2 grid = vec2(3.0 + mod(i, 4.0), 4.0);
        vec2 id = floor(vec2(uv.x * grid.x - time * (0.38 + i * 0.016), uv.y * grid.y + time * (0.20 + i * 0.012) + i * 7.1));
        number seed = hash(id + i);
        vec2 p = vec2(fract((id.x + hash(id + 1.0)) / grid.x), fract((id.y + hash(id + 2.0)) / grid.y));
        p.x = fract(p.x + time * (0.20 + seed * 0.08));
        p.y = fract(p.y - time * (0.12 + seed * 0.05));
        number radius = 0.023 + seed * 0.020;
        snow += flake(uv, p, radius) * (0.10 + seed * 0.08);
    }
    pixel.rgb += vec3(0.88, 0.98, 1.0) * min(snow, 0.50) * strength;

    number ice_crack = line_band(fract(uv.x * -2.4 + uv.y * 5.0 + 0.21) - 0.5, 0.010);
    ice_crack += line_band(fract(uv.x * 3.8 + uv.y * 2.0 + 0.68) - 0.5, 0.008);
    pixel.rgb += vec3(0.55, 0.88, 1.0) * ice_crack * edge * 0.07 * strength + vec3(balatro_uniforms);
    if (aura_mode > 0.5) {
        number aura = clamp(blizzard * 1.15 + snow * 1.25 + frost * 0.36 + edge * 0.38, 0.0, 1.0);
        pixel.a *= smoothstep(0.10, 0.50, aura) * 0.78;
    }
    return pixel * colour;
}
