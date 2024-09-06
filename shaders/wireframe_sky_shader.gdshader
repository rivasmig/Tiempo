shader_type sky;

// Define constants and uniform groups
#define USE_TWINKLE

group_uniforms sky;
uniform vec3 sky_color : source_color = vec3(0.03, 0.05, 0.11); // Base sky color

group_uniforms grid;
uniform vec3 grid_color : source_color = vec3(0.0, 1.0, 0.5); // Color of the grid lines
uniform float grid_spacing : hint_range(0.01, 1.0) = 10.0; // Distance between grid lines
uniform float grid_thickness : hint_range(0.001, 5.0) = 0.005; // Thickness of the grid lines
uniform float grid_glow_intensity : hint_range(0.0, 5.0) = 2.0; // Glow intensity for grid

group_uniforms stars;
uniform vec3 star_base_color : source_color = vec3(0.8, 1.0, 0.3);
uniform float star_hue_offset : hint_range(0., 1.) = 0.6;
uniform float star_intensity : hint_range(0., 0.2) = 0.08;
#ifdef USE_TWINKLE
uniform float star_twinkle_speed : hint_range(0.0, 2.0) = 0.8;
uniform float star_twinkle_intensity : hint_range(0.0, 1.0) = 0.2;
#endif

group_uniforms layers;
uniform float layer_scale : hint_range(0., 60.) = 20.;
uniform float layer_scale_step : hint_range(0., 40.) = 10.;
uniform int layers_count : hint_range(0, 12) = 3;

// New uniform for horizon fade control
uniform float horizon_fade_range : hint_range(0.0, 1.0) = 0.2;

// Helper functions for hue shift and Voronoi calculation
vec3 hue(vec3 input, float offset, int range_index) {
    // RGB to HSV
    vec4 k = vec4(0., -1./3., 2./3., -1.);
    vec4 p = mix(vec4(input.bg, k.wz), vec4(input.gb, k.xy), step(input.b, input.g));
    vec4 q = mix(vec4(p.xyw, input.r), vec4(input.r, p.yzx), step(p.x, input.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.e-10;
    vec3 hsv = vec3(abs(q.z + (q.w - q.y) / (6. * d + e)), d / (q.x + e), q.x);

    offset = (range_index == 0) ? offset / 360. : offset;
    float hue = hsv.x + offset;
    if (hue < 0.) {
        hsv.x = hue + 1.;
    } else if (hue > 1.) {
        hsv.x = hue - 1.;
    } else {
        hsv.x = hue;
    }

    // HSV to RGB
    vec4 k2 = vec4(1., 2./3., 1./3., 3.);
    vec3 p2 = abs(fract(hsv.xxx + k2.xyz) * 6. - k2.www);
    vec3 rgb = hsv.z * mix(k2.xxx, clamp(p2 - k2.xxx, 0., 1.), hsv.y);
    return rgb;
}

vec3 hash(vec3 x) {
    x = vec3(dot(x, vec3(127.1, 311.7, 74.7)),
             dot(x, vec3(269.5, 183.3, 246.1)),
             dot(x, vec3(113.5, 271.9, 124.6)));
    return fract(sin(x) * 43758.5453123);
}

vec2 voronoi(in vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);

    float res = 100.;
    float id = 0.;

    for (float k = -1.; k <= 1.; k += 1.) {
        for (float j = -1.; j <= 1.; j += 1.) {
            for (float i = -1.; i <= 1.; i += 1.) {
                vec3 b = vec3(i, j, k);
                vec3 r = vec3(b) - f + hash(p + b);
                float d = dot(r, r);
                if (d < res) {
                    res = d;
                    id = dot(p + b, vec3(0., 57., 113.));
                }
            }
        }
    }

    return vec2(sqrt(res), id);
}

void sky() {
    // Start with the base sky color
    COLOR = sky_color;

    // Calculate the fade factor based on the horizon level
    float horizon_fade = smoothstep(0.0, horizon_fade_range, -EYEDIR.y);

    // Draw the star layer
    for (int i = 0; i < layers_count; i++) {
        vec3 pos = EYEDIR * (layer_scale + float(i) * layer_scale_step);
        vec2 layer = voronoi(pos);

        vec3 rand = hash(vec3(layer.y));

        #ifdef USE_TWINKLE
            float twinkle = sin(TIME * PI * star_twinkle_speed + rand.x * TAU);
            twinkle *= star_twinkle_intensity;
            float star = smoothstep(star_intensity + star_intensity * twinkle, 0., layer.x);
        #else
            float star = smoothstep(star_intensity, 0., layer.x);
        #endif

        // Apply horizon fade to star intensity
        star *= horizon_fade;

        vec3 star_color = star * hue((COLOR + star_base_color), rand.y * star_hue_offset, 1);

        COLOR += star_color;
    }

    // Add the wireframe grid on the ground plane extending towards the horizon
    vec3 dir = normalize(EYEDIR); // Use EYEDIR for the normalized direction in 3D space

    // Calculate the grid based on the direction's x and z (horizontal) components
    float grid_distance = abs(dir.y); // The closer to the horizon, the smaller the value
    vec2 grid_coords = dir.xz / max(grid_distance, 0.001); // Project the grid on the xz plane

    // Compute grid lines based on spacing
    float grid_x = abs(fract(grid_coords.x / grid_spacing) - 0.5);
    float grid_y = abs(fract(grid_coords.y / grid_spacing) - 0.5);

    // Use step function for sharper grid lines
    float grid_line_x = step(grid_thickness, grid_x);
    float grid_line_y = step(grid_thickness, grid_y);

    // Combine the grid lines to create the wireframe effect
    float grid_intensity = 1.0 - grid_line_x * grid_line_y; // Correctly combine the intensities

    // Apply the grid glow and fade it towards the horizon
    float fade = smoothstep(0.0, 1.0, dir.y * 2.0); // Fade out near the horizon
    vec3 final_grid_color = grid_color * grid_glow_intensity * grid_intensity * fade;

    // Add grid to the final color
    COLOR += final_grid_color;
}
