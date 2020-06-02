class Player extends Entity {
  final float PLAYER_HEIGHT_STANDING = 1.8;
  final float PLAYER_HEIGHT_CROUCHED = 1.1;
  float player_height = PLAYER_HEIGHT_STANDING;

  final float GROUND_MAX_SPEED = 8;
  final float GROUND_ACCELERATION = 30; // and deceleration
  final float AIR_MAX_STRAFE_SPEED = 2;
  final float AIR_ACCELERATION = 40;
  final float JUMP_SPEED = 5.4;
  final float GRAVITY = 9.8;

  final float COLLISION_HEIGHT_OFFSET = 0.1;
  final float COLLISION_RADIUS = 0.2;
  final float COLLISION_STEP_MARGIN = 0.11;

  boolean on_ground = false;

  float orient_angle_horizontal = 0;
  float orient_angle_vertical = 0;

  Player(PVector pos, PVector vel) {
    this.pos = pos.copy();
    this.vel = vel.copy();
  }
  Player(PVector pos) {
    this(pos, VEC(0));
  }
  Player() {
    this(VEC(0, 20, 0));
  }

  void update_input(float dt) {
    FloatPair delta_orientation = mouse_input();
    local_player.rotate_orientation(delta_orientation.a, delta_orientation.b);

    PVector dir_forward = VEC(sin(orient_angle_horizontal), 0, cos(orient_angle_horizontal));
    PVector dir_right = VEC(dir_forward.z, 0, -dir_forward.x);

    PVector dir_move = VEC();
    vec_add_scaled(dir_move, dir_forward, input_move_forward);
    vec_add_scaled(dir_move, dir_right, input_move_right);
    dir_move.normalize();

    if (is_keybind_pressed("player_jump") && on_ground) {
      vec_add_scaled(vel, VEC_UP, JUMP_SPEED);
      on_ground = false;
    }

    if (is_keybind_pressed("player_crouch")) {
      if (player_height == PLAYER_HEIGHT_STANDING) {
        player_height = PLAYER_HEIGHT_CROUCHED;
        if (!on_ground) {
          pos.y += (PLAYER_HEIGHT_STANDING-PLAYER_HEIGHT_CROUCHED)/2;
        }
      }
    } else {
      player_height = PLAYER_HEIGHT_STANDING;
    }

    if (on_ground) {
      vec_add_scaled(vel, dir_move, 2 * GROUND_ACCELERATION * dt); // Acceleration    
      vel.setMag(constrain(vel.mag() - GROUND_ACCELERATION * dt, 0, Float.MAX_VALUE)); // Deceleration

      if (dir_move.dot(vel) > GROUND_MAX_SPEED) {
        vel.setMag(GROUND_MAX_SPEED);
      }
    } else { // in air
      if (dir_move.dot(vel) < AIR_MAX_STRAFE_SPEED) {
        vec_add_scaled(vel, dir_move, AIR_ACCELERATION * dt);
      }
    }

    vec_add_scaled(vel, VEC_DOWN, GRAVITY * dt);
  }

  void update(float dt) {
    vec_add_scaled(pos, vel, dt);
    //if (pos.y < 0) {
    //  pos.y = 0;
    //  vel.y = 0;
    //  on_ground = true;
    //}
    PVector centered_pos = VEC(pos.x, pos.y+(player_height+COLLISION_HEIGHT_OFFSET)/2, pos.z);
    on_ground = false;
    for (Prop pr : props) {
      PVector col = collision_cuboid_cylinder_aa(pr.pos, pr.dimensions, centered_pos, player_height+COLLISION_HEIGHT_OFFSET, COLLISION_RADIUS, COLLISION_STEP_MARGIN);
      if (col != null) {
        pos.add(col);
        PVector normal_vel = col.copy().normalize();
        normal_vel.mult(vel.dot(normal_vel));
        vel.sub(normal_vel);

        if (col.y > 0) {
          on_ground = true;
        }

        pr.test_boop = true;
      }
    }
  }

  void show(float dt) {
    if (perspective_player == this) {
      //TODO: Draw firstperson stuff
    } else {
      //TODO: Draw other players
    }
  }

  PVector get_head_position() {
    return VEC(pos.x, pos.y+player_height, pos.z);
  }

  void set_orientation(float horizontal, float vertical) {
    orient_angle_horizontal = horizontal % TWO_PI;
    orient_angle_vertical = constrain(vertical, -HALF_PI, HALF_PI);
  }

  void rotate_orientation(float delta_horizontal, float delta_vertical) {
    set_orientation(orient_angle_horizontal+delta_horizontal, orient_angle_vertical+delta_vertical);
  }
}
