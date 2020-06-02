abstract class Entity {
  PVector pos;
  PVector vel;
  abstract void update(float dt);
  abstract void show(float dt);
}
