#version 300 es
precision mediump float;

in vec2 vTextureCoord;

uniform sampler2D uTexture;
uniform sampler2D uMaskTexture;
uniform vec2 uMousePos;
uniform vec2 uTMousePos;
uniform vec2 uResolution;
uniform float uRadius;
uniform float uDistort;
uniform float uDispersion;
uniform float uRotSpeed;
uniform float uShadowIntensity;
uniform float uShadowOffsetX;
uniform float uShadowOffsetY;
uniform float uShadowBlur;

out vec4 fragColor;

const float PI = 3.14159265359;

mat2 rot(float a) { 
  float c = cos(a), s = sin(a); 
  return mat2(c, -s, s, c); 
}

float sdCircle(vec2 uv, float r) { 
  return length(uv) - r; 
}

float getDist(vec2 uv) {
  float sd = sdCircle(uv, uRadius);
  vec2 asp = vec2(uResolution.x / uResolution.y, 1.0);
  vec2 mp = uTMousePos * asp;
  float md = length(vTextureCoord * asp - mp);
  float fall = smoothstep(0.0, 0.8, md);
  float tweak = mix(0.02 / fall, 0.1 / fall, uDistort * sd);
  tweak = min(-tweak, 0.0);
  return sd - tweak;
}

// 计算投影
float getShadow(vec2 uv, vec2 lightPos) {
  // 使用独立的X和Y偏移
  vec2 shadowOffset = vec2(uShadowOffsetX, uShadowOffsetY);
  vec2 shadowPos = uv - lightPos + shadowOffset;
  
  // 计算投影区域的距离场
  vec2 asp = vec2(uResolution.x / uResolution.y, 1.0);
  vec2 st = shadowPos * asp;
  st *= 1.0 / (0.4920 + 0.2);
  st = rot(-uRotSpeed * 2.0 * PI) * st;
  
  float shadowDist = getDist(st);
  
  // 使用模糊边缘创建柔和投影
  float shadow = 1.0 - smoothstep(-uShadowBlur, uShadowBlur, shadowDist);
  
  // 投影衰减（距离光源越远投影越淡）
  float distanceFromLight = length(uv - lightPos);
  float attenuation = 1.0 - smoothstep(0.0, 1.0, distanceFromLight);
  
  return shadow * uShadowIntensity * attenuation;
}

vec4 refrakt(float sd, vec2 st, vec4 bg, vec2 originalUV) {
  vec2 offset = mix(vec2(0), normalize(st) / sd, length(st));
  float disp = uDispersion * 0.01;
  
  // 对折射后的坐标也应用投影
  vec2 refractedUV = originalUV + offset * disp;
  vec4 originalBg = texture(uTexture, refractedUV);
  float shadow = getShadow(refractedUV, uMousePos);
  vec3 shadowColor = vec3(0.0, 0.0, 0.0);
  originalBg.rgb = mix(originalBg.rgb, shadowColor, shadow);
  
  vec4 r;
  r.r = originalBg.r;
  r.g = originalBg.g;
  r.b = originalBg.b;
  r.a = 1.0;
  float op = smoothstep(0.0, 0.0025, -sd);
  return mix(bg, r, op);
}

vec4 getEffect(vec2 st, vec4 bg, vec2 originalUV) {
  float eps = 0.0005;
  vec4 sum = vec4(0.0);
  sum += refrakt(getDist(st), st, bg, originalUV);
  sum += refrakt(getDist(st + vec2(eps, 0)), st + vec2(eps, 0), bg, originalUV);
  sum += refrakt(getDist(st - vec2(eps, 0)), st - vec2(eps, 0), bg, originalUV);
  sum += refrakt(getDist(st + vec2(0, eps)), st + vec2(0, eps), bg, originalUV);
  sum += refrakt(getDist(st - vec2(0, eps)), st - vec2(0, eps), bg, originalUV);
  return sum * 0.2;
}

void main() {
  vec2 uv = vTextureCoord;
  vec4 bg = texture(uTexture, uv);
  
  // 计算投影并应用到背景
  float shadow = getShadow(uv, uMousePos);
  vec3 shadowColor = vec3(0.0, 0.0, 0.0); // 黑色投影
  bg.rgb = mix(bg.rgb, shadowColor, shadow);
  
  vec2 st = uv - uMousePos;
  st *= vec2(uResolution.x / uResolution.y, 1.0);
  st *= 1.0 / (0.4920 + 0.2);
  st = rot(-uRotSpeed * 2.0 * PI) * st;
  vec4 color = getEffect(st, bg, uv);
  vec4 m = texture(uMaskTexture, uv);
  fragColor = color * (m.a * m.a);
}
