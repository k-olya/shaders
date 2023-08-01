// normalize screen space coordinates
vec2 norm(int x, int y) {
    // replace with actual screen resolution
    vec2 resolution = vec2(float(1914), float(1019));
    return vec2(float(x), float(y)) / resolution;
}

// map one rect to another
void collage( out vec4 fragColor, in vec2 srcXY, in vec2 srcWH, in vec2 destXY, in vec2 destWH, in vec2 uv) {
    if (clamp(uv, destXY, destXY + destWH) == uv) {
        vec2 t = (uv - destXY) / destWH;
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

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    vec4 color = texture(iChannel0, uv);

    // Output to screen
    fragColor = vec4(0.);
    
    //                 video  x, y     video  w, h     screen x, y      screen w, h
    collage(fragColor, vec2(0.1, 0.0), vec2(0.2, .50), norm(0, 216), norm(252, 627), uv);
    collage(fragColor, vec2(0.1, 0.0), vec2(0.3, 1.0), norm(257, 195), norm(131, 824), uv);
    
    collage(fragColor, vec2(0.1, 0.0), vec2(0.3, 1.0), norm(394, 195), norm(136, 824), uv);
    collage(fragColor, vec2(0.1, 0.0), vec2(0.3, 1.0), norm(536, 216), norm(153, 803), uv);
    collage(fragColor, vec2(0.1, 0.0), vec2(0.3, 1.0), norm(694, 216), norm(153, 634), uv);
    collage(fragColor, vec2(0.1, 0.0), vec2(0.3, 1.0), norm(853, 196), norm(153, 654), uv);
    collage(fragColor, vec2(0.1, 0.0), vec2(0.3, 1.0), norm(1009, 0), norm(147, 391), uv);
    collage(fragColor, vec2(0.1, 0.0), vec2(0.3, 1.0), norm(1009, 723), norm(147, 127), uv);
    collage(fragColor, vec2(0.1, 0.0), vec2(0.3, 1.0), norm(1158, 0), norm(141, 391), uv);
    
    collage(fragColor, vec2(0.1, 0.0), vec2(0.3, 1.0), norm(1158, 723), norm(141, 127), uv);
    collage(fragColor, vec2(0.1, 0.0), vec2(0.3, 1.0), norm(1301, 0), norm(143, 391), uv);
    collage(fragColor, vec2(0.1, 0.0), vec2(0.3, 1.0), norm(1301, 723), norm(143, 127), uv);
    collage(fragColor, vec2(0.1, 0.0), vec2(0.3, 1.0), norm(1446, 0), norm(148, 391), uv);
    collage(fragColor, vec2(0.1, 0.0), vec2(0.3, 1.0), norm(1446, 723), norm(148, 127), uv);
    collage(fragColor, vec2(0.1, 0.0), vec2(0.3, 1.0), norm(1596, 196), norm(148, 654), uv);
    collage(fragColor, vec2(0.1, 0.0), vec2(0.3, 1.0), norm(1748, 196), norm(166, 654), uv);
    
    
    // example mask
    mask(fragColor, norm(420, 256), norm(64, 64), uv);
}