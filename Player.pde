HashMap<Integer, Player> players = new HashMap<Integer, Player>();
Player perspective_player;
Player local_player;

class Player extends Entity implements NetPackable {
  final float HEIGHT_STANDING = 1.8;
  final float HEIGHT_CROUCHED = 1.1;
  final float HEIGHT_EYE_OFFSET = -0.2; // How far down the camera is from the top of the player
  float body_height = HEIGHT_STANDING;

  final float GROUND_MAX_SPEED_STANDING = 0.025 * 250;
  final float GROUND_MAX_SPEED_CROUCHED = 0.025 * 85;
  float ground_max_speed = GROUND_MAX_SPEED_STANDING;
  final float GROUND_ACCELERATION_FACTOR = 5.5;
  final float GROUND_FRICTION_FACTOR = 5.2;
  final float AIR_MAX_STRAFE_SPEED = 0.025 * 30;
  final float AIR_ACCELERATION_FACTOR = 100;
  final float JUMP_SPEED = 0.025 * 301.993377;
  final float GRAVITY = 0.025 * 800;

  final float COLLISION_RADIUS = 0.5;
  final float COLLISION_STEP_MARGIN = 0.11;

  final PVector GUN_OFFSET_PERSP = VEC(0.2, -0.25, 0.25);
  final PVector GUN_OFFSET_OTHER = VEC(0.3, -0.4, 0.5);
  Gun gun;
  boolean gun_shooting = false;

  RayCastShape hitbox;

  final int INIT_HEALTH = 100;
  int health = INIT_HEALTH;

  boolean on_ground = false;

  float orient_angle_horizontal = 0;
  float orient_angle_vertical = 0;

  Player(PVector pos, PVector vel) {
    super(pos, vel);
    this.gun = new Gun();
    this.hitbox = new RayCastShapeCylinder(this, VEC(0), COLLISION_RADIUS, body_height);
  }
  Player(PVector pos) {
    this(pos, VEC(0));
  }
  Player() {
    this(VEC(0, 50, 0));
  }

  void update_input(float dt) {
    FloatPair delta_orientation = mouse_input();
    rotate_orientation(delta_orientation.a, delta_orientation.b);

    PVector dir_forward = VEC(sin(orient_angle_horizontal), 0, cos(orient_angle_horizontal));
    PVector dir_right = VEC(dir_forward.z, 0, -dir_forward.x);

    PVector dir_move = VEC();
    vec_add_scaled(dir_move, dir_forward, input_move_forward);
    vec_add_scaled(dir_move, dir_right, input_move_right);
    dir_move.normalize();

    if (is_keybind_pressed("player_jump") && on_ground) {
      //println(vel);
      vec_add_scaled(vel, VEC_UP, JUMP_SPEED);
      //vel.y = JUMP_SPEED;
      on_ground = false;
    }

    set_stance(!is_keybind_pressed("player_crouch"));
    //if (!on_ground && !is_standing()) {
    //  pos.y += (HEIGHT_STANDING-HEIGHT_CROUCHED)/2;
    //}

    if (on_ground) {
      vec_add_scaled(vel, dir_move, dt * GROUND_ACCELERATION_FACTOR*ground_max_speed); // Acceleration

      if (dir_move.dot(vel) > ground_max_speed) {
        vel.setMag(ground_max_speed);
      }
    } else { // in air
      if (dir_move.dot(vel) < AIR_MAX_STRAFE_SPEED) {
        vec_add_scaled(vel, dir_move, AIR_ACCELERATION_FACTOR * AIR_MAX_STRAFE_SPEED * dt);
      }
    }

    gun_shooting = is_keybind_pressed("player_shoot");
  }

  boolean update(float dt) {

    //if (pos.y < 0) {
    //  pos.y = 0;
    //  vel.y = 0;
    //  on_ground = true;
    //}
    if (on_ground) {
      float vel_mag = vel.mag();
      float vel_new_mag = vel_mag*min(1, 1 - dt*GROUND_FRICTION_FACTOR);
      if (vel_new_mag < 0) {//TODO: Stop even earlier -> Flo's code?
        vel_new_mag = 0;
      }
      vel.setMag(vel_new_mag); // Deceleration
    }

    vec_add_scaled(vel, VEC_DOWN, GRAVITY * dt);
    vec_add_scaled(pos, vel, dt);
    on_ground = false;
    for (Prop pr : props) {
      if (!(pr instanceof PropBox)) continue; //TODO: Not nice

      PVector col = collision_cuboid_cylinder_aa(pr.pos, ((PropBox)pr).dimensions, pos, body_height, COLLISION_RADIUS, COLLISION_STEP_MARGIN);
      if (col != null) {
        pos.add(col);
        PVector normal_vel = col.copy().normalize();
        normal_vel.mult(vel.dot(normal_vel));
        vel.sub(normal_vel);
        if (col.y > 0) {
          on_ground = true;
        }
      }
    }
    //if(on_ground && vel.y != 0)println(vel.y);
    if (this == local_player) {
      update_input(dt);
    }

    gun.update(dt, gun_shooting, this);

    return true;
  }

  void show(float dt) {
    push();
    //PVector dir_forward = VEC(sin(orient_angle_horizontal), 0, cos(orient_angle_horizontal));
    //PVector dir_right = VEC(dir_forward.z, 0, -dir_forward.x);


    if (this == perspective_player) {
      camera(0, 0, 0, 0, 0, 1, 0, -1, 0);
      translate(GUN_OFFSET_PERSP.x, GUN_OFFSET_PERSP.y, GUN_OFFSET_PERSP.z);
      gun.show(dt);
    } else { // Not the perspective player
      // Draw player
      pushMatrix();
      PVector foot_pos = get_foot_pos();
      translate(foot_pos.x, foot_pos.y, foot_pos.z);
      scale(COLLISION_RADIUS, body_height, COLLISION_RADIUS);

      //shader(player_shader);
      shape(player_shape);
      resetShader();
      popMatrix();

      // Draw gun
      pushMatrix();
      PVector eye_pos = get_eye_position();
      translate(eye_pos.x, eye_pos.y, eye_pos.z);
      rotateY(orient_angle_horizontal);
      rotateX(-orient_angle_vertical);
      translate(GUN_OFFSET_OTHER.x, GUN_OFFSET_OTHER.y, GUN_OFFSET_OTHER.z);
      gun.show(dt);


      popMatrix();
    }
    //resetMatrix();
    //update_camera();
    //PVector eye_pos = get_eye_position();
    //PVector eye_dir = get_eye_direction();
    //line(eye_pos.x, eye_pos.y, eye_pos.z, eye_pos.x+eye_dir.x, eye_pos.y+eye_dir.y, eye_pos.z+eye_dir.z);
    //translate(eye_pos.x+eye_dir.x,eye_pos.y+eye_dir.y,eye_pos.z+eye_dir.z);
    //sphere(0.1);
    pop();
  }

  void set_stance(boolean standing) {
    if (standing) {
      body_height = HEIGHT_STANDING;
      ground_max_speed = GROUND_MAX_SPEED_STANDING;
    } else {
      body_height = HEIGHT_CROUCHED;
      ground_max_speed = GROUND_MAX_SPEED_CROUCHED;
    }
    ((RayCastShapeCylinder)hitbox).cylinder_height = body_height;
  }

  boolean is_standing() {
    return body_height == HEIGHT_STANDING;
  }

  PVector get_foot_pos() {
    return VEC(pos.x, pos.y-(body_height)/2, pos.z);
  }

  void hit(IntersectResult intersects, float damage) {
    super.hit(intersects, damage);
    health -= damage;
    if (health <= 0) {
      health = INIT_HEALTH;
      spawn_player(this, random(0, 2)<1);
    }
    //set_stance(!is_standing());
    //props.add(new PropBox(intersects.a, VEC(0.1, 0.1, 0.1), false));
  }

  RayCastResult cast_eye_ray() {
    return raycast(get_eye_position(), get_eye_direction(), hitbox);
  }

  PVector get_eye_position() {
    return VEC(pos.x, pos.y+body_height/2+HEIGHT_EYE_OFFSET, pos.z);
  }

  PVector get_eye_direction() {
    return VEC(cos(orient_angle_vertical) * sin(orient_angle_horizontal), sin(orient_angle_vertical), cos(orient_angle_vertical) * cos(orient_angle_horizontal));
  }

  void set_orientation(float horizontal, float vertical) {
    orient_angle_horizontal = (horizontal+TWO_PI) % TWO_PI;
    orient_angle_vertical = constrain(vertical, -0.99*HALF_PI, 0.99*HALF_PI);
  }

  void rotate_orientation(float delta_horizontal, float delta_vertical) {
    set_orientation(orient_angle_horizontal+delta_horizontal, orient_angle_vertical+delta_vertical);
  }

  String pack() {
    String s = "";
    s += net_vec_to_string(pos) + ";";
    s += net_vec_to_string(vel) + ";";
    s += orient_angle_horizontal + ";";
    s += orient_angle_vertical + ";";
    s += is_standing() + ";";
    s += gun_shooting + ";";
    return s;
  }

  void unpack(String s) {
    String[] lines = s.split(";");
    //for(String l : lines) {
    //  println(l);
    //}
    //println(lines.length);
    if (lines.length == 6) {
      pos = net_string_to_vec(lines[0]);
      vel = net_string_to_vec(lines[1]);
      orient_angle_horizontal = float(lines[2]);
      orient_angle_vertical = float(lines[3]);
      set_stance(boolean(lines[4]));
      gun_shooting = boolean(lines[5]);
    } else {
      println("ERROR: Could not unpack: \"" + s + "\"");
    }
  }
}

void spawn_player(Player p, boolean team_ab) {
  if (team_ab) {
    p.pos = spawn_team_cross.copy();
  } else {
    p.pos = spawn_team_star.copy();
  }
}

void add_player(int net_id, Player p) {
  players.put(net_id, p);
}
