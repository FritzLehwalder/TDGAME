import java.io.*;
class Trap {
  float x, y, w, h;
  int dmg, hp;
  PImage img;
  Trap (float x, float y, int dmg, int hp){
    this.x = x;
    this.y = y;
    this.dmg = dmg;
    this.hp = hp;
    try {
      img = loadImage("./data/trap.png");
    } catch (NullPointerException e) {
      e.printStackTrace();
    }
    w = 50;
    h = 50;
  }
  void update(){
    imageMode(CENTER);
    image(img, x, y);
  }
}
