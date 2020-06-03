ArrayList<RayCastShape> enabled_raycast_shapes = new ArrayList<RayCastShape>();

RayCastResult raycast(PVector ray_base, PVector ray_dir, RayCastShape excluded) {
  for (RayCastShape s : enabled_raycast_shapes) {
    if (s != excluded) {
      VecPair inters = s.intersect_line(ray_base, ray_dir);
      if (inters != null) {
        inters.sort_by_dist(ray_base);
        return new RayCastResult(s, inters);
      }
    }
  }
  return null;
}

abstract class RayCastShape {
  Entity owner;
  PVector pos_offset;

  VecPair intersect_line(PVector line_base, PVector line_dir) {
    return null;
  }

  RayCastShape(Entity owner, PVector pos_offset, boolean enabled) {
    this.owner = owner;
    this.pos_offset = pos_offset;
    if (enabled) enable();
  }
  RayCastShape(Entity owner, PVector pos_offset) {
    this(owner, pos_offset, true);
  }

  void enable() {
    enabled_raycast_shapes.add(this);
  }

  void disable() {
    enabled_raycast_shapes.remove(this);
  }

  PVector get_pos() {
    return PVector.add(owner.pos, pos_offset);
  }
}

class RayCastShapeCylinder extends RayCastShape {
  float cylinder_radius;
  float cylinder_height;

  RayCastShapeCylinder(Entity owner, PVector pos, float cylinder_radius, float cylinder_height) {
    super(owner, pos);
    this.cylinder_radius = cylinder_radius;
    this.cylinder_height = cylinder_height;
  }

  VecPair intersect_line(PVector line_base, PVector line_dir) {
    line_base = PVector.sub(line_base, get_pos());
    float cylinder_height_half = cylinder_height/2;
    float a = sq(line_dir.x)+sq(line_dir.z);
    float p_half = (line_base.x*line_dir.x + line_base.z*line_dir.z)/a;
    float q = (sq(line_base.x) + sq(line_base.z) - sq(cylinder_radius))/a;
    float s_sq = sq(p_half) - q;
    if (s_sq <= 0) return null;
    float s = sqrt(s_sq);

    float t1 = -p_half + s;
    float t2 = -p_half - s;

    VecPair sol = new VecPair(vec_add_scaled(line_base.copy(), line_dir, t1), vec_add_scaled(line_base.copy(), line_dir, t2));
    if (abs(sol.a.y) > cylinder_height_half) sol.a = null;
    if (abs(sol.b.y) > cylinder_height_half) sol.b = null;
    if (sol.a == null || sol.b == null) {
      if (line_dir.y == 0) return null;

      float t_top = (cylinder_height_half-line_base.y)/line_dir.y;
      float t_bottom = (-cylinder_height_half-line_base.y)/line_dir.y;

      PVector sol1 = vec_add_scaled(line_base.copy(), line_dir, t_top);
      PVector sol2 = vec_add_scaled(line_base.copy(), line_dir, t_bottom);

      if (sq(sol1.x)+sq(sol1.z) < sq(cylinder_radius)) {
        sol.append(sol1);
      }
      if (sq(sol2.x)+sq(sol2.z) < sq(cylinder_radius)) {
        sol.append(sol2);
      }
    }
    if (sol.a == null || sol.b == null) return null;

    sol.a.add(get_pos());
    sol.b.add(get_pos());
    return sol;
  }
}



class VecPair {
  PVector a = null;
  PVector b = null;

  VecPair(PVector a, PVector b) {
    this.a = a.copy();
    this.b = b.copy();
  }
  VecPair() {
  }

  void append(PVector p) {
    if (a == null) {
      a = p;
    } else if (b == null) {
      b = p;
    }
  }

  void swap() {
    PVector t = a;
    a = b;
    b = t;
  }


  PVector get_closer(PVector v) {
    float da_sq = sq(a.x-v.x) + sq(a.y-v.y) + sq(a.z-v.z);
    float db_sq = sq(b.x-v.x) + sq(b.y-v.y) + sq(b.z-v.z);
    if (db_sq < da_sq) {
      return b;
    } else {
      return a;
    }
  }

  void sort_by_dist(PVector v) {
    if (get_closer(v) == b) {
      swap();
    }
  }


  String toString() {
    String sa = (a == null ? "null" : a.toString());
    String sb = (b == null ? "null" : b.toString()); 
    return "{"+sa+", "+sb+"}";
  }
}

class RayCastResult {
  RayCastShape shape;
  VecPair intersects;

  RayCastResult(RayCastShape shape, VecPair intersects) {
    this.shape = shape;
    this.intersects = intersects;
  }
}
