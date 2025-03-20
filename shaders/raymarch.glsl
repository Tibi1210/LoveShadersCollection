extern number iTime;
extern vec2 screen;
extern sampler2D uNoise;

#define MAX_STEPS 100

float sdSphere(vec3 p, float radius) {
    return length(p) - radius;
}

float noise(vec3 x ) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);

    vec2 uv = (p.xy + vec2(37.0,239.0) * p.z) + f.xy;
    vec2 tex = texture2D(uNoise, (uv + 0.5) / 256.0, 0.0).yx;

    return mix(tex.x, tex.y, f.z) * 2.0 - 1.0;
}

float fbm(vec3 p) {
    vec3 q = p + iTime * 0.1 * vec3(1.0, -0.2, -1.0);
    float g = noise(q);

    float f = 0.0;
    float scale = 0.5;
    float factor = 2.02;

    for (int i = 0; i < 6; i++) {
        f += scale * noise(q);
        q *= factor;
        factor += 0.21;
        scale *= 0.5;
    }

    return f;
}

float scene(vec3 p) {
    float distance = sdSphere(p, 1.0);

    float f = fbm(p);

    return -distance + f;
}

const float MARCH_SIZE = 0.08;

vec4 raymarch(vec3 rayOrigin, vec3 rayDirection) {
    float depth = 0.0;
    vec3 p = rayOrigin + depth * rayDirection;

    vec4 res = vec4(0.0);

    for (int i = 0; i < MAX_STEPS; i++) {
    float density = scene(p);

    // We only draw the density if it's greater than 0
    if (density > 0.0) {
        vec4 color = vec4(mix(vec3(1.0,1.0,1.0), vec3(0.0, 0.0, 0.0), density), density );
        color.rgb *= color.a;
        res += color*(1.0-res.a);
    }

    depth += MARCH_SIZE;
    p = rayOrigin + depth * rayDirection;
    }

    return res;
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){

    //center (0,0) with scaling
    vec2 uv = (screen_coords * 2.0 - screen) / screen.y;
    uv.y = uv.y * -1.0;

    vec3 ro = vec3(0.0, 0.0, 5.0);
    vec3 rd = normalize(vec3(uv, -1.0));
    vec3 finalColor = vec3(0.0);
    vec4 res = raymarch(ro, rd);
    finalColor = res.rgb;

    vec4 pixelColor = vec4(finalColor, 1.0);
    return pixelColor;
}