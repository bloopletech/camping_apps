public class Colour
{
   private int Hue = 0, sat = 0, bright = 0;
   public Colour(int inHue, int inSat, int inBright)
   {
      Hue = inHue;
      sat = inSat;
      bright = inBright;
   }
   public int getHue()
   {
      return Hue;
   }
   public int getSat()
   {
      return sat;
   }
   public int getBright()
   {
      return bright;
   }
}
      
