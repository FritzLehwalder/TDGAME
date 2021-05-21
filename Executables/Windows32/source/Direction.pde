import java.lang.Math;
static class Direction {
  static public double calcAngle(float x0, float y0, float x1, float y1){
    double angle = Math.atan2(y1 - y0, x1 - x0); // theta angle
    return angle+Math.PI/2;
  }
}
