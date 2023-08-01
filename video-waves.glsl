// iChannel0 is video input
// based on https://www.shadertoy.com/view/3ttSzr

vec2 rot(vec2 uv, float angle) {
    float cosA = cos(angle);
    float sinA = sin(angle);
    return vec2(uv.x * cosA - uv.y * sinA, uv.x * sinA + uv.y * cosA);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec2 uv =  (2.0 * fragCoord - iResolution.xy) / min(iResolution.x, iResolution.y);
   uv = rot(uv, -0.5 + iTime * 0.05);
    for(float i = 1.0; i < 5.0; i++){
    uv.y += i * 0.05 / i * 
      sin(uv.x * i * i + iTime * 2.5) * sin(uv.y * i * i + iTime * 3.5);
  }
    

   vec3 col = texture(iChannel0, uv * .5 + .5).rgb;
    
    fragColor = vec4(col,1.0);
}