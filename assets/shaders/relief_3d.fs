extern number time;
extern number strength;

// Create a 3D relief effect with depth perception
vec4 effect(vec4 colour, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = texture_coords;
    
    // Sample the base texture
    vec4 pixel = Texel(tex, uv);
    
    // Create a subtle emboss effect for depth perception
    vec4 pixelUp = Texel(tex, uv + vec2(0.0, 0.001));
    vec4 pixelLeft = Texel(tex, uv + vec2(-0.001, 0.0));
    
    // Calculate surface normal for lighting effect
    vec3 normal = normalize(vec3(
        pixelLeft.rgb - pixel.rgb,
        pixelUp.rgb - pixel.rgb,
        0.5
    ));
    
    // Light source position (top-left)
    vec3 lightDir = normalize(vec3(-1.0, -1.0, 1.0));
    float lighting = dot(normal, lightDir) * 0.5 + 0.5;
    
    // Apply lighting with strength control
    pixel.rgb = mix(pixel.rgb, pixel.rgb * lighting, strength * 0.15);
    
    // Add subtle shadow for lower part (bottom half gets darker)
    float shadow = smoothstep(0.0, 1.0, uv.y) * 0.3;
    pixel.rgb *= (1.0 - shadow * strength * 0.1);
    
    // Add highlight on upper part
    float highlight = (1.0 - smoothstep(0.0, 0.5, uv.y)) * 0.2;
    pixel.rgb += vec3(1.0) * highlight * strength * 0.05;
    
    return pixel * colour;
}
