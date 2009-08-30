//Script copyright (c) 2005 BR Fletcher & R Williams
//BUILD 7/19/2005 12:54PM


/*this function checks that that the vvoices fore chord one and two don't go outside their
singing range.*/
function checkRanges(chord1, chord2)
{
   var output = "";

   //the first two if statements are used as an example.
   //if the first chords soprano is higher than it's range, add a mesage to the output
   if(chord1.s > 79) output = output + "In the soprano part for chord 1, you wrote a note that is too high for the soprano voice to sing.\n";
   //if the first chords soprano is lower than it's range, add a mesage to the output
   if(chord1.s < 60) output = output + "In the soprano part for chord 1, you wrote a note that is too low for the soprano voice to sing.\n";
   //and so on...
   if(chord1.a > 74) output = output + "In the alto part for chord 1, you wrote a note that is too high for the alto voice to sing.\n";
   if(chord1.a < 55) output = output + "In the alto part for chord 1, you wrote a note that is too low for the alto voice to sing.\n";
   if(chord1.t > 67) output = output + "In the tenor part for chord 1, you wrote a note that is too high for the tenor voice to sing.\n";
   if(chord1.t < 36) output = output + "In the tenor part for chord 1, you wrote a note that is too low for the tenor voice to sing.\n";
   if(chord1.b > 62) output = output + "In the bass part for chord 1, you wrote a note that is too high for the bass voice to sing.\n";
   if(chord1.b < 29) output = output + "In the bass part for chord 1, you wrote a note that is too low for the bass voice to sing.\n";



   //this is that same as above, except for chord 2 instead of chord 1
   if(chord2.s > 79) output = output + "In the soprano part for chord 2, you wrote a note that is too high for the soprano voice to sing.\n";
   if(chord2.s < 60) output = output + "In the soprano part for chord 2, you wrote a note that is too low for the soprano voice to sing.\n";
   if(chord2.a > 74) output = output + "In the alto part for chord 2, you wrote a note that is too high for the alto voice to sing.\n";
   if(chord2.a < 55) output = output + "In the alto part for chord 2, you wrote a note that is too low for the alto voice to sing.\n";
   if(chord2.t > 67) output = output + "In the tenor part for chord 2, you wrote a note that is too high for the tenor voice to sing.\n";
   if(chord2.t < 36) output = output + "In the tenor part for chord 2, you wrote a note that is too low for the tenor voice to sing.\n";
   if(chord2.b > 62) output = output + "In the bass part for chord 2, you wrote a note that is too high for the bass voice to sing.\n";
   if(chord2.b < 29) output = output + "In the bass part for chord 2, you wrote a note that is too low for the bass voice to sing.\n";

   //return any messages
   return output;
}


/*this function checks for consecutive fifths or octaves between two voice parts in chord 1
and chord 2.
 
The definition of a consecutive fifth also extends to a consecutive interval of an
octave + a fifth, or multiple octaves + a fifth. The definition of a consecutive octave also
extends to a consecutive interval of an octave + a octave, or multiple octaves + a octave.
This function checks for the extended definition of cosecutives.*/
function checkFifthsOctaves(chord1, chord2)
{
   var output = "";


/////////////////// THIS section of code checks for consecutive fifths [+ octave(s)] //////




//////this portion of code checks for consecutive intervals between the soprano and other voices.

   //chord1.s to chord1.b and chord2.s to chord2.b represent the pitches of the voice parts
   //make copies of chord1.s to chord2.b
   var s1 = chord1.s, a1 = chord1.a, t1 = chord1.t, b1 = chord1.b;
   var s2 = chord2.s, a2 = chord2.a, t2 = chord2.t, b2 = chord2.b;


   //this code puts all of the voice parts in the same octave as the soprano
   while((s1 - a1) > 7) a1 += 12;
   while((s2 - a2) > 7) a2 += 12;
   while((s1 - t1) > 7) t1 += 12;
   while((s2 - t2) > 7) t2 += 12;
   while((s1 - b1) > 7) b1 += 12;
   while((s2 - b2) > 7) b2 += 12;


   //check for plain fifths in chord 1 - chord 2
   if((s1 - a1) == 7)
   {
      if((s2 - a2) == 7) output = output + "There is a consecutive fifth [+ octave(s)] between the soprano and alto voices.\n";
   }
   if((s1 - t1) == 7)
   {
      if((s2 - t2) == 7) output = output + "There is a consecutive fifth [+ octave(s)] between the soprano and tenor voices.\n";
   }
   if((s1 - b1) == 7)
   {
      if((s2 - b2) == 7) output = output + "There is a consecutive fifth [+ octave(s)] between the soprano and bass voices.\n";
   }



//////end portion that checks for consecutive intervals between the soprano and the other voices



//////this portion of code checks for consecutive intervals between the alto and other voices.

   
   
   //make copies of chord1.s to chord2.b
   s1 = chord1.s, a1 = chord1.a, t1 = chord1.t, b1 = chord1.b;
   s2 = chord2.s, a2 = chord2.a, t2 = chord2.t, b2 = chord2.b;

   //this puts all the voice parts in the same octave as the alto
   while((a1 - t1) > 7) t1 += 12;
   while((a2 - t2) > 7) t2 += 12;
   while((a1 - b1) > 7) b1 += 12;
   while((a2 - b2) > 7) b2 += 12;


   //check for plain fifths in chord 1 - chord 2
   if((a1 - t1) == 7)
   {
      if((a2 - t2) == 7) output = output + "There is a consecutive fifth [+ octave(s)] between the alto and tenor voices.\n";
   }
   if((a1 - b1) == 7)
   {
      if((a2 - b2) == 7) output = output + "There is a consecutive fifth [+ octave(s)] bewteen the alto and bass voices.\n";
   }



//////end portion that checks for consecutive intervals between the alto and the other voices



//////this portion of code checks for consecutive intervals between the tenor and other voices.


   //make copies of chord1.s to chord2.b
   s1 = chord1.s, a1 = chord1.a, t1 = chord1.t, b1 = chord1.b;
   s2 = chord2.s, a2 = chord2.a, t2 = chord2.t, b2 = chord2.b;

   //this puts all the voice parts in the same octave as the alto
   while((t1 - b1) > 7) b1 += 12;
   while((t2 - b2) > 7) b2 += 12;


   //check for plain fifths in chord 1 - chord 2
   if((t1 - b1) == 7)
   {
      if((t2 - b2) == 7) output = output + "There is a consecutive fifth [+ octave(s)] between the tenor and bass voices.\n";
   }







/////////////////// THIS section of code checks for consecutive octaves [+ octave(s)] //////


//////this portion of code checks for consecutive intervals between the soprano and other voices.

   //make copies of chord1.s to chord2.b
   s1 = chord1.s, a1 = chord1.a, t1 = chord1.t, b1 = chord1.b;
   s2 = chord2.s, a2 = chord2.a, t2 = chord2.t, b2 = chord2.b;

   //this code puts all of the voice parts in the same octave as the soprano
   while((s1 - a1) > 12) a1 += 12;
   while((s2 - a2) > 12) a2 += 12;
   while((s1 - t1) > 12) t1 += 12;
   while((s2 - t2) > 12) t2 += 12;
   while((s1 - b1) > 12) b1 += 12;
   while((s2 - b2) > 12) b2 += 12;

   //check for plain octaves in chord 1 - chord 2
   if((s1 - a1) == 12)
   {
      if((s2 - a2) == 12) output = output + "There is a consecutive octave(s) between the soprano and alto voices.\n";
   }
   if((s1 - t1) == 12)
   {
      if((s2 - t2) == 12) output = output + "There is a consecutive octave(s) between the soprano and tenor voices.\n";
   }
   if((s1 - b1) == 12)
   {
      if((s2 - b2) == 12) output = output + "There is a consecutive octave(s) between the soprano and bass voices.\n";
   }


   //make copies of chord1.s to chord2.b
   s1 = chord1.s, a1 = chord1.a, t1 = chord1.t, b1 = chord1.b;
   s2 = chord2.s, a2 = chord2.a, t2 = chord2.t, b2 = chord2.b;

   //this code puts all of the voice parts in the same octave as the alto
   while((a1 - t1) > 12) t1 += 12;
   while((a2 - t2) > 12) t2 += 12;
   while((a1 - b1) > 12) b1 += 12;
   while((a2 - b2) > 12) b2 += 12;

   //check for plain octaves in chord 1 - chord 2
   if((a1 - t1) == 12)
   {
      if((a2 - t2) == 12) output = output + "There is a consecutive octave(s) between the alto and tenor voices.\n";
   }
   if((a1 - b1) == 12)
   {
      if((a2 - b2) == 12) output = output + "There is a consecutive octave(s) bewteen the alto and bass voices.\n";
   }



   //make copies of chord1.s to chord2.b
   s1 = chord1.s, a1 = chord1.a, t1 = chord1.t, b1 = chord1.b;
   s2 = chord2.s, a2 = chord2.a, t2 = chord2.t, b2 = chord2.b;

   //this code puts all of the voice parts in the same octave as the tenor
   while((t1 - b1) > 12) b1 += 12;
   while((t2 - b2) > 12) b2 += 12;


   //check for plain octaves in chord 1 - chord 2
   if((t1 - b1) == 12)
   {
      if((t2 - b2) == 12) output = output + "There is a consecutive octave between the tenor and bass voices.\n";
   }


   //return any output messages
   return output;
}



//this function checks that the user has not omitted the root or the third from their chords.
//note: in this function, root ten alt sop, are NOT from 0
//chord is the chord to check, 

function checkRootsThirds(chord, chordType)
{
   var output = "";

   //allocate storage for the root to fifth of the chord
   var root = chord.b;
   var sop = chord.s;
   var alt = chord.a;
   var ten = chord.t;

   /*put the root in the octave of Middle C.
   We do this becaue the chord's setTriad is in the octave of C major,
   and we want to compare them.*/
   root = FO(root, 0);

   /*this section of code checks that the bass note matches the root of the triad for this chord.
   for example, if the triad is CEG, this checks that the bass note is C.
   if the chord is in root position*/
   if(chord.inv == 1)
   {
      /*if the root of this chord doesn't match with the root it's suposed to have,
      output a message*/
      if(root != chord.setTriad.root) output = "The base part for chord " + chordType + " does not match the inversion specified.\n";
   }
   //if the chord is in first inversion
   else if(chord.inv == 2)
   {
      /*if the root of this chord doesn't match with the root it's suposed to have,
      output a message*/
      if(root != chord.setTriad.third) output = "The base part for chord " + chordType + " does not match the inversion specified.\n";
   }
   //if the chord is in second inversion
   else if(chord.inv == 3)
   {
      /*if the root of this chord doesn't match with the root it's suposed to have,
      output a message*/
      if(root != chord.setTriad.fifth) output = "The base part for chord " + chordType + " does not match the inversion specified.\n";
   }


   //put the notes of the chord in the octave of Middle C
   sop = FO(sop, 0);
   alt = FO(alt, 0);
   ten = FO(ten, 0);

   //this is a counter variable
   var tc = 0;
   
   //count how many times the setTriad's root occures in the chord
   if(chord.setTriad.root == root) tc++;
   if(chord.setTriad.root == alt) tc++;
   if(chord.setTriad.root == ten) tc++;
   if(chord.setTriad.root == sop) tc++;

   //if the user has omitted the root, print a message
   if(tc == 0) output = output + "You have ommitted the root in chord " + chordType + ".\n";


   //reset the counter variable
   tc = 0;

   //count how many times the setTriad's third occures in the chord
   if(chord.setTriad.third == root) tc++;
   if(chord.setTriad.third == alt) tc++;
   if(chord.setTriad.third == ten) tc++;
   if(chord.setTriad.third == sop) tc++;


   //if the user has omitted the third, print a message
   if(tc == 0) output = output + "You have ommitted the third in chord " + chordType + ".\n";

   /*if the user has doubled, tripled, or quadrupled, the third, and this isn't chord 6 (where
   you are allowed to double the third), print a message.*/
   if((tc > 1) && (chord.id != 6)) output = output + "You have included the third more than once in chord " + chordType + ".\n";

   //return output messages
   return output;
}

//this function is not used in this version; it may be used in the next version.
function checkPresenceLeadingNote(chord1, chord2, keySig)
{
   var output = "";

   if(keySig.Type == 1) return "";

   var seventh = (keySig.tonic - 2) + 12;

   var root = chord1.b;
   var sop = chord1.s;
   var alt = chord1.a;
   var ten = chord1.t;

   while(sop >= (root + 12)) sop -= 12;
   while(alt >= (root + 12)) alt -= 12;
   while(ten >= (root + 12)) ten -= 12;

   if(sop == seventh) output = output + "In the soprano voice for chord 1, you have not raised the leading note. The leading note ofa minorkeymust always be raised.";
   if(alt == seventh) output = output + "In the alto voice for chord 1, you have not raised the leading note. The leading note ofa minorkeymust always be raised.";
   if(ten == seventh) output = output + "In the tenor voice for chord 1, you have not raised the leading note. The leading note ofa minorkeymust always be raised.";
   if(root == seventh) output = output + "In the bass voice for chord 1, you have not raised the leading note. The leading note ofa minorkeymust always be raised.";


   root = chord2.b;
   sop = chord2.s;
   alt = chord2.a;
   ten = chord2.t;

   while(sop >= (root + 12)) sop -= 12;
   while(alt >= (root + 12)) alt -= 12;
   while(ten >= (root + 12)) ten -= 12;

   if(sop == seventh) output = output + "In the soprano voice for chord 2, you have not raised the leading note. The leading note ofa minorkeymust always be raised.";
   if(alt == seventh) output = output + "In the alto voice for chord 2, you have not raised the leading note. The leading note ofa minorkeymust always be raised.";
   if(ten == seventh) output = output + "In the tenor voice for chord 2, you have not raised the leading note. The leading note ofa minorkeymust always be raised.";
   if(root == seventh) output = output + "In the bass voice for chord 2, you have not raised the leading note. The leading note ofa minorkeymust always be raised.";

   return output;
}


