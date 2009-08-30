void setup() 
{ 
   size(300, 300);
   smooth();
   noLoop();
   colorMode(HSB);
   background(172, 0, 255);
   //line2(100, 100, 60, 0);
   //line2(100, 100, 60, 10);
   //line2(100, 100, 60, 20);
   //line2(100, 100, 60, 30);
   //line2(100, 100, 60, 40);
   
} 

void draw()
{
   drawtree(width / 2, height - 1, 0, 75, 120, 50, 50, 15, 8);
}

void drawtree(int x, int y, int angle, int distance, int Hue, int sat, int bright, int strokeWidth,  int level)
{
   strokeWeight(strokeWidth);
   if(strokeWidth > 1)
   {
      strokeWidth = ((strokeWidth - 4) >= 1) ? strokeWidth - 4 : 1;
   }

   stroke(Hue, sat, bright);
   sat += 10;
   bright += 10;

   int[] temp = line2(x, y, distance, angle);
   x = temp[0];
   y = temp[1];
   
   if(level > 1)
   {
      level--;
      drawtree(x, y, angle - 15, int(distance * 0.75), Hue, sat, bright, strokeWidth, level);
      drawtree(x, y, angle - 25, int(distance * 0.75), Hue, sat, bright, ((strokeWidth - 2) >= 1) ? strokeWidth - 2 : 1, level);
      drawtree(x, y, angle + 5, int(distance * 0.75), Hue, sat, bright, strokeWidth, level);
      drawtree(x, y, angle + 25, int(distance * 0.75), Hue, sat, bright, ((strokeWidth - 2) >= 1) ? strokeWidth - 2 : 1, level);
   }
}

int[] line2(int x, int y, int distance, int angle)
{
   angle -= 90;
   int[] output = { x + int(cos(radians(angle)) * distance), y + int(sin(radians(angle)) * distance)};
   //println("x: " + x + " y: " + y + " distance: " + distance + " angle: " + angle + " cos: " + cos(radians(angle)) + " sin: " + cos(radians(angle)));
   line(x, y, output[0], output[1]);
   return output;
}
