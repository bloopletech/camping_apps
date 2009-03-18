int POINTCOUNT = 100;
int yPoints[] = new int[POINTCOUNT];
int xPoints[] = new int[POINTCOUNT];
int direcPoints[] = new int[POINTCOUNT];

void setup() 
{ 
   size(300, 300);
   smooth();
   colorMode(RGB);
   background(0, 0, 0);
   stroke(255, 255, 255);
   for(int i = 0; i < POINTCOUNT; i++)
   {
      int angle = randint(361);
      int xy[] = point2(width / 2, height / 2, randint(150), angle);
      xPoints[i] = xy[0];
      yPoints[i] = xy[1];
      direcPoints[i] = angle;
   }
} 



void draw()
{
   background(0, 0, 0);
   for(int i = 0; i < POINTCOUNT; i++)
   {
      int xy[] = point2(xPoints[i], yPoints[i], 4, direcPoints[i]);
      xPoints[i] = xy[0];
      yPoints[i] = xy[1];

      if(xPoints[i] < 0 || xPoints[i] >= width || yPoints[i] < 0 || yPoints[i] >= width)
      {
         int angle = randint(361);
         xy = point2(width / 2, height / 2, randint(150), angle);
         xPoints[i] = xy[0];
         yPoints[i] = xy[1];
         direcPoints[i] = angle;
      }
   }

   stroke(0, 0, 0);
   fill(0, 0, 0);
   ellipseMode(CORNERS);
   ellipse((width / 2) - 25, (height / 2) - 25, (width / 2) + 25, (height / 2) + 25);

   stroke(255, 255, 255);
   delay(20);
}

int[] line2(int x, int y, int distance, int angle)
{
   angle -= 90;

   int[] output = { x + int(cos(radians(angle)) * distance), y + int(sin(radians(angle)) * distance)};

   //println("x: " + x + " y: " + y + " distance: " + distance + " angle: " + angle + " cos: " + cos(radians(angle)) + " sin: " + cos(radians(angle)));

   line(x, y, output[0], output[1]);
   return output;
}

int[] point2(int x, int y, int distance, int angle)
{
   angle -= 90;

   int[] output = { x + int(cos(radians(angle)) * distance), y + int(sin(radians(angle)) * distance)};

   //println("x: " + x + " y: " + y + " distance: " + distance + " angle: " + angle + " cos: " + cos(radians(angle)) + " sin: " + cos(radians(angle)));

   point(x, y);
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
