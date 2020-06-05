final float LEVEL_SCALE_XZ = 1.0;
final float LEVE_SCALE_Y = 0.1;

void load_level(String path) {
  Table table = loadTable(path);
  int columns = table.getColumnCount(), rows = table.getRowCount();
  //println(columns);
  //println(rows);
  add_prop(new PropBox(VEC(0.5*columns*LEVEL_SCALE_XZ, -10, 0.5*rows*LEVEL_SCALE_XZ), VEC(columns*LEVEL_SCALE_XZ, 10, rows*LEVEL_SCALE_XZ), true));
  for (int j = 0; j < rows; j++) {
    for (int i = 0; i < columns; i++) {
      float x = LEVEL_SCALE_XZ * i;
      float z = LEVEL_SCALE_XZ * j;
      String cell = table.getString(j, i);
      if (cell != null && cell.length() >= 1) {
        char c = cell.charAt(0);
        //print(c);
        if ('0' <= c && c <= '9') {
          add_prop(new PropBox(VEC(x, 0, z), VEC(LEVEL_SCALE_XZ, int(c-'0')*LEVE_SCALE_Y, LEVEL_SCALE_XZ), true));
        } else if ('a' <= c && c <= 'z') {
          add_prop(new PropBox(VEC(x, 0, z), VEC(LEVEL_SCALE_XZ, int(10+c-'a')*LEVE_SCALE_Y, LEVEL_SCALE_XZ), true));
        } else if ('A' <= c && c <= 'Z') {
          // add_prop(new PropBox(VEC(x, int((10+c-'A'))*LEVE_SCALE_Y, z), VEC(LEVEL_SCALE_XZ, int(36-(10+c-'A'))*LEVE_SCALE_Y, LEVEL_SCALE_XZ), true));
          add_prop(new PropBox(VEC(x, int((10+c-'A'))*LEVE_SCALE_Y, z), VEC(LEVEL_SCALE_XZ, int(100-(10+c-'A'))*LEVE_SCALE_Y, LEVEL_SCALE_XZ), true));
        } else if (c == '!') {
          add_prop(new PropBox(VEC(x, 0, z), VEC(LEVEL_SCALE_XZ, 100*LEVE_SCALE_Y, LEVEL_SCALE_XZ), true));
        } else if (c == '+') {
          spawn_team_cross = VEC(x, 2, z);
        } else if (c == '*') {
          spawn_team_star = VEC(x, 2, z);
        } else if (c == ' ' || c == '\0') {
          // Ignore blank cells
        } else {
          //println("LevelLoader encountered unknown symbol: '" + c + "'");
        }
      }
    }
    //println();
  }
}
