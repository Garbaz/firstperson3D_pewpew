ArrayList<Prop> props = new ArrayList<Prop>();

abstract class Prop extends Entity {
  PShape model;
  PShader shader;
  RayCastShape shape;

  Prop(PVector pos, PShape model, PShader shader) {
    super(pos);
    this.model = model;
    this.shader = shader;
  }

  Prop(PVector pos) {
    this(pos, null, null);
  }
}

class PropBox extends Prop {
  PVector dimensions;

  PropBox(PVector pos, PVector dimensions, boolean floor_pos) {
    super(pos);
    if (floor_pos) {
      this.pos.add(0, dimensions.y/2, 0);
    }
    this.dimensions = dimensions.copy();
    this.shape = new RayCastShapeCuboid(this, VEC(0), dimensions);
  }

  PropBox(PVector pos, PVector dimensions) {
    this(pos, dimensions, false);
  }

  boolean update(float dt) {
    return true;
  }

  void show(float dt) {
    push();
    fill(230);
    stroke(60);
    //if (test_boop) {
    //  fill(#B53FD1);
    //  test_boop = false;
    //}
    boxAt(pos.x, pos.y, pos.z, dimensions.x, dimensions.y, dimensions.z);
    pop();
  }
}

void add_prop(Prop p) {
  props.add(p);
}
