class Turret {
  float x, y, w, h;
  int dmg, hp, maxhp;
  Timer fireTimer;
  PImage turretimg;
  boolean hidden, ready;
  Enemy enemy;
  class Type {
    
  }
  Turret(float x, float y, int dmg) {
    fireTimer = new Timer(1000);
    this.x = x;
    this.y = y;
    w = 50;
    h = 50;
    this.dmg = dmg;
    hp = 1000;
    if(dmg == 100) hp = 2000;
    maxhp = hp;
    if (dmg == 50) turretimg = loadImage("./data/turret.png");
    if (dmg == 100) turretimg = loadImage("./data/turretHard.png");
    if (dmg == 25) turretimg = loadImage("./data/turretShotgun.png");
    if (dmg == 10) {
      fireTimer.totalTime = 150;
      turretimg = loadImage("./data/turretMachine.png");
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
