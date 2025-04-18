extern number _Time;
extern vec2 _ScreenSize;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

#define NUM_OCTAVES 5

float fbm (vec2 uv) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5),
                    -sin(0.5), cos(0.50));

    for (int i = 0; i < NUM_OCTAVES; ++i) {
        v += a * noise(uv);
        uv = rot * uv * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){

    vec2 uv = (screen_coords * 2.0 - _ScreenSize) / _ScreenSize.y;
    uv.y = uv.y * -1.0;

    vec3 pixelColor = vec3(0.0);
    uv += uv * abs(sin(_Time * 0.1) * 3.0);

    vec2 q = vec2(0.0);
    q.x = fbm(uv + 0.0 * _Time);
    q.y = fbm(uv + vec2(1.0));

    vec2 r = vec2(0.0);
    r.x = fbm(uv + 1.0 * q + vec2(1.7, 9.2)+ 0.15 * _Time );
    r.y = fbm(uv + 1.0 * q + vec2(8.3, 2.8)+ 0.126 * _Time);

    float f = fbm(uv+r);

    pixelColor = mix(vec3(0.101961, 0.619608, 0.666667),
                     vec3(0.666667, 0.666667, 0.498039),
                     clamp((f * f) * 4.0, 0.0, 1.0));

    pixelColor = mix(pixelColor,
                     vec3(0.0, 0.0, 0.164706),
                     clamp(length(q), 0.0, 1.0));

    pixelColor = mix(pixelColor,
                     vec3(0.666667, 1.0, 1.0),
                     clamp(length(r.x), 0.0, 1.0));

    return vec4((f * f * f + 0.6 * f * f + 0.5 * f) * pixelColor, 1.0);

}

