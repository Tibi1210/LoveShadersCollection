extern number iTime;
extern vec2 screen;
extern vec2 mouse_pos;
extern number cell;


// checkEdge() checks whether two point straddle the surface by checking for opposite signs
#define checkEdge(a, b) (a < 0.0) != (b < 0.0)
// vertexInterp() Solves for the intersection point linearly and interpolates the edge vertices (v1 and v2) accordingly
#define vertexInterp(v1, v2, d1, d2) mix(v1, v2, d1 / (d1 - d2))

float sdShape(in vec3 p) {
    p /= 2;
    //vec3 q = abs(p) - 1.35;
    //float cube = max(q.x, max(q.y, q.z));
    float sphere = length(p) - 1.6875;
    //float cylinder1 = length(p.yz) - 0.6;
    //float cylinder2 = length(p.xz) - 0.6;
    //float cylinder3 = length(p.xy) - 0.6;
    //return max(max(cube, sphere), -min(cylinder1, min(cylinder2, cylinder3))) * 1.5;
    return sphere;
}

vec4 mapScene(in vec3 p) {
    //float csz = 0.6 + 0.5 * sin(iTime); // Cell size
    float csz = cell;
    
    //float shape = 0.1;
    float shape = sdShape(p);

    vec3 c = floor(p / csz) * csz;

    vec3 ldb_p = c;                       // (l)eft,  (d)own, (b)ack  cell corner
    vec3 rdb_p = c + vec3(csz, 0.0, 0.0); // (r)ight, (d)own, (b)ack  cell corner
    vec3 lub_p = c + vec3(0.0, csz, 0.0); // (l)eft,  (u)p,   (b)ack  cell corner
    vec3 rub_p = c + vec3(csz, csz, 0.0); // (r)ight, (u)p,   (b)ack  cell corner
    vec3 ldf_p = c + vec3(0.0, 0.0, csz); // (l)eft,  (d)own, (f)ront cell corner
    vec3 rdf_p = c + vec3(csz, 0.0, csz); // (r)ight, (d)own, (f)ront cell corner
    vec3 luf_p = c + vec3(0.0, csz, csz); // (l)eft,  (u)p,   (f)ront cell corner
    vec3 ruf_p = c + csz;                 // (r)ight, (u)p,   (f)ront cell corner

    float ldb = sdShape(ldb_p); // Distance field sample at cell corner ldb_p
    float rdb = sdShape(rdb_p); // Distance field sample at cell corner rdb_p
    float lub = sdShape(lub_p); // Distance field sample at cell corner lub_p
    float rub = sdShape(rub_p); // Distance field sample at cell corner rub_p
    float ldf = sdShape(ldf_p); // Distance field sample at cell corner ldf_p
    float rdf = sdShape(rdf_p); // Distance field sample at cell corner rdf_p
    float luf = sdShape(luf_p); // Distance field sample at cell corner luf_p
    float ruf = sdShape(ruf_p); // Distance field sample at cell corner ruf_p

    float i = 1000000.0;

    // Checking all the cell edges for intersection and then calculating the intersection point
    if (checkEdge(lub, luf)) i = min(i, length(p - vertexInterp(lub_p, luf_p, lub, luf)) - 0.1);
    if (checkEdge(luf, ruf)) i = min(i, length(p - vertexInterp(luf_p, ruf_p, luf, ruf)) - 0.1);
    if (checkEdge(ruf, rub)) i = min(i, length(p - vertexInterp(ruf_p, rub_p, ruf, rub)) - 0.1);
    if (checkEdge(rub, lub)) i = min(i, length(p - vertexInterp(rub_p, lub_p, rub, lub)) - 0.1);
    if (checkEdge(lub, ldb)) i = min(i, length(p - vertexInterp(lub_p, ldb_p, lub, ldb)) - 0.1);
    if (checkEdge(luf, ldf)) i = min(i, length(p - vertexInterp(luf_p, ldf_p, luf, ldf)) - 0.1);
    if (checkEdge(ruf, rdf)) i = min(i, length(p - vertexInterp(ruf_p, rdf_p, ruf, rdf)) - 0.1);
    if (checkEdge(rub, rdb)) i = min(i, length(p - vertexInterp(rub_p, rdb_p, rub, rdb)) - 0.1);
    if (checkEdge(ldb, ldf)) i = min(i, length(p - vertexInterp(ldb_p, ldf_p, ldb, ldf)) - 0.1);
    if (checkEdge(ldf, rdf)) i = min(i, length(p - vertexInterp(ldf_p, rdf_p, ldf, rdf)) - 0.1);
    if (checkEdge(rdf, rdb)) i = min(i, length(p - vertexInterp(rdf_p, rdb_p, rdf, rdb)) - 0.1);
    if (checkEdge(rdb, ldb)) i = min(i, length(p - vertexInterp(rdb_p, ldb_p, rdb, ldb)) - 0.1);

    return shape < i ? vec4(shape, 1.0, 1.0, 0.0) : vec4(i, 0.5, 0.5, 0.5);
}

vec3 getNormal(in vec3 p) {
    return normalize(vec3(mapScene(p + vec3(0.001, 0.0, 0.0)).x - mapScene(p - vec3(0.001, 0.0, 0.0)).x,
                          mapScene(p + vec3(0.0, 0.001, 0.0)).x - mapScene(p - vec3(0.0, 0.001, 0.0)).x,
                          mapScene(p + vec3(0.0, 0.0, 0.001)).x - mapScene(p - vec3(0.0, 0.0, 0.001)).x));
}

vec3 rot(vec3 p,float tt)
{
    float c1 = cos(tt), s1 = sin(tt);
    float c2 = c1, s2 = s1;
    p.xz *= mat2(c1, s1, -s1, c1);
    p.yz *= mat2(c2, s2, -s2, c2);
    return p;
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){

    //center (0,0) with scaling
    vec2 uv = (screen_coords * 2.0 - screen) / screen.y;
    uv.y = uv.y * -1.0;
    uv*=2.0;

    vec2 mouse = (mouse_pos * 2.0 - screen) / screen.y;
    //mouse.y = mouse.y * -1.0;

    vec2  m = mouse_pos.x <= 0. ? vec2(-0.3) : mouse;
      
    vec4 fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    
    //vec3 ro = vec3(0.0, 0.0, 10.0);
    vec3 ro = vec3(sin(m.y+.76) * cos(-m.x), sin(m.y+.76) * sin(-m.x), cos(m.y +.76))*15.;

    vec3 rd = normalize(vec3(uv, -1.0));
    
   // float c1 = cos(iTime), s1 = sin(iTime);
    float c1 = 1, s1 = 1;

    float c2 = c1, s2 = s1;

    float t = 0.0;

    for (float iters=0.0; iters < 150.0; iters++) {
        vec3 p = ro + rd * t;
        p /= 1.25;

        p.xz *= mat2(c1, s1, -s1, c1);
        p.yz *= mat2(c2, s2, -s2, c2);

        vec4 d = mapScene(p);
        if (d.x < 0.001) {
            vec3 n = getNormal(p);
            vec3 l = vec3(-0.58, 0.58, 0.58);

            n.yz *= mat2(c2, -s2, s2, c2);
            n.xz *= mat2(c1, -s1, s1, c1);

            fragColor.rgb += d.yzw;
            fragColor.rgb *= max(0.2, dot(n, l));
            break;
        }

        if (t > 50.0) {
            break;
        }

        t += d.x;
    }

    return fragColor;
}
