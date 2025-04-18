extern number _Time;
extern vec2 _ScreenSize;

vec3 hash(vec3 p){
	p = vec3( dot(p,vec3(127.1, 311.7, 74.7)),
			  dot(p,vec3(269.5, 183.3, 246.1)),
			  dot(p,vec3(113.5, 271.9, 124.6)));
	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

// return value noise (in x) and its derivatives (in yzw)
vec4 noised( in vec3 x )
{
    // grid
    vec3 i = floor(x);
    vec3 f = fract(x);
    
    // quintic interpolant
    vec3 u = f*f*f*(f*(f*6.0-15.0)+10.0);
    vec3 du = 30.0*f*f*(f*(f-2.0)+1.0);
   
    // gradients
    vec3 ga = hash( i+vec3(0.0,0.0,0.0) );
    vec3 gb = hash( i+vec3(1.0,0.0,0.0) );
    vec3 gc = hash( i+vec3(0.0,1.0,0.0) );
    vec3 gd = hash( i+vec3(1.0,1.0,0.0) );
    vec3 ge = hash( i+vec3(0.0,0.0,1.0) );
	vec3 gf = hash( i+vec3(1.0,0.0,1.0) );
    vec3 gg = hash( i+vec3(0.0,1.0,1.0) );
    vec3 gh = hash( i+vec3(1.0,1.0,1.0) );
    
    // projections
    float va = dot( ga, f-vec3(0.0,0.0,0.0) );
    float vb = dot( gb, f-vec3(1.0,0.0,0.0) );
    float vc = dot( gc, f-vec3(0.0,1.0,0.0) );
    float vd = dot( gd, f-vec3(1.0,1.0,0.0) );
    float ve = dot( ge, f-vec3(0.0,0.0,1.0) );
    float vf = dot( gf, f-vec3(1.0,0.0,1.0) );
    float vg = dot( gg, f-vec3(0.0,1.0,1.0) );
    float vh = dot( gh, f-vec3(1.0,1.0,1.0) );
	
    // interpolations
    return vec4( va + u.x*(vb-va) + u.y*(vc-va) + u.z*(ve-va) + u.x*u.y*(va-vb-vc+vd) + u.y*u.z*(va-vc-ve+vg) + u.z*u.x*(va-vb-ve+vf) + (-va+vb+vc-vd+ve-vf-vg+vh)*u.x*u.y*u.z,    // value
                 ga + u.x*(gb-ga) + u.y*(gc-ga) + u.z*(ge-ga) + u.x*u.y*(ga-gb-gc+gd) + u.y*u.z*(ga-gc-ge+gg) + u.z*u.x*(ga-gb-ge+gf) + (-ga+gb+gc-gd+ge-gf-gg+gh)*u.x*u.y*u.z +   // derivatives
                 du * (vec3(vb,vc,ve) - va + u.yzx*vec3(va-vb-vc+vd,va-vc-ve+vg,va-vb-ve+vf) + u.zxy*vec3(va-vb-ve+vf,va-vb-vc+vd,va-vc-ve+vg) + u.yzx*u.zxy*(-va+vb+vc-vd+ve-vf-vg+vh) ));
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){

    vec2 p = (screen_coords * 2.0 - _ScreenSize) / _ScreenSize.y;
    p.y = p.y * -1.0;

     // camera movement	
	float an = 0.5 * _Time;
	vec3 ro = vec3(2.5 * cos(an), 1.0, 2.5 * sin(an));
    vec3 ta = vec3(0.0, 1.0, 0.0);
    // camera matrix
    vec3 ww = normalize(ta - ro);
    vec3 uu = normalize(cross(ww,vec3(0.0, 1.0, 0.0)));
    vec3 vv = normalize(cross(uu, ww));
	// create view ray
	vec3 rd = normalize(p.x * uu + p.y * vv + 1.5 * ww);

    // sphere center	
	vec3 sc = vec3(0.0, 1.0, 0.0);

    // raytrace
	float tmin = 10000.0;
	vec3  nor = vec3(0.0);
	float occ = 1.0;
	vec3  pos = vec3(0.0);
	
	// raytrace-plane
	float h = (0.0 - ro.y) / rd.y;
	if(h > 0.0){ 
		tmin = h; 
		nor = vec3(0.0, 1.0, 0.0); 
		pos = ro + h * rd;
		vec3 di = sc - pos;
		float l = length(di);
		occ = 1.0 - dot(nor, di / l) * 1.0 * 1.0 / (l * l); 
	}

	// raytrace-sphere
	vec3  ce = ro - sc;
	float b = dot( rd, ce );
	float c = dot( ce, ce ) - 1.0;
	h = b*b - c;
	if(h > 0.0){
		h = -b - sqrt(h);
		if(h < tmin){ 
			tmin=h; 
			nor = normalize(ro + h * rd - sc); 
			occ = 0.5 + 0.5 * nor.y;
		}
	}

    // shading/lighting	
	vec3 col = vec3(0.9);
	if( tmin<100.0 ){
	    pos = ro + tmin * rd;
        vec4 n = noised(12.0 * pos);
        col = 0.5 + 0.5 * ((p.x > 0.0) ? n.yzw : n.xxx);
		col = mix(col, vec3(0.9), 1.0-exp(-0.003 * tmin * tmin));
	}
    vec4 pixelColor = vec4(col, 1.0);
    return pixelColor;
}



