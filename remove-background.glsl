uniform texture2d bg_image;
uniform float threshold = 0.06; //<Range(0.0,1.0)>
uniform float suckIn = 0.05;
uniform float averageDistance = 0.008;
uniform bool blue_pixel_dropping = false;
uniform float blue_pixel_dropping_threshold = 0.0;
uniform bool mute_blues = false;

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

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

      float4 bg = bg_image.Sample(textureSampler, uv2);
      float4 fg = image.Sample(textureSampler, uv2);

      float3 diff = abs(fg.rgb-bg.rgb);
      float3 diffhue = abs(rgb2hsv(bg.rgb)-rgb2hsv(fg.rgb));
      float biggestDiff = max(max(max(max(max(diff.r,diff.g), diff.b), diffhue[0]), diffhue[1]), diffhue[2]);
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
 // return float4(1,1,1,diffAvgHere);
  //if (biggestDiff < 0.06 && diffAvg < 0.1) return float4(fg.rgb,0);
  //return fg;
  if (blue_pixel_dropping && fg.b > (fg.g+fg.r)+0.2-blue_pixel_dropping_threshold) return float4(0,0,0,0);

 // if (blue_pixel_dropping) {
 //   float3 hsv = rgb2hsv(fg.rgb);
 //   if (hsv[0] > 0.56 && hsv[0] < 0.65 && hsv[1] > blue_pixel_dropping_threshold && hsv[2] > blue_pixel_dropping_threshold)
 //     return float4(0,0,0,0);
 // }


  if (diffAvgLeft > threshold && diffAvgRight > threshold && diffAvgUp > threshold) {
    if (mute_blues && fg.b > (fg.g+fg.r)-0.2) {
      fg.b = (fg.g+fg.r)-0.2;
    }
    return fg;
  }
  return float4(0,0,0,0);

  //if (diffAvgHere < 0.06 && diffAvgLeft < 0.06) ;
  //return fg;
}
