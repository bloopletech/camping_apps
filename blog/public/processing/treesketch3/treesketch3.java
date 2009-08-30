import processing.core.*; import java.applet.*; import java.awt.*; import java.awt.image.*; import java.awt.event.*; import java.io.*; import java.net.*; import java.text.*; import java.util.*; import java.util.zip.*; public class treesketch3 extends PApplet {public void setup() 
{ 
   size(600, 600);
   smooth();
   noLoop();
   colorMode(HSB);
   background(randint(256), randint(256), randint(256));
}

public void mouseReleased()
{
   background(randint(256), randint(256), randint(256));
   redraw();
}

public void draw()
{
   int count = randint(3, 6);
   int[] angles = new int[count];
   for(int i = 0; i < angles.length; i++) angles[i] = randint(360);

   while(similar(angles))
   {
      for(int i = 0; i < angles.length; i++) angles[i] = randint(360);
   }

   for(int i = 0; i < angles.length; i++)
      drawtree(width / 2, height / 2, angles[i], randint(15, 51), randint(256), randint(256), randint(50, 256), 8, 0);
}

public void drawtree(int x, int y, int angle, int distance, int Hue, int sat, int bright, int level, int cumulativeDistance)
{
   stroke(Hue, sat, bright);

   int type = randint(2);
   if(type == 1)
      sat += PApplet.toInt(choose(random(15, 46), -(random(15, 46))));
   else
      bright += PApplet.toInt(choose(random(15, 46), -(random(15, 46))));

   int[] temp = line2(x, y, distance, angle);
   x = temp[0];
   y = temp[1];
   
   distance = randint(15, 51);

   cumulativeDistance += distance;

   if(x < 0) x = 0;
   if(y < 0) y = 0;
   
   if(level > 1 && cumulativeDistance <= 265)
   {
      level--;

      type = randint(6);
      if(type == 0)
      {
         drawtree(x, y, angle + 25, distance, Hue, sat, bright, level, cumulativeDistance);
         drawtree(x, y, angle - 25, distance, Hue, sat, bright, level, cumulativeDistance);
      }
      else if(randint(15) == 0)
      {
         drawtree(x, y, angle + (randint(20, 35)), distance, Hue, sat, bright, level, cumulativeDistance);
         drawtree(x, y, angle + PApplet.toInt(choose(random(20), -(random(20)))), distance, Hue, sat, bright, level, cumulativeDistance);
         drawtree(x, y, angle - (randint(20, 35)), distance, Hue, sat, bright, level, cumulativeDistance);
      }
      else
      {
         angle += PApplet.toInt(choose(    random(5, 51)    ,     -(random(5, 51))    ));
         drawtree(x, y, angle, distance, Hue, sat, bright, level, cumulativeDistance);
      }
   }
}

public int[] line2(int x, int y, int distance, int angle)
{
   angle -= 90;

   int[] output = { x + PApplet.toInt(cos(radians(angle)) * distance), y + PApplet.toInt(sin(radians(angle)) * distance)};

   //println("x: " + x + " y: " + y + " distance: " + distance + " angle: " + angle + " cos: " + cos(radians(angle)) + " sin: " + cos(radians(angle)));

   line(x, y, output[0], output[1]);
   return output;
}

public float choose(float a, float b)
{
   int choice = randint(2);
   return (choice == 1 ? a : b);
}

public int randint(int maximum)
{
   return PApplet.toInt(random(maximum));
}
public int randint(int minimum, int maximum)
{
   return PApplet.toInt(random(minimum, maximum));
}

public boolean similar(int[] input)
{
   int temps[] = new int[input.length];
   System.arraycopy(input, 0, temps, 0, input.length);
   java.util.Arrays.sort(temps);
   for(int i = 1; i < temps.length; i++)
   {
      if((temps[i] - temps[i - 1]) < (260 / temps.length)) return false;
   }
   return true;
}
static public void main(String args[]) {   PApplet.main(new String[] { "treesketch3" });}}