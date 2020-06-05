import processing.net.*;

Client client;

void setup() {
  client = new Client(this, "127.0.0.1", 1729);
}

void draw() {
}

String pack(String s) {
  return "(S)"+s;
}

String pack(float f) {
  return "(F)"+f;
}

String pack(PVector v) {
  return "(V)"+v.x+","+v.y+","+v.z;
}

String unpack(String s) {
}
