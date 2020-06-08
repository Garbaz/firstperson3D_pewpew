import com.jogamp.newt.opengl.GLWindow;
import processing.net.*;

final float TIME_SCALE = 1.0;



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
  perspective_projection(VIEW_FOV);

  setup_key_binds();

  load_global_assets();

  load_level("levels/de_cache.csv");
  //add_prop(new PropBox(VEC(0, -1, 0), VEC(100, 1, 100), true));
  //add_prop(new PropBox(VEC(0, 1.5, 2), VEC(1, 1, 1)));
  //props.get(0).shape.disable();

  init_network_id();

  local_player = new Player();
  perspective_player = local_player;
  add_player(net_local_id, local_player);
  local_player.hit(null, 9001);

  //add_player(1337, new Player(spawn_team_cross));

  net_host();
  //net_connect("192.168.178.127");

  //particles.add(new Particle(spawn_team_cross));

  //players.add(new Player(VEC(5.6, 40, 0)));

  deltatime_lasttime = millis();
}

void draw() {
  background(#D4F2FA);
  directionalLight(200, 200, 180, 0.4330127, -0.5, 0.75);
  ambientLight(150, 160, 160);

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

  ArrayList<Particle> particles_tbr = new ArrayList<Particle>();
  for (Particle p : particles) {
    if (!p.update(dt)) {
      particles_tbr.add(p);
    }
  }
  particles.removeAll(particles_tbr);
  for (Particle p : particles) {
    p.show(dt);
  }

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
