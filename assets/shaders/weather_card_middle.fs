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
    return fract(sin(dot(p, vec2(91.7, 237.4))) * 41923.381);
}

number ellipse(vec2 p, vec2 radius) {
    vec2 q = p / radius;
    return 1.0 - smoothstep(0.72, 1.0, dot(q, q));
}

number flower_shape(vec2 uv, vec2 center, number size, number spin) {
    number bloom = 0.0;
    for (int i = 0; i < 8; i++) {
        number a = spin + float(i) * 0.785398;
        vec2 dir = vec2(cos(a), sin(a));
        vec2 petal_center = center + dir * size * 0.44;
        vec2 d = uv - petal_center;
        vec2 q = vec2(dot(d, dir), dot(d, vec2(-dir.y, dir.x)));
        bloom = max(bloom, ellipse(q, vec2(size * 0.42, size * 0.24)));
    }
    number middle = 1.0 - smoothstep(size * 0.08, size * 0.24, distance(uv, center));
    return max(bloom, middle);
}

number ray_mask(vec2 uv, vec2 origin, number count, number speed) {
    vec2 d = uv - origin;
    number a = atan(d.y, d.x);
    number r = length(d);
    number ray = 0.5 + 0.5 * cos(a * count + time * speed);
    ray = pow(ray, 8.0);
    return ray * smoothstep(0.08, 0.62, r) * (1.0 - smoothstep(0.86, 1.18, r));
}

vec4 effect(vec4 colour, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = texture_coords;
    number t = time * 0.42;
    number shadow_flag = 0.0;
    if (shadow) {
        shadow_flag = 1.0;
    }
    number balatro_uniforms = (dissolve + texture_details.x + image_details.x + burn_colour_1.a + burn_colour_2.a + length(mouse_screen_pos) / max(screen_scale, 1.0) + hovering + shadow_flag + aura_mode) * 0.000001;

    vec2 sun = vec2(0.5, 0.36);
    vec2 to_sun = uv - sun;
    number sun_dist = length(to_sun);
    number shimmer = sin(uv.y * 14.0 + time * 1.1) * 0.0012 * strength;
    vec4 pixel = Texel(tex, vec2(uv.x + shimmer, uv.y));

    vec3 dawn = vec3(1.0, 0.62, 0.20);
    vec3 sky = vec3(0.42, 0.88, 1.0);
    vec3 green = vec3(0.28, 0.70, 0.34);
    pixel.rgb = mix(pixel.rgb, mix(dawn, sky, smoothstep(0.12, 0.82, uv.y)), 0.18 * strength);
    pixel.rgb = mix(pixel.rgb, green, smoothstep(0.72, 1.0, uv.y) * 0.18 * strength);

    number halo = 1.0 - smoothstep(0.08, 0.58, sun_dist);
    number disc = 1.0 - smoothstep(0.105, 0.145, sun_dist);
    number outer_ring = 1.0 - smoothstep(0.012, 0.035, abs(sun_dist - 0.18));
    pixel.rgb += vec3(1.0, 0.78, 0.22) * halo * 0.42 * strength;
    pixel.rgb += vec3(1.0, 0.64, 0.12) * ray_mask(uv, sun, 18.0, 0.7) * 0.22 * strength;
    pixel.rgb += vec3(1.0, 0.92, 0.42) * outer_ring * 0.16 * strength;
    pixel.rgb = mix(pixel.rgb, vec3(1.0, 0.94, 0.54), disc * 0.82 * strength);

    number flowers = 0.0;
    vec3 flower_rgb = vec3(0.0);
    for (int i = 0; i < 22; i++) {
        number fi = float(i);
        number seed = hash(vec2(fi, 11.0));
        vec2 p = vec2(0.08 + hash(vec2(fi, 1.7)) * 0.84, 0.10 + hash(vec2(fi, 3.0)) * 0.80);
        p += vec2(sin(t * 2.0 + fi) * 0.018, cos(t * 1.5 + fi * 1.3) * 0.014);

        number cycle = fract(time * (0.065 + hash(vec2(fi, 9.0)) * 0.050) + seed);
        number fade = smoothstep(0.03, 0.24, cycle) * (1.0 - smoothstep(0.66, 0.96, cycle));
        number twinkle = 0.78 + 0.22 * sin(time * (1.8 + seed * 2.5) + fi * 4.1);
        number visibility = fade * twinkle;

        number size = 0.064 + hash(vec2(fi, 6.0)) * 0.032;
        number bloom = flower_shape(uv, p, size, t * 0.45 + seed * 6.28) * visibility;
        vec3 pink = vec3(1.0, 0.36, 0.68);
        vec3 yellow = vec3(1.0, 0.86, 0.22);
        vec3 violet = vec3(0.72, 0.46, 1.0);
        vec3 white = vec3(1.0, 0.96, 0.78);
        vec3 tint = mix(mix(pink, yellow, hash(vec2(fi, 2.0))), violet, hash(vec2(fi, 5.0)) * 0.30);
        tint = mix(tint, white, 0.16);
        flower_rgb += tint * bloom;
        flowers += bloom;
    }
    number flower_alpha = clamp(flowers, 0.0, 1.0);
    pixel.rgb = mix(pixel.rgb, flower_rgb / max(flowers, 1.0), flower_alpha * 0.78 * strength);
    pixel.rgb += vec3(1.0, 0.93, 0.56) * flower_alpha * 0.22 * strength;

    number motes = 0.0;
    for (int i = 0; i < 18; i++) {
        number fi = float(i);
        vec2 p = vec2(hash(vec2(fi, 0.4)), hash(vec2(fi, 3.9)));
        p.y = fract(p.y - t * (0.08 + hash(vec2(fi, 2.8)) * 0.05));
        p.x += sin(t * 2.0 + fi) * 0.025;
        number radius = 0.007 + hash(vec2(fi, 5.0)) * 0.010;
        motes += (1.0 - smoothstep(radius * 0.25, radius, distance(uv, p))) * 0.050;
    }
    pixel.rgb += vec3(1.0, 0.86, 0.34) * min(motes, 0.24) * strength + vec3(balatro_uniforms);
    if (aura_mode > 0.5) {
        number aura = clamp(halo * 0.55 + outer_ring * 0.65 + flowers * 0.75 + motes * 1.2, 0.0, 1.0);
        pixel.a *= smoothstep(0.08, 0.42, aura) * 0.80;
    }
    return pixel * colour;
}
