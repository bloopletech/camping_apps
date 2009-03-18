//Script copyright (c) 2005 BR Fletcher & R Williams
//BUILD 7/19/2005 1:13PM


function FO(what, level)
{
   if(what < level)
   {
      while(what < level) { what += 12; }
   }
   else
   {
      while(what >= (level + 12)) { what -= 12; }
   }
   return what;
}



//converts a note with an accidental.
//Also adjusts for key signature
function convertAccKeySig(note, acc, keysig)
{
   var tempNote = note;
   var oldNote = note;
   tempNote = FO(tempNote, 0);

   switch(tempNote)
   {
/*      case keysig.nearNote: note += keysig.root; note = accfix(note, acc, keysig.root); break;
      case keysig.nearNote + 2: note += keysig.supt; note = accfix(note, acc, keysig.supt); break;
      case keysig.nearNote + 4: note += keysig.medi; note = accfix(note, acc, keysig.medi); break;
      case keysig.nearNote + 5: note += keysig.subd; note = accfix(note, acc, keysig.subd); break;
      case keysig.nearNote + 7: note += keysig.domi; note = accfix(note, acc, keysig.domi); break;
      case keysig.nearNote + 9: note += keysig.subm; note = accfix(note, acc, keysig.subm); break;
      case keysig.nearNote + 11: note += keysig.lean; note = accfix(note, acc, keysig.lean); break;*/
      case 0: note += keysig.c; note = accfix(note, acc, keysig.c); break;
      case 2: note += keysig.d; note = accfix(note, acc, keysig.d); break;
      case 4: note += keysig.e; note = accfix(note, acc, keysig.e); break;
      case 5: note += keysig.f; note = accfix(note, acc, keysig.f); break;
      case 7: note += keysig.g; note = accfix(note, acc, keysig.g); break;
      case 9: note += keysig.a; note = accfix(note, acc, keysig.a); break;
      case 11: note += keysig.b; note = accfix(note, acc, keysig.b); break;

   }
   //alert("acc: " + acc + ", tempNote: " + tempNote + ", oldNote: " + oldNote + ", note: " + note);
   //alert("lean: " + keysig.lean);


   //alert("note: " + note);
   return note;
}

function accfix(note, acc, type1)
{
   if(acc == "none")
   {
      return note;
   }


   /*var tempNote = note;
   tempNote = FO(tempNote, 0);
   if(keysig.tonic != keysig.nearNote && tempNote == keysig.tonic)
   {
      alert("type1");
      note -= type1;
   }*/

   if(type1 == -1)
   {
      if(acc == "bb")
      {
         return note - 1;
      }
      else if(acc == "b")
      {
         return note;
      }
      else if(acc == " ")
      {
         return note + 1;
      }
      else if(acc == "#")
      {
         return note + 2;
      }
      else if(acc == "x")
      {
         return note + 3;
      }
   }
   else if(type1 == 0)
   {
      if(acc == "bb")
      {
         return note - 2;
      }
      else if(acc == "b")
      {
         return note - 1;
      }
      else if(acc == " ")
      {
         return note;
      }
      else if(acc == "#")
      {
         return note + 1;
      }
      else if(acc == "x")
      {
         return note + 2;
      }
   }
   else if(type1 == 1)
   {
      if(acc == "bb")
      {
         return note - 3;
      }
      else if(acc == "b")
      {
         return note - 2;
      }
      else if(acc == " ")
      {
         return note - 1;
      }
      else if(acc == "#")
      {
         return note;
      }
      else if(acc == "x")
      {
         return note + 1;
      }
   }
   return -5;
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
   this.boogers = "none at all";
}
/*   this.isTriad = calculateIsTriad(b, t, a, s);
   this.uld = shouldTriad;
   this.isTriad = isTriad;
}*/
function Chord_toString()
{
   return "s: " + this.b + " a: " + this.a + " t: " + this.t + " b: "
    + this.b + " id: " + this.id + " inv: " + this.inv;
}
new Chord(0, 0, 0, 0, 0, 0);
Chord.prototype.toString = Chord_toString;


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
   if(name.charAt(name.length - 1) == "a") { inv = 1; }
   if(name.charAt(name.length - 1) == "b") { inv = 2; }
   if(name.charAt(name.length - 1) == "c") { inv = 3; }
   id = convertChordName(name.substring(0, name.length - 1));
   //alert("id: " + id + ", inv: " + inv);

   return new Chord(b, t, a, s, id, inv);
}

function convertChordName(input)
{
   //alert("input: " + input);
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

function getTriad(key, triad, inversion)
{
   var output = new Triad(0, 0, 0, 0);
   //alert("triad:" + triad);
   if(key.Type == 1)
   {
      switch(triad)
      {
         case 1: output.root = (key.tonic);
                 output.third = (key.tonic + 4);
                 output.fifth = (key.tonic + 7);
                 break;
         case 2: output.root = (key.tonic + 2);
                 output.third = (key.tonic + 5);
                 output.fifth = (key.tonic + 9);
                 break;
         case 3: output.root = (key.tonic + 4);
                 output.third = (key.tonic + 7);
                 output.fifth = (key.tonic + 11);
                 break;
         case 4: output.root = (key.tonic + 5);
                 output.third = (key.tonic + 9);
                 output.fifth = (key.tonic + 12);
                 break;
         case 5: output.root = (key.tonic + 7);
                 output.third = (key.tonic + 11);
                 output.fifth = (key.tonic + 14);
                 break;
         case 6: output.root = (key.tonic + 9);
                 output.third = (key.tonic + 12);
                 output.fifth = (key.tonic + 16);
                 break;
         case 7: output.root = (key.tonic + 11);
                 output.third = (key.tonic + 14);
                 output.fifth = (key.tonic + 17);
                 break;
      }
   }
   else
   {
      switch(triad)
      {
         case 1: output.root = (key.tonic);
                 output.third = (key.tonic + 3);
                 output.fifth = (key.tonic + 7);
                 break;
         case 2: output.root = (key.tonic + 2);
                 output.third = (key.tonic + 5);
                 output.fifth = (key.tonic + 8);
                 break;
         case 3: output.root = (key.tonic + 3);
                 output.third = (key.tonic + 7);
                 output.fifth = (key.tonic + 10);
                 break;
         case 4: output.root = (key.tonic + 5);
                 output.third = (key.tonic + 8);
                 output.fifth = (key.tonic + 12);
                 break;
         case 5: output.root = (key.tonic + 7);
                 output.third = (key.tonic + 10);
                 output.fifth = (key.tonic + 14);
                 break;
         case 6: output.root = (key.tonic + 8);
                 output.third = (key.tonic + 12);
                 output.fifth = (key.tonic + 15);
                 break;
         case 7: output.root = (key.tonic + 10);
                 output.third = (key.tonic + 14);
                 output.fifth = (key.tonic + 17);
                 break;
      }

      if(output.root == (key.tonic + 10)) output.root = output.root + 1;
      if(output.third == (key.tonic + 10)) output.third = output.third + 1;
      if(output.fifth == (key.tonic + 10)) output.fifth = output.fifth + 1;
   }

   var troot = output.root;
   var tthird = output.third;
   var tfifth = output.fifth;

   troot = FO(troot, key.tonic);
   tthird = FO(tthird, key.tonic);
   tfifth = FO(tfifth, key.tonic);
//   alert(troot + ", " + tthird + ", " + tfifth);

   if(key.Type == 2)
   {
      //alert("Minor key" + (key.tonic + 11));
      if(troot == (key.tonic + 10 + key.lean))
      {
         output.root += 1;
      }
      if(tthird ==(key.tonic + 10 + key.lean))
      {
         output.third += 1;
      }
      if(tfifth == (key.tonic + 10 + key.lean))
      {
         output.fifth += 1;
      }
   }
   //alert(output.root + ", " + output.third + ", " + output.fifth);
   troot = output.root;
   tthird = output.third;
   tfifth = output.fifth;

   return output;
}

function fixTriad(triad)
{
   var output = new Triad(triad.root, triad.third, triad.fifth, triad.inv);
   output.root = FO(output.root, 0);
   output.third = FO(output.third, 0);
   output.fifth = FO(output.fifth, 0);

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
      //alert("calcBasedOnTonic: " + key.nearNote);
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
      //alert("in calcBsedOnTonic");
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
      if(Type == 1)
      {
         return new KeySig(1, 0, 0, 1, 0, 0, 0, 2, 1, 2);
      }
      else
      {
         return new KeySig(0, 0, 0, 0, 0, 0, -1, 2, 2, 2);
      }
   }
   else if(keyname == "D#")
   {
      if(Type == 2)
      {
         return new KeySig(1, 1, 1, 1, 1, 1, 0, 3, 2, 2);
      }
      else
      {
         return 0;
      }
   }
   else if(keyname == "Db")
   {
      if(Type == 1)
      {
         return new KeySig(-1, -1, -1, 0, -1, -1, -1, 1, 2, 2);
      }
      else
      {
         return 0;
      }
   }
   else if(keyname == "A")
   {
      if(Type == 1)
      {
         return new KeySig(1, 0, 0, 1, 1, 0, 0, 9, 1, 9);
      }
      else
      {
         return new KeySig(0, 0, 0, 0, 0, 0, 0, 9, 2, 9);
      }
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
      if(Type == 2)
      {
         return new KeySig(1, 1, 1, 1, 1, 1, 1, 10, 2, 9);
      }
      else
      {
         return 0;
      }
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
         return new KeySig(0, 0, 0, 0, 0, 0, -1, 5, 1, 5);
      }
      else
      {
         return new KeySig(0, -1, -1, 0, 0, -1, -1, 5, 2, 5);
      }
   }
   else if(keyname == "Bb")
   {
      if(Type == 1)
      {
         return new KeySig(0, 0, -1, 0, 0, 0, -1, 10, 1, 11);
      }
      else
      {
         return new KeySig(0, -1, -1, 0, -1, -1, -1, 10, 2, 11);
      }
   }
   else if(keyname == "Eb")
   {
      if(Type == 1)
      {
         return new KeySig(0, 0, -1, 0, 0, -1, -1, 3, 1, 4);
      }
      else
      {
         return new KeySig(0, 0, -1, 0, 0, 0, -1, 3, 2, 4);
      }
   }
   else if(keyname == "Gb")
   {
      if(Type == 1)
      {
         return new KeySig(-1, -1, -1, 0, -1, -1, -1, 6, 2, 7);
      }
      else
      {
         return 0;
      }
   }
   else if(keyname == "Cb")
   {
      if(Type == 1)
      {
         return new KeySig(-1, -1, -1, -1, -1, -1, -1, -1, 1, 0);
      }
      else
      {
         return 0;
      }
   }
   else if(keyname == "G#")
   {
      if(Type == 2)
      {
         return new KeySig(1, 1, 0, 1, 1, 1, 0, 8, 2, 7);
      }
      else
      {
         return 0;
      }
   }
   else
   {
      return 0;
   }
}
