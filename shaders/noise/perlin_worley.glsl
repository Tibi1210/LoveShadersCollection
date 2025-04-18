#pragma language glsl3

extern number _Time;
extern vec2 _ScreenSize;
extern vec2 _MousePos;

// Hash by David_Hoskins
#define UI0 1597334673U
#define UI1 3812015801U
#define UI2 uvec2(UI0, UI1)
#define UI3 uvec3(UI0, UI1, 2798796415U)
#define UIF (1.0 / float(0xffffffffU))

vec3 hash33(vec3 p){
	uvec3 q = uvec3(ivec3(p)) * UI3;
	q = (q.x ^ q.y ^ q.z)*UI3;
	return -1.0 + 2.0 * vec3(q) * UIF;
}

float remap(float x, float a, float b, float c, float d){
    return (((x - a) / (b - a)) * (d - c)) + c;
}

// Gradient noise by iq (modified to be tileable)
float gradientNoise(vec3 x, float freq){
    // grid
    vec3 p = floor(x);
    vec3 w = fract(x);
    
    // quintic interpolant
    vec3 u = w * w * w * (w * (w * 6.0 - 15.0) + 10.0);

    
    // gradients
    vec3 ga = hash33(mod(p + vec3(0.0, 0.0, 0.0), freq));
    vec3 gb = hash33(mod(p + vec3(1.0, 0.0, 0.0), freq));
    vec3 gc = hash33(mod(p + vec3(0.0, 1.0, 0.0), freq));
    vec3 gd = hash33(mod(p + vec3(1.0, 1.0, 0.0), freq));
    vec3 ge = hash33(mod(p + vec3(0.0, 0.0, 1.0), freq));
    vec3 gf = hash33(mod(p + vec3(1.0, 0.0, 1.0), freq));
    vec3 gg = hash33(mod(p + vec3(0.0, 1.0, 1.0), freq));
    vec3 gh = hash33(mod(p + vec3(1.0, 1.0, 1.0), freq));
    
    // projections
    float va = dot(ga, w - vec3(0.0, 0.0, 0.0));
    float vb = dot(gb, w - vec3(1.0, 0.0, 0.0));
    float vc = dot(gc, w - vec3(0.0, 1.0, 0.0));
    float vd = dot(gd, w - vec3(1.0, 1.0, 0.0));
    float ve = dot(ge, w - vec3(0.0, 0.0, 1.0));
    float vf = dot(gf, w - vec3(1.0, 0.0, 1.0));
    float vg = dot(gg, w - vec3(0.0, 1.0, 1.0));
    float vh = dot(gh, w - vec3(1.0, 1.0, 1.0));
	
    // interpolation
    return va + 
           u.x * (vb - va) + 
           u.y * (vc - va) + 
           u.z * (ve - va) + 
           u.x * u.y * (va - vb - vc + vd) + 
           u.y * u.z * (va - vc - ve + vg) + 
           u.z * u.x * (va - vb - ve + vf) + 
           u.x * u.y * u.z * (-va + vb + vc - vd + ve - vf - vg + vh);
}

// Tileable 3D worley noise
float worleyNoise(vec3 uv, float freq){    
    vec3 id = floor(uv);
    vec3 p = fract(uv);
    
    float minDist = 10000.0;
    for (float x = -1.; x <= 1.; ++x){
        for(float y = -1.; y <= 1.; ++y){
            for(float z = -1.; z <= 1.; ++z){
                vec3 offset = vec3(x, y, z);
            	vec3 h = hash33(mod(id + offset, vec3(freq))) * 0.5 + 0.5;
    			h += offset;
            	vec3 d = p - h;
           		minDist = min(minDist, dot(d, d));
            }
        }
    }
    
    // inverted worley noise
    return 1.0 - minDist;
}

// Fbm for Perlin noise based on iq's blog
float perlinfbm(vec3 p, float freq, int octaves){
    float G = exp2(-0.85);
    float amp = 1.0;
    float noise = 0.0;
    for (int i = 0; i < octaves; ++i){
        noise += amp * gradientNoise(p * freq, freq);
        freq *= 2.0;
        amp *= G;
    }
    
    return noise;
}

// Tileable Worley fbm inspired by Andrew Schneider's Real-Time Volumetric Cloudscapes
// chapter in GPU Pro 7.
float worleyFbm(vec3 p, float freq){
    return worleyNoise(p*freq, freq) * 0.625 +
        	 worleyNoise(p*freq*2.0, freq*2.0) * 0.25 +
        	 worleyNoise(p*freq*4.0, freq*4.0) * 0.125;
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){

    vec2 uv = (screen_coords * 2.0 - _ScreenSize) / _ScreenSize.y;
    vec2 m = (_MousePos * 2.0 - _ScreenSize) / _ScreenSize.y;
    uv.y = uv.y * -1.0;
    m.y = m.y * -1.0;

    uv -= 0.02 * _Time;
    vec4 noiseTex = vec4(0.0);
    
    float slices = 128.0; // number of layers of the 3d texture
    float freq = 4.0;
    
    float pfbm= mix(1.0, perlinfbm(vec3(uv, floor(m.y*slices)/slices), 4.0, 7), 0.5);
    pfbm = abs(pfbm * 2.0 - 1.0); // billowy perlin noise
    
    noiseTex.g += worleyFbm(vec3(uv, floor(m.y*slices)/slices), freq);
    noiseTex.b += worleyFbm(vec3(uv, floor(m.y*slices)/slices), freq*2.0);
    noiseTex.a += worleyFbm(vec3(uv, floor(m.y*slices)/slices), freq*4.0);
    noiseTex.r += remap(pfbm, 0.0, 1.0, noiseTex.g, 1.0); // perlin-worley

    vec2 st = (screen_coords * 2.0 - _ScreenSize) / _ScreenSize.y;
    st.y = st.y * -1.0;
    st.x *= 5.0; // 5 columns for different noises
    
    vec3 col = vec3(0.0);
    
    float perlinWorley = noiseTex.x;
    
    // worley fbms with different frequencies
    vec3 worley = noiseTex.yzw;
    float wfbm = worley.x * 0.625 +
        		 worley.y * 0.125 +
        		 worley.z * 0.25; 
    
    // cloud shape modeled after the GPU Pro 7 chapter
    float cloud = remap(perlinWorley, wfbm - 1.0, 1.0, 0.0, 1.0);
    cloud = remap(cloud, 0.85, 1.0, 0.0, 1.0); // fake cloud coverage
    
    if (st.x < -5.4)
        col += perlinWorley;
    else if(st.x < -1.8)
        col += worley.x;
    else if(st.x < 1.8)
        col += worley.y;
	else if(st.x < 5.4)
        col += worley.z;
    else if(st.x < 9.0)
        col += cloud;
            
    // column dividers
    float div = smoothstep(0.05, 0.0, abs(st.x - -5.4));
    div += smoothstep(0.05, 0.0, abs(st.x - -1.8));
	div += smoothstep(0.05, 0.0, abs(st.x - 1.8));
    div += smoothstep(0.05, 0.0, abs(st.x - 5.4));
        
    col = mix(col, vec3(0.0, 0.0, 0.866), div);
            
    return vec4(col,1.0);
}