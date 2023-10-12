//
//  RainDrop.metal
//  MetalTest
//
//  Created by Tom on 10/1/23.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

inline float S(float a, float b, float t) {
  return smoothstep(a, b, t);
}

float3 N13(float p) {
  float3 p3 = fract(float3(p) * float3(0.1031, 0.11369, 0.13787));
  p3 += dot(p3, float3(p3.y, p3.z, p3.x) + 19.19);
  return fract(float3((p3.x + p3.y) * p3.z, (p3.x + p3.z) * p3.y, (p3.y + p3.z) * p3.x));
}

float4 N14(float t) {
  return fract(sin(t * float4(123.0, 1024.0, 1456.0, 264.0)) * float4(6547.0, 345.0, 8799.0, 1564.0));
}

float N(float t) {
  return fract(sin(t * 12345.564) * 7658.76);
}

float Saw(float b, float t) {
  return S(0.0, b, t) * S(1.0, b, t);
}

float2 DropLayer2(float2 uv, float t) {
  float2 UV = uv;
  
  uv.y += t * 0.75;
  
  // Define grid
  float2 a = float2(6.0, 1.0);
  float2 grid = a * 2.0;
  float2 id = floor(uv * grid);
  
  // Column shift
  float colShift = N(id.x);
  uv.y += colShift;
  
  id = floor(uv * grid);
  float3 n = N13(id.x * 35.2 + id.y * 2376.1);
  float2 st = fract(uv * grid) - float2(0.5, 0.0);
  
  // Setting x position
  float x = n.x - 0.5;
  
  float y = UV.y * 20.0;
  float wiggle = sin(y + sin(y));
  x += wiggle * (0.5 - abs(x)) * (n.z - 0.5);
  x *= 0.7;
  float ti = fract(t + n.z);
  y = (Saw(0.85, ti) - 0.5) * 0.9 + 0.5;
  float2 p = float2(x, y);
  
  // Calculate distance for the main drop
  float d = length((st - p) * a.yx);
  
  // Main drop
  float mainDrop = S(0.4, 0.0, d);
  
  // Drop trail
  float r = sqrt(S(1.0, y, st.y));
  float cd = abs(st.x - x);
  float trail = S(0.23 * r, 0.15 * r * r, cd);
  float trailFront = S(-0.02, 0.02, st.y - y);
  trail *= trailFront * r * r;
  
  y = UV.y;
  float trail2 = S(0.2 * r, 0.0, cd);
  float droplets = max(0.0, (sin(y * (1.0 - y) * 120.0) - st.y)) * trail2 * trailFront * n.z;
  y = fract(y * 10.0) + (st.y - 0.5);
  float dd = length(st - float2(x, y));
  droplets = S(0.3, 0.0, dd);
  float m = mainDrop + droplets * r * trailFront;
  
  return float2(m, trail);
}

float StaticDrops(float2 uv, float t) {
  uv *= 30.0;
  
  float2 id = floor(uv);
  uv = fract(uv) - 0.5;
  float3 n = N13(id.x * 107.45 + id.y * 3543.654);
  float2 p = (n.xy - 0.5) * 0.7;
  float d = length(uv - p);
  
  float fade = Saw(0.025, fract(t + n.z));
  float c = S(0.3, 0.0, d) * fract(n.z * 10.0) * fade;
  return c;
}

float2 Drops(float2 uv, float t, float l0, float l1, float l2) {
  float s = StaticDrops(uv, t) * l0;
  float2 m1 = DropLayer2(uv, t) * l1;
  float2 m2 = DropLayer2(uv * 1.85, t) * l2;
  
  float c = s + m1.x + m2.x;
  c = S(0.3, 1.0, c);
  
  return float2(c, max(m1.y * l0, m2.y * l1));
}

half3 bilateralBlur(SwiftUI::Layer layer, float2 uv, float2 res) {
  
  const int GAUSSIAN_SAMPLES = 9;
  const float2 inCoordinate = uv;
  
  int multiplier = 0;
  float2 blurStep;
  float2 singleStepOffset(float(6.0) / res.x, float(6.0) / res.y);
  float2 blurCoordinates[GAUSSIAN_SAMPLES];
  
  for (int i = 0; i < GAUSSIAN_SAMPLES; i++) {
    multiplier = (i - ((GAUSSIAN_SAMPLES - 1) / 2));
    blurStep = float(multiplier) * singleStepOffset;
    blurCoordinates[i] = inCoordinate + blurStep;
  }
  
  half4 centralColor;
  float gaussianWeightTotal;
  half4 sum;
  half4 sampleColor;
  float distanceFromCentralColor;
  float gaussianWeight;
  
  const float distanceNormalizationFactor = float(0.01);
  
  centralColor = layer.sample(blurCoordinates[4]);
  gaussianWeightTotal = 0.18;
  sum = centralColor * 0.18;
  
  sampleColor = layer.sample(blurCoordinates[0]);
  distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
  gaussianWeight = 0.05 * (1.0 - distanceFromCentralColor);
  gaussianWeightTotal += gaussianWeight;
  sum += sampleColor * gaussianWeight;
  
  sampleColor = layer.sample(blurCoordinates[1]);
  distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
  gaussianWeight = 0.09 * (1.0 - distanceFromCentralColor);
  gaussianWeightTotal += gaussianWeight;
  sum += sampleColor * gaussianWeight;
  
  sampleColor = layer.sample(blurCoordinates[2]);
  distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
  gaussianWeight = 0.12 * (1.0 - distanceFromCentralColor);
  gaussianWeightTotal += gaussianWeight;
  sum += sampleColor * gaussianWeight;
  
  sampleColor = layer.sample(blurCoordinates[3]);
  distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
  gaussianWeight = 0.15 * (1.0 - distanceFromCentralColor);
  gaussianWeightTotal += gaussianWeight;
  sum += sampleColor * gaussianWeight;
  
  sampleColor = layer.sample(blurCoordinates[5]);
  distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
  gaussianWeight = 0.15 * (1.0 - distanceFromCentralColor);
  gaussianWeightTotal += gaussianWeight;
  sum += sampleColor * gaussianWeight;
  
  sampleColor = layer.sample(blurCoordinates[6]);
  distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
  gaussianWeight = 0.12 * (1.0 - distanceFromCentralColor);
  gaussianWeightTotal += gaussianWeight;
  sum += sampleColor * gaussianWeight;
  
  sampleColor = layer.sample(blurCoordinates[7]);
  distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
  gaussianWeight = 0.09 * (1.0 - distanceFromCentralColor);
  gaussianWeightTotal += gaussianWeight;
  sum += sampleColor * gaussianWeight;
  
  sampleColor = layer.sample(blurCoordinates[8]);
  distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
  gaussianWeight = 0.05 * (1.0 - distanceFromCentralColor);
  gaussianWeightTotal += gaussianWeight;
  sum += sampleColor * gaussianWeight;
  
  half4 ret = sum / gaussianWeightTotal;
  return half3(ret.rgb);
}

//[[stitchable]] half4 rainDrop(float2 position, SwiftUI::Layer layer, float4 bounds, float time) {
//  float2 resolution = bounds.zw;
//  float2 uv = (position - 0.5 * resolution) / resolution.y;
//  uv.y *= -1.0;
//  float2 UV = position / resolution;
//  UV += 0.5;
////  UV.y = 0.5 + UV.y;
//  
//  float t = time * 0.2;
//  float rainAmount = 0.9;
//  
//  float staticDrops = S(-0.5, 1.0, rainAmount);
//  float layer1 = S(0.25, 0.75, rainAmount);
//  float layer2 = S(0.0, 0.5, rainAmount);
//  
//  float2 c = Drops(uv, t, staticDrops, layer1, layer2);
//  float2 e = float2(0.008, 0.0);
//  float cx = Drops(uv + e, t, staticDrops, layer1, layer2).x;
//  float cy = Drops(uv + float2(e.y, e.x), t, staticDrops, layer1, layer2).x;
//  float2 n = float2(cx - c.x, cy - c.x);
//  
//  half3 color = bilateralBlur(layer, UV + n, resolution);
//  
//  return half4(color.rgb, 1.0);
//}


[[stitchable]] half4 rainDrop(float2 position, half4 color, texture2d<half> image, float4 bounds, float time) {
  constexpr sampler sampler(address::clamp_to_edge, filter::linear);
  
  float2 resolution = bounds.zw;
  float2 uv = (position.xy - 0.5 * resolution.xy) / resolution.y;
  uv.y *= -1.0;
  float2 UV = position.xy / resolution.xy;
  float t = time * 0.2;
  
  float rainAmount = sin(time * 0.05) * 0.3 + 0.7;
  
  uv *= 0.6;
  
  float staticDrops = S(-0.5, 1.0, rainAmount) * 2.0;
  float layer1 = S(0.25, 0.75, rainAmount);
  float layer2 = S(0.0, 0.5, rainAmount);
  
  float2 c = Drops(uv, t, staticDrops, layer1, layer2);
  
  // Define the normals
  float2 e = float2(0.001, 0.0);
  float cx = Drops(uv + e, t, staticDrops, layer1, layer2).x;
  float cy = Drops(uv + float2(e.y, e.x), t, staticDrops, layer1, layer2).x;
  float2 n = float2(cx - c.x, cy - c.x);
  
  float maxBlur = mix(3.0, 6.0, rainAmount);
  float minBlur = 0.2;
  
  float focus = mix(maxBlur - c.y, minBlur, S(0.1, 0.2, c.x));
  
  return image.sample(sampler, UV + n * focus);
}
