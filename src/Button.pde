class Button {
  PFont Gotham = createFont("./data/Gotham-Bold.otf", 40);
  float x,y,w,h,r,ts;
  public boolean active;
  String text,num;
  color textColor = #ffffff;
  color actColor = #2C2F33;
  color defColor = #23272A;
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
  void update(float tx, float ty){
    active = tx>x-w/2 && tx<x+w/2 && ty>y && ty<y+h;
  }
  void display(){
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
  void setValue(String num){
    this.text = num;
  }
  void textColor(color text){
    this.textColor = text;
  }
  void setColor(color t1, color t2){
    this.actColor = t1;
    this.defColor = t2;
  }
  void setPos(float x, float y){
    this.x = x;
    this.y = y;
  }
}
