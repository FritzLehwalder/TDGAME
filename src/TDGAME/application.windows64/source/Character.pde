import java.io.*;
class Character {
  float x, y, w, h, velocityX, velocityY, speed;
  int hp, maxhp, shield, maxshield, damage;
  PImage player;
  boolean hidden, readyToFire;
  Timer fireTimer;
  Character(float x, float y, float speed){
    this.x = x;
    this.y = y;
    this.speed = speed;
    w = 50;
    h = 50;
    hp = 100;
    damage = 50;
    maxhp = hp;
    shield = 0;
    maxshield = 100;
    velocityX = 0;
    velocityY = 0;
    try {
      player = loadImage("./data/player.png");
    } catch (NullPointerException e) {
      e.printStackTrace();
    }
    hidden = false;
    fireTimer = new Timer(500);
  }
  void update(){
    if(hp <= 0){
      velocityX = 0;
      velocityY = 0;
      hidden = true;
    }
    if(fireTimer.isFinished()){
      readyToFire = true;
    }
    if(x+velocityX >= 0+w/2-2 && x+velocityX <= 1000-w/2+2) x+=velocityX;
    if(y+velocityY >= 0+h/2-2 && y+velocityY <= 1000-h/2+2) y+=velocityY;
    if(!keyPressed){
      velocityY = 0;
      velocityX = 0;
    }
    if(!hidden && hp != 0) draw();
  }
  private void draw(){
    textSize(10);
    imageMode(CENTER);
    image(player,x,y);
    textAlign(CENTER);
    fill(#434343);
    rect(x-w/2-3,(y+h/2)+2,x+w/2-(x-w/2)+6,17);
    fill(#2acb35);
    float temp = (x+w/2-(x-w/2))/(maxhp/hp);
    if((x+w/2-(x-w/2))/(maxhp/hp)+x-w/2 < x-w/2) temp = 0;
    rect(x-w/2,y+h/2+5,temp,11);
    if(shield > 0){
      fill(#434343);
      rect(x-w/2-3,(y+h/2)+20,x+w/2-(x-w/2)+6,17);
      fill(#33b1cc);
      float temp2 = (x+w/2-(x-w/2))/(maxshield/shield);
      if((x+w/2-(x-w/2))/(maxshield/shield)+x-w/2 < x-w/2) temp2 = 0;
      rect(x-w/2,y+h/2+23,temp2,11);
      fill(255);
      text(shield, x, y+h/2+32, 5);
    }
    fill(255);
    if(hp > 0) text(hp, x, y+h/2+14, 5);
  }
  Boolean checkRay(Ray bullet){
    if(bullet.x>x-w/2 && bullet.x<x+w/2 && bullet.y>y-h/2 && bullet.y<y+h/2) 
      if(shield <= 0){
        if(!invincible) hp-=5;
      } else {
        if(!invincible) shield-=10;
      }
    return bullet.x>x-w/2 && bullet.x<x+w/2 && bullet.y>y-h/2 && bullet.y<y+h/2;
  }
  boolean checkEnemy(Enemy bullet){
    if(bullet.x>x-w/2 && bullet.x<x+w/2 && bullet.y>y-h/2 && bullet.y<y+h/2){
      if(shield <= 0){
        if(!invincible) hp-=10/(bullet.maxhp/bullet.hp);
      } else {
        if(!invincible) shield-=10/(bullet.maxhp/bullet.hp) ;
      }
    }
    return bullet.x>x-w/2 && bullet.x<x+w/2 && bullet.y>y-h/2 && bullet.y<y+h/2;
  }
}
