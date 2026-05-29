extern number time;
extern number strength;

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec2 uv = texture_coords;
    vec2 center = vec2(0.5, 0.5);
    vec2 delta = uv - center;
    float dist = length(delta);
    float angle = atan(delta.y, delta.x);

    float funnel = smoothstep(0.62, 0.05, dist) * strength;
    float spin = sin(angle * 7.0 - time * 13.0 + dist * 30.0);
    float spiral = cos(angle * 4.0 + time * 9.0 - dist * 42.0);
    float pull = funnel * (0.018 + 0.022 * spiral);

    vec2 tangent = vec2(-delta.y, delta.x);
    uv += tangent * pull;
    uv += normalize(delta + vec2(0.0001)) * spin * funnel * 0.012;
    uv.x += sin(screen_coords.y * 0.055 + time * 38.0) * 0.004 * strength;
    uv.y += cos(screen_coords.x * 0.045 + time * 31.0) * 0.003 * strength;

    vec4 base = Texel(texture, uv) * colour;
    float dust = smoothstep(0.15, 0.95, fract(sin(dot(screen_coords + time * 80.0, vec2(12.9898,78.233))) * 43758.5453));
    float fog_a = smoothstep(0.24, 0.88, sin(screen_coords.x * 0.018 + screen_coords.y * 0.009 + time * 7.2) * 0.5 + 0.5);
    float fog_b = smoothstep(0.20, 0.92, sin(screen_coords.x * -0.011 + screen_coords.y * 0.021 - time * 9.5) * 0.5 + 0.5);
    float gust = smoothstep(0.06, 0.0, abs(fract(screen_coords.y * 0.012 + screen_coords.x * 0.004 - time * 3.4) - 0.5));
    float ring = smoothstep(0.06, 0.0, abs(dist - (0.18 + 0.08 * sin(time * 5.0)))) * strength;
    float fog = (fog_a * 0.34 + fog_b * 0.32 + gust * 0.42 + dust * 0.18) * strength;
    vec3 storm = vec3(0.70, 0.74, 0.75) * (0.14 * funnel + 0.24 * dust * strength + 0.32 * ring + fog);

    base.rgb = mix(base.rgb, vec3(0.58, 0.60, 0.60), 0.34 * strength);
    base.rgb = mix(base.rgb, base.rgb * 0.62 + storm, 0.78 * strength);
    base.rgb += vec3(0.08, 0.09, 0.09) * funnel + vec3(0.12, 0.13, 0.13) * gust * strength;
    return base;
}
