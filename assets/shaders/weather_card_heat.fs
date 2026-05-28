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
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

number noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    number a = hash(i);
    number b = hash(i + vec2(1.0, 0.0));
    number c = hash(i + vec2(0.0, 1.0));
    number d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

number fbm(vec2 p) {
    number v = 0.0;
    number a = 0.5;
    for (int i = 0; i < 5; i++) {
        v += noise(p) * a;
        p = vec2(1.62 * p.x + 1.18 * p.y, -1.18 * p.x + 1.62 * p.y) + 7.3;
        a *= 0.5;
    }
    return v;
}

number band(number value, number width) {
    return 1.0 - smoothstep(0.0, width, abs(value));
}

vec4 effect(vec4 colour, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = texture_coords;
    vec2 centered = uv - vec2(0.5, 0.54);
    centered.x *= 0.78;
    number r = length(centered);
    number angle = atan(centered.y, centered.x);
    number t = time * 0.82;
    number shadow_flag = 0.0;
    if (shadow) {
        shadow_flag = 1.0;
    }
    number balatro_uniforms = (dissolve + texture_details.x + image_details.x + burn_colour_1.a + burn_colour_2.a + length(mouse_screen_pos) / max(screen_scale, 1.0) + hovering + shadow_flag + aura_mode) * 0.000001;

    number turbulence = fbm(vec2(angle * 1.6 + t * 2.2, r * 9.0 - t * 3.1));
    number spiral = sin(angle * 5.5 - r * 24.0 + t * 4.6 + turbulence * 3.2);
    number funnel = (1.0 - smoothstep(0.10, 0.76, r)) * smoothstep(0.025, 0.20, r);
    number lick = smoothstep(0.18, 0.94, spiral + turbulence * 0.55) * funnel;
    number core = (1.0 - smoothstep(0.0, 0.25, r)) * (0.75 + 0.25 * sin(t * 5.0 + angle * 4.0));
    number heat_warp = (spiral * 0.0045 + (turbulence - 0.5) * 0.006) * strength * funnel;

    vec4 pixel = Texel(tex, vec2(uv.x + heat_warp, uv.y + heat_warp * 0.65));

    vec3 pale_sand = vec3(0.88, 0.68, 0.34);
    vec3 red_sand = vec3(0.66, 0.31, 0.10);
    vec3 smoke = vec3(0.16, 0.11, 0.08);
    vec3 ember = vec3(1.0, 0.25, 0.025);
    vec3 gold = vec3(1.0, 0.72, 0.16);
    vec3 white_hot = vec3(1.0, 0.93, 0.58);

    number desert_grain = fbm(uv * vec2(32.0, 52.0) + vec2(t * 1.5, -t * 2.0));
    pixel.rgb = mix(pixel.rgb, pale_sand, (0.18 + desert_grain * 0.12) * strength);
    pixel.rgb = mix(pixel.rgb, red_sand, smoothstep(0.50, 1.0, uv.y) * 0.22 * strength);
    pixel.rgb = mix(pixel.rgb, smoke, smoothstep(0.64, 1.0, r) * 0.18 * strength);

    pixel.rgb += ember * lick * 0.52 * strength;
    pixel.rgb += gold * smoothstep(0.42, 1.0, lick + core) * 0.28 * strength;
    pixel.rgb += white_hot * core * 0.24 * strength;

    number sparks = 0.0;
    for (int idx = 0; idx < 22; idx++) {
        number i = float(idx);
        number seed = hash(vec2(i, 2.7));
        vec2 p = vec2(hash(vec2(i, 1.0)), hash(vec2(i, 4.0)));
        p.x = fract(p.x + sin(t * 1.7 + seed * 6.28) * 0.18);
        p.y = fract(p.y - t * (0.34 + seed * 0.28));
        p.x += sin(p.y * 7.0 + t * 3.0) * 0.11;
        number radius = 0.006 + seed * 0.012;
        sparks += (1.0 - smoothstep(radius * 0.25, radius, distance(uv, p))) * (0.05 + seed * 0.06);
    }
    pixel.rgb += vec3(1.0, 0.55, 0.08) * min(sparks, 0.30) * strength;

    number sand_streaks = 0.0;
    for (int idx = 0; idx < 12; idx++) {
        number i = float(idx);
        number lane = fract(uv.x * (2.5 + mod(i, 4.0)) + uv.y * 2.2 + t * (0.14 + i * 0.02) + i * 0.37);
        sand_streaks += band(lane - 0.5, 0.018 + hash(vec2(i, 9.1)) * 0.010) * 0.025;
    }
    pixel.rgb += vec3(0.96, 0.70, 0.28) * min(sand_streaks, 0.12) * strength;

    number cracks = band(fract(uv.x * 3.1 + uv.y * 7.8 + 0.12) - 0.5, 0.010);
    cracks += band(fract(uv.x * -5.4 + uv.y * 3.2 + 0.72) - 0.5, 0.008);
    cracks *= smoothstep(0.58, 1.0, uv.y) * 0.075 * strength;
    pixel.rgb = mix(pixel.rgb, vec3(0.09, 0.035, 0.015), cracks);

    number edge_burn = 1.0 - smoothstep(0.0, 0.20, min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
    pixel.rgb += vec3(1.0, 0.18, 0.015) * edge_burn * 0.18 * strength + vec3(balatro_uniforms);
    if (aura_mode > 0.5) {
        number aura = clamp(lick * 0.62 + sparks * 1.7 + sand_streaks * 0.8 + edge_burn * 0.40, 0.0, 1.0);
        pixel.a *= smoothstep(0.08, 0.46, aura) * 0.82;
    }
    return pixel * colour;
}
