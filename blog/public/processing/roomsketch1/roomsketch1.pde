int yPoints[] = new int[200];
int xPoints[] = new int[200];
int direcPoints[] = new int[200];

int redPoints[] = new int[200];
int greenPoints[] = new int[200];
int bluePoints[] = new int[200];

void setup() 
{ 
   size(600, 600);
   smooth();
   colorMode(RGB);
   background(0, 0, 0);
   stroke(255, 255, 255);
   for(int i = 0; i < 200; i++)
   {
      xPoints[i] = randint(width);
      yPoints[i] = randint(height);
      direcPoints[i] = randint(361);

      redPoints[i] = randint(256);
      greenPoints[i] = randint(256);
      bluePoints[i] = randint(256);
   }
} 



void draw()
{
   background(0, 0, 0);
   for(int i = 0; i < 200; i++)
   {
      stroke(redPoints[i], greenPoints[i], bluePoints[i]);

      int xy[] = point2(xPoints[i], yPoints[i], 2, direcPoints[i]);
      xPoints[i] = xy[0];
      yPoints[i] = xy[1];

      if(xPoints[i] <= 0 || xPoints[i] >= width)
      {
         direcPoints[i] = 360 - direcPoints[i];
         if(direcPoints[i] < 0) direcPoints[i] = 360 - direcPoints[i];
         if(direcPoints[i] > 359) direcPoints[i] = direcPoints[i] - 360;
      }
      else if(yPoints[i] <= 0 || yPoints[i] >= height)
      {
         direcPoints[i] = 180 - direcPoints[i];
         if(direcPoints[i] < 0) direcPoints[i] = 180 - direcPoints[i];
         if(direcPoints[i] > 359) direcPoints[i] = direcPoints[i] - 180;
      }
   }
   //delay(50);
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
