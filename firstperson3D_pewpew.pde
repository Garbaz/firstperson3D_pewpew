import com.jogamp.newt.opengl.GLWindow;
import processing.net.*;

final float TIME_SCALE = 1.0;

//ArrayList<Player> players = new ArrayList<Player>();
HashMap<Integer, Player> players = new HashMap<Integer, Player>();
Player perspective_player;
Player local_player;

PVector spawn_team_cross = VEC(), spawn_team_star = VEC();

ArrayList<Prop> props = new ArrayList<Prop>();

float test_rot = 0;

PShape player_shape, player_gun_shape;
//PShader player_shader, player_gun_shader;
PImage pew_image;

GLWindow gl_window;

void settings() {
  //size(800, 800, P3D);
  fullScreen(P3D);
}
void setup() {
  frameRate(144);
  gl_window = (GLWindow)getSurface().getNative();
  noCursor();
  mouseX = width/2;
  mouseY = height/2;
  //gl_window.confinePointer(true);

  setup_key_binds();

  perspective_projection(VIEW_FOV);

  player_shape = loadShape("assets/player_shape.obj");
  player_shape.setFill(#700000);
  player_gun_shape = loadShape("assets/player_gun.obj");
  player_gun_shape.setTexture(loadImage("assets/player_gun_tex.jpg"));
  //player_gun_shape = loadShape("assets/kar98k.obj");
  //player_gun_shape.setTexture(loadImage("assets/kar98k_texture.jpg"));

  pew_image = loadImage("assets/pew.png");



  //props.add(new PropBox(VEC(0, -1, 0), VEC(200, 1, 200), true));
  //for (int i = 0; i < 20; i++) {
  //  props.add(new PropBox(VEC(random(-100, 100), 0.0, random(-100, 100)), VEC(random(2, 6), random(0.5, 1), random(2, 6)), true));
  //}
  //props.add(new PropBox(VEC(4, 0, 0), VEC(2, 1, 6), true));

  //for (int i = 1; i < 25; i++) {
  //  props.add(new PropBox(VEC(-3, 0, 2*i), VEC(2, 0.1*i, 2), true));
  //}
  load_level("levels/de_cache.csv");

  init_network_id();

  local_player = new Player();
  perspective_player = local_player;
  add_player(net_local_id, local_player);
  local_player.hit(null, 100);

  net_host();
  //net_connect("192.168.178.127");

  //players.add(new Player(VEC(5.6, 40, 0)));
  deltatime_lasttime = millis();
}

void draw() {
  background(#D4F2FA);
  float dt = TIME_SCALE*deltatime();

  for (Prop p : props) {
    p.update(dt);
  }
  for (Player p : players.values()) {
    p.update(dt);
  }
  update_camera();

  for (Prop p : props) {
    p.show(dt);
  }

  for (Player p : players.values()) {
    if (p != perspective_player) {
      p.show(dt);
    }
  }

  perspective_player.show(dt);//Drawing perspective player last because of pew transparency....

  net_update(dt);
  //println(local_player.pack());

  draw_ui(dt);
}


void draw_ui(float dt) {
  ui_begin();

  //Debug Text
  debug_show();

  fill(0);
  // textSize(14);
  textAlign(RIGHT, TOP);
  text(frameRate, width, 0);

  //text(test_rot, 0, 140);
  //text(c, 0, 160);

  //text(players.get(1).pos.toString(), 0, 140);

  //Crosshair
  stroke(0);
  line(width/2-10, height/2, width/2-2, height/2);
  line(width/2+10, height/2, width/2+2, height/2);
  line(width/2, height/2-10, width/2, height/2-2);
  line(width/2, height/2+10, width/2, height/2+2);

  //fill(#00ffff);

  //translate(width-300, 300);
  //final float MAP_SCALE = 70;
  //circle(local_player.pos.x, local_player.pos.z, MAP_SCALE*2*local_player.COLLISION_RADIUS);
  //drawArrow_(vec_xz(local_player.get_eye_position()), vec_xz(local_player.get_eye_direction()), 100);
  //stroke(#ff0000);
  //line(local_player.pos.x, local_player.pos.z, local_player.pos.x+10*local_player.vel.x, local_player.pos.z+10*local_player.vel.z);
  //stroke(#0000ff);
  //line(local_player.pos.x, local_player.pos.z, local_player.pos.x+10*local_player.GROUND_MAX_SPEED*sin(local_player.orient_angle_horizontal), local_player.pos.z+10*local_player.GROUND_MAX_SPEED*cos(local_player.orient_angle_horizontal));



  //for (Prop p : props) {
  //  rect(p.pos.x-p.dimensions.x/2, p.pos.z-p.dimensions.z/2, p.dimensions.x, p.dimensions.z);
  //}

  ui_end();
}
