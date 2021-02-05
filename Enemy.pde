class Enemy {
  float x,y,w,h,speed, id;
  float maxhp;
  float maxspeed;
  int hp;
  PImage img;
  Turret target;
  Boolean boss;
  Enemy(float x, float y, int hp, float speed, boolean boss){
    id = enemyId;
    enemyId+=1;
    this.x = x;
    this.y = y;
    w = 50;
    h = 50;
    this.hp = hp;
    this.boss = boss;
    maxhp = hp;
    maxspeed = speed;
    this.speed = speed;
    img = loadImage("./data/enemy.png");
    if(boss) img = loadImage("./data/boss.png");
  }
  void update(Character player){
    if(hp < maxhp && !boss) speed=maxspeed/(maxhp/hp);
    double angle = Direction.calcAngle(x, y, width/2, height/2);
    if(target != null) angle = Direction.calcAngle(x, y, target.x, target.y);
    if(!player.hidden) angle = Direction.calcAngle(x, y, player.x, player.y);
    double scaleX = Math.sin(angle);
    double scaleY = -Math.cos(angle);
    x+=(speed*scaleX);
    y+=(speed*scaleY);
  }
  void display(){
    textSize(10);
    imageMode(CENTER);
    image(img,x,y);
    fill(#434343);
    rect(x-w/2-3,(y+h/2)+2,x+w/2-(x-w/2)+6,17);
    fill(#2acb35);
    float temp = (x+w/2-(x-w/2))/(maxhp/hp);
    if((x+w/2-(x-w/2))/(maxhp/hp)+x-w/2 < x-w/2) temp = 0;
    rect(x-w/2,y+h/2+5,temp,11);
    fill(255);
    if(hp > 0) text(hp, x, y+h/2+14, 5);
  }
  Boolean checkRay(Ray bullet, Boolean canceler){
    if(bullet.type.equals("bomb")) return false;
    if(bullet.type.equals("laser")){
      if(bullet.x>x-w*2 && bullet.x<x+w && bullet.y>y-h && bullet.y<y+h) if(!canceler && !bullet.type.equals("boss")){
        hp-=bullet.dmg;
      } else if (this.boss = true){
        hp-=bullet.dmg/8;
      }
    } else {
      if(bullet.x>x-w/2 && bullet.x<x+w/2 && bullet.y>y-h/2 && bullet.y<y+h/2) if(!canceler && !bullet.type.equals("boss")) hp-=bullet.dmg;
    }
    return bullet.x>x-w/2 && bullet.x<x+w/2 && bullet.y>y-h/2 && bullet.y<y+h/2 && !bullet.type.equals("boss");
  }
  Boolean checkTrap(Trap bullet){
    if(bullet.x>x-w/2 && bullet.x<x+w/2 && bullet.y>y-h/2 && bullet.y<y+h/2){
      hp-=bullet.dmg;
      bullet.hp-=50;
    }
    return bullet.x>x-w/2 && bullet.x<x+w/2 && bullet.y>y-h/2 && bullet.y<y+h/2;
  }
}
