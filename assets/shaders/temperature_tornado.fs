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
    float ring = smoothstep(0.06, 0.0, abs(dist - (0.18 + 0.08 * sin(time * 5.0)))) * strength;
    vec3 storm = vec3(0.68, 0.74, 0.76) * (0.08 * funnel + 0.12 * dust * strength + 0.2 * ring);

    base.rgb = mix(base.rgb, base.rgb * 0.78 + storm, 0.55 * strength);
    base.rgb += vec3(0.04, 0.06, 0.07) * funnel;
    return base;
}
