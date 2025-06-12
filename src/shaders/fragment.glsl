#version 300 es
precision mediump float;

in vec2 vTextureCoord;

uniform sampler2D uTexture;
uniform sampler2D uMaskTexture;
uniform vec2 uMousePos;
uniform vec2 uTMousePos;
uniform vec2 uResolution;
uniform vec2 uTextureResolution;
uniform float uRadius;
uniform float uDistort;
uniform float uDispersion;
uniform float uRotSpeed;
uniform float uShadowIntensity;
uniform float uShadowOffsetX;
uniform float uShadowOffsetY;
uniform float uShadowBlur;
uniform float uHighlightIntensity;
uniform float uHighlightSize;
uniform float uHighlightOffsetX;
uniform float uHighlightOffsetY;

out vec4 fragColor;

const float PI = 3.14159265359;

mat2 rot(float a) { 
  float c = cos(a), s = sin(a); 
  return mat2(c, -s, s, c); 
}

// Transform UV coordinates to maintain aspect ratio - contain mode (show complete image)
vec2 getAspectCorrectedUV(vec2 uv, out bool isOutOfBounds) {
  // Calculate aspect ratios
  float textureAspect = uTextureResolution.x / uTextureResolution.y;
  float screenAspect = uResolution.x / uResolution.y;
  
  // Contain mode - fit the entire image within the screen, may have letterboxing
  vec2 scale = vec2(1.0);
  
  if (textureAspect > screenAspect) {
    // Image is wider than screen - fit to screen width, letterbox top/bottom
    scale.y = textureAspect / screenAspect;
  } else {
    // Image is taller than screen - fit to screen height, letterbox left/right
    scale.x = screenAspect / textureAspect;
  }
  
  // Apply scaling and center
  vec2 correctedUV = (uv - 0.5) * scale + 0.5;
  
  // Check if UV is out of bounds (letterbox area)
  isOutOfBounds = correctedUV.x < 0.0 || correctedUV.x > 1.0 || correctedUV.y < 0.0 || correctedUV.y > 1.0;
  
  return correctedUV;
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

// Calculate shadow
float getShadow(vec2 uv, vec2 lightPos) {
  // Use independent X and Y offsets
  vec2 shadowOffset = vec2(uShadowOffsetX, uShadowOffsetY);
  vec2 shadowPos = uv - lightPos + shadowOffset;
  
  // Calculate distance field for shadow area
  vec2 asp = vec2(uResolution.x / uResolution.y, 1.0);
  vec2 st = shadowPos * asp;
  st *= 1.0 / (0.4920 + 0.2);
  st = rot(-uRotSpeed * 2.0 * PI) * st;
  
  float shadowDist = getDist(st);
  
  // Create soft shadow with blurred edges
  float shadow = 1.0 - smoothstep(-uShadowBlur, uShadowBlur, shadowDist);
  
  // Shadow attenuation (farther from light source, fainter shadow)
  float distanceFromLight = length(uv - lightPos);
  float attenuation = 1.0 - smoothstep(0.0, 1.0, distanceFromLight);
  
  return shadow * uShadowIntensity * attenuation;
}

// Calculate highlight effect
float getHighlight(vec2 uv, vec2 lightPos) {
  // Use independent X and Y offsets for highlight
  vec2 highlightOffset = vec2(uHighlightOffsetX, uHighlightOffsetY);
  vec2 highlightPos = uv - lightPos + highlightOffset;
  
  // Calculate distance field for highlight area
  vec2 asp = vec2(uResolution.x / uResolution.y, 1.0);
  vec2 st = highlightPos * asp;
  st *= 1.0 / (0.4920 + 0.2);
  st = rot(-uRotSpeed * 2.0 * PI) * st;
  
  // Create smaller highlight circle
  float highlightRadius = uRadius * uHighlightSize;
  float highlightDist = sdCircle(st, highlightRadius);
  
  // Create soft highlight with smooth edges
  float highlight = 1.0 - smoothstep(-0.02, 0.02, highlightDist);
  
  // Add falloff from center for more realistic glass highlight
  float centerDist = length(st);
  float centerFalloff = 1.0 - smoothstep(0.0, highlightRadius * 0.8, centerDist);
  highlight *= centerFalloff;
  
  // Distance attenuation
  float distanceFromLight = length(uv - lightPos);
  float attenuation = 1.0 - smoothstep(0.0, 1.0, distanceFromLight);
  
  return highlight * uHighlightIntensity * attenuation;
}

vec4 refrakt(float sd, vec2 st, vec4 bg, vec2 originalUV) {
  vec2 offset = mix(vec2(0), normalize(st) / sd, length(st));
  float disp = uDispersion * 0.01;
  
  // Apply shadow to refracted coordinates as well
  vec2 refractedUV = originalUV + offset * disp;
  bool isOutOfBounds;
  vec2 aspectCorrectedRefractedUV = getAspectCorrectedUV(refractedUV, isOutOfBounds);
  
  vec4 originalBg;
  if (isOutOfBounds) {
    // Use a neutral background color for out-of-bounds areas
    originalBg = vec4(0.8, 0.8, 0.8, 1.0); // Light gray background
  } else {
    originalBg = texture(uTexture, aspectCorrectedRefractedUV);
  }
  
  float shadow = getShadow(refractedUV, uMousePos);
  vec3 shadowColor = vec3(0.0, 0.0, 0.0); // Black shadow
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
  bool isOutOfBounds;
  vec2 aspectCorrectedUV = getAspectCorrectedUV(uv, isOutOfBounds);
  
  vec4 bg;
  if (isOutOfBounds) {
    // Use a neutral background color for letterbox areas
    bg = vec4(0.8, 0.8, 0.8, 1.0); // Light gray background
  } else {
    bg = texture(uTexture, aspectCorrectedUV);
  }
  
  // Calculate shadow and apply to background
  float shadow = getShadow(uv, uMousePos);
  vec3 shadowColor = vec3(0.0, 0.0, 0.0); // Black shadow
  bg.rgb = mix(bg.rgb, shadowColor, shadow);
  
  vec2 st = uv - uMousePos;
  st *= vec2(uResolution.x / uResolution.y, 1.0);
  st *= 1.0 / (0.4920 + 0.2);
  st = rot(-uRotSpeed * 2.0 * PI) * st;
  
  vec4 color = getEffect(st, bg, uv);
  
  // Add realistic highlight effect - simulate exposure increase instead of adding white
  float highlight = getHighlight(uv, uMousePos);
  
  // Method 1: Exposure-based highlight (preserves color ratios)
  float exposure = 1.0 + highlight * 2.5; // Increase exposure in highlight areas
  vec3 exposedColor = 1.0 - exp(-color.rgb * exposure);
  
  // Method 2: Brightness enhancement (alternative approach)
  vec3 brightenedColor = color.rgb * (1.0 + highlight * 1.8);
  
  // Blend between exposure and brightness methods for best result
  color.rgb = mix(exposedColor, brightenedColor, 0.3);
  
  // Add subtle warm tint to simulate realistic light reflection
  vec3 warmTint = vec3(1.02, 1.01, 0.98); // Slightly warm
  color.rgb *= mix(vec3(1.0), warmTint, highlight * 0.3);
  
  vec4 m = texture(uMaskTexture, uv);
  fragColor = color * (m.a * m.a);
}
