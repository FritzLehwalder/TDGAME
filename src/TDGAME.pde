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
void setup() {
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
  background = loadImage("./data/background2.png");
  curs = loadImage("./data/cursor.png");
  cursMenu = loadImage("./data/cursurMenu.png");
  player = new Character(width/2, height/2, 4);
  size(1000, 1000);
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
void draw() {
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
void keyPressed() {
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
void keyReleased() {
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
void mousePressed() {
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
void mouseReleased() {
  if (mouseButton == RIGHT) {
    menu.active(false);
  }
  if (mouseButton == LEFT && menu.active) {
    menu.click = false;
  }
}
