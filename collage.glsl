float random (vec2 st) {
        st = fract(st * vec2(123.45, 456.78));
        st += dot(st, st * 42.0);
        return clamp(fract(st.x * st.y) + .2, 0., 1.);
    }

// normalize screen space coordinates
vec2 norm(int x, int y) {
    // replace with actual screen resolution
    vec2 resolution = vec2(float(1914), float(1019));
    return vec2(float(x), float(y)) / resolution;
}
float o(int i) {
    float x = float(11 - i);
    return clamp(smoothstep(.0 + x, 1. + x, 40. + 40. * sin(iTime * .2)), 0., 1.);
}
// map one rect to another
void collage( out vec4 fragColor, in vec2 srcXY, in float srcW, in vec2 destXY, in vec2 destWH, in vec2 uv, in int i) {
    // destWH.y *= o(i); // enable show/hide transition fx
    //destXY.y -= destWH.y;
    float randv = dot(random(destXY), random(destXY));
    destXY.y += .1 * sin(float(i) * 1.57 + iTime * 1.57 * randv);
    destWH.y *= .75 + .25 * sin(float(i) * 1.57 + iTime * 1.57 * randv);//sin(float(i * 10) + iTime * 9.72);
    vec2 destWHprev = destWH;
    // shrink & no overlap
    //destWH.x *= .66 + .33 * sin(float(11 - i) * 1.57 + iTime * 1.57 * randv);
    // shrink & overlap
    destWH.x = .5 + .5 * sin(float(11 - i) * 1.57 + iTime * 1.57 * randv);
    if (clamp(uv, destXY, destXY + destWH) == uv) {
        srcXY = fract(srcXY);
        vec2 srcWH = vec2(srcW, srcW * destWHprev.y / destWHprev.x);
        vec2 t = (uv - destXY) / destWHprev;
        vec2 st = mix(srcXY, srcXY + srcWH, t);
        fragColor = texture(iChannel0, st); // vec4(.75, 0.0, 0.75, 1.0);
    }
}

// black rectangular mask
void mask( out vec4 fragColor, in vec2 xy, in vec2 wh, in vec2 uv ) {
    if (clamp(uv, xy, xy + wh) == uv) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    }
}

// animation functions
float vx(int i) {
    return 0.07 * mix(pow(float(i + 2), 0.8), float(i + 2), .5 + .5 * sin(iTime * .15));
}
float vy(int i) {
    return 0.;
}
float vw(int i) {
    return 0.086 / mix(pow(float(i + 4), .2), 1.0, .5 + .5 * sin(iTime * .25)) + clamp(float(1 - i), 0.0, 1.0) * 0.06;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    vec4 color = texture(iChannel0, fract(uv));

    // Output to screen
    fragColor = vec4(0.);
    
    //                 video  x, y     video  w       screen x, y      screen w, h
    collage(fragColor, vec2(vx(0), vy(0)), vw(0), norm(0, 216), norm(252, 627), uv, 0);
    collage(fragColor, vec2(vx(1), vy(1)), vw(1), norm(257, 195), norm(131, 824), uv, 1);
    collage(fragColor, vec2(vx(2), vy(2)), vw(2), norm(394, 195), norm(136, 824), uv, 2);
    collage(fragColor, vec2(vx(3), vy(3)), vw(3), norm(536, 216), norm(153, 803), uv, 3);
    collage(fragColor, vec2(vx(4), vy(4)), vw(4), norm(694, 216), norm(153, 634), uv, 4);
    collage(fragColor, vec2(vx(5), vy(5)), vw(5), norm(853, 196), norm(153, 654), uv, 5);
    
    //collage(fragColor, vec2(vx(6), vy(6)), vw(6), norm(1009, 0), norm(147, 391), uv, 6);
    //collage(fragColor, vec2(vx(6), vy(6)), vw(6), norm(1009, 723), norm(147, 127), uv, 6);
    collage(fragColor, vec2(vx(6), vy(6)), vw(6), norm(1009, 0), norm(147, 850), uv, 6);
    
    //collage(fragColor, vec2(vx(7), vy(7)), vw(7), norm(1158, 0), norm(141, 391), uv, 7);
    //collage(fragColor, vec2(vx(7), vy(7)), vw(7), norm(1158, 723), norm(141, 127), uv, 7);
    collage(fragColor, vec2(vx(7), vy(7)), vw(7), norm(1158, 0), norm(141, 850), uv, 7);
    
    //collage(fragColor, vec2(vx(8), vy(8)), vw(8), norm(1301, 0), norm(142, 391), uv, 8);
    //collage(fragColor, vec2(vx(8), vy(8)), vw(8), norm(1301, 723), norm(142, 127), uv, 8);
    collage(fragColor, vec2(vx(8), vy(8)), vw(8), norm(1301, 0), norm(142, 850), uv, 8);
    
    //collage(fragColor, vec2(vx(9), vy(9)), vw(9), norm(1446, 0), norm(148, 391), uv, 9);
    //collage(fragColor, vec2(vx(9), vy(9)), vw(9), norm(1446, 723), norm(148, 127), uv, 9);
    collage(fragColor, vec2(vx(9), vy(9)), vw(9), norm(1446, 0), norm(148, 850), uv, 9);
    
    
    
    collage(fragColor, vec2(vx(10), vy(10)), vw(10), norm(1596, 196), norm(148, 654), uv, 10);
    collage(fragColor, vec2(vx(11), vy(11)), vw(11), norm(1748, 196), norm(166, 654), uv, 11);
    
    
    // example mask
    mask(fragColor, norm(1009, 391), norm(585, 332), uv);
}