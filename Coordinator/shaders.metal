#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

// --- HELPER: Random Noise Generator ---
float random(float2 st) {
    return fract(sin(dot(st.xy, float2(12.9898,78.233))) * 43758.5453123);
}

// --- 1. SEXY WAVE SHADER ---
[[ stitchable ]] half4 sexyWave(float2 position, half4 currentColor, float2 size, float time) {
    float2 uv = position / size;
    
    // Wave settings
    float waveHeight = 0.05;
    float waterLevel = 0.5;
    
    // Combine 3 sine waves for organic look
    float y1 = sin((uv.x * 5.0) + time) * waveHeight;
    float y2 = sin((uv.x * 13.0) + (time * 2.3)) * (waveHeight * 0.5);
    float y3 = sin((uv.x * 30.0) + (time * 3.5)) * (waveHeight * 0.2);
    
    float totalWaveY = waterLevel + y1 + y2 + y3;
    
    // Draw Air (Transparent)
    if (uv.y < (1.0 - totalWaveY)) {
        return half4(0.0, 0.0, 0.0, 0.0);
    }
    
    // Draw Water
    float depth = (uv.y - (1.0 - totalWaveY));
    float foamLine = step(depth, 0.01);
    
    half4 deepBlue = half4(0.1, 0.2, 0.6, 1.0);
    half4 tropical = half4(0.0, 0.8, 0.9, 1.0);
    half4 foam = half4(1.0, 1.0, 1.0, 1.0);
    
    half4 waterColor = mix(tropical, deepBlue, depth * 3.0);
    return mix(waterColor, foam, foamLine);
}

// --- 2. SEXY RAIN SHADER ---
[[ stitchable ]] half4 sexyRain(float2 position, half4 currentColor, float2 size, float time) {
    float2 uv = position / size;
    uv.x *= size.x / size.y; // Fix aspect ratio
    uv.x -= uv.y * 0.2;      // Tilt
    
    float fallSpeed = 2.0;
    float2 rainUV = uv;
    rainUV.y += time * fallSpeed;
    rainUV.y *= 20.0; // Stretch drops
    
    float2 cellId = floor(rainUV);
    float2 cellUV = fract(rainUV);
    float rand = random(cellId);
    
    float drop = step(0.97, rand) * (1.0 - cellUV.y);
    half4 rainColor = half4(0.8, 0.9, 1.0, 0.5);
    
    return mix(currentColor, rainColor, drop);
}

// --- 3. SEXY SNOW SHADER ---
[[ stitchable ]] half4 sexySnow(float2 position, half4 currentColor, float2 size, float time) {
    float2 uv = position / size;
    uv.x *= size.x / size.y;
    
    float brightness = 0.0;
    
    for (float i = 1.0; i <= 3.0; i++) {
        float speed = 0.3 * i;
        float layerSize = 5.0 * i;
        float2 layerUV = uv;
        
        layerUV.y += time * speed;
        layerUV.x += sin(time + layerUV.y * 2.0) * 0.1;
        layerUV *= layerSize;
        
        float2 cellId = floor(layerUV);
        float2 cellUV = fract(layerUV) - 0.5;
        float rand = random(cellId * i);
        
        float snowflake = smoothstep(0.3, 0.1, length(cellUV));
        if (rand > 0.8) { brightness += snowflake * rand; }
    }
    
    return mix(currentColor, half4(1.0, 1.0, 1.0, 1.0), min(brightness, 1.0));
}
