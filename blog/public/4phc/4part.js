//Script copyright (c) 2005 BR Fletcher & R Williams


   //alert("MainChord" + whatSet + " = " + a + ";");
   //alert(MainChord1.toString() + ", " + MainChord2.toString());

   //alert(note + ", " + key);

function ensure(output, TempMainChord1, TempMainChord2)
{
   var output = "";
   if(TempMainChord1.s == -1)
   {
      output = "You didn't set a note for the soprano voice in chord 1.\n";
   }
   if(TempMainChord1.a == -1)
   {
      output = output + "You didn't set a note for the alto voice in chord 1.\n";
   }
   if(TempMainChord1.t == -1)
   {
      output = output + "You didn't set a note for the tenor voice in chord 1.\n";
   }
   if(TempMainChord1.b == -1)
   {
      output = output + "You didn't set a note for the bass voice in chord 1.\n";
   }

   if(TempMainChord2.s == -1)
   {
      output = "You didn't set a note for the soprano voice in chord 2.\n";
   }
   if(TempMainChord2.a == -1)
   {
      output = output + "You didn't set a note for the alto voice in chord 2.\n";
   }
   if(TempMainChord2.t == -1)
   {
      output = output + "You didn't set a note for the tenor voice in chord 2.\n";
   }
   if(TempMainChord2.b == -1)
   {
      output = output + "You didn't set a note for the bass voice in chord 2.\n";
   }
   return output;
}


function convertNoteBack(note)
{
   var tempNote = note;
   var name = "";

   var i = 0;
   while(tempNote >= 12)
   {
      i++;
      tempNote -= 12;
   }

   switch(tempNote)
   {
      case 0: name = 'C'; break;
      case 2: name = 'D'; break;
      case 4: name = 'E'; break;
      case 5: name = 'F'; break;
      case 7: name = 'G'; break;
      case 9: name = 'A'; break;
      case 11: name = 'B'; break;
   }

   return name + i;
}

function convertAcc(note, acc)
{
   if(acc == "bb")
   {
      note--;
      note--;
   }
   if(acc == "b")
   {
      note--;
   }
   if(acc == "#")
   {
      note++;
   }
   if(acc == "x")
   {
      note++;
      note++;
   }

   return note;
}


/* The Chord class is called with the Bass (b), Tenor (t), Alto (a), and Soprano (s) parts.
   Id is the number ofthe chord, 1, 2, 3,  4, 5, 6, 7. Inv is the inversion, 1, 2, or 3 for
                                 I  II III IV V  VI VII                      a  b     c
*/
function Chord(b, t, a, s, id, inv)
{
   this.b = b; //integer
   this.t = t; //integer
   this.a = a; //integer
   this.s = s; //integer
   this.id = id; //integer
   this.inv = inv; //integer
   this.triad = new Triad(0, 0, 0, 0);
   this.setTriad = new Triad(0, 0, 0, 0);
}
/*   this.isTriad = calculateIsTriad(b, t, a, s);
   this.uld = shouldTriad;
   this.isTriad = isTriad;
}*/

function Triad(r, t, f, inv)
{
   this.root = r;
   this.third = t;
   this.fifth = f;
   this.inv = inv;
}

function createInputChord(b, t, a, s, name)
{
   var id = "";
   var inv = "";
   if(name.charAt(name.length - 1) == "a")
   {
      inv = 1;
      id = convertChordName(name.substring(0, name.length - 2));
   }
   if(name.charAt(name.length - 1) == "b")
   {
      inv = 2;
      id = convertChordName(name.substring(0, name.length - 2));
   }
   else
   {
      id = convertChordName(name);
   }
   return new Chord(b, t, a, s, id, inv);
}

function convertChordName(input)
{
   if(input == "I")
   {
      return 1;
   }
   else if(input == "II")
   {
      return 2;
   }
   else if(input == "III")
   {
      return 3;
   }
   else if(input == "IV")
   {
      return 4;
   }
   else if(input == "V")
   {
      return 5;
   }
   else if(input == "VI")
   {
      return 6;
   }
   else if(input == "VII")
   {
      return 7;
   }

   return 0;
}


// for eachType, x is the note change in semitones
function KeySig(c, d, e, f, g, a, b, tonic, Type, nearestTone)
{
   this.c = c;
   this.d = d;
   this.e = e;
   this.f = f;
   this.g = g;
   this.a = a;
   this.b = b;
   this.tonic = tonic;
   this.Type = Type;
   this.nearNote = nearestTone;
   this.root = 0;
   this.supt = 0;
   this.medi = 0;
   this.subd = 0;
   this.domi = 0;
   this.subm = 0;
   this.lean = 0;
}

function getTriad(key, triad)
{
   var output = new Triad(0, 0, 0, 0);
   switch(triad)
   {
      case 1: output.root = (key.tonic + key.root);
              output.third = (key.tonic + 4 + key.medi);
              output.fifth = (key.tonic + 7 + key.domi);
              break;
      case 2: output.root = (key.tonic + 2 + key.supt);
              output.third = (key.tonic + 5 + key.subd);
              output.fifth = (key.tonic + 9 + key.subm);
              break;
      case 3: output.root = (key.tonic + 4 + key.medi);
              output.third = (key.tonic + 7 + key.domi);
              output.fifth = (key.tonic + 11 + key.lean);
              break;
      case 4: output.root = (key.tonic + 5 + key.subd);
              output.third = (key.tonic + 9 + key.subm);
              output.fifth = (key.tonic + 12 + key.root);
              break;
      case 5: output.root = (key.tonic + 7 + key.domi);
              output.third = (key.tonic + 11 + key.lean);
              output.fifth = (key.tonic + 14 + key.supt);
              break;
      case 6: output.root = (key.tonic + 9 + key.subm);
              output.third = (key.tonic + 12 + key.root);
              output.fifth = (key.tonic + 16 + key.subm);
              break;
      case 7: output.root = (key.tonic + 11 + key.lean);
              output.third = (key.tonic + 14 + key.supt);
              output.fifth = (key.tonic + 17 + key.subd);
              break;
   }

   var troot = output.root;
   var tthird = output.third;
   var tfifth = output.fifth;

   while(troot > (key.tonic + 12)) { troot -= 12; }
   while(tthird > (key.tonic + 12)) { tthird -= 12; }
   while(tfifth > (key.tonic + 12)) { tfifth -= 12; }
//   alert(troot + ", " + tthird + ", " + tfifth);

   if(key.Type == 2)
   {
      if(troot == (key.tonic + 11 + key.lean))
      {
         output.root += 1;
      }
      if(tthird ==(key.tonic + 11 + key.lean))
      {
         output.third += 1;
      }
      if(tfifth == (key.tonic + 11 + key.lean))
      {
         output.fifth += 1;
      }
   }
//   alert(output.root + ", " + output.third + ", " + output.fifth);

   return output;
}

function fixTriad(triad)
{
   var output = new Triad(triad.root, triad.third, triad.fifth, triad.inv);
   while(triad.third >= 12) { triad.third -= 12; }
   while(triad.fifth >= 12) { triad.fifth -= 12; }

   return output;
}
      

function calcBasedOnTonic(key)
{
   if(key.nearNote == 0)
   {
      key.root = key.c;
      key.supt = key.d;
      key.medi = key.e;
      key.subd = key.f;
      key.domi = key.g;
      key.subm = key.a;
      key.lean = key.b;
   }
   else if(key.nearNote == 2)
   {
      key.root = key.d;
      key.supt = key.e;
      key.medi = key.f;
      key.subd = key.g;
      key.domi = key.a;
      key.subm = key.b;
      key.lean = key.c;
   }
   else if(key.nearNote == 4)
   {
      key.root = key.e;
      key.supt = key.f;
      key.medi = key.g;
      key.subd = key.a;
      key.domi = key.b;
      key.subm = key.c;
      key.lean = key.d;
   }
   else if(key.nearNote == 5)
   {
      key.root = key.f;
      key.supt = key.g;
      key.medi = key.a;
      key.subd = key.b;
      key.domi = key.c;
      key.subm = key.d;
      key.lean = key.e;
   }
   else if(key.nearNote == 7)
   {
      key.root = key.g;
      key.supt = key.a;
      key.medi = key.b;
      key.subd = key.c;
      key.domi = key.d;
      key.subm = key.e;
      key.lean = key.f;
   }
   else if(key.nearNote == 9)
   {
      key.root = key.a;
      key.supt = key.b;
      key.medi = key.c;
      key.subd = key.d;
      key.domi = key.e;
      key.subm = key.f;
      key.lean = key.g;
   }
   else if(key.nearNote == 11)
   {
      key.root = key.b;
      key.supt = key.c;
      key.medi = key.d;
      key.subd = key.e;
      key.domi = key.f;
      key.subm = key.g;
      key.lean = key.a;
   }
}

function createKeySignature(keyname, Type)
{
   if(keyname == "C")
   {
      if(Type == "1")
      {
         return new KeySig(0, 0, 0, 0, 0, 0, 0, 0, 1, 0);
      }
      else
      {
         return new KeySig(0, 0, -1, 0, 0, -1, -1, 0, 2, 0);
      }
   }
   else if(keyname == "G")
   {
      if(Type == "1")
      {
         return new KeySig(0, 0, 0, 1, 0, 0, 0, 7, 1, 7);
      }
      else
      {
         return new KeySig(0, 0, -1, 0, 0, 0, -1, 7, 2, 7);
      }
   }
   else if(keyname == "D")
   {
      return new KeySig(1, 0, 0, 1, 0, 0, 0, 2, 1, 2);
   }
   else if(keyname == "D#")
   {
      return new KeySig(1, 1, 1, 1, 1, 1, 0, 3, 2, 2);
   }
   else if(keyname == "Db")
   {
      return new KeySig(-1, -1, -1, 0, -1, -1, -1, 1, 2, 2);
   }
   else if(keyname == "A")
   {
      return new KeySig(1, 0, 0, 1, 1, 0, 0, 9, 1, 9);
   }
   else if(keyname == "Ab")
   {
      if(Type == 1)
      {
         return new KeySig(0, -1, -1, 0, 0, -1, -1, 8, 1, 9);
      }
      else
      {
         return new KeySig(-1, -1, -1, -1, -1, -1, -1, 8, 2, 9);
      }
   }
   else if(keyname == "A#")
   {
      return new KeySig(1, 1, 1, 1, 1, 1, 1, 10, 2, 9);
   }
   else if(keyname == "E")
   {
      if(Type == 1)
      {
         return new KeySig(1, 1, 0, 1, 1, 0, 0, 4, 1, 4);
      }
      else
      {
         return new KeySig(0, 0, 0, 1, 0, 0, 0, 4, 2, 4);
      }
   }
   else if(keyname == "B")
   {
      if(Type == 1)
      {
         return new KeySig(1, 1, 0, 1, 1, 1, 0, 11, 1, 11);
      }
      else
      {
         return new KeySig(1, 0, 0, 1, 0, 0, 0, 11, 2, 11);
      }
   }
   else if(keyname == "F#")
   {
      if(Type == 1)
      {
         return new KeySig(1, 1, 1, 1, 1, 1, 0, 6, 1, 5);
      }
      else
      {
         return new KeySig(1, 0, 0, 1, 1, 0, 0, 6, 2, 5);
      }
   }
   else if(keyname == "C#")
   {
      if(Type == 1)
      {
         return new KeySig(1,1 ,1 ,1 ,1 ,1 ,1 ,13,1, 0);
      }
      else
      {
         return new KeySig(1,1 ,0 ,1 ,1 ,0 ,0 ,13 ,2 , 0);
      }
   }
   else if(keyname == "F")
   {
      if(Type == 1)
      {
         return new KeySig(0,0 ,0 ,5 ,0 ,0 ,2 ,0 ,1 , 5);
      }
      else
      {
         return new KeySig(0,2 ,2 ,5 ,0 ,2 ,2 ,0 , 2, 5);
      }
   }
   else if(keyname == "Bb")
   {
      if(Type == 1)
      {
         return new KeySig(0,0 ,2 ,0 ,0 ,0 ,10 ,0 , 1, 11);
      }
      else
      {
         return new KeySig(0,2 ,2 ,0 ,2 ,2 ,10 ,0 ,2 , 11);
      }
   }
   else if(keyname == "Eb")
   {
      if(Type == 1)
      {
         return new KeySig(0, 0, 3, 0, 0, 2, 2, 0, 2, 1, 4);
      }
      else
      {
         return new KeySig(2,2 ,3 ,0 ,2 ,2 ,2 ,2 ,2 , 4);
      }
   }
   else if(keyname == "Gb")
   {
      return new KeySig(2,2 ,2 ,0 ,6 ,2 ,2 ,2 , 1, 7);
   }
   else if(keyname == "Cb")
   {
      return new KeySig(11,2 ,2 ,2 ,2 ,2 ,2 ,11 , 1, 0);
   }
   else if(keyname == "G#")
   {
      return new KeySig(1,1 ,0 ,1 ,8 ,1 ,0 ,1 , 2, 7);
   }
   else
   {
      return 0;
   }
}