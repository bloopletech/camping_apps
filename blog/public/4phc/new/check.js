//Script copyright (c) 2005 BR Fletcher & R Williams
//BUILD 7/19/2005 12:54PM
function checkRanges(chord1, chord2)
{
   //alert(chord1.s + ", " + chord1.a + ", " + chord1.t + ", " + chord1.b);
   var output = "";
   if(chord1.s > 79)
   {
      output = output + "In the soprano part for chord 1, you wrote a note that is too high for the soprano voice to sing.\n";
   }
   if(chord1.s < 60)
   {
      output = output + "In the soprano part for chord 1, you wrote a note that is too low for the soprano voice to sing.\n";
   }
   if(chord1.a > 74)
   {
      output = output + "In the alto part for chord 1, you wrote a note that is too high for the alto voice to sing.\n";
   }
   if(chord1.a < 55)
   {
      output = output + "In the alto part for chord 1, you wrote a note that is too low for the alto voice to sing.\n";
   }
   if(chord1.t > 67)
   {
      output = output + "In the tenor part for chord 1, you wrote a note that is too high for the tenor voice to sing.\n";
   }
   if(chord1.t < 36)
   {
      output = output + "In the tenor part for chord 1, you wrote a note that is too low for the tenor voice to sing.\n";
   }
   if(chord1.b > 62)
   {
      output = output + "In the bass part for chord 1, you wrote a note that is too high for the bass voice to sing.\n";
   }
   if(chord1.b < 29)
   {
      output = output + "In the bass part for chord 1, you wrote a note that is too low for the bass voice to sing.\n";
   }






   if(chord2.s > 79)
   {
      output = output + "In the soprano part for chord 2, you wrote a note that is too high for the soprano voice to sing.\n";
   }
   if(chord2.s < 60)
   {
      output = output + "In the soprano part for chord 2, you wrote a note that is too low for the soprano voice to sing.\n";
   }
   if(chord2.a > 74)
   {
      output = output + "In the alto part for chord 2, you wrote a note that is too high for the alto voice to sing.\n";
   }
   if(chord2.a < 55)
   {
      output = output + "In the alto part for chord 2, you wrote a note that is too low for the alto voice to sing.\n";
   }
   if(chord2.t > 67)
   {
      output = output + "In the tenor part for chord 2, you wrote a note that is too high for the tenor voice to sing.\n";
   }
   if(chord2.t < 36)
   {
      output = output + "In the tenor part for chord 2, you wrote a note that is too low for the tenor voice to sing.\n";
   }
   if(chord2.b > 62)
   {
      output = output + "In the bass part for chord 2, you wrote a note that is too high for the bass voice to sing.\n";
   }
   if(chord2.b < 29)
   {
      output = output + "In the bass part for chord 2, you wrote a note that is too low for the bass voice to sing.\n";
   }

   return output;
}

function checkFifthsOctaves(chord1, chord2)
{
   var output = "";

   var s1 = chord1.s, a1 = chord1.a, t1 = chord1.t, b1 = chord1.b;
   var s2 = chord2.s, a2 = chord2.a, t2 = chord2.t, b2 = chord2.b;

   while((s1 - a1) > 7) { a1 += 12; }
   while((s2 - a2) > 7) { a2 += 12; }
   while((s1 - t1) > 7) { t1 += 12; }
   while((s2 - t2) > 7) { t2 += 12; }
   while((s1 - b1) > 7) { b1 += 12; }
   while((s2 - b2) > 7) { b2 += 12; }

   //check for plain fifths in chord 1
   if((s1 - a1) == 7)
   {
      if((s2 - a2) == 7)
      {
         output = output + "There is a consecutive fifth [+ octave(s)] between the soprano and alto voices.\n";
      }
   }
   if((s1 - t1) == 7)
   {
      if((s2 - t2) == 7)
      {
         output = output + "There is a consecutive fifth [+ octave(s)] between the soprano and tenor voices.\n";
      }
   }
   if((s1 - b1) == 7)
   {
      if((s2 - b2) == 7)
      {
         output = output + "There is a consecutive fifth [+ octave(s)] between the soprano and bass voices.\n";
      }
   }


   s1 = chord1.s, a1 = chord1.a, t1 = chord1.t, b1 = chord1.b;
   s2 = chord2.s, a2 = chord2.a, t2 = chord2.t, b2 = chord2.b;

   while((a1 - t1) > 7) { t1 += 12; }
   while((a2 - t2) > 7) { t2 += 12; }
   while((a1 - b1) > 7) { b1 += 12; }
   while((a2 - b2) > 7) { b2 += 12; }


   if((a1 - t1) == 7)
   {
      if((a2 - t2) == 7)
      {
         output = output + "There is a consecutive fifth [+ octave(s)] between the alto and tenor voices.\n";
      }
   }
   if((a1 - b1) == 7)
   {
      if((a2 - b2) == 7)
      {
         output = output + "There is a consecutive fifth [+ octave(s)] bewteen the alto and bass voices.\n";
      }
   }


   s1 = chord1.s, a1 = chord1.a, t1 = chord1.t, b1 = chord1.b;
   s2 = chord2.s, a2 = chord2.a, t2 = chord2.t, b2 = chord2.b;

   while((t1 - b1) > 7) { b1 += 12; }
   while((t2 - b2) > 7) { b2 += 12; }


   if((t1 - b1) == 7)
   {
      if((t2 - b2) == 7)
      {
         output = output + "There is a consecutive fifth [+ octave(s)] between the tenor and bass voices.\n";
      }
   }









   s1 = chord1.s, a1 = chord1.a, t1 = chord1.t, b1 = chord1.b;
   s2 = chord2.s, a2 = chord2.a, t2 = chord2.t, b2 = chord2.b;

   while((s1 - a1) > 12) { a1 += 12; }
   while((s2 - a2) > 12) { a2 += 12; }
   while((s1 - t1) > 12) { t1 += 12; }
   while((s2 - t2) > 12) { t2 += 12; }
   while((s1 - b1) > 12) { b1 += 12; }
   while((s2 - b2) > 12) { b2 += 12; }

   //check for plain octaves in chord 1
   if((s1 - a1) == 12)
   {
      if((s2 - a2) == 12)
      {
         output = output + "There is a consecutive octave(s) between the soprano and alto voices.\n";
      }
   }
   if((s1 - t1) == 12)
   {
      if((s2 - t2) == 12)
      {
         output = output + "There is a consecutive octave(s) between the soprano and tenor voices.\n";
      }
   }
   if((s1 - b1) == 12)
   {
      if((s2 - b2) == 12)
      {
         output = output + "There is a consecutive octave(s) between the soprano and bass voices.\n";
      }
   }



   s1 = chord1.s, a1 = chord1.a, t1 = chord1.t, b1 = chord1.b;
   s2 = chord2.s, a2 = chord2.a, t2 = chord2.t, b2 = chord2.b;

   while((a1 - t1) > 12) { t1 += 12; }
   while((a2 - t2) > 12) { t2 += 12; }
   while((a1 - b1) > 12) { b1 += 12; }
   while((a2 - b2) > 12) { b2 += 12; }

   if((a1 - t1) == 12)
   {
      if((a2 - t2) == 12)
      {
         output = output + "There is a consecutive octave(s) between the alto and tenor voices.\n";
      }
   }
   if((a1 - b1) == 12)
   {
      if((a2 - b2) == 12)
      {
         output = output + "There is a consecutive octave(s) bewteen the alto and bass voices.\n";
      }
   }



   s1 = chord1.s, a1 = chord1.a, t1 = chord1.t, b1 = chord1.b;
   s2 = chord2.s, a2 = chord2.a, t2 = chord2.t, b2 = chord2.b;

   while((t1 - b1) > 12) { b1 += 12; }
   while((t2 - b2) > 12) { b2 += 12; }


   if((t1 - b1) == 12)
   {
      if((t2 - b2) == 12)
      {
         output = output + "There is a consecutive octave between the tenor and bass voices.\n";
      }
   }


   return output;
}


//note: in this function, root ten alt sop, are NOT from 0
function checkRootsThirds(chord, chordType)
{
   var output = "";

   var root = chord.b;
   var sop = chord.s;
   var alt = chord.a;
   var ten = chord.t;

   root = FO(root, 0);
   /*if(chord.inv == 1)
      root = chord.setTriad.root;
   else if(chord.inv == 2)
      root = chord.setTriad.third;
   else if(chord.inv == 3)
      root = chord.setTriad.fifth;*/

   //alert("root: " + root);
   if(chord.inv == 1)
   {
      if(root != chord.setTriad.root)
         output = "The base part for chord " + chordType + " does not match the inversion specified.\n";
   }
   else if(chord.inv == 2)
   {
      if(root != chord.setTriad.third)
         output = "The base part for chord " + chordType + " does not match the inversion specified.\n";
   }
   else if(chord.inv == 3)
   {
      if(root != chord.setTriad.fifth)
         output = "The base part for chord " + chordType + " does not match the inversion specified.\n";
   }


   sop = FO(sop, 0);
   alt = FO(alt, 0);
   ten = FO(ten, 0);

   //alert("root: " + root + " ten: " + ten + " alt: " + alt + " sop: " + sop);

   //alert("c.st.root: " + chord.setTriad.root + " c.st.third: " + chord.setTriad.third + " c.st.fifth: " + chord.setTriad.fifth);
   var tc = 0;
   
   if(chord.setTriad.root == root) tc++;
   if(chord.setTriad.root == alt) tc++;
   if(chord.setTriad.root == ten) tc++;
   if(chord.setTriad.root == sop) tc++;
   /*if(chord.inv == 1)
   {
      if(chord.setTriad.root == root) tc++;
      if(chord.setTriad.root == alt) tc++;
      if(chord.setTriad.root == ten) tc++;
      if(chord.setTriad.root == sop) tc++;
   }
   else if(chord.inv == 2)
   {
      if(chord.setTriad.third == root) tc++;
      if(chord.setTriad.third == alt) tc++;
      if(chord.setTriad.third == ten) tc++;
      if(chord.setTriad.third == sop) tc++;
   }
   else if(chord.inv == 3)
   {
      if(chord.setTriad.fifth == root) tc++;
      if(chord.setTriad.fifth == alt) tc++;
      if(chord.setTriad.fifth == ten) tc++;
      if(chord.setTriad.fifth == sop) tc++;
   }*/

   if(tc == 0)
   {
      output = output + "You have ommitted the root in chord " + chordType + ".\n";
   }


   tc = 0;

   if(chord.setTriad.third == root) tc++;
   if(chord.setTriad.third == alt) tc++;
   if(chord.setTriad.third == ten) tc++;
   if(chord.setTriad.third == sop) tc++;
   /*if(chord.inv == 1)
   {
      if(chord.setTriad.third == root) tc++;
      if(chord.setTriad.third == alt) tc++;
      if(chord.setTriad.third == ten) tc++;
      if(chord.setTriad.third == sop) tc++;
   }
   else if(chord.inv == 2)
   {
      if(chord.setTriad.fifth == root) tc++;
      if(chord.setTriad.fifth == alt) tc++;
      if(chord.setTriad.fifth == ten) tc++;
      if(chord.setTriad.fifth == sop) tc++;
   }
   else if(chord.inv == 3)
   {
      alert("dgdfgd");
      if(chord.setTriad.root == root) tc++;
      if(chord.setTriad.root == alt) tc++;
      if(chord.setTriad.root == ten) tc++;
      if(chord.setTriad.root == sop) tc++;
   }*/


   if(tc == 0)
   {
      output = output + "You have ommitted the third in chord " + chordType + ".\n";
   }
   if(tc > 1)
   {
      if(chord.id != 6)
      {
         output = output + "You have included the third more than once in chord " + chordType + ".\n";
      }
   }

   return output;
}

function checkPresenceLeadingNote(chord1, chord2, keySig)
{
   var output = "";
   if(keySig.Type == 1)
   {
      return "";
   }

   var seventh = (keySig.tonic - 2) + 12;

   var root = chord1.b;
   var sop = chord1.s;
   var alt = chord1.a;
   var ten = chord1.t;

   while(sop >= (root + 12))
   {
      sop -= 12;
   }

   while(alt >= (root + 12))
   {
      alt -= 12;
   }

   while(ten >= (root + 12))
   {
      ten -= 12;
   }

   if(sop == seventh)
   {
      output = output + "In the soprano voice for chord 1, you have not raised the leading note. The leading note ofa minorkeymust always be raised.";
   }
   if(alt == seventh)
   {
      output = output + "In the alto voice for chord 1, you have not raised the leading note. The leading note ofa minorkeymust always be raised.";
   }
   if(ten == seventh)
   {
      output = output + "In the tenor voice for chord 1, you have not raised the leading note. The leading note ofa minorkeymust always be raised.";
   }
   if(root == seventh)
   {
      output = output + "In the bass voice for chord 1, you have not raised the leading note. The leading note ofa minorkeymust always be raised.";
   }


   var root = chord2.b;
   var sop = chord2.s;
   var alt = chord2.a;
   var ten = chord2.t;

   while(sop >= (root + 12))
   {
      sop -= 12;
   }

   while(alt >= (root + 12))
   {
      alt -= 12;
   }

   while(ten >= (root + 12))
   {
      ten -= 12;
   }

   if(sop == seventh)
   {
      output = output + "In the soprano voice for chord 2, you have not raised the leading note. The leading note ofa minorkeymust always be raised.";
   }
   if(alt == seventh)
   {
      output = output + "In the alto voice for chord 2, you have not raised the leading note. The leading note ofa minorkeymust always be raised.";
   }
   if(ten == seventh)
   {
      output = output + "In the tenor voice for chord 2, you have not raised the leading note. The leading note ofa minorkeymust always be raised.";
   }
   if(root == seventh)
   {
      output = output + "In the bass voice for chord 2, you have not raised the leading note. The leading note ofa minorkeymust always be raised.";
   }

   return output;
}


