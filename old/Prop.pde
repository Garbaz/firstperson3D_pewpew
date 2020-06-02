class Prop extends Entity {
  boolean kinematic = false;

  PVector dimensions;

  boolean test_boop;

  Prop(PVector pos, PVector dimensions, boolean floor_pos) {
    this.pos = pos.copy();
    if (floor_pos) {
      this.pos.add(0, dimensions.y/2, 0);
    }
    this.vel = VEC(0);
    this.dimensions = dimensions.copy();
  }

  Prop(PVector pos, PVector dimensions) {
    this(pos, dimensions, false);
  }

  Prop(PVector pos) {
    this(pos, VEC(1, 1, 1));
  }

  void update(float dt) {
  }

  void show(float dt) {
    push();
    fill(0xEE);
    //if (test_boop) {
    //  fill(#B53FD1);
    //  test_boop = false;
    //}
    boxAt(pos.x, pos.y, pos.z, dimensions.x, dimensions.y, dimensions.z);
    pop();
  }
}
