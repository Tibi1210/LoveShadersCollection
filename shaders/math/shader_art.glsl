extern number _Time;
extern vec2 _ScreenSize;

float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 palette(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.263, 0.416, 0.557);

    return a + b * cos(6.28318 * (c * t + d));
}


vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){

    vec2 uv = (screen_coords * 2.0 - _ScreenSize) / _ScreenSize.y;
    uv.y = uv.y * -1.0;

    vec2 orig_uv = uv;
    vec3 finalColor = vec3(0.0);

    for( float i = 0.0; i < 5.0; i++){
        uv = fract(uv * 1.5) - 0.5;

        float d = length(uv) * exp(-length(orig_uv));

        vec3 col = palette(length(orig_uv) + i * 0.3 + _Time * 0.3);

        d = sin(d * 8.0 + _Time) / 8.0;
        d = abs(d);
        d = pow(0.01 / d, 2.0);

        finalColor += col * d;
    }

    vec4 pixelColor = vec4(finalColor, 1.0);
    return pixelColor;
}