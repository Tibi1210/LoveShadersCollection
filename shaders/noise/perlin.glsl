extern number iTime;
extern vec2 screen;
extern bool mouse_click;
//extern sampler2D NoiseTex;

vec2 GetGradient(vec2 intPos, float t) {
    
    float rand = fract(sin(dot(intPos, vec2(12.9898, 78.233))) * 43758.5453);;
    
    // Rotate gradient: random starting rotation, random rotation rate
    float angle = 6.283185 * rand + 4.0 * t * rand;
    return vec2(cos(angle), sin(angle));
}

float Pseudo3dNoise(vec3 pos) {
    vec2 i = floor(pos.xy);
    vec2 f = pos.xy - i;
    vec2 blend = f * f * (3.0 - 2.0 * f);
    float noiseVal = 
        mix(
            mix(
                dot(GetGradient(i + vec2(0, 0), pos.z), f - vec2(0, 0)),
                dot(GetGradient(i + vec2(1, 0), pos.z), f - vec2(1, 0)),
                blend.x),
            mix(
                dot(GetGradient(i + vec2(0, 1), pos.z), f - vec2(0, 1)),
                dot(GetGradient(i + vec2(1, 1), pos.z), f - vec2(1, 1)),
                blend.x),
        blend.y
    );
    return noiseVal / 0.7; // normalize to about [-1..1]
}

vec3 palette(float t) {
    vec3 a = vec3(0.0, 0.5, 0.4);
    vec3 b = vec3(0.0, 0.4, 0.2);
    vec3 c = vec3(1.0, 0.7, 1.0);
    vec3 d = vec3(0.00, 0.5, 0.5);

    return a + b*cos( 6.28318*(c*t+d));
}


vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){

    //center (0,0) with scaling
    vec2 uv = (screen_coords * 2.0 - screen) / screen.y;
    uv.y = uv.y * -1.0;

    vec4 fragColor = vec4(0.0, 0.0, 0.0, 1.0);

    // Mouse down: one noise channel
    if (mouse_click) {
        float noiseVal = 0.5 + 0.5 * Pseudo3dNoise(vec3(uv * 10.0, iTime));
        fragColor.rgb = vec3(noiseVal);
    }
    
    // Mouse up: layered noise
    else {
		const int ITERATIONS = 10;
        float noiseVal = 0.0;
        float sum = 0.0;
        float multiplier = 1.0;
        for (int i = 0; i < ITERATIONS; i++) {
            vec3 noisePos = vec3(uv, 0.2 * iTime / multiplier);
            noiseVal += multiplier * abs(Pseudo3dNoise(noisePos));
            sum += multiplier;
            multiplier *= 0.6;
            uv = 2.0 * uv + 4.3;
        }
        noiseVal /= sum;
        
        // Map to a color palette
        fragColor.rgb = palette(noiseVal);
    }
    return fragColor;
}
