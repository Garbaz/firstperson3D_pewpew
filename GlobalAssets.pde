PShape player_shape, player_gun_shape;
PImage pew_image;

PShader shot_impact_particle_shader;

void load_global_assets() {
  player_shape = loadShape("assets/player_shape.obj");
  player_shape.setFill(#700000);
  
  player_gun_shape = loadShape("assets/player_gun.obj");
  player_gun_shape.setTexture(loadImage("assets/player_gun_tex.jpg"));
  //player_gun_shape = loadShape("assets/kar98k.obj");
  //player_gun_shape.setTexture(loadImage("assets/kar98k_texture.jpg"));

  pew_image = loadImage("assets/pew.png");

  shot_impact_particle_shader = loadShader("assets/shot_impact_particle.frag", "assets/shot_impact_particle.vert");
  shot_impact_particle_shader.set("tex", loadImage("assets/shot_impact_tex.png"));
}
