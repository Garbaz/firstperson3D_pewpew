class Gun {
  final color PEW_TINT = #FFCD00;
  final float PEW_SIZE = 0.1;
  final float PEW_SHOW_DURATION = 0.03;
  PShape model = player_gun_shape;
  PVector gun_shooty_end_offset = VEC(0.0, 0.048791, 0.84);

  private float shoot_timer = 0;

  float shoot_fire_period = 1.0/10;

  float hit_damage = 25;

  void update(float dt, boolean shooting, Player holder) {
    shoot_timer += dt;
    if (shooting) {
      if (shoot_timer > shoot_fire_period) {
        shoot(holder);
      }
    }
  }

  void shoot(Player holder) {
    shoot_timer = 0;

    RayCastResult r = holder.cast_eye_ray();
    if (r != null) {
      r.shape.owner.hit(r.intersects, hit_damage);
    }
  }

  void show(float dt) {
    //shader(player_gun_shader);
    scale(1.4);
    shape(player_gun_shape);

    translate(gun_shooty_end_offset.x, gun_shooty_end_offset.y, gun_shooty_end_offset.z);
    //pg.scale(0.004);
    //pg.image(pew_image, -pew_image.width/2, -pew_image.height/2);
    if (shoot_timer < PEW_SHOW_DURATION) {
      tint(PEW_TINT);
      beginShape();
      noStroke();
      texture(pew_image);
      vertex(-PEW_SIZE, -PEW_SIZE, 0, 0);
      vertex(-PEW_SIZE, PEW_SIZE, 0, pew_image.height);
      vertex(PEW_SIZE, PEW_SIZE, pew_image.width, pew_image.height);
      vertex(PEW_SIZE, -PEW_SIZE, pew_image.width, 0);
      endShape(CLOSE);
    }
  }
}
