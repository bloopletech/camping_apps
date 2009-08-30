public class ImageScroller
{
   public static final int SCROLLBAR_WIDTH = 13;
   PImage image2 = null;
   int x = 0, y = 0;
   int width2 = 0, height2 = 0;
   int thumbPos = 0;
   int imageY = 0;
   int changeInterval = 0;
   int thumbChangeInterval = 0;

   public ImageScroller(PImage inImage, int inX, int inY, int inWidth, int inHeight)
   {
      image2 = inImage;
      x = inX;
      y = inY;
      width2 = inWidth;
      height2 = inHeight;
      changeInterval = round((image2.height * 1.0) / height2);
      thumbChangeInterval = round((image2.height * 1.0) / (height2 + (SCROLLBAR_WIDTH * 2)));
      //println("Ci: " + changeInterval + ", TcI: " + thumbChangeInterval);
   }


   public void drawImage()
   {
      noFill();
      rect(x, y, width2 - 1, height2 - 1);


      PImage temp = image2.get(0, imageY, image2.width, height2 - 2);
      image(temp, x + 1, y + 1);

      PImage scrollTop = loadImage("ImageScroller/scrolltop.gif");
      image(scrollTop, x + width2 - 13, y);

      fill(200);
      rect(x + (width2 - 13), y + 12, 12, height2 - 25);

      fill(255);
      //rect(x + width2 - 12, y + thumbPos + 12, 10, 10);
      noFill();

      scrollTop = loadImage("ImageScroller/scrollbottom.gif");
      image(scrollTop, x + width2 - 13, y + height2 - 13);
   }

   public boolean mouseReleased(int mouseX, int mouseY)
   {
      if(between(mouseX, x + width2 - 14, x + width2 - 1) && between(mouseY, y, y + 14))
      {
         if(imageY > 0)
         {
            imageY -= changeInterval;
            thumbPos -= thumbChangeInterval;
                  //println("imageY: " + imageY);
         }
         return true;
      }
      else if(between(mouseX, x + width2 - 14, x + width2 - 1) && between(mouseY, y + height2 - 14, y + height2 - 1))
      {
         if(imageY <= (image2.height - height2))
         {
            imageY += changeInterval;
            thumbPos += thumbChangeInterval;
                  //println("imageY: " + imageY + ", thumbChangeInterval: " + thumbChangeInterval);
         }
         return true;
      }
            //println("imageY: " + imageY);
      return false;
   }
   
   /*public boolean mouseDragged(int mouseX, int mouseY)
   {
      */

   public boolean between(int a, int x, int y)
   {
      return (a >= x && a <= y);
   }
}
      
