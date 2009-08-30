void setup() 
{ 
   size(600, 600);
   smooth();
   colorMode(HSB);
   noLoop();
} 

void draw()
{
   drawsquare(0, 0, width - 1, height - 1, int(random(255)), 255, 255, 300);
}

void drawsquare(int x, int y, int Width, int Height, int Red, int Green, int Blue, int level)
{
   stroke(Red, Green, Blue);
   
   rect(x, y, Width, Height);

   x += 1;
   y += 1;
   Width -= int(random(5));
   Height -= int(random(5));
   level--;

   
   Green = int(random(255));
   Blue = int(random(255));
   if(level > 1)
      drawsquare(x, y, Width, Height, Red, Green, Blue, level);
}
