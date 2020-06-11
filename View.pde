
final float VIEW_FOV = 73.7;
final float VIEW_UI_FOV = 60;
final float VIEW_CLIP_DIST_FAR = 10000;
final float VIEW_CLIP_DIST_CLOSE = 0.01;

void update_camera() {
  if (is_keybind_pressed("player_scope")) {
    perspective_projection(30);
  } else {
    perspective_projection(VIEW_FOV);
  }
  
  PVector position = perspective_player.get_eye_position();
  PVector camera_dir = perspective_player.get_eye_direction();
  camera(position.x, position.y, position.z, position.x+camera_dir.x, position.y+camera_dir.y, position.z+camera_dir.z, 0, -1, 0);
}

void perspective_projection(float fov_degrees) {
  perspective(radians(fov_degrees), float(width)/float(height), VIEW_CLIP_DIST_CLOSE, VIEW_CLIP_DIST_FAR);
}

void ui_begin() {
  push();
  camera();
  noLights();
  hint(DISABLE_DEPTH_TEST);
  perspective_projection(VIEW_UI_FOV);
}

void ui_end() {
  perspective_projection(VIEW_FOV);
  hint(ENABLE_DEPTH_TEST);
  lights();
  pop();
}
