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
    menu = loadImage("./data/menu.png");
  }
  void display(){
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
  void active(boolean active){
    this.active = active;
    x = mouseX;
    y = mouseY;
  }
}
