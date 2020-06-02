
// cylinder is y-aligned in height direction
// if the shapes collide, returns the vector the cylinder has to move (mag equal to depth of intersection)
// if the shapes dont intersect, returns null
// step_margin is for "smooth" walking up steps
PVector collision_cuboid_cylinder_aa(PVector cuboid_pos, PVector cuboid_dim, PVector cylinder_pos, float cylinder_height, float cylinder_radius, float step_margin) {
  float intersect_y = abs(cuboid_pos.y-cylinder_pos.y) - (cuboid_dim.y+cylinder_height)/2;
  if (intersect_y < 0) { // Shapes interesct at least in y-directions
    PVector collision_xz = collision2D_rect_circle(VEC(cuboid_pos.x, cuboid_pos.z), VEC(cuboid_dim.x, cuboid_dim.z), VEC(cylinder_pos.x, cylinder_pos.z), cylinder_radius);
    if (collision_xz != null) { // Shapes intersect
      if (collision_xz.magSq() > sq(intersect_y) || (sign(cylinder_pos.y-cuboid_pos.y) > 0 && -intersect_y < step_margin)) { // Intersection happened from the top or bottom
        return VEC(0, sign(cylinder_pos.y-cuboid_pos.y)*(-intersect_y), 0);
      } else { // Intersection happened from the side

        return VEC(collision_xz.x, 0, collision_xz.y);
      }
    }
  }
  return null;
}

PVector collision2D_rect_circle(PVector rect_pos, PVector rect_dim, PVector circle_pos, float circle_radius) {
  PVector rel_pos = PVector.sub(rect_pos, circle_pos);
  float dist_x = abs(rel_pos.x), dist_y = abs(rel_pos.y);
  PVector rect_radius = PVector.mult(rect_dim, 0.5);
  if (dist_x <= circle_radius + rect_radius.x && dist_y <= circle_radius + rect_radius.y) {
    if (dist_x <= rect_radius.x || dist_y <= rect_radius.y) {
      if (dist_x < dist_y) {
        if (rel_pos.x < rel_pos.y) {
          return new PVector(0, -(circle_radius+rect_radius.y-dist_y));
        } else {
          return new PVector(0, circle_radius+rect_radius.y-dist_y);
        }
      } else {
        if (rel_pos.x < rel_pos.y) {
          return new PVector(circle_radius+rect_radius.x-dist_x, 0);
        } else {
          return new PVector(-(circle_radius+rect_radius.x-dist_x), 0);
        }
      }
    } else {
      float corner_dist_x = dist_x-rect_radius.x, corner_dist_y = dist_y-rect_radius.y;
      float corner_dist_sq = corner_dist_x*corner_dist_x + corner_dist_y*corner_dist_y;
      if (corner_dist_sq <= circle_radius*circle_radius) {
        PVector ret = new PVector((rel_pos.x/dist_x) * corner_dist_x, (rel_pos.y/dist_y) * corner_dist_y);
        ret.setMag(sqrt(corner_dist_sq)-circle_radius);
        return ret;
      }
    }
  }
  return null;
}
