final PVector VEC_UP = new PVector(0, 1, 0);
final PVector VEC_DOWN = new PVector(0, -1, 0);

PVector VEC(float x, float y, float z) { // Because typing "new PVector" all the time gets old fast
  return new PVector(x, y, z);
}
PVector VEC(float x, float y) { // Because typing "new PVector" all the time gets old fast
  return new PVector(x, y);
}
PVector VEC(float xyz) {
  return new PVector(xyz, xyz, xyz);
}
PVector VEC() { // Because typing "new PVector" all the time gets old fast
  return new PVector();
}

class FloatPair {
  float a, b;

  FloatPair(float a_, float b_) {
    a = a_;
    b = b_;
  }
}


/**
 out = out + scalar * in
 For example: out = position, in = velocity, scalar = deltaTime
 */
PVector vec_add_scaled(PVector out, PVector in, float scalar) {
  return out.add(scalar*in.x, scalar*in.y, scalar*in.z);
}

void vec_swap(PVector v, PVector w) {
  PVector t = v;
  v = w;
  w = t;
}

PVector vec_xz(PVector v) {
  return VEC(v.x, v.z);
}

float vec_dist_sq(PVector v1, PVector v2) {
  return sq(v1.x-v2.x)+sq(v1.y-v2.y)+sq(v1.z-v2.z);
}

int sign(float x) {
  if (x < 0) return -1;
  if (x > 0) return 1;
  return 0;
}

int sign(int x) {
  if (x < 0) return -1;
  if (x > 0) return 1;
  return 0;
}

PVector round(PVector v) {
  return VEC(round(v.x), round(v.y), round(v.z));
}

PVector round(PVector v, int sig_digits) {
  return VEC(round(v.x, sig_digits), round(v.y, sig_digits), round(v.z, sig_digits));
}

float round(float x, int sig_digits) {
  float s = pow(10, sig_digits);
  return round(s*x)/s;
}

//String nff(float x, int letters) {
//  String s = str(x);
//  s = s.substring(0, min(letters, s.length()-1));
//  String spaces = new String(new char[max(0, s.length()-letters)]).replace("\0", " ");
//  return spaces+s;
//}


//String nff(PVector p, int letters_per_dim) {
//  return "("+nff(p.x, letters_per_dim)+", "+nff(p.y, letters_per_dim)+", "+nff(p.z, letters_per_dim)+")";
//}

String nfs(PVector v, int left, int right) {
  return "("+nfs(v.x, left, right)+", "+nfs(v.y, left, right)+", "+nfs(v.z, left, right)+")";
}

String nfss(float x, int left, int right) {
  String s = nfs(x, left, right);
  char[] sa = s.toCharArray();
  for (int i = 0; i < sa.length; i++) {
    if (!(sa[i] == ' ' || sa[i] == '-')) {
      if (sa[i] == '0') {
        sa[i] = ' ';
      } else {
        break;
      }
    }
  }
  return new String(sa);
}

String nfss(PVector v, int left, int right) {
  return "("+nfss(v.x, left, right)+", "+nfss(v.y, left, right)+", "+nfss(v.z, left, right)+")";
}



int deltatime_lasttime = 0;
float deltatime() {
  int deltaTime = millis() - deltatime_lasttime;
  deltatime_lasttime += deltaTime;
  return deltaTime/1000.0;
}

void boxAt(float x, float y, float z, float w, float h, float d) {
  pushMatrix();
  translate(x, y, z);
  box(w, h, d);
  popMatrix();
}

void boxAtFloor(float x, float z, float w, float h, float d) {
  boxAt(x, h/2, z, w, h, d);
}


// Calculates intersection of a line going from bl to bl+l and a triangle with the corners bp, bp+p1, bp+p2.
// Returns the intersection point if the line and triangle intersect and null if they don't.
PVector intersect_line_triangle(PVector bl, PVector l, PVector bp, PVector p1, PVector p2) {
  PVector b = PVector.sub(bl, bp);

  //Solution to the equation `b = u*p1 + v*p2 - t*l` (or `bl + t*l = bp + u*p1 + v*p2`) from Maxima. 
  float u=-((b.x)*((l.z)*(p2.y)-(l.y)*(p2.z))+(l.x)*((b.y)*(p2.z)-(b.z)*(p2.y))+((b.z)*(l.y)-(b.y)*(l.z))*(p2.x))/((l.x)*((p1.z)*(p2.y)-(p1.y)*(p2.z))+(p1.x)*((l.y)*(p2.z)-(l.z)*(p2.y))+((l.z)*(p1.y)-(l.y)*(p1.z))*(p2.x)); 
  float v=((b.x)*((l.z)*(p1.y)-(l.y)*(p1.z))+(l.x)*((b.y)*(p1.z)-(b.z)*(p1.y))+((b.z)*(l.y)-(b.y)*(l.z))*(p1.x))/((l.x)*((p1.z)*(p2.y)-(p1.y)*(p2.z))+(p1.x)*((l.y)*(p2.z)-(l.z)*(p2.y))+((l.z)*(p1.y)-(l.y)*(p1.z))*(p2.x));
  float t=-((b.x)*((p1.z)*(p2.y)-(p1.y)*(p2.z))+(p1.x)*((b.y)*(p2.z)-(b.z)*(p2.y))+((b.z)*(p1.y)-(b.y)*(p1.z))*(p2.x))/((l.x)*((p1.z)*(p2.y)-(p1.y)*(p2.z))+(p1.x)*((l.y)*(p2.z)-(l.z)*(p2.y))+((l.z)*(p1.y)-(l.y)*(p1.z))*(p2.x));

  //Check that the solution actually is on the line and on the triangle
  if (0 <= t && t <= 1 && 0 <= u && 0 <= v && u+v <= 1) {
    PVector solution = l;
    solution.mult(t);
    solution.add(bl);
    return solution;
  } else {
    return null;
  }
}

IntersectResult intersect2D_line_circle(PVector line_base, PVector line_dir, PVector circle_pos, float circle_radius) {
  line_base = PVector.sub(line_base, circle_pos);
  //float a = sq(line_dir.x) + sq(line_dir.y);
  float p_half = (line_base.x*line_dir.x + line_base.y*line_dir.y);
  float q = (sq(line_base.x) + sq(line_base.y) - sq(circle_radius));

  float s_sq = sq(p_half) - q;
  //println(p_half);
  //println(sq(p_half));
  //println(q);
  //println(s_sq);
  //println("---------");
  if (s_sq <= 0) return null;
  float s = sqrt(s_sq);

  float t1 = -p_half + s;
  float t2 = -p_half - s;
  if (t1 < 0 && t2 < 0) { // Ignoring line_base inside circle case
    return null;
  }

  PVector sol1 = vec_add_scaled(line_base.copy(), line_dir, t1).add(circle_pos);
  PVector sol2 = vec_add_scaled(line_base.copy(), line_dir, t2).add(circle_pos);

  //println(sol1);
  //println(sol2);

  return new IntersectResult(sol1, sol2, null, null);
}

IntersectResult intersect2D_line_aa_rect(PVector line_base, PVector line_dir, PVector rect_pos, PVector rect_dim) {
  line_base = PVector.sub(line_base, rect_pos);
  //PVector rect_rad = PVector.mult(rect_dim, 0.5);

  IntersectResult sol = new IntersectResult();

  float bs = line_base.x/rect_dim.x + line_base.y/rect_dim.y;
  float bd = line_base.x/rect_dim.x - line_base.y/rect_dim.y;
  float ds = line_dir.x/rect_dim.x + line_dir.y/rect_dim.y;
  float dd = line_dir.x/rect_dim.x - line_dir.y/rect_dim.y;

  for (int ss = -1; ss <= 1; ss+=2) {
    for (int sd = -1; sd <= 1; sd+=2 ) {
      float t = (1-(ss*bs + sd*bd))/(ss*ds + sd*dd);
      PVector s = vec_add_scaled(line_base.copy(), line_dir, t);
      if ((ss*sd < 0 && abs(s.x) <= rect_dim.x/2) || (ss*sd > 0 && abs(s.y) <= rect_dim.y/2)) {
        s.z = t;
        sol.append(s, null);
      }
    }
  }

  if (sol.first != null && sol.second != null && (sol.first.z >= 0 || sol.second.z >= 0)) {
    sol.first.z = 0;
    sol.second.z = 0;
    sol.first.add(rect_pos);
    sol.second.add(rect_pos);
    return sol;
  } else {
    return null;
  }
}

void drawArrow(float x_from, float y_from, float x_to, float y_to) {
  line(x_from, y_from, x_to, y_to);
  PVector v = new PVector(x_from - x_to, y_from - y_to);
  v.normalize();
  v.mult(5);
  v.rotate(QUARTER_PI);
  line(x_to, y_to, x_to+v.x, y_to+v.y);
  v.rotate(-HALF_PI);
  line(x_to, y_to, x_to+v.x, y_to+v.y);
}

void drawArrow(PVector from, PVector to) {
  drawArrow(from.x, from.y, to.x, to.y);
}

void drawArrow_(float x_pos, float y_pos, float x_dir, float y_dir) {
  drawArrow(x_pos, y_pos, x_pos+x_dir, y_pos+y_dir);
}

void drawArrow_(PVector pos, PVector dir) {
  drawArrow_(pos.x, pos.y, dir.x, dir.y);
}

void drawArrow_(PVector pos, PVector dir, float length_scale) {
  drawArrow_(pos.x, pos.y, length_scale*dir.x, length_scale*dir.y);
}
