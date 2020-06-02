
PVector square_pos, square_dim, circle_pos;
float circle_radius;

void settings() {
  size(800, 800,P3D);
}
void setup() {
  square_pos = new PVector(width/2, 0, height/2);
  square_dim = new PVector(170, 10, 330);
  circle_pos = new PVector();
  circle_radius = 100;
}

void draw() {
  background(0xcc);
  circle_pos.set(mouseX, 0, mouseY);

  PVector collision = collision_cuboid_cylinder_aa(square_pos, square_dim, circle_pos, circle_radius, 100);
  if (collision != null) {
    fill(#ff0000);
    //circle_pos.add(collision);
  } else {
    fill(0xff);
  }
  circle(circle_pos.x, circle_pos.z, 2*circle_radius);
  rect(square_pos.x-square_dim.x/2, square_pos.z-square_dim.z/2, square_dim.x, square_dim.z);
  if (collision != null) {
    line(circle_pos.x, circle_pos.z, circle_pos.x+collision.x, circle_pos.z+collision.z);
  }
}

PVector collision_cuboid_cylinder_aa(PVector cuboid_pos, PVector cuboid_dim, PVector cylinder_pos, float cylinder_radius, float cylinder_height) {
  float intersect_y = abs(cuboid_pos.y-cylinder_pos.y) - (cuboid_dim.y+cylinder_height)/2;
  //println(intersect_y);
  if (intersect_y < 0) { // Shapes interesct at least in y-directions
    PVector collision_xz = collision2D_rect_circle(new PVector(cuboid_pos.x, cuboid_pos.z), new PVector(cuboid_dim.x, cuboid_dim.z), new PVector(cylinder_pos.x, cylinder_pos.z), cylinder_radius);
    if (collision_xz != null) { // Shapes intersect
      // println(collision_xz.mag());
      //if (collision_xz.magSq() < sq(intersect_y)) { // Intersection happened from the side
      return new PVector(collision_xz.x, 0, collision_xz.y);
      //} else { // Intersection happened from the top or bottom
      //return new PVector(0, sign(cylinder_pos.y-cuboid_pos.y)*(-intersect_y), 0);
      //}
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
//PVector collision2D_square_circle(PVector square_pos, PVector square_dim, PVector circle_pos, float circle_radius) {
//  PVector rel_pos = PVector.sub(square_pos, circle_pos);
//  float dist_x = abs(rel_pos.x), dist_y = abs(rel_pos.y);
//  PVector square_rads = PVector.mult(square_dim, 0.5);
//  if (dist_x < circle_radius + square_rads.x && dist_y < circle_radius + square_rads.y) {
//    if (dist_x <= square_rads.x || dist_y <= square_rads.y) {
//      if (dist_x < dist_y) {
//        if (rel_pos.x < rel_pos.y) {
//          return new PVector(0, -(circle_radius+square_rads.y-dist_y));
//        } else {
//          return new PVector(0, circle_radius+square_rads.y-dist_y);
//        }
//      } else {
//        if (rel_pos.x < rel_pos.y) {
//          return new PVector(circle_radius+square_rads.y-dist_x, 0);
//        } else {

//          return new PVector(-(circle_radius+square_rads.x-dist_x), 0);
//        }
//      }
//    } else {
//      float corner_dist_x = dist_x-square_rads.x, corner_dist_y = dist_y-square_rads.y;
//      float corner_dist_sq = corner_dist_x*corner_dist_x + corner_dist_y*corner_dist_y;
//      if (corner_dist_sq <= circle_radius*circle_radius) {
//        PVector ret = new PVector((rel_pos.x/dist_x) * corner_dist_x, (rel_pos.y/dist_y) * corner_dist_y);
//        ret.setMag(sqrt(corner_dist_sq)-circle_radius);
//        return ret;
//      }
//    }
//  }
//  return null;
//}

void keyPressed(KeyEvent e) {
  if (!e.isAutoRepeat()) {
    println("Key Code:  " + hex(e.getKeyCode()));
    //println("Key (hex): " + hex(e.getKey()));
    //println("Key:       " + e.getKey());
    //println("Modifiers: " + hex(e.getModifiers()));
    //println(KeyEvent.CTRL);
    //println("");
  }
}

//void keyReleased() {
//  println("KEY UP: ");
//  println(hex(key));
//  println(key);
//  println(char(key + 0x60));
//}
