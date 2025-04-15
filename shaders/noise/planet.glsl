extern vec2 screen;
extern vec2 mouse_pos;
extern float mouse_wheel;

#define MOD3 vec3(.1031,.11369,.13787)

vec3 hash33(vec3 p3){
	p3 = fract(p3 * MOD3);
    p3 += dot(p3, p3.yxz+19.19);
    return -1.0 + 2.0 * fract(vec3((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y, (p3.y+p3.z)*p3.x));
}

float perlin_noise(vec3 p){
    vec3 pi = floor(p);
    vec3 pf = p - pi;
    
    vec3 w = pf * pf * (3.0 - 2.0 * pf);
    
    return 	mix(
        		mix(
                	mix(dot(pf - vec3(0, 0, 0), hash33(pi + vec3(0, 0, 0))), 
                        dot(pf - vec3(1, 0, 0), hash33(pi + vec3(1, 0, 0))),
                       	w.x),
                	mix(dot(pf - vec3(0, 0, 1), hash33(pi + vec3(0, 0, 1))), 
                        dot(pf - vec3(1, 0, 1), hash33(pi + vec3(1, 0, 1))),
                       	w.x),
                	w.z),
        		mix(
                    mix(dot(pf - vec3(0, 1, 0), hash33(pi + vec3(0, 1, 0))), 
                        dot(pf - vec3(1, 1, 0), hash33(pi + vec3(1, 1, 0))),
                       	w.x),
                   	mix(dot(pf - vec3(0, 1, 1), hash33(pi + vec3(0, 1, 1))), 
                        dot(pf - vec3(1, 1, 1), hash33(pi + vec3(1, 1, 1))),
                       	w.x),
                	w.z),
    			w.y);
}

vec3 palette(float t) {
    vec3 a = vec3(0.0, 0.5, 0.4);
    vec3 b = vec3(0.0, 0.4, 0.2);
    vec3 c = vec3(1.0, 0.7, 1.0);
    vec3 d = vec3(0.00, 0.5, 0.5);

    return a + b*cos( 6.28318*(c*t+d));
}

#define PI 3.14159265358979323846
float rad(int angle){
    return angle * (PI / 180);
}

mat2 direction(float angle){
    return mat2(normalize(vec2(cos(angle),sin(angle))),
                    normalize(vec2(-sin(angle),cos(angle))));
}  

#define NUM_OCTAVES 5

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){

    //center (0,0) with scaling
    vec2 uv = (screen_coords * 2.0 - screen) / screen.y;
    uv.y = uv.y * -1.0;

    float shift[NUM_OCTAVES];
    shift[0] = 1.0;
    shift[1] = 2.0;
    shift[2] = 3.0;
    shift[3] = 4.0;
    shift[4] = 10.0;

    float persistence[NUM_OCTAVES];
    persistence[0] = 0.7;
    persistence[1] = 1.6;
    persistence[2] = 0.7;
    persistence[3] = 0.2;
    persistence[4] = 1.6;

    float frequency[NUM_OCTAVES];
    frequency[0] = 5.0;
    frequency[1] = 1.0;
    frequency[2] = 2.0;
    frequency[3] = 3.0;
    frequency[4] = 1.0;

    int rotation[NUM_OCTAVES];
    rotation[0] = 1;
    rotation[1] = 100;
    rotation[2] = 1;
    rotation[3] = 1;
    rotation[4] = 1;

    float total = 0.0;
    float amplitude = 1.0;

    uv.x -= mouse_pos.x * 0.05;
    uv.y += mouse_pos.y * 0.05;
    uv *= mouse_wheel * 0.1;

    for (int i = 0; i < NUM_OCTAVES; ++i) {
        uv = (direction(rad(rotation[i])) * uv) * frequency[i] + shift[i];
        amplitude *= persistence[i];
        total += amplitude * perlin_noise(vec3(abs(uv),1.0));
    }

    vec3 blu = vec3(0.0,0.0,0.2);
    vec3 gren = vec3(0.0,0.7,0.0);
    vec4 fragColor = vec4(mix(blu,gren, total), 1.0);

    return fragColor;
}
