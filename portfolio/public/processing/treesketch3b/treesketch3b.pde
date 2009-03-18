void setup() 
{ 
   size(600, 600);
   smooth();
   noLoop();
   colorMode(HSB);
   background(randint(256), randint(256), randint(256));
}

void mouseReleased()
{
   background(randint(256), randint(256), randint(256));
   redraw();
}

void draw()
{
   int original = randint(361);
   int sec = randint(361);
   int third = randint(361);
   int fourth = randint(361);

   while(similar(original, sec, third, fourth))
   {
      original = randint(361);
      sec = randint(361);
      third = randint(361);
      fourth = randint(361);
   }

   drawtree(randint(0, width - 2), randint(0, height - 2), original, 0, randint(256), randint(256), randint(50, 256), 10, 0);
   drawtree(randint(0, width - 2), randint(0, height - 2), sec, 0, randint(256), randint(256), randint(50, 256), 10, 0);
   drawtree(randint(0, width - 2), randint(0, height - 2), third, 0, randint(256), randint(256), randint(50, 256), 10, 0);
   drawtree(randint(0, width - 2), randint(0, height - 2), fourth, 0, randint(256), randint(256), randint(50, 256), 10, 0);
}

void drawtree(int x, int y, int angle, int distance, int Hue, int sat, int bright, int level, int cumulativeDistance)
{
   stroke(Hue, sat, bright);

   int type = randint(2);
   if(type == 1)
      sat += int(choose(random(15, 46), -(random(15, 46))));
   else
      bright += int(choose(random(15, 46), -(random(15, 46))));

   int[] temp = line2(x, y, distance, angle);
   x = temp[0];
   y = temp[1];
   
   distance = randint(15, 50);

   cumulativeDistance += distance;

   if(x < 0) x = 0;
   if(y < 0) y = 0;
   
   if(level > 1 || cumulativeDistance <= 250)
   {
      level--;

      type = randint(6);
      if(type == 0)
      {
         drawtree(x, y, angle + 25, distance, Hue, sat, bright, level, cumulativeDistance);
         drawtree(x, y, angle - 25, distance, Hue, sat, bright, level, cumulativeDistance);
      }
      else if(randint(12) == 0)
      {
         drawtree(x, y, angle + (randint(20, 35)), distance, Hue, sat, bright, level, cumulativeDistance);
         drawtree(x, y, angle + int(choose(random(20), -(random(20)))), distance, Hue, sat, bright, level, cumulativeDistance);
         drawtree(x, y, angle - (randint(20, 35)), distance, Hue, sat, bright, level, cumulativeDistance);
      }
      else
      {
         angle += int(choose(    random(5, 51)    ,     -(random(5, 51))    ));
         drawtree(x, y, angle, distance, Hue, sat, bright, level, cumulativeDistance);
      }
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

float choose(float a, float b)
{
   int choice = randint(2);
   return (choice == 1 ? a : b);
}

int randint(int maximum)
{
   return int(random(maximum));
}
int randint(int minimum, int maximum)
{
   return int(random(minimum, maximum + 1));
}


boolean similar(int a, int b, int c, int d)
{
   int temps[] = {a, b, c, d};
   java.util.Arrays.sort(temps);
   if((temps[1] - temps[0]) < 35) return false;
   if((temps[2] - temps[1]) < 35) return false;
   if((temps[3] - temps[2]) < 35) return false;
   return true;
}
