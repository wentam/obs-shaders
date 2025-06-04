uniform texture2d bg_image;
uniform float threshold = 0.06; //<Range(0.0,1.0)>
uniform float suckIn = 0.05;
uniform float averageDistance = 0.008;

float diffAvg(vec2 uv_in) {
  float sampling_offset = averageDistance;

  float diffAvg = 0.0;
  int count = 0;
  for (int i = -5; i <= 5; i++) {
    vec2 uv = uv_in;
    uv.x += i*sampling_offset;

    for (int j = -5; j <= 5; j++) {
      vec2 uv2 = uv;
      uv2.y += j*sampling_offset;

      float weight1 = (11.0-abs(j))/11.0;
      float weight2 = (11.0-abs(i))/11.0;
      //weight1 = 1.0;
      //weight2 = 1.0;

      float4 bg = bg_image.Sample(textureSampler, uv2);
      float4 fg = image.Sample(textureSampler, uv2);

      float3 diff = abs(fg.rgb-bg.rgb);
      float biggestDiff = max(max(diff.r,diff.g), diff.b);
      diffAvg += biggestDiff*weight1*weight2;

      count++;
    }
  }
  diffAvg /= count;
  return diffAvg;
}

float4 mainImage(VertData v_in) : TARGET {
  float diffAvgHere = diffAvg(v_in.uv);

  vec2 left = v_in.uv;
  left.x -= suckIn;
  float diffAvgLeft = diffAvg(left);

  vec2 right = v_in.uv;
  right.x += suckIn;
  float diffAvgRight = diffAvg(right);

  vec2 up = v_in.uv;
  up.y -= suckIn;
  float diffAvgUp = diffAvg(up);

  float4 fg = image.Sample(textureSampler, v_in.uv);
  float4 bg = bg_image.Sample(textureSampler, v_in.uv);

  float3 diff = abs(fg.rgb-bg.rgb);
  float biggestDiff = max(max(diff.r,diff.g), diff.b);

  //if (biggestDiff < 0.06 && diffAvg < 0.1) return float4(fg.rgb,0);

  if (diffAvgLeft > threshold && diffAvgRight > threshold && diffAvgUp > threshold) return fg;
  return float4(fg.rgb,0);

  //if (diffAvgHere < 0.06 && diffAvgLeft < 0.06) ;
  //return fg;
}
