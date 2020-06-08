ArrayList<RayCastShape> enabled_raycast_shapes = new ArrayList<RayCastShape>();

RayCastResult raycast(PVector ray_base, PVector ray_dir, RayCastShape excluded) {
  RayCastResult r = new RayCastResult(null, null);
  float r_dist_sq = Float.MAX_VALUE;
  for (RayCastShape s : enabled_raycast_shapes) {
    if (s != excluded) {
      IntersectResult inters = s.intersect_line(ray_base, ray_dir);
      if (inters != null) {
        //inters.sort_by_dist(ray_base);
        float d = vec_dist_sq(ray_base, inters.first);
        if (d < r_dist_sq) {
          r.shape = s;
          r.intersects = inters;
          r_dist_sq = d;
        }
      }
    }
  }
  if (r.shape != null) {
    return r;
  } else {
    return null;
  }
}

abstract class RayCastShape {
  Entity parent;
  PVector pos_offset;

  IntersectResult intersect_line(PVector line_base, PVector line_dir) {
    return null;
  }

  RayCastShape(Entity parent, PVector pos_offset, boolean enabled) {
    this.parent = parent;
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
    return PVector.add(parent.pos, pos_offset);
  }
}

class RayCastShapeCylinder extends RayCastShape {
  float cylinder_radius;
  float cylinder_height;

  RayCastShapeCylinder(Entity parent, PVector pos_offset, float cylinder_radius, float cylinder_height) {
    super(parent, pos_offset);
    this.cylinder_radius = cylinder_radius;
    this.cylinder_height = cylinder_height;
  }

  IntersectResult intersect_line(PVector line_base, PVector line_dir) {
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
    PVector sol1 = vec_add_scaled(line_base.copy(), line_dir, t1);
    PVector sol2 = vec_add_scaled(line_base.copy(), line_dir, t2);
    IntersectResult sol = new IntersectResult(sol1, sol2, VEC(sol1.x,0,sol1.z).normalize(), VEC(sol2.x,0,sol2.z).normalize());
    if (abs(sol.first.y) > cylinder_height_half) sol.first = null;
    if (abs(sol.second.y) > cylinder_height_half) sol.second = null;
    if (sol.first == null || sol.second == null) {
      if (line_dir.y == 0) return null;

      float t_top = (cylinder_height_half-line_base.y)/line_dir.y;
      float t_bottom = (-cylinder_height_half-line_base.y)/line_dir.y;

      PVector solT = vec_add_scaled(line_base.copy(), line_dir, t_top);
      PVector solB = vec_add_scaled(line_base.copy(), line_dir, t_bottom);

      if (sq(solT.x)+sq(solT.z) < sq(cylinder_radius)) {
        sol.append(solT, VEC(0, 1, 0));
      }
      if (sq(solB.x)+sq(solB.z) < sq(cylinder_radius)) {
        sol.append(solB, VEC(0, -1, 0));
      }
    }
    if (sol.first == null || sol.second == null) return null;

    sol.sort_by_dist(line_base);
    sol.first.add(get_pos());
    sol.second.add(get_pos());
    return sol;
  }
}

class RayCastShapeCuboid extends RayCastShape {
  PVector dimensions;

  RayCastShapeCuboid(Entity parent, PVector pos_offset, PVector dimensions) {
    super(parent, pos_offset);
    this.dimensions = dimensions.copy();
  }

  IntersectResult intersect_line(PVector line_base, PVector line_dir) {
    line_base = PVector.sub(line_base, get_pos());
    //PVector rect_rad = PVector.mult(rect_dim, 0.5);

    IntersectResult sol = new IntersectResult();

    PVector b = VEC(line_base.x/dimensions.x, line_base.y/dimensions.y, line_base.z/dimensions.z);
    PVector d = VEC(line_dir.x/dimensions.x, line_dir.y/dimensions.y, line_dir.z/dimensions.z);

    for (int sgn = -1; sgn <=1; sgn+=2) {
      PVector sx = __intersect_line_substep(4*sgn, 0, 0, b, d);
      if (sx != null) sol.append(sx, VEC(sgn, 0, 0));
      PVector sy = __intersect_line_substep(0, 4*sgn, 0, b, d);
      if (sy != null) sol.append(sy, VEC(0, sgn, 0));
      PVector sz = __intersect_line_substep(0, 0, 4*sgn, b, d);
      if (sz != null) sol.append(sz, VEC(0, 0, sgn));
      //println(tx, ty, tz);
    }
    //println("------");

    if (sol.first != null && sol.second != null) {
      sol.first.set(sol.first.x*dimensions.x, sol.first.y*dimensions.y, sol.first.z*dimensions.z);
      sol.second.set(sol.second.x*dimensions.x, sol.second.y*dimensions.y, sol.second.z*dimensions.z);
      sol.sort_by_dist(line_base);
      sol.first.add(get_pos());
      sol.second.add(get_pos());
      return sol;
    } else {
      return null;
    }
  }

  private PVector __intersect_line_substep(float ax, float ay, float az, PVector b, PVector d) {
    float t = (2 - ax*b.x - ay*b.y - az*b.z)/(ax*d.x + ay*d.y + az*d.z);
    if (t >= 0) {
      PVector s = vec_add_scaled(b.copy(), d, t);
      //print(s);
      if (abs(s.x) <= 0.50001 && abs(s.y) <= 0.50001 && abs(s.z) <= 0.50001) {//TODO: 0.50001 to account for possible float errors, not a nice way...
        //println("<--");
        return s;
      } else {
        //println();
      }
    }
    return null;
  }
}



class IntersectResult {
  PVector first = null;
  PVector second = null;

  PVector normal_first = null;
  PVector normal_second = null;

  IntersectResult(PVector first, PVector second, PVector normal_first, PVector normal_second) {
    this.first = first;
    this.second = second;
    this.normal_first = normal_first;
    this.normal_second = normal_second;
  }
  IntersectResult() {
  }

  void append(PVector p, PVector np) {
    if (first == null) {
      first = p;
      normal_first = np;
    } else if (second == null) {
      second = p;
      normal_second = np;
    }
  }

  void swap() {
    PVector t = first;
    first = second;
    second = t;
    PVector nt = normal_first;
    normal_first = normal_second;
    normal_second = nt;
  }


  PVector get_closer(PVector v) {
    float da_sq = vec_dist_sq(first, v);
    float db_sq = vec_dist_sq(second, v);
    if (db_sq < da_sq) {
      return second;
    } else {
      return first;
    }
  }

  void sort_by_dist(PVector v) {
    if (get_closer(v) == second) {
      swap();
    }
  }


  String toString() {
    String sa = (first == null ? "null" : first.toString());
    String sb = (second == null ? "null" : second.toString()); 
    return "{"+sa+", "+sb+"}";
  }
}

class RayCastResult {
  RayCastShape shape;
  IntersectResult intersects;

  RayCastResult(RayCastShape shape, IntersectResult intersects) {
    this.shape = shape;
    this.intersects = intersects;
  }

  String toString() {
    return shape + " :: " + intersects;
  }
}
