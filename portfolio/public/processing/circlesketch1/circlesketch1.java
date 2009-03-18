
int randColor = 0;
void setup()
{ 
   size(200, 200);
   smooth();
   ellipseMode(CORNER);
   colorMode(HSB);
   randColor = int(random(255));
}

void draw()
{
   background(randColor, 255, 255);
   //drawsquare(-(width / 4), -(height / 4), width + (width / 4) - 1, height + (height / 4) - 1, randColor, 255, 255, 300);
   drawsquare(0, 0, width - 1, height - 1, randColor, 255, 255, (width / 2) + 1);
   randColor -= 1;
}


void drawsquare(int x, int y, int Width, int Height, int Hue, int sat, int bright, int level)
{
   stroke(Hue, sat, bright);
   
   ellipse(x, y, Width, Height);

   x += 1;
   y += 1;
   Width -= 2;
   Height -= 2;
   level--;

   if(bright > 0) bright--;
   else
   {
      sat--;
      bright = 255;
   }
   if(level > 1)
      drawsquare(x, y, Width, Height, Hue, bright, sat, level);
}
