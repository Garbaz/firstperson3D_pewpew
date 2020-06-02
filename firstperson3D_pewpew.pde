import com.jogamp.newt.opengl.GLWindow;

ArrayList<Player> players = new ArrayList<Player>();
Player perspective_player;
Player local_player;

ArrayList<Prop> props = new ArrayList<Prop>();

float test_rot = 0;

PShape player_shape, player_gun_shape;
//PShader player_shader, player_gun_shader;
PImage pew_image;

GLWindow gl_window;

void settings() {
  size(800, 800, P3D);
  //fullScreen(P3D);
}
void setup() {
  gl_window = (GLWindow)getSurface().getNative();
  noCursor();
  //gl_window.confinePointer(true);

  setup_key_binds();

  perspective_projection(VIEW_FOV);

  player_shape = loadShape("assets/player_shape.obj");
  player_shape.setFill(#700000);
  player_gun_shape = loadShape("assets/player_gun.obj");
  player_gun_shape.setTexture(loadImage("assets/player_gun_tex.jpg"));

  pew_image = loadImage("assets/pew.png");

  local_player = new Player();
  perspective_player = local_player;
  players.add(local_player);

  players.add(new Player(VEC(5.6, 40, 0)));

  props.add(new PropBox(VEC(0, -1, 0), VEC(200, 1, 200), true));
  for (int i = 0; i < 20; i++) {
    props.add(new PropBox(VEC(random(-100, 100), 0.0, random(-100, 100)), VEC(random(2, 6), random(0.5, 1), random(2, 6)), true));
  }
  props.add(new PropBox(VEC(4, 0, 0), VEC(2, 1, 6), true));

  for (int i = 1; i < 25; i++) {
    props.add(new PropBox(VEC(-3, 0, 2*i), VEC(2, 0.1*i, 2), true));
  }
}

void draw() {
  background(#D4F2FA);
  float dt = deltatime();


  for (Prop p : props) {
    p.update(dt);
  }
  for (Prop p : props) {
    p.show(dt);
  }

  local_player.update_input(dt);
  for (Player p : players) {
    p.update(dt);
  }

  update_camera();

  for (Player p : players) {
    if (p != perspective_player) {
      p.show(dt);
    }
  }

  perspective_player.show(dt);//Drawing perspective player last because of pew transparency....



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
  text("heading = " + round(degrees(perspective_player.orient_angle_horizontal), 1) + ", " + round(degrees(perspective_player.orient_angle_vertical), 1), 0, 20);
  text("velocity = " + round(perspective_player.vel, 1), 0, 40);
  text("|velocity| = " + round(perspective_player.vel.mag(), 3), 0, 60);
  text("|velocity.xz| = " + round(sqrt(sq(perspective_player.vel.x) + sq(perspective_player.vel.z)), 3), 0, 80);
  text("on_ground = " + perspective_player.on_ground, 0, 100);
  text("head_pos = " + round(perspective_player.get_eye_position(), 1), 0, 120);
  text(test_rot, 0, 140);
  text(c, 0, 160);

  //text(players.get(1).pos.toString(), 0, 140);

  //Crosshair
  stroke(0);
  line(width/2-10, height/2, width/2-2, height/2);
  line(width/2+10, height/2, width/2+2, height/2);
  line(width/2, height/2-10, width/2, height/2-2);
  line(width/2, height/2+10, width/2, height/2+2);

  fill(#00ffff);

  translate(width/2-300, height/2-300);
  final float MAP_SCALE = 70;
  circle(local_player.pos.x, local_player.pos.z, MAP_SCALE*2*local_player.COLLISION_RADIUS);
  stroke(#ff0000);
  line(local_player.pos.x, local_player.pos.z, local_player.pos.x+10*local_player.vel.x, local_player.pos.z+10*local_player.vel.z);
  stroke(#0000ff);
  line(local_player.pos.x, local_player.pos.z, local_player.pos.x+10*local_player.GROUND_MAX_SPEED*sin(local_player.orient_angle_horizontal), local_player.pos.z+10*local_player.GROUND_MAX_SPEED*cos(local_player.orient_angle_horizontal));


  //for (Prop p : props) {
  //  rect(p.pos.x-p.dimensions.x/2, p.pos.z-p.dimensions.z/2, p.dimensions.x, p.dimensions.z);
  //}

  ui_end();
}
