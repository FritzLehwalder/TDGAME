import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.io.*; 
import java.io.*; 
import java.io.*; 
import java.lang.Math; 
import java.io.*; 
import java.io.*; 
import java.io.*; 
import java.io.*; 
import java.io.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class TDGAME extends PApplet {

//powerups, lasergun turret, electric tesla turret (arcs between enemies), gun upgrade shooting (faster shooting, more damage), aoe bomb turret, upgrade damage on turrets, autosnap to close turrets/traps when building, pathfinding, walls

ArrayList<Ray> rays;
ArrayList<Turret> turrets;
ArrayList<Enemy> enemies;
ArrayList<Trap> traps;
Timer EnemyTimer;
Timer LevelTimer;
Timer PrepTimer;
Timer BossShotTimer;
int level;
int startingHP;
int totalEnemies;
Character player;
PImage background;
PFont Gotham;
int money;
int highscore;
Boolean instaKill;
Button respawn;
boolean turretTracking;
boolean invincible;
double respawnCost;
Menu menu;
PImage curs;
PImage cursMenu;
Boolean prep;
Boolean spawn;
Boolean temp2;
int activeKey;
Boolean paused;
boolean a;
public void setup(){
  instaKill = false;
  money = 0;
  rays = new ArrayList<Ray>();
  turrets = new ArrayList<Turret>();
  enemies = new ArrayList<Enemy>();
  traps = new ArrayList<Trap>();
  EnemyTimer = new Timer(5000);
  LevelTimer = new Timer(30000);
  PrepTimer = new Timer(15000);
  BossShotTimer = new Timer(750);
  startingHP = 100;
  invincible = false;
  Gotham = createFont("./data/Gotham-Bold.otf", 40);
  try {
    background = loadImage("./data/background2.png");
    curs = loadImage("./data/cursor.png");
    cursMenu = loadImage("./data/cursurMenu.png");
  } catch (NullPointerException e) {
    e.printStackTrace();
  }
  player = new Character(width/2, height/2, 4);
  
  noStroke();
  EnemyTimer.start();
  respawn = new Button(width/2, (height/5)*4, 380, 50, 15, "Respawn? $1000", 40, "test");
  menu = new Menu();
  respawnCost = 1000;
  noCursor();
  prep = false;
  spawn = true;
  temp2 = false;
  paused = false;
  a = false;
}
public void draw() {
  imageMode(CENTER);
  if(enemies.size() >= 500){
    for(int i = 0; i < enemies.size()+500; i++){
      if(enemies.get(i+500) != null) enemies.remove(i+500);
    }
  }
  image(background, width/2, height/2);
  player.update();
  if (!paused) {
    if (rays.size() >= 1) for (int i = 0; i < rays.size(); i++) { 
      Ray ray = rays.get(i);
      if (ray.dmg <= 5) {
        if (player.checkRay(ray) && !player.hidden) rays.remove(ray);
      }
      ray.update();
      if (ray.purge) rays.remove(i);
      if (enemies.size() >= 1) {
        int temptarget = (int)random(0, enemies.size());
        Enemy target = enemies.get(temptarget);
        if (turretTracking && ray.tracked == null) ray.track(target);
      }
      if (enemies.size() >= 1) for (int j = 0; j < enemies.size(); j++) { 
        Enemy enemy = enemies.get(j);
        if (ray.dmg > 5) if (enemy.checkRay(ray) && i < rays.size() && !enemy.boss) {
          rays.remove(i);
          if (instaKill) {
            enemies.remove(j);
            money+=50;
          }
        }
      }
      try {
        if (ray.x >= 1050 || ray.x <= -50 || ray.y >= 1050 || ray.y <= -50 && rays.get(i) != null) rays.remove(i); // off screen culling
      } 
      catch (Exception e) {
        println(e);
      }
    }
    if (turrets.size() >= 1) for (int i = 0; i < turrets.size(); i++) { 
      Turret turret = turrets.get(i);
      if (turret.hp <= 0) turrets.remove(i);
      Enemy closest = null;
      if (enemies.size() >= 1) for (int j = 0; j < enemies.size(); j++) {
        closest = enemies.get((int)random(0, enemies.size()));
        Enemy enemy = enemies.get(j);
        if (player.hidden) {
          if (turret.checkEnemy(enemy)) {
            if (!enemy.boss) {
              enemies.remove(j);
            } else {
              enemy.hp-=100;
            }
            turret.hp-=50/(enemy.maxhp/enemy.hp);
          }
        }
        if (dist(turret.x, turret.y, enemy.x, enemy.y) > dist(turret.x, turret.y, closest.x, closest.y)) closest = enemies.get(j);
      }
      if (turret.enemy != null) {
        if (enemies.indexOf(turret.enemy) >= 0) {
          turret.enemy = enemies.get(enemies.indexOf(turret.enemy));
        } else {
          if (enemies.size() > 0) {
            turret.enemy = enemies.get((int)random(0, enemies.size()));
          } else {
            turret.enemy = null;
          }
        }
      }
      if (turret.enemy != null && turret.enemy.hp <= 0) turret.enemy = null;
      if (turret.enemy == null) turret.enemy = closest;
      if (turret.hp > 0) {
        turret.update();
        if (turret.ready && enemies.size() >= 1) {
          Enemy target = enemies.get((int)random(0, enemies.size()));
          if (turret.dmg == 10) {
            rays.add(new Ray(turret.x, turret.y, Direction.calcAngle(turret.x, turret.y, turret.enemy.x+random(-50, 50), turret.enemy.y+random(-50, 50)), 10, turret.dmg));
          } else if (turret.dmg == 100) {
            rays.add(new Ray(turret.x, turret.y, Direction.calcAngle(turret.x, turret.y, turret.enemy.x, target.y), 20, turret.dmg));
          } else if (turret.dmg == 25) {
            rays.add(new Ray(turret.x, turret.y, Direction.calcAngle(turret.x, turret.y, target.x, target.y), 10, turret.dmg));
            target = enemies.get((int)random(0, enemies.size()));
            rays.add(new Ray(turret.x, turret.y, Direction.calcAngle(turret.x, turret.y, target.x, target.y), 10, turret.dmg));
            target = enemies.get((int)random(0, enemies.size()));
            rays.add(new Ray(turret.x, turret.y, Direction.calcAngle(turret.x, turret.y, target.x, target.y), 10, turret.dmg));
          } else {
            rays.add(new Ray(turret.x, turret.y, Direction.calcAngle(turret.x, turret.y, turret.enemy.x, turret.enemy.y), 10, turret.dmg));
          }
          turret.ready = false;
          turret.fireTimer.start();
        }
      }
    }
    if (!a) {
      a = true;
      BossShotTimer.start();
    }
    if (enemies.size() >= 1) for (int i = 0; i < enemies.size(); i++) { 
      Enemy enemy = enemies.get(i);
      println(BossShotTimer.isFinished());
      if (enemy.boss && BossShotTimer.isFinished() && !player.hidden) {
        rays.add(new Ray(enemy.x, enemy.y, Direction.calcAngle(enemy.x, enemy.y, player.x, player.y), 10, 5));
        rays.add(new Ray(enemy.x, enemy.y, Direction.calcAngle(enemy.x, enemy.y, player.x+player.x/10, player.y+player.y/10), 10, 5));
        rays.add(new Ray(enemy.x, enemy.y, Direction.calcAngle(enemy.x, enemy.y, player.x-player.x/10, player.y-player.y/10), 10, 5));
        BossShotTimer.start();
      }
      Turret closest = null;
      if (turrets.size() >= 0) for (int j = 0; j < turrets.size(); j++) {
        Turret turret = turrets.get(j);
        closest = turrets.get((int)random(0, turrets.size()-1));
        if (dist(enemy.x, enemy.y, closest.x, closest.y) > dist(enemy.x, enemy.y, turret.x, turret.y)) closest = turrets.get(j);
      }
      if (enemy.target == null && turrets.size() >= 1) enemy.target = closest;
      if (enemy.target != null) {
        if (turrets.indexOf(enemy.target) >= 0) {
          enemy.target = turrets.get(turrets.indexOf(enemy.target));
        } else {
          if (turrets.size() > 1) {
            enemy.target = turrets.get((int)random(0, turrets.size()));
          } else {
            enemy.target = null;
          }
        }
      }
      if (turrets.size() == 0) enemy.target = null;
      boolean cont = true;
      if (enemy.hp <= 0) {
        enemies.remove(i);
        cont = false;
        if (level < 10) money+=50;
        if (level >= 10 && level <= 15) money+=25;
        if (level > 15) money+=10;
        highscore+=100;
      }
      enemy.update(player);
      enemy.display();
      if (player.checkEnemy(enemy) && cont && !player.hidden) {
        if (!enemy.boss) {
          enemies.remove(i);
        } else {
          enemy.hp-=100;
        }
      }
      if (traps.size() >= 1) for (int j = 0; j < traps.size(); j++) {
        Trap trap = traps.get(j);
        if (enemy.checkTrap(trap)) {
          if (trap.hp <= 0) traps.remove(j);
          if (enemy.hp <= 0) money+=3;
        }
      }
    }
    if (EnemyTimer.isFinished() && !prep && spawn) {
      for (int i = 0; i < totalEnemies; i++) {
        int rand = (int)random(0, 3);
        float tx = random(0, 1000);
        float ty = -50;
        switch (rand) {
        case 0:
          tx = random(0, 1000);
          ty = -50;
          break;
        case 1:
          ty = random(0, 1000);
          tx = 1050;
          break;
        case 2:
          tx = random(0, 1000);
          ty = 1050;
          break;
        case 3:
          ty = random(0, 1000);
          tx = -50;
          break;
        }
        enemies.add(new Enemy(tx, ty, startingHP, 3, false));
      }
      EnemyTimer.start();
    }
    if (traps.size() >= 1) for (int j = 0; j < traps.size(); j++) {
      Trap trap = traps.get(j);
      trap.update();
    }
    if (LevelTimer.isFinished()) {
      if (!prep && enemies.size() <= 0) {
        PrepTimer.start();
        temp2 = true;
        prep = true;
        money+=200;
      }
      spawn = false;
      if (PrepTimer.isFinished() && enemies.size() <= 0 && temp2) {
        level+=1;
        LevelTimer.start();
        prep = false;
        temp2 = false;
        spawn = true;
        int rand = (int)random(0, 3);
        float tx = random(0, 1000);
        float ty = -50;
        switch (rand) {
        case 0:
          tx = random(0, 1000);
          ty = -50;
          break;
        case 1:
          ty = random(0, 1000);
          tx = 1050;
          break;
        case 2:
          tx = random(0, 1000);
          ty = 1050;
          break;
        case 3:
          ty = random(0, 1000);
          tx = -50;
          break;
        }
        switch(level) {
        case 5:
          enemies.add(new Enemy(tx, ty, 5500, 1, true));
          break;
        case 10:
          enemies.add(new Enemy(tx, ty, 15000, 1, true));
          break;
        case 15:
          enemies.add(new Enemy(tx, ty, 24500, 1, true));
          break;
        case 20:
          enemies.add(new Enemy(tx, ty, 30000, 1, true));
          break;
        }
      }
    }
    switch (level) {
    case 0:
      EnemyTimer.totalTime = 4000;
      startingHP = 100;
      totalEnemies = 1;
      break;
    case 1:
      EnemyTimer.totalTime = 4000;
      startingHP = 125;
      totalEnemies = 2;
      break;
    case 2:
      EnemyTimer.totalTime = 4000;
      startingHP = 200;
      totalEnemies = 3;
      break;
    case 3:
      EnemyTimer.totalTime = 4000;
      startingHP = 250;
      totalEnemies = 3;
      break;
    case 4:
      EnemyTimer.totalTime = 3000;
      startingHP = 250;
      totalEnemies = 4;
      break;
    case 5:
      EnemyTimer.totalTime = 3000;
      startingHP = 280;
      totalEnemies = 4;
      break;
    case 6:
      EnemyTimer.totalTime = 3000;
      startingHP = 310;
      totalEnemies = 4;
      break;
    case 7:
      EnemyTimer.totalTime = 3000;
      startingHP = 310;
      totalEnemies = 4;
      break;
    case 8:
      EnemyTimer.totalTime = 3000;
      totalEnemies = 5;
      startingHP = 340;
      break;
    case 9:
      EnemyTimer.totalTime = 2000;
      totalEnemies = 5;
      startingHP = 355;
      break;
    case 10:
      EnemyTimer.totalTime = 2000;
      totalEnemies = 5;
      startingHP = 400;
      break;
    case 11:
      EnemyTimer.totalTime = 2000;
      totalEnemies = 6;
      break;
    case 12:
      EnemyTimer.totalTime = 2000;
      totalEnemies = 6;
      startingHP = 450;
      break;
    case 13: 
      EnemyTimer.totalTime = 1500;
      totalEnemies = 6;
      startingHP = 450;
      break;
    case 14:
      EnemyTimer.totalTime = 1500;
      totalEnemies = 6;
      startingHP = 495;
      break;
    case 15:
      EnemyTimer.totalTime = 1500;
      totalEnemies = 7;
      startingHP = 535;
      break;
    case 16:
      EnemyTimer.totalTime = 1500;
      totalEnemies = 7;
      startingHP = 570;
      break;
    case 17:
      EnemyTimer.totalTime = 1500;
      totalEnemies = 7;
      startingHP = 600;
      break;
    case 18:
      EnemyTimer.totalTime = 1250;
      totalEnemies = 7;
      startingHP = 600;
      break;
    case 19:
      EnemyTimer.totalTime = 1250;
      totalEnemies = 7;
      startingHP = 625;
      break;
    case 20:
      EnemyTimer.totalTime = 1250;
      totalEnemies = 8;
      startingHP = 625;
      break;
    }
    menu.display();
    if (menu.queue != null) {
      boolean valid = true;
      if (turrets.size() >= 1) for (int i = 0; i < turrets.size(); i++) {
        Turret turret = turrets.get(i);
        if (menu.x>turret.x-50 && menu.x<turret.x+50 && menu.y>turret.y-50 && menu.y<turret.y+50) valid = false;
      }
      if (traps.size() >= 1) for (int i = 0; i < traps.size(); i++) {
        Trap turret = traps.get(i);
        if (menu.x>turret.x-25 && menu.x<turret.x+50 && menu.y>turret.y-50 && menu.y<turret.y+50) valid = false;
      }
      if (menu.queue == "turretEasy" && money >= 500 && valid) {
        turrets.add(new Turret(menu.x, menu.y, 50));
        money-=500;
      } else if (menu.queue == "turretHard" && money >= 1000 && valid) {
        turrets.add(new Turret(menu.x, menu.y, 100));
        money-=1000;
      } else if (menu.queue == "turretShotgun" && money >= 750 && valid) {
        turrets.add(new Turret(menu.x, menu.y, 25));
        money-=750;
      } else if (menu.queue == "turretMachine" && money >= 750 && valid) {
        turrets.add(new Turret(menu.x, menu.y, 10));
        money-=750;
      } else if (menu.queue == "trap" && money >= 150 && valid) {
        traps.add(new Trap(menu.x, menu.y, 5, 2400));
        money-=150;
      } else if (menu.queue == "shield" && money >= 1000 && player.shield < 100) {
        money-=1000;
        player.shield = 100;
      }
      menu.queue = null;
    }
    fill(255);
    textFont(Gotham, 40);
    textAlign(LEFT);
    text("$"+money, 5, 40);
    textAlign(RIGHT);
    if (prep && enemies.size() == 0) text("Prep: "+(level+1)+"  "+(int)((PrepTimer.totalTime/1000)-(millis()-PrepTimer.savedTime)/1000)+"sec", width-5, 40);
    if (!spawn && enemies.size() >= 1) text("Level: "+level+"  "+"0sec", width-5, 40);
    if (!prep && spawn) text("Level: "+level+"  "+(int)((LevelTimer.totalTime/1000)-(millis()-LevelTimer.savedTime)/1000)+"sec", width-5, 40);
    if (player.hidden) {
      respawn.update(mouseX, mouseY);
      respawn.display();
    }
    textAlign(CENTER);
    textFont(Gotham, 10);
    if (instaKill) text("instakill on", width/2, 50);
    if (turretTracking) text("turrettracking on", width/2, 38);
    fill(255);
    imageMode(CENTER);
    if (menu.active) {
      image(cursMenu, mouseX, mouseY);
    } else {
      image(curs, mouseX, mouseY);
    }
  } else {
    textSize(50);
    textAlign(CENTER);
    text("Paused", width/2, height/2);
    player.velocityX = 0;
    player.velocityY = 0;
    if (!enemies.isEmpty()) for (int i = 0; i < enemies.size(); i++) {
      Enemy enemy = enemies.get(i);
      enemy.display();
    }
  }
}
public void keyPressed() {
  activeKey = keyCode;
  switch(keyCode) {
  case 32: //space
    rays.add(new Ray(player.x, player.y, Direction.calcAngle(player.x, player.y, mouseX, mouseY), 10, 50));
    break;
  case 87: //w
    if (!player.hidden && !paused) {
      player.velocityY=0;
      player.velocityY=-player.speed;
    }
    break;
  case 65: //a
    if (!player.hidden && !paused) { 
      player.velocityX=0;
      player.velocityX=-player.speed;
    }
    break;
  case 83: //s
    if (!player.hidden && !paused) {
      player.velocityY=0;
      player.velocityY=+player.speed;
    }
    break;
  case 68: //d
    if (!player.hidden && !paused) {
      player.velocityX=0;
      player.velocityX=+player.speed;
    }
    break;
  case 8: //BS
    prep = false;
    level+=1;
    LevelTimer.start();
    prep = false;
    int rand = (int)random(0, 3);
    float tx = random(0, 1000);
    float ty = -50;
    switch (rand) {
    case 0:
      tx = random(0, 1000);
      ty = -50;
      break;
    case 1:
      ty = random(0, 1000);
      tx = 1050;
      break;
    case 2:
      tx = random(0, 1000);
      ty = 1050;
      break;
    case 3:
      ty = random(0, 1000);
      tx = -50;
      break;
    }
    switch(level) {
    case 5:
      enemies.add(new Enemy(tx, ty, 5500, 1, true));
      break;
    case 10:
      enemies.add(new Enemy(tx, ty, 15000, 1, true));
      break;
    case 15:
      enemies.add(new Enemy(tx, ty, 24500, 1, true));
      break;
    case 20:
      enemies.add(new Enemy(tx, ty, 30000, 1, true));
      break;
    case 25:
      enemies.add(new Enemy(tx, ty, 45000, 1, true));
    }
    break;
  case 127: //del
    money+=1000000;
    break;
  case 84: //t
    if (!instaKill) {
      instaKill = true;
    } else {
      instaKill = false;
    }
    break;
  case 85: //u
    if (!turretTracking) {
      turretTracking = true;
    } else {
      turretTracking = false;
    }
    break;
  case 80: //p
    paused = !paused;
    break;
  case 69: //e
    if (!menu.active) menu.active(true);
    break;
  case 73: //i
    invincible = !invincible;
    break;
  }
}
public void keyReleased() {
  switch(keyCode) {
  case 87: //w
    if (activeKey != 83) player.velocityY=0;
    break;
  case 65: //a
    if (activeKey != 68) player.velocityX=0;
    break;
  case 83: //s
    if (activeKey != 87) player.velocityY=0;
    break;
  case 68: //d
    if (activeKey != 65) player.velocityX=0;
    break;
  case 69: //e
    if (menu.active) menu.active(false);
    break;
  }
}
public void mousePressed() {
  if (player.hidden) {
    if (respawn.active && money >= respawnCost) {
      player.hidden = false;
      player.hp = 100;
      money-=respawnCost;
      respawnCost*=2;
      respawn.setValue("Respawn? $"+(int)respawnCost);
    }
  } else {
    if (menu.active && mouseButton == LEFT) {
      menu.click = true;
    } else if (mouseButton == LEFT && player.readyToFire) {
      rays.add(new Ray(player.x, player.y, Direction.calcAngle(player.x, player.y, mouseX, mouseY), 10, player.damage));
      player.readyToFire = false;
      player.fireTimer.start();
    }
    if (mouseButton == RIGHT) {
      menu.active(true);
    }
  }
}
public void mouseReleased() {
  if (mouseButton == RIGHT) {
    menu.active(false);
  }
  if (mouseButton == LEFT && menu.active) {
    menu.click = false;
  }
}

class Button {
  PFont Gotham = createFont("./data/Gotham-Bold.otf", 40);
  float x,y,w,h,r,ts;
  public boolean active;
  String text,num;
  int textColor = 0xffffffff;
  int actColor = 0xff2C2F33;
  int defColor = 0xff23272A;
  Button(float x, float y, float w, float h, float r, String t, float ts, String num){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.r = r;
    this.text = t;
    this.ts = ts;
    this.num = num;
  }
  public void update(float tx, float ty){
    active = tx>x-w/2 && tx<x+w/2 && ty>y && ty<y+h;
  }
  public void display(){
    boolean t = this.active;
    if(t){
      fill(actColor);
    } else {
      fill(defColor);
    }
    noStroke();
    rect(x-w/2, y, w, h, r);
    fill(textColor);
    textAlign(CENTER,CENTER);
    textFont(Gotham, ts);
    text(text,x,y+h/2);
  }
  public void setValue(String num){
    this.text = num;
  }
  public void textColor(int text){
    this.textColor = text;
  }
  public void setColor(int t1, int t2){
    this.actColor = t1;
    this.defColor = t2;
  }
  public void setPos(float x, float y){
    this.x = x;
    this.y = y;
  }
}

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
  public void update(){
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
    fill(0xff434343);
    rect(x-w/2-3,(y+h/2)+2,x+w/2-(x-w/2)+6,17);
    fill(0xff2acb35);
    float temp = (x+w/2-(x-w/2))/(maxhp/hp);
    if((x+w/2-(x-w/2))/(maxhp/hp)+x-w/2 < x-w/2) temp = 0;
    rect(x-w/2,y+h/2+5,temp,11);
    if(shield > 0){
      fill(0xff434343);
      rect(x-w/2-3,(y+h/2)+20,x+w/2-(x-w/2)+6,17);
      fill(0xff33b1cc);
      float temp2 = (x+w/2-(x-w/2))/(maxshield/shield);
      if((x+w/2-(x-w/2))/(maxshield/shield)+x-w/2 < x-w/2) temp2 = 0;
      rect(x-w/2,y+h/2+23,temp2,11);
      fill(255);
      text(shield, x, y+h/2+32, 5);
    }
    fill(255);
    if(hp > 0) text(hp, x, y+h/2+14, 5);
  }
  public Boolean checkRay(Ray bullet){
    if(bullet.x>x-w/2 && bullet.x<x+w/2 && bullet.y>y-h/2 && bullet.y<y+h/2) 
      if(shield <= 0){
        if(!invincible) hp-=5;
      } else {
        if(!invincible) shield-=10;
      }
    return bullet.x>x-w/2 && bullet.x<x+w/2 && bullet.y>y-h/2 && bullet.y<y+h/2;
  }
  public boolean checkEnemy(Enemy bullet){
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

static class Direction {
  static public double calcAngle(float x0, float y0, float x1, float y1){
    double angle = Math.atan2(y1 - y0, x1 - x0); // theta angle
    return angle+Math.PI/2;
  }
}

class Enemy {
  float x,y,w,h,speed;
  float maxhp;
  float maxspeed;
  int hp;
  PImage img;
  Turret target;
  Boolean boss;
  Enemy(float x, float y, int hp, float speed, boolean boss){
    this.x = x;
    this.y = y;
    w = 50;
    h = 50;
    this.hp = hp;
    this.boss = boss;
    maxhp = hp;
    maxspeed = speed;
    this.speed = speed;
    try {
      img = loadImage("./data/enemy.png");
      if(boss) img = loadImage("./data/boss.png");
    } catch (NullPointerException e) {
      e.printStackTrace();
    }
  }
  public void update(Character player){
    if(hp < maxhp && !boss) speed=maxspeed/(maxhp/hp);
    double angle = Direction.calcAngle(x, y, width/2, height/2);
    if(target != null) angle = Direction.calcAngle(x, y, target.x, target.y);
    if(!player.hidden) angle = Direction.calcAngle(x, y, player.x, player.y);
    double scaleX = Math.sin(angle);
    double scaleY = -Math.cos(angle);
    x+=(speed*scaleX);
    y+=(speed*scaleY);
  }
  public void display(){
    textSize(10);
    imageMode(CENTER);
    image(img,x,y);
    fill(0xff434343);
    rect(x-w/2-3,(y+h/2)+2,x+w/2-(x-w/2)+6,17);
    fill(0xff2acb35);
    float temp = (x+w/2-(x-w/2))/(maxhp/hp);
    if((x+w/2-(x-w/2))/(maxhp/hp)+x-w/2 < x-w/2) temp = 0;
    rect(x-w/2,y+h/2+5,temp,11);
    fill(255);
    if(hp > 0) text(hp, x, y+h/2+14, 5);
  }
  public Boolean checkRay(Ray bullet){
    if(bullet.x>x-w/2 && bullet.x<x+w/2 && bullet.y>y-h/2 && bullet.y<y+h/2) hp-=bullet.dmg;
    return bullet.x>x-w/2 && bullet.x<x+w/2 && bullet.y>y-h/2 && bullet.y<y+h/2;
  }
  public Boolean checkTrap(Trap bullet){
    if(bullet.x>x-w/2 && bullet.x<x+w/2 && bullet.y>y-h/2 && bullet.y<y+h/2){
      hp-=bullet.dmg;
      bullet.hp-=50;
    }
    return bullet.x>x-w/2 && bullet.x<x+w/2 && bullet.y>y-h/2 && bullet.y<y+h/2;
  }
}

class Menu {
  Boolean active, click;
  String queue;
  float x,y;
  PImage menu;
  Button turretEasy;
  Button turretHard;
  Button turretMachine;
  Button turretShotgun;
  Button trap;
  Button wall;
  Menu(){
    turretEasy = new Button(x,y,80,50,15,"Turret\n$500",10,"test");
    turretHard = new Button(x,y,80,50,15,"Hardened\nTurret\n$1000",10,"test");
    turretShotgun = new Button(x,y,80,50,15,"Multishot\n$750",10,"test");
    turretMachine = new Button(x,y,80,50,15,"Machine Gun\n$750",10,"test");
    trap = new Button(x,y,80,50,15,"Spiked Trap\n$150",10,"test");
    wall = new Button(x,y,80,50,15,"Player Shield\n$1000",10,"test");
    active = false;
    click = false;
    queue = null;
    try {
      menu = loadImage("./data/menu/png");
    } catch (NullPointerException e) {
      e.printStackTrace();
    }
  }
  public void display(){
    if(queue != null) queue = null;
    if(active){
      turretEasy.setPos(x-45,y-85);
      turretHard.setPos(x+45,y-85);
      turretShotgun.setPos(x-45,y-25);
      turretMachine.setPos(x+45,y-25);
      trap.setPos(x+45,y+35);
      wall.setPos(x-45,y+35);
      imageMode(CENTER);
      image(menu,x,y);
      turretEasy.update(mouseX, mouseY);
      turretEasy.display();
      turretHard.update(mouseX, mouseY);
      turretHard.display();
      turretShotgun.update(mouseX, mouseY);
      turretShotgun.display();
      turretMachine.update(mouseX,mouseY);
      turretMachine.display();
      trap.update(mouseX,mouseY);
      trap.display();
      wall.update(mouseX,mouseY);
      wall.display();
      if(turretEasy.active && click) queue = "turretEasy";
      if(turretHard.active && click) queue = "turretHard";
      if(turretShotgun.active && click) queue = "turretShotgun";
      if(turretMachine.active && click) queue = "turretMachine";
      if(trap.active && click) queue = "trap";
      if(wall.active && click) queue = "shield";
      click = false;
    }
  }
  public void active(boolean active){
    this.active = active;
    x = mouseX;
    y = mouseY;
  }
}

class Ray {
  float x, y, speed;
  int dmg;
  PImage bullet;
  double angle;
  Boolean hidden;
  Boolean tracking;
  Boolean purge;
  Enemy tracked;
  Ray(float x, float y, double angle, float speed, int dmg){
    this.x = x;
    this.y = y;
    this.angle = angle;
    this.speed = speed;
    tracking = false;
    tracked = null;
    this.dmg = dmg;
    try {
      bullet = loadImage("./data/bullet.png");
      if(dmg <= 5) bullet = loadImage("./data/enemyBullet.png");
    } catch (NullPointerException e) {
      e.printStackTrace();
    }
    hidden = false;
    purge = false;
  }
  public void update(){
    if(tracking && tracked != null && tracked.hp != 0) angle = Direction.calcAngle(x, y, tracked.x+random(-10,10), tracked.y+random(-10,10));
    if(tracking && tracked != null && tracked.hp == 0) purge = true;
    if(tracking && tracked == null) purge = true;
    double scaleX = Math.sin(angle);
    double scaleY = -Math.cos(angle);
    x+=(speed*scaleX);
    y+=(speed*scaleY);
    if(!hidden) draw();
  }
  private void draw(){
    imageMode(CENTER);
    image(bullet,x,y);
  }
  public void track(Enemy target){
    tracked = target;
    tracking = true;
  }
}

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
  public void update(){
    imageMode(CENTER);
    image(img, x, y);
  }
}

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
    try {
      if (dmg == 50) turretimg = loadImage("./data/turret.png");
      if (dmg == 100) turretimg = loadImage("./data/turretHard.png");
      if (dmg == 25) turretimg = loadImage("./data/turretShotgun.png");
      if (dmg == 10) {
        fireTimer.totalTime = 150;
        turretimg = loadImage("./data/turretMachine.png");
      }
    } catch (NullPointerException e) {
      e.printStackTrace();
    }
  }
  public void update() {
    if (fireTimer.isFinished()) {
      ready = true;
    }
    if (!hidden) draw();
  }
  private void draw() {
    imageMode(CENTER);
    image(turretimg, x, y);
  }
  public boolean checkEnemy(Enemy enemy) {
    if (hp < 0) {
      return false;
    } else {
      textSize(10);
      fill(0xff434343);
      rect(x-w/2-3, (y+h/2)+2, x+w/2-(x-w/2)+6, 17);
      fill(0xff2acb35);
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
class Timer {
   
  int savedTime; // When Timer started
  int totalTime; // How long Timer should last

  Timer(int tempTotalTime) {
    totalTime = tempTotalTime;
  }

  // Starting the timer
  public void start() {
    // When the timer starts it stores the current time in milliseconds.
    savedTime = millis();
  }

  // The function isFinished() returns true if 5,000 ms have passed. 
  // The work of the timer is farmed out to this method.
  public boolean isFinished() { 
    // Check how much time has passed
    int passedTime = millis()- savedTime;
    if (passedTime > totalTime) {
      return true;
    } else {
      return false;
    }
  }
}
  public void settings() {  size(1000, 1000); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "TDGAME" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
