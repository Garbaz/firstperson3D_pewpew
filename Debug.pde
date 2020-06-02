final int DEBUG_LINE_HEIGHT = 20;

int debug_text_line;
void debug_show() {
  debug_text_line = 0;
  push();
  fill(0);
  textAlign(LEFT, TOP);
  debug_text("position = " + round(perspective_player.pos, 1));
  debug_text("heading = " + round(degrees(perspective_player.orient_angle_horizontal), 1) + ", " + round(degrees(perspective_player.orient_angle_vertical), 1));
  debug_text("eye_pos = " + round(perspective_player.get_eye_position(), 1));
  debug_text("eye_dir = " + round(perspective_player.get_eye_direction(), 1));
  debug_text("velocity = " + round(perspective_player.vel, 1));
  debug_text("|velocity| = " + round(perspective_player.vel.mag(), 3));
  debug_text("|velocity.xz| = " + round(sqrt(sq(perspective_player.vel.x) + sq(perspective_player.vel.z)), 3));
  debug_text("on_ground = " + perspective_player.on_ground);
  debug_text_background(5);
  pop();
}

void debug_text(String s) {
  debug_text_background(DEBUG_LINE_HEIGHT);
  fill(255);
  text(s, 5, 5 + DEBUG_LINE_HEIGHT*debug_text_line);
  debug_text_line++;
}

void debug_text_background(float bg_height) {
  noStroke();
  fill(0, 0, 0, 128);
  rect(0, DEBUG_LINE_HEIGHT*debug_text_line, 300, bg_height);
}
