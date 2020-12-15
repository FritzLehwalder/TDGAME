class Turret {
  float x, y, w, h;
  int dmg, hp, maxhp;
  Timer fireTimer;
  PImage turretimg;
  boolean hidden, ready;
  String type;
  Enemy enemy;
  class Type {
    
  }
  Turret(float x, float y, int dmg, String type) {
    this.type = type;
    fireTimer = new Timer(1000);
    this.x = x;
    this.y = y;
    w = 50;
    h = 50;
    this.dmg = dmg;
    hp = 1000;
    maxhp = hp;
    if (type.equals("turretEasy")) turretimg = loadImage("./data/turret.png");
    if (type.equals("turretHard")){
      turretimg = loadImage("./data/turretHard.png");
      hp = 2000;
    }
    if (type.equals("turretShotgun")) turretimg = loadImage("./data/turretShotgun.png");
    if (type.equals("turretMachine")) {
      fireTimer.totalTime = 150;
      turretimg = loadImage("./data/turretMachine.png");
    }
    if(type.equals("tesla")){
      turretimg = loadImage("./data/tesla.png");
      fireTimer.totalTime = 2000;
    }
    if(type.equals("laser")){
      turretimg = loadImage("./data/laser.png");
      fireTimer.totalTime = 10500;
    }
    if(type.equals("bomb")){ // stun movement around bomb crater
      turretimg = loadImage("./data/bomb.png");
      fireTimer.totalTime = 10500;
    }
  }
  void update() {
    if (fireTimer.isFinished()) {
      ready = true;
    }
    if (!hidden) draw();
  }
  private void draw() {
    imageMode(CENTER);
    image(turretimg, x, y);
  }
  boolean checkEnemy(Enemy enemy) {
    if (hp < 0) {
      return false;
    } else {
      textSize(10);
      fill(#434343);
      rect(x-w/2-3, (y+h/2)+2, x+w/2-(x-w/2)+6, 17);
      fill(#2acb35);
      if (hp > 0) {
        float temp = (x+w/2-(x-w/2))/(maxhp/hp);
        if ((x+w/2-(x-w/2))/(maxhp/hp)+x-w/2 < x-w/2) temp = 0;
        rect(x-w/2, y+h/2+5, temp, 11);
        fill(255);
        if (hp > 0) text(this.hp, x, y+h/2+14, 5);
      }
      return enemy.x>x-w/2 && enemy.x<x+w/2 && enemy.y>y-h/2 && enemy.y<y+h/2;
    }
  }
}
