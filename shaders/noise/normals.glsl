extern vec2 _ScreenSize;
extern vec2 _MousePos;
extern float _MouseWheel;
extern float _Time;
extern bool _MouseClick;

#define MOD3 vec3(0.1031, 0.11369, 0.13787)

vec3 hash33(vec3 p3){
	p3 = fract(p3 * MOD3);
    p3 += dot(p3, p3.yxz + 19.19);
    return -1.0 + 2.0 * fract(vec3((p3.x + p3.y) * p3.z, (p3.x+p3.z) * p3.y, (p3.y+p3.z) * p3.x));
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

vec2 NormalMap(float height) 
{
    return -vec2(dFdx(height), dFdy(height));
}

#define normalStrength 10.0

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){

    vec2 uv = (screen_coords * 2.0 - _ScreenSize) / _ScreenSize.y;
    uv.y = uv.y * -1.0;
    uv *= _MouseWheel * 0.1;

    float mousePosition = (_MousePos.x > 0.1) ? _MousePos.x : _ScreenSize.x * 0.5;
    float mouseSplit = floor(mousePosition * 0.5) * 2. + 1.;
    vec4 fragColor = vec4(0.0,0.0,0.0,1.0);
    
    if (abs(screen_coords.x - mouseSplit) < 1.0) 
    {
        return fragColor;
    }

    float noiseVal = perlin_noise(vec3(uv*100.0, 1.0));

    vec2 normal = NormalMap(noiseVal);
    normal *= normalStrength;
    normal += 0.5;

    if(screen_coords.x > mouseSplit){
        fragColor = vec4(normal, 1.0, 1.0);
    }else{
        fragColor = vec4(noiseVal, noiseVal, noiseVal, 1.0);
    }

    return fragColor;
}



