import java.awt.Robot;

ArrayList<Player> players = new ArrayList<Player>();
Player perspective_player;
Player local_player;

ArrayList<Prop> props = new ArrayList<Prop>();

void settings() {
  //size(600,600,P3D);
  fullScreen(P3D);
}
void setup() {
  noCursor();
  try {
    robby = new Robot();
  }
  catch(Exception e) {
    e.printStackTrace();
  }
  mouseX = width/2;
  mouseY = height/2;
  
  setup_key_binds();

  perspective_projection(VIEW_FOV);

  local_player = new Player();
  perspective_player = local_player;
  players.add(local_player);

  props.add(new Prop(VEC(0, -1, 0), VEC(200, 1, 200), true));
  for (int i = 0; i < 20; i++) {
    props.add(new Prop(VEC(random(-100, 100), 0.0, random(-100, 100)), VEC(random(2, 6), random(0.5, 1), random(2, 6)), true));
  }
  props.add(new Prop(VEC(4, 0, 0), VEC(2, 1, 6), true));

  for (int i = 0; i < 25; i++) {
    props.add(new Prop(VEC(-3, 0, 2*i), VEC(2, 0.1*i, 2), true));
  }
}

void draw() {
  background(#D4F2FA);
  float dt = deltatime();

  local_player.update_input(dt);

  for (Player p : players) {
    p.update(dt);
  }
  for (Player p : players) {
    p.show(dt);
  }
  for (Prop p : props) {
    p.update(dt);
  }
  for (Prop p : props) {
    p.show(dt);
  }
  update_camera(perspective_player.get_head_position(), perspective_player.orient_angle_horizontal, perspective_player.orient_angle_vertical);

  draw_ui(dt);
}


void draw_ui(float dt) {
  ui_begin();

  //Debug Text
  fill(0);
  // textSize(14);
  textAlign(RIGHT, TOP);
  text(frameRate, width, 0);
  textAlign(LEFT, TOP);
  text("position = " + round(perspective_player.pos, 1), 0, 0);
  text("velocity = " + round(perspective_player.vel, 1), 0, 20);
  text("|velocity| = " + round(perspective_player.vel.mag(), 3), 0, 40);
  text("|velocity.xz| = " + round(sqrt(sq(perspective_player.vel.x) + sq(perspective_player.vel.z)), 3), 0, 60);
  text("on_ground = " + perspective_player.on_ground, 0, 80);
  text("head_pos = " + round(perspective_player.get_head_position(), 1), 0, 100);

  //Crosshair
  stroke(0);
  line(width/2-10, height/2, width/2-2, height/2);
  line(width/2+10, height/2, width/2+2, height/2);
  line(width/2, height/2-10, width/2, height/2-2);
  line(width/2, height/2+10, width/2, height/2+2);

  fill(#00ffff);

  //translate(width/2-200, 200);
  //final float MAP_SCALE = 30;
  //circle(local_player.pos.x, local_player.pos.z, 2*local_player.COLLISION_RADIUS);
  //for (Prop p : props) {
  //  rect(p.pos.x-p.dimensions.x/2, p.pos.z-p.dimensions.z/2, p.dimensions.x, p.dimensions.z);
  //}

  ui_end();
}
