precision mediump float;

varying vec2 vUv;
uniform vec2 u_resolution;
uniform float u_time;

#define FACTOR 40.

float HexDist(vec2 p, vec2 id){
    float t = u_time;

    p = abs(p); // Copy over first quad into all
    float c = dot(p, normalize(vec2(1,1.73)));// Dot to get correct angle
    return max(c, p.x); // Find where the vert line and angled intersect
}

vec4 HexCoords(vec2 uv){
    vec2 rep = vec2(1, 1.73);
    vec2 h = rep*0.5;
    vec2 a = mod(uv, rep)-h;
    vec2 b = mod(uv-h, rep)-h;


    vec2 gv;
	if(length(a) < length(b))
    	gv = a;
    else
        gv = b;

    vec2 id = (uv-gv)+FACTOR;
    float y = 0.5-HexDist(gv, id);
    return vec4(gv.x, y, id.x, id.y);
}
float Circle(vec2 pos)
{
    float o_radius = 1.0;
    float i_radius = 0.7;
    float d = length(pos.xy);
    float c = max(o_radius-(o_radius-mod(d-u_time*0.2, o_radius))-i_radius, 0.0);
    return c;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord-0.5*u_resolution.xy)/u_resolution.y;

    vec3 col = vec3(0);
float circle = Circle(uv);
    uv *= FACTOR;
	vec4 hexC = HexCoords(uv);
	float t = mod(u_time, 2000.);
    col += smoothstep(0.05, 0.1, hexC.y*sin(hexC.w*hexC.z+t));
    col += smoothstep(0.2, 0.15, hexC.y);
    col += 0.5-smoothstep(0.15, 0.1, hexC.y);
    col *= (sin(((hexC.z)/32.))*0.5)*vec3(0.4, 0.7, 1.0);
    col += vec3(0.3, 0.4, 0.8)*0.2;
    if (hexC.w < 30.1) {
        col *= smoothstep(20. , 28.0, hexC.w);
    } else if (hexC.w > 50.) {
        col *= smoothstep( 60.0, 53.0, hexC.w);
    }
    if (hexC.z < 30.1) {
        col *= smoothstep(20. , 28.0, hexC.z);
    } else if (hexC.z > 50.) {
        col *= smoothstep( 60.0, 51.0, hexC.z);
    }
    // Output to screen
    vec3 gridColor = vec3(0.2, 0.3, 0.5);
    col *=gridColor*circle*8.;

    fragColor = vec4(col,0.7);
}
void main() {
    mainImage(gl_FragColor, vUv * u_resolution.xy);
}