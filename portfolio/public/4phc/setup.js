//Script copyright (c) 2005 BR Fletcher & R Williams
//BUILD 8/11/2005 12:08PM

/*this function gets the object referred to by `name` (in an id or name attribute on an
html element) and returns the object*/
function get(name)
{
   return document.getElementById(name);
}


/*this function gets the name of an object referred to by `object` and returns the name*/
function getName(element)
{
   if(element.name) return element.name;
   else if(element.id) return element.id;
   else return "";
}


/*this function returns a version of `what` altered by a multiple of 12 so that is in the
range of `level` and `level + 12`. the function is used in this script to change the octave
of a note*/
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


/*this function applies the accidental `acc` to the note `note`, and also applies the
keysignature `keysig` for that  to `note`.*/
function convertAccKeySig(note, acc, keysig)
{
   /*we make a copy of note, and alter the copy so that it is within one octave of
   middle C (0 - 11). We do this for the switch statement, instead of using a huge
   switch statement*/
   var tempNote = FO(note, 0);

   //based on the pitch of the temp note, add the keysig and accidental
   switch(tempNote)
   {
      //if note is C, add the keysig for C, and add the accidental
      case 0: note += keysig.c; note = accfix(note, acc, keysig.c); break;
      //same for D, and so on
      case 2: note += keysig.d; note = accfix(note, acc, keysig.d); break;
      case 4: note += keysig.e; note = accfix(note, acc, keysig.e); break;
      case 5: note += keysig.f; note = accfix(note, acc, keysig.f); break;
      case 7: note += keysig.g; note = accfix(note, acc, keysig.g); break;
      case 9: note += keysig.a; note = accfix(note, acc, keysig.a); break;
      case 11: note += keysig.b; note = accfix(note, acc, keysig.b); break;

   }

   //return the modified note
   return note;
}


/*This function applies an accidental to a note.
An accidental is relative to the note itself:
If the note is usually flattened by the keysignature (for example a B in F major is
flattened by the keysignature), and the accidental is a sharp, the result is
B natural (11   -   1   +   1)
           B      flat  |  sharp
           nat- | key-  |  acc-  
           ural | sig   |  idental
This function accounts for the above phenomenon, and applies the accidental to the note, and
taking into account the keysignature.
`note` is the note to apply the accidental to. `acc` is the accidental itself as a string.
`type1` is the numerical change applied to a note by the keysignature.*/
function accfix(note, acc, type1)
{
   //if there is no accidental, don't change the note at all
   if(acc == "none")
   {
      return note;
   }

   //the first if is used as an example: if the keysignatue accidental for this note is flat...
   if(type1 == -1)
   {
      /*if the accidental is a double flat; the note has already been flattened once,
      so we flatten the note once more*/
      if(acc == "bb") return note - 1;
      /*if the accidental is a flat; the note has already been flattened once,
      so we don't do anything*/
      else if(acc == "b") return note;
      /*if the accidental is a natural; the note has been flattened once,
      so we sharpen the note*/
      else if(acc == " ") return note + 1;
      /*if the accidental is a sharp; the note has been flattened once,
      so we sharpen the note once to compensate and once again for the sharp*/
      else if(acc == "#") return note + 2;
      /*if the accidental is a double sharp; the note has been flattened once,
      so we sharpen the note once to compensate and twice again for the double sharp*/
      else if(acc == "x") return note + 3;
   }
   else if(type1 == 0)
   {
      if(acc == "bb") return note - 2;
      else if(acc == "b") return note - 1;
      else if(acc == " ") return note;
      else if(acc == "#") return note + 1;
      else if(acc == "x") return note + 2;
   }
   else if(type1 == 1)
   {
      if(acc == "bb") return note - 3;
      else if(acc == "b") return note - 2;
      else if(acc == " ") return note - 1;
      else if(acc == "#") return note;
      else if(acc == "x") return note + 1;
   }
   //else return sentinel value fro vo valid result
   return -5;
}


/* The chord class holds the four notes in a hour part harmony chord.
It also holds the triad represented by the four notes.
The Chord class is called with the Bass (b), Tenor (t), Alto (a), and Soprano (s) parts.
Id is the number ofthe chord, 1, 2, 3,  4, 5, 6, 7. Inv is the inversion, 1, 2, or 3 for
                              I  II III IV V  VI VII                      a  b     c
*/
function Chord(b, t, a, s, id, inv)
{
   /*these are the notes in the chord, represented by integers, the same way as in the MIDI
   format; that is, Middle C = 60, C#/Db = 61*/
   this.b = b; //integer
   this.t = t; //integer
   this.a = a; //integer
   this.s = s; //integer

   /*There is a triad represented by this chord. This is the name of the triad,
   in respect to the scale from which it came; for example, in C Major, the triad CEG would be
   Chord 1, GBD would be chord 5. This is the id for that triad.*/
   this.id = id; //integer

   /*what inversion this chord is in.*/
   this.inv = inv; //integer

   /*chord.triad is the triad that sould be represented by the chord name and inverison.
   This may or may not mach the notes in the chord; it only represents what the chord *should*
   look like. This is always in root position, so any operations on this need to take this into
   account if the chord is in a position other than root position.*/
   this.triad = new Triad(0, 0, 0, 0);

   /*this is the same as triad above, except that the notes are all in the octave of Middle C.*/
   this.setTriad = new Triad(0, 0, 0, 0);
}
function Chord_toString()
{
   return "s: " + this.s + " a: " + this.a + " t: " + this.t + " b: "
    + this.b + " id: " + this.id + " inv: " + this.inv;
}
new Chord(0, 0, 0, 0, 0, 0);
Chord.prototype.toString = Chord_toString;


//This class represents a triad of three notes, and an inversion.
function Triad(r, t, f, inv)
{
   this.root = r;
   this.third = t;
   this.fifth = f;
   this.inv = inv;
}

/*this function, given 4 notes and a name+inversion, this creates a chord initialised with the
four notes, and the name of the chord and it's inversion  */
function createInputChord(b, t, a, s, name)
{
   var id = "";
   var inv = "";

   //get the inversion of the chord based on the `name`
   if(name.charAt(name.length - 1) == "a") { inv = 1; }
   if(name.charAt(name.length - 1) == "b") { inv = 2; }
   if(name.charAt(name.length - 1) == "c") { inv = 3; }

   //get the name of the chord
   id = convertChordName(name.substring(0, name.length - 1));

   //create and return a chord with the notew, name and inversion
   return new Chord(b, t, a, s, id, inv);
}

/*this function, given a triad name in roman numerals, converts it into it's numerical
equivilent*/
function convertChordName(input)
{
   if(input == "I") return 1;
   else if(input == "II") return 2;
   else if(input == "III") return 3;
   else if(input == "IV") return 4;
   else if(input == "V") return 5;
   else if(input == "VI") return 6;
   else if(input == "VII") return 7;

   return 0;
}



/*this class represents a Key Signature.
a keysignature changes the pitch of certian notes.
`c - b` are variables representing the numerical change in pitch for the notes C - B respectivley.
For example, in F major, the variables are 0, 0, 0, 0, 0, 0, -1
This represents that F major makes no change to any of the notes, except for B.
In F major the B is flattened, thus the -1 for `down one semitone`.

`tonic` is the numerical note that starts the scale,. tonic ranges from 0 - 11. In F major,
tonic would be 5. for F above middle C.
`Type` is either 0 or 1, for Major or Minor scale.
`nearestTone` is similar to tonic, but it represents the nearest natural note.
For example, in F# major, tonic would be 6, but nearestTone would be 5.

Sometimes, it is easier to deal with a keysginature in terms of the tonic, the supertonic,
and the mediant, instead of c - b.

It is more efficient to deal with a set of variables from root to leading note, rather
than using nearestNote to calculate the tonic based on c - b every time.
`root - lean` represent the tonic to leading note of the scale, and the adjustement
made by the keysignature for each.*/
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




/*given a keysignature, a chord name, and an inversion, this function will generate a
matching Triad. For example, given the input F major for key, I (1) for triad, and `a` (1)
for inverison, this function will return a triad: F, A, C (5, 9, 12).*/
/*An interestin phenomenon relating to the Major and Minor diatonic scales is that
all of the Major keys have the same sequence of pitches, they just start on different notes.
The phenomenon is the same for the Minor keys, it's just a different sequence of notes.
To create a tonic triad in C major, you just take 0 (middle c), and add 4 for the third, and
7 for the fifth; 0, 4, 7.
Same for G major: 7 (g) + 4 for third, + 7 for fifth: 7, 11, 14.
This function uses this phenomenon to create triads.*/
function getTriad(key, triad, inversion)
{
   //declare the ouput Triad
   var output = new Triad(0, 0, 0, 0);

   /*the major and minor scales have different intervals between the notes;
   so there are two branches in the following if statement.*/
   //if the keysignature is Major
   if(key.Type == 1)
   {
      //switch based on the chord name
      switch(triad)
      {
         /*create an appropriate triad using the phenomenon described above,
         using the tonic of the key*/
         case 1: output.root = (key.tonic);
                 output.third = (key.tonic + 4);
                 output.fifth = (key.tonic + 7);
                 break;
         /*create an appropriate triad using the phenomenon described above,
         using the tonic of the key, etc. for each of the case's*/
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
   //if the key is minor
   else
   {
      //switch based on the chord name
      switch(triad)
      {
         /*create an appropriate triad using the phenomenon described above,
         using the tonic of the key*/
         case 1: output.root = (key.tonic);
                 output.third = (key.tonic + 3);
                 output.fifth = (key.tonic + 7);
                 break;
         /*create an appropriate triad using the phenomenon described above,
         using the tonic of the key, etc. for each of the case's*/
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

      //the following bit of code raises the leading note in a minor key
      //if the root of the triad equals the leading note, raise it
      if(output.root == (key.tonic + 10)) output.root = output.root + 1;
      //if the root of the triad equals the leading note, raise it
      if(output.third == (key.tonic + 10)) output.third = output.third + 1;
      //if the root of the triad equals the leading note, raise it
      if(output.fifth == (key.tonic + 10)) output.fifth = output.fifth + 1;
   }

   //here we declare a copy of the triad
   var troot = output.root;
   var tthird = output.third;
   var tfifth = output.fifth;

   //here we make sure that the root the third and the fifth are all in the same octave
   troot = FO(troot, key.tonic);
   tthird = FO(tthird, key.tonic);
   tfifth = FO(tfifth, key.tonic);


   //if we are in a minor key...
   if(key.Type == 2)
   {
      //if the root is the leading note (including any modifications made by the keysig...
      if(troot == (key.tonic + 10 + key.lean))
      {
         //add a semitone to the leading note
         output.root += 1;
      }
      //if the third is the leading note (including any modifications made by the keysig...
      if(tthird ==(key.tonic + 10 + key.lean))
      {
         //add a semitone to the leading note
         output.third += 1;
      }
      //if the fifth is the leading note (including any modifications made by the keysig...
      if(tfifth == (key.tonic + 10 + key.lean))
      {
         //add a semitone to the leading note
         output.fifth += 1;
      }
   }

   return output;
}

/*create a modified version of triad, with the three notes of the triad all places in the same
octave as the root. For example, if the root is A, and the third is C, and the fifth is E,
the old triad would have numerical values for the root third and fifth of 9, 12, and 14.
This function creates, in this case, a triad with the values, 9, 0, 4: A, C, E*/
function fixTriad(triad)
{
   var output = new Triad(triad.root, triad.third, triad.fifth, triad.inv);
   output.root = FO(output.root, 0);
   output.third = FO(output.third, 0);
   output.fifth = FO(output.fifth, 0);

   return output;
}


/*initialise parts of keysig.
this function initialises the parts of keysig key.root to key.lean with the correct values
from the key signature.*/
function calcBasedOnTonic(key)
{
   //the first two if's is used as an example
   //if the key starts with Cb C natural or C#,
   if(key.nearNote == 0)
   {
      //the tonic of the ley is c
      key.root = key.c;
      //the supertonic is d, etc.
      key.supt = key.d;
      key.medi = key.e;
      key.subd = key.f;
      key.domi = key.g;
      key.subm = key.a;
      key.lean = key.b;
   }
   //if the key starts with Db D natural or D#, 
   else if(key.nearNote == 2)
   {
      //the tonic of the key is D
      key.root = key.d;
      //the supertonic is E, etc.
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


/* given a name of a musical key, and a type (Major or Minor), this function returns
a KeySig object representing the inputted key signatue name and type.*/
function createKeySignature(keyname, Type)
{
   //the first if is used as an example
   //if the key is C...
   if(keyname == "C")
   {
      //...Major, return an appropriate KeySig
      if(Type == "1") return new KeySig(0, 0, 0, 0, 0, 0, 0, 0, 1, 0);
      //...Minor, return an Appropriate KeySig
      else return new KeySig(0, 0, -1, 0, 0, -1, -1, 0, 2, 0);
   }
   else if(keyname == "G")
   {
      if(Type == "1") return new KeySig(0, 0, 0, 1, 0, 0, 0, 7, 1, 7);
      else return new KeySig(0, 0, -1, 0, 0, 0, -1, 7, 2, 7);
   }
   else if(keyname == "D")
   {
      if(Type == 1) return new KeySig(1, 0, 0, 1, 0, 0, 0, 2, 1, 2);
      else return new KeySig(0, 0, 0, 0, 0, 0, -1, 2, 2, 2);
   }
   else if(keyname == "D#")
   {
      if(Type == 2) return new KeySig(1, 1, 1, 1, 1, 1, 0, 3, 2, 2);
      else return 0;
   }
   else if(keyname == "Db")
   {
      if(Type == 1) return new KeySig(-1, -1, -1, 0, -1, -1, -1, 1, 2, 2);
      else return 0;
   }
   else if(keyname == "A")
   {
      if(Type == 1) return new KeySig(1, 0, 0, 1, 1, 0, 0, 9, 1, 9);
      else return new KeySig(0, 0, 0, 0, 0, 0, 0, 9, 2, 9);
   }
   else if(keyname == "Ab")
   {
      if(Type == 1) return new KeySig(0, -1, -1, 0, 0, -1, -1, 8, 1, 9);
      else return new KeySig(-1, -1, -1, -1, -1, -1, -1, 8, 2, 9);
   }
   else if(keyname == "A#")
   {
      if(Type == 2) return new KeySig(1, 1, 1, 1, 1, 1, 1, 10, 2, 9);
      else return 0;
   }
   else if(keyname == "E")
   {
      if(Type == 1) return new KeySig(1, 1, 0, 1, 1, 0, 0, 4, 1, 4);
      else return new KeySig(0, 0, 0, 1, 0, 0, 0, 4, 2, 4);
   }
   else if(keyname == "B")
   {
      if(Type == 1) return new KeySig(1, 1, 0, 1, 1, 1, 0, 11, 1, 11);
      else return new KeySig(1, 0, 0, 1, 0, 0, 0, 11, 2, 11);
   }
   else if(keyname == "F#")
   {
      if(Type == 1) return new KeySig(1, 1, 1, 1, 1, 1, 0, 6, 1, 5);
      else return new KeySig(1, 0, 0, 1, 1, 0, 0, 6, 2, 5);
   }
   else if(keyname == "C#")
   {
      if(Type == 1) return new KeySig(1,1 ,1 ,1 ,1 ,1 ,1 ,13,1, 0);
      else return new KeySig(1,1 ,0 ,1 ,1 ,0 ,0 ,13 ,2 , 0);
   }
   else if(keyname == "F")
   {
      if(Type == 1) return new KeySig(0, 0, 0, 0, 0, 0, -1, 5, 1, 5);
      else return new KeySig(0, -1, -1, 0, 0, -1, -1, 5, 2, 5);
   }
   else if(keyname == "Bb")
   {
      if(Type == 1) return new KeySig(0, 0, -1, 0, 0, 0, -1, 10, 1, 11);
      else return new KeySig(0, -1, -1, 0, -1, -1, -1, 10, 2, 11);
   }
   else if(keyname == "Eb")
   {
      if(Type == 1) return new KeySig(0, 0, -1, 0, 0, -1, -1, 3, 1, 4);
      else return new KeySig(0, 0, -1, 0, 0, 0, -1, 3, 2, 4);
   }
   else if(keyname == "Gb")
   {
      if(Type == 1) return new KeySig(-1, -1, -1, 0, -1, -1, -1, 6, 2, 7);
      else return 0;
   }
   else if(keyname == "Cb")
   {
      if(Type == 1) return new KeySig(-1, -1, -1, -1, -1, -1, -1, -1, 1, 0);
      else return 0;
   }
   else if(keyname == "G#")
   {
      if(Type == 2) return new KeySig(1, 1, 0, 1, 1, 1, 0, 8, 2, 7);
      else return 0;
   }
   else
   {
      //return sentinel value
      return 0;
   }
}
