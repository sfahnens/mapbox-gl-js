attribute vec2 a_pos;
attribute vec2 a_anchor_pos;
attribute vec2 a_extrude;
attribute vec2 a_data;

uniform mat4 u_matrix;
uniform float u_scale;
uniform float u_pitch;
uniform float u_collision_y_stretch;
uniform float u_minimum_pitch_scaling;
uniform float u_maximum_pitch_scaling;
uniform float u_camera_to_center_distance;

varying float v_max_zoom;
varying float v_placement_zoom;
varying float v_perspective_zoom_adjust;

void main() {
    vec4 projectedPoint = u_matrix * vec4(a_anchor_pos, 0, 1);
    highp float camera_to_anchor_distance = projectedPoint.w;
    highp float collision_pitch_scaling = (camera_to_anchor_distance > u_camera_to_center_distance) ? u_minimum_pitch_scaling : u_maximum_pitch_scaling;
    highp float collision_perspective_ratio = 1.0 +
          (1.0 - collision_pitch_scaling)
        * ((camera_to_anchor_distance / u_camera_to_center_distance) - 1.0);

    highp float incidence_stretch  = camera_to_anchor_distance / (u_camera_to_center_distance * cos(u_pitch));
    highp float collision_adjustment = max(1.0, incidence_stretch / u_collision_y_stretch);

    gl_Position = u_matrix * vec4(a_pos + a_extrude * collision_perspective_ratio * collision_adjustment / u_scale, 0.0, 1.0);

    v_perspective_zoom_adjust = log2(collision_perspective_ratio * collision_adjustment)*10.0;

    v_max_zoom = a_data.x + v_perspective_zoom_adjust;
    v_placement_zoom = a_data.y + v_perspective_zoom_adjust;
}
