class Menu {
  Boolean active, click;
  int page,maxpage;
  String queue;
  float x,y;
  PImage menu;
  Button turretEasy;
  Button turretHard;
  Button turretMachine;
  Button turretShotgun;
  Button trap;
  Button wall;
  Button tesla;
  Button laser;
  Button bomb;
  Button back;
  Button next;
  Menu(){
    page = 1;
    maxpage = 2;
    turretEasy = new Button(x,y,80,50,15,"Turret\n$500",10);
    turretHard = new Button(x,y,80,50,15,"Hardened\nTurret\n$1000",10);
    turretShotgun = new Button(x,y,80,50,15,"Multishot\n$750",10);
    turretMachine = new Button(x,y,80,50,15,"Machine Gun\n$750",10);
    trap = new Button(x,y,80,50,15,"Spiked Trap\n$150",10);
    wall = new Button(x,y,80,50,15,"Player Shield\n$1000",10);
    tesla = new Button(x,y,80,50,15,"Tesla\n$1000",10);
    laser = new Button(x,y,80,50,15,"Laser\n$2500",10);
    bomb = new Button(x,y,80,50,15,"Bomb\n$2000",10);
    back = new Button(x,y,50,30,15,"<",10);
    next = new Button(x,y,50,30,15,">",10);
    active = false;
    click = false;
    queue = null;
    menu = loadImage("./data/menu.png");
  }
  void display(){
    if(active){
      back.setPos(x-45,y+105);
      next.setPos(x+45,y+105);
      back.update(mouseX,mouseY);
      next.update(mouseX,mouseY);
      next.display();
      back.display();
      if(next.active && click && page < maxpage) page+=1;
      if(back.active && click && page > 1) page-=1;
    }
    if(active && page == 1){
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
    }
    if(active && page == 2){
      tesla.setPos(x-45,y-85);
      laser.setPos(x+45,y-85);
      bomb.setPos(x-45,y-25);
      imageMode(CENTER);
      image(menu,x,y);
      tesla.update(mouseX, mouseY);
      tesla.display();
      laser.update(mouseX, mouseY);
      laser.display();
      bomb.update(mouseX, mouseY);
      bomb.display();
      if(tesla.active && click) queue = "tesla";
      if(laser.active && click) queue = "laser";
      if(bomb.active && click) queue = "bomb";
    
    }
    if(active) click = false;
  }
  void active(boolean active){
    this.active = active;
    x = mouseX;
    y = mouseY-120;
  }
}
