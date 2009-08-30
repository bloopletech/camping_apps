Colour colours[] = new Colour[16];
void setup() 
{ 
   size(600, 600);
   noLoop();
   colorMode(RGB);
   rectMode(CORNER);
   docolour(new Colour(randint(256), randint(256), randint(256)));
}

void mouseReleased()
{
   if(mouseButton == LEFT)
   {
      int x = 0, y = 0;
      if(mouseX < 150)
      {
         x = 0;
      }
      else if(mouseX < 300)
      {
         x = 1;
      }
      else if(mouseX < 450)
      {
         x = 2;
      }
      else
      {
         x = 3;
      }
      if(mouseY < 150)
      {
         y = 0;
      }
      else if(mouseY < 300)
      {
         y = 4;
      }
      else if(mouseY < 450)
      {
         y = 8;
      }
      else
      {
         y = 12;
      }
      docolour(colours[x + y]);
   }
   else
   {
      docolour(new Colour(randint(256), randint(256), randint(256)));
   }
   redraw();
}

void draw()
{
   int square = width / 4;
   int x = 0, y = 0;
   int k = 0;
   for(int i = 0; i < 4; i++)
   {
      for(int j = 0; j < 4; j++)
      {
         Colour colour = colours[k];
         fill(colour.getHue(), colour.getSat(), colour.getSat());
         stroke(colour.getHue(), colour.getSat(), colour.getSat());
         rect(x, y, square, square);
         x += square;
         k++;
      }
      y += square;
      x = 0;
   }
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
   return int(random(minimum, maximum));
}

void docolour(Colour colour)
{
   colours[0] = colour;
   int red1 = colour.getHue();
   int green1 = colour.getSat();
   int blue1 = colour.getBright();
   int fixedColour = randint(3);
   for(int i = 1; i < colours.length; i++)
   {
      if(fixedColour == 0)
      {
         //green1 += int(choose(random(0, 80), -(random(0, 80))));
         //blue1 += int(choose(random(0, 80), -(random(0, 80))));
         green1 = randint(256);
         blue1 = randint(256);
      }
      else if(fixedColour == 1)
      {
         //red1 += int(choose(random(0, 80), -(random(0, 80))));
         //blue1 += int(choose(random(0, 80), -(random(0, 80))));
         red1 = randint(256);
         blue1 = randint(256);
      }
      else
      {
         //red1 += int(choose(random(0, 80), -(random(0, 80))));
         //green1 += int(choose(random(0, 80), -(random(0, 80))));
         red1 = randint(256);
         green1 = randint(256);
      }
      /*int type = randint(3);
      if(type == 1)
         sat = int(choose(random(10, 60), -(random(10, 60))));
      else if(type == 2)
         bright = int(choose(random(10, 60), -(random(10, 60))));
      else
      {
         sat = int(choose(random(10, 60), -(random(10, 60))));
         bright = int(choose(random(10, 60), -(random(10, 60))));
      }*/
      colours[i] = new Colour(red1, green1, blue1);
      /*sat = colour.getSat();
      bright = colour.getBright();*/
   }
}
  
