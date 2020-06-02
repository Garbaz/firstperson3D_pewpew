
final float VIEW_FOV = radians(78);
final float VIEW_UI_FOV = radians(60);
final float VIEW_CLIP_DIST_FAR = 10000;
final float VIEW_CLIP_DIST_CLOSE = 0.1;

void update_camera(PVector position, float angle_horizontal, float angle_vertical) {
  PVector camera_dir = VEC(cos(angle_vertical) * sin(angle_horizontal), sin(angle_vertical), cos(angle_vertical) * cos(angle_horizontal));
  camera(position.x, position.y, position.z, position.x+camera_dir.x, position.y+camera_dir.y, position.z+camera_dir.z, 0, -1, 0);
}

void perspective_projection(float fov) {
  perspective(fov, float(width)/float(height), VIEW_CLIP_DIST_CLOSE, VIEW_CLIP_DIST_FAR);
}

void ui_begin() {
  push();
  camera();
  hint(DISABLE_DEPTH_TEST);
  perspective_projection(VIEW_UI_FOV);
}

void ui_end() {
  hint(ENABLE_DEPTH_TEST);
  perspective_projection(VIEW_FOV);
  pop();
}
