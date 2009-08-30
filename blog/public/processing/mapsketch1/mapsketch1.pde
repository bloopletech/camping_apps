int xTop = 0, yTop = 0;
float zoomFactor = 1;
String[] data = null;
boolean showCo = false;
boolean showSym = true;
boolean showLine = false;

ImageScroller sc = null;


void setup()
{ 
   size(1000, 700);
   //smooth();
   noLoop();
   colorMode(RGB);

   background(255, 255, 255);
   stroke(0, 0, 0);
   fill(0, 0, 0);

   data = loadStrings("data.txt");
}

void draw()
{
   background(255, 255, 255);

   
   PImage im = loadImage("key.gif");
   sc = (sc == null ? new ImageScroller(im, width - (160 + ImageScroller.SCROLLBAR_WIDTH), height - 210, (150 + ImageScroller.SCROLLBAR_WIDTH), 200) : sc);

   int x = xTop + 400, y = yTop + 400;
   String t = null;
   PFont font = loadFont("ArialMT-11.vlw");
   textFont(font);
   
   /*int red2 = 0, green2 = 0, blue2 = 0, angleFromPath = 0, distanceFromPath = 0;*/
   int i = 1;
   /*for(; i < data.length; i++)
   {
      if(data[i].charAt(0) == 'l')
      {
         String[] line = split(data[i], ",");
         //line[0] is 'l'
         red2 = int(line[1]);
         green2 = int(line[2]);
         blue2 = int([3]);
         angleFromPath = int(tokens[4]);
         distanceFromPath = int(tokens[5]);
         showLine = true;
      }
      break;
   }*/
         
   
   

   int red2 = 0, green2 = 0, blue2 = 0;
   for(; i < (data.length); i++)
   {
      String[] line = split(data[i], ",");

      if(line[0].charAt(0) == 's')
      {
         red2 = int(line[1]);
         green2 = int(line[2]);
         blue2 = int(line[3]);
         x = xTop + 400;
         y = yTop + 400;
         int temp[] = linecalc(x, y, int(int(line[5]) * zoomFactor), int(line[4]));
         x = temp[0];
         y = temp[1];
      }
      stroke(red2, green2, blue2);
         
      
      
      float positionDistance = float(line[4]);
      String position = line[3];
      String icon = line[2];
      float distance = 0;

      String distanceT = line[1];
      String[] tempTokens = split(distanceT, "+");
      if(tempTokens.length > 1)
      {
         distance = float(tempTokens[0]) + float(tempTokens[1]);
      }
      else
      {
         distance = float(tempTokens[0]);
      }

      float angle = float(line[0]);
      int linecoord[] = {-1, -1};
 
      int[] temp = line2(x, y, (int)(distance * zoomFactor), (int)(angle));

      if(showSym && icon.length() > 1)
      {
         String[] tokens = split(icon, ";");
         int[] t2 = {x , y};

         for(int j = 0; j < tokens.length; j++)
         {
            String filename = tokens[j];
            if(filename.length() > 1)
            {
               im = loadImage(filename + ".gif");
               
               if(position.equals("l"))
               {
                  float a2 = angle - 90;
                  if(a2 < 0) a2 += 360;
                  t2 = linecalc(t2[0], t2[1], int(15 * zoomFactor), int(a2));
               }
               else if(position.equals("r"))
               {
                  float a2 = angle + 90;
                  if(a2 > 359) a2 -= 360;
                  t2 = linecalc(t2[0], t2[1], int(15 * zoomFactor), int(a2));
               }
               else if(position.equals("b"))
               {
                  t2 = linecalc(t2[0], t2[1], int(15 * zoomFactor), int(angle));
               }
               else
               {
                  float a2 = float(position);
                  //println(icon + ", " + a2);
                  t2 = linecalc(t2[0], t2[1], int(positionDistance * zoomFactor), int(a2));
               }
               image(im, t2[0] - 8, t2[1] - 8);
               if(angle <= 90)
               {
                  t2[0] = x;
                  t2[1] -= 16;
               }
               else if(angle >= 270)
               {
                  t2[0] = x;
                  t2[1] += 16;
               }
               else if(angle > 90)
               {
                  t2[0] -= 16;
                  t2[1] = y;
               }
               else
               {
                  t2[0] += 16;
                  t2[1] = y;
               }
            }
         }
      }
      stroke(0, 0, 0);
      fill(0, 0, 0);
      
      if(showCo)
      {
         /*int[] t2 = new int[2];*/
         t = round(distance) + ", " + round(angle);

         /*println("Printing Coordinate: " + t);

         float a2 = angle - 90;
         if(angle < 0) angle += 180;
         t2 = linecalc(x, y, -25, int(a2));

         translate(width, height);
         rotate(radians(a2));
         println("Rotated 180");*/

         text(t, x - (t.length() * 7), y);

         /*rotate(radians(-a2));
         println("Rotated -180");*/
      }

      
      /*if(showLine)
      {
         stroke(red2, green2, blue2);
         println("distancefromPath: " + distanceFromPath);
         if(linecoord[0] == -1) linecoord = linecalc(x, y, int(distance/* + (distance / distanceFromPath)*//*), int(angle));
         linecoord = line2(x, y, distanceFromPath, int(angle + angleFromPath));
         linecoord = line2(linecoord[0], linecoord[1], int(distance/* + (distance / distanceFromPath)*//*), int(angle));
         stroke(0, 0, 0);
      }*/

      x = temp[0];
      y = temp[1];
   }

   sc.drawImage();
   im = loadImage("show.gif");
   image(im, 100, height - 40);
   im = loadImage("scale.gif");
   image(im, 400, height - 70);
   im = loadImage("zoom.gif");
   image(im, width - 108, height - 260);
   im = loadImage("north.gif");
   image(im, width - 40, 100);

   t = data[0];
   text(t, width - (t.length() * 7), 20);
}














void mouseReleased()
{
   if(sc.mouseReleased(mouseX, mouseY))
   {
      redraw();
      return;
   }
   if(mouseX < 20)
   {
      xTop += 60;
      redraw();
   }
   else if(mouseX > (width - 20))
   {
      xTop -= 60;
      redraw();
   }

   if(mouseY < 20)
   {
      yTop += 60;
      redraw();
   }
   else if(mouseY > (height - 20))
   {
      yTop-= 60;
      redraw();
   }

   if(between(mouseX, 100, 251) && between(mouseY, height - 40, height - 19))
   {
      showCo = !showCo;
      redraw();
   }
   else if(between(mouseX, 252, 399) && between(mouseY, height - 40, height - 19))
   {
      showSym = !showSym;
   }

   if(between(mouseX, width - 108, width - 65) && between(mouseY, height - 260, height - 219))
   {
      zoomFactor += 0.1;

   }
   else if(between(mouseX, width - 66, width - 19) && between(mouseY, height - 260, height - 219))
   {
      zoomFactor -= 0.1;
   }
   redraw();
}


public boolean between(int a, int x, int y)
{
   return (a >= x && a <= y);
}
















int[] line2(int x, int y, int distance, int angle)
{
   angle -= 90;

   int[] output = { x + int(cos(radians(angle)) * distance), y + int(sin(radians(angle)) * distance)};
   line(x, y, output[0], output[1]);
   return output;
}

int[] linecalc(int x, int y, int distance, int angle)
{
   angle -= 90;

   int[] output = { x + int(cos(radians(angle)) * distance), y + int(sin(radians(angle)) * distance)};
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

boolean similar(int a, int b, int c, int x, int y, int z)
{
   if(max(a, x) - min(a, x) <= 70) return true;
   if(max(b, y) - min(b, y) <= 70) return true;
   if(max(c, z) - min(c, z) <= 70) return true;
   return false;
}
