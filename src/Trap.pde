class Trap {
  float x, y, w, h;
  int dmg, hp;
  PImage img;
  Trap (float x, float y, int dmg, int hp){
    this.x = x;
    this.y = y;
    this.dmg = dmg;
    this.hp = hp;
    img = loadImage("./data/trap.png");
    w = 50;
    h = 50;
  }
  void update(){
    imageMode(CENTER);
    image(img, x, y);
  }
}
