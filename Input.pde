

final float INPUT_MOUSE_SENS = 3.0*radians(0.022);

int input_move_right = 0;
int input_move_forward = 0;

void setup_key_binds() {
  bind_key("player_forward", 0x57);
  bind_key("player_backward", 0x53);
  bind_key("player_left", 0x41);
  bind_key("player_right", 0x44);
  bind_key("player_jump", 0x20);
  bind_key("player_crouch", 0x11);
  bind_key("player_shoot", -LEFT);
  bind_key("player_scope", -RIGHT);
}


HashMap<Integer, String> key_map_bind = new HashMap<Integer, String>();
HashMap<String, Boolean> key_map_state = new HashMap<String, Boolean>();

boolean is_keybind_pressed(String key_bind) {
  Boolean s = key_map_state.get(key_bind);
  return s!=null && (boolean)s;
}

void bind_key(String key_bind, int key_code) {
  key_map_bind.put(key_code, key_bind);
}


void update_key_state(int key_code, boolean pressed) {
  key_map_state.put(key_map_bind.get(key_code), pressed);
  update_player_move();
}

void update_player_move() {
  input_move_forward = int(is_keybind_pressed("player_forward"))-int(is_keybind_pressed("player_backward"));
  input_move_right = int(is_keybind_pressed("player_right"))-int(is_keybind_pressed("player_left"));
}

void keyPressed(KeyEvent e) {
  update_key_state(e.getKeyCode(), true);
}

void keyReleased(KeyEvent e) {
  update_key_state(e.getKeyCode(), false);
}

void mousePressed() {
  update_key_state(-mouseButton, true);
}

void mouseReleased() {
  update_key_state(-mouseButton, false);
}

float c = 0;
FloatPair mouse_input() {
  if (focused) {
    float mouseDeltaX = mouseX - width/2;
    float mouseDeltaY = mouseY - height/2;
    
    //println(mouseDeltaX);
    //println(mouseDeltaY);
    
    gl_window.warpPointer(width/2, height/2);

    //if (local_player.on_ground) mouseDeltaX += test_rot;
    //if (is_keybind_pressed("player_crouch") && test_rot > 40) test_rot-=0.5;
    //c += mouseDeltaX;
    return new FloatPair(INPUT_MOUSE_SENS * mouseDeltaX, -INPUT_MOUSE_SENS * mouseDeltaY);
  } else {
    return new FloatPair(0, 0);
  }
}

void mouseWheel(MouseEvent e) {
  test_rot -= e.getCount();
}

//void keyPressed(KeyEvent e) {
//  println(e.getAction());
//  if (!e.isAutoRepeat()) {
//    char k = e.getKey();
//    int kc = e.getKeyCode();
//    if (kc == LEFT || k == 'a' || kc == 'a'-0x20) {
//      key_left = e.getAction() == KeyEvent.PRESS;
//    } else if (kc == RIGHT || k == 'd' || k == 'd'-0x60) {
//      key_right = e.getAction() == KeyEvent.PRESS;
//    } else if (kc == UP || k == 'w' || k == 'w'-0x60) {
//      key_up = e.getAction() == KeyEvent.PRESS;
//    } else if (kc == DOWN || k == 's' || k == 's'-0x60) {
//      key_down = e.getAction() == KeyEvent.PRESS;
//    } else if (k == ' ') {
//      key_jump = e.getAction() == KeyEvent.PRESS;
//    } else if (kc == CONTROL) {
//      key_crouch = e.getAction() == KeyEvent.PRESS;
//    } else {
//      //println(hex(key));
//      //println(key);
//      //println(char(key + 0x60));
//      //println(e.getNative());
//    }
//    update_player_move();
//  }
//}
//void keyReleased(KeyEvent e) {
//  println("RRR"+e.getAction());
//}
////void keyReleased() {
////  if (keyCode == LEFT || key == 'a' || key == 'a'-0x60) {
////    key_left = false;
////  } else if (keyCode == RIGHT || key == 'd' || key == 'd'-0x60) {
////    key_right = false;
////  } else if (keyCode == UP || key == 'w' || key == 'w'-0x60) {
////    key_up = false;
////  } else if (keyCode == DOWN || key == 's' || key == 's'-0x60) {
////    key_down = false;
////  } else if (key == ' ') {
////    key_jump = false;
////  } else if (keyCode == CONTROL) {
////    key_crouch = false;
////  }

////  update_player_move();
////}
