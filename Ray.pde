class Ray {
  float x, y, speed; //<>//
  int dmg, teslaCount; //<>//
  PImage bullet; //<>//
  double angle; //<>//
  Boolean hidden; //<>//
  Boolean tracking; //<>//
  Boolean purge, noDmg; //<>//
  String type; //<>//
  Enemy tracked; //<>//
  Ray(float x, float y, double angle, float speed, int dmg, String type){
    noDmg = false;
    teslaCount = 0;
    this.type = type;
    this.x = x;
    this.y = y;
    this.angle = angle;
    this.speed = speed;
    tracking = false;
    tracked = null;
    this.dmg = dmg;
    if(type.equals("normal") || type.equals("player")) bullet = loadImage("./data/bullet.png");
    if(type.equals("tesla")){
      bullet = loadImage("./data/teslaRay.png");
      bullet.resize(20,20);d
    }
    if(type.equals("boss")) bullet = loadImage("./data/enemyBullet.png");
    hidden = false;
    purge = false;
  }
  void update(){
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
  void newTarget(float x, float y){
    angle = Direction.calcAngle(this.x, this.y, x, y);
  }
  void track(Enemy target){
    tracked = target;
    tracking = true;
  }
}
