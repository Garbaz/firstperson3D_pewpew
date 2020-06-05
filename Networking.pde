final int NET_PORT = 1729;
final float NET_UPDATE_PERIOD = 1.0/32;

float net_update_timer = 0;

Client net_client;
Server net_server;

int net_local_id;

void init_network_id() {
  net_local_id = int(random(0, 1<<30));
}

void net_connect(String server_ip) {
  init_network_id();
  net_client = new Client(this, server_ip, NET_PORT);
}

void net_host() {
  init_network_id();
  net_server = new Server(this, NET_PORT);
}

void net_update(float dt) {
  //RECIEVING
  if (net_server != null) {
    Client c;
    do {
      c = net_server.available();
      if (c != null) {
        recieve_client(c);
      }
    } while (c != null);
  } else if (net_client != null) { 
    recieve_client(net_client);
  }

  //SENDING
  net_update_timer += dt;
  if (net_update_timer >= NET_UPDATE_PERIOD) {
    net_update_timer = 0;

    if (net_server != null) {
      for (HashMap.Entry<Integer, Player> entry : players.entrySet()) {
        int id = entry.getKey();
        Player p = entry.getValue();
        net_server.write(net_package_str(id, p.pack()));
      }
    } else if (net_client != null) {
      net_client.write(net_package_str(local_player.pack()));
    }
  }
}

void recieve_client(Client c) {
  if (c.available() > 0) {
    String[] lines = c.readString().split("\n");
    println(lines);
    for (String l : lines) {
      String[] id_pack = l.split(";", 2);
      if (id_pack.length == 2) {
        int id = int(id_pack[0]);
        if (id != net_local_id) {
          String pack = id_pack[1];
          Player p = players.get(id);
          if (p == null) {
            p = new Player();
            players.put(id, p);
          }
          p.unpack(pack);
        }
      }
    }
  }
}

String net_package_str(String s) {
  return net_package_str(net_local_id, s);
}

String net_package_str(int id, String s) {
  return id + ";" + s + "\n";
}

interface NetPackable {
  String pack(); // Returned String can not contain '\n'
  void unpack(String p);
}

String net_vec_to_string(PVector v) {
  return v.x+","+v.y+","+v.z;
}

PVector net_string_to_vec(String s) {
  String[] spl = s.split(","); 
  if (spl.length == 3) {
    return VEC(float(spl[0]), float(spl[1]), float(spl[2]));
  } else {
    return null;
  }
}

//JSONObject vec2json(PVector v) {
//  JSONObject j = new JSONObject();
//  j.setFloat("x", v.x);
//  j.setFloat("y", v.y);
//  j.setFloat("z", v.z);
//  return j;
//}

//PVector json2vec(JSONObject j) {
//  PVector v = VEC();
//  if (json2vec(j, v)) {
//    return v;
//  } else {
//    return null;
//  }
//} 

//boolean json2vec(JSONObject j, PVector v) {
//  if (j.isNull("x") || j.isNull("y")) return false;
//  if (j.isNull("z")) v.set(j.getFloat("x"), j.getFloat("y"));
//  v.set(j.getFloat("x"), j.getFloat("y"), j.getFloat("z"));
//  return true;
//}
