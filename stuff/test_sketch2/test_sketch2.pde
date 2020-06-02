
PImage p;

void settings() {
  size(800, 800, P3D);
}
void setup() {
  p = loadImage("../../assets/pew.png");
  image(p, 0, 0);
}
