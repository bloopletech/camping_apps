//Script copyright (c) 2005 BR Fletcher & R Williams
//Portions of the code in this file are from www.quirksmode.org
//BUILD 8/12/2005 11:18AM


/*onscreen,

*/
/*the valid vertical positions for notes. element 0 is top G, element 1 is F below top G.
This is used to lock the notes to the nearest line or space in the staff.*/
var validPositionsY = new Array(
32 + 20,
44 + 20,
56 + 20,
68 + 20,
80 + 20,
92 + 20,
104 + 20,
116 + 20,
128 + 20,
140 + 20,
152 + 20,
164 + 20,
176 + 20,
188 + 20,
200 + 20,
212 + 20,
224 + 20,
236 + 20,
248 + 20,
260 + 20,
272 + 20,
284 + 20,
296 + 20);
//
var pitches = new Array(19, 17, 16, 14, 12, 11, 9, 7, 5, 4, 2, 0, -1, -3, -5, -7, -8, -10, -12, -13, -15, -17, -19);


/*the valid horizontal positions for notes. element 0 is chord one, element 1 is chord 2.
This is used to lock the notes to the nearest chord.*/
var validPositionsX = new Array(348, 470);




/*these are the vertical positions of the different sharps for the keysignature in the
treble clef.*/
var sharpHeights = new Array(1 + 20, 38 + 20, 0, 25 + 20, 62 + 20, 14 + 20, 49 + 20);

/*these are the vertical positions of the different sharps for the keysignature in the
bass clef.*/
var sharpHeights2 = new Array(213 - 23, 250 - 23, 202 - 23, 237 - 23, 274 - 23, 226 - 23, 261 - 23);

/*these are the horizonal positions of the different sharps for the keysignature for both
clefs at once. both the treble and bass horizontal positions are the same.*/
var sharpLefts = new Array(130, 160, 185, 210, 235, 260, 285);



/*these are the vertical positions of the different flats for the keysignature in the
treble clef.*/
var flatHeights = new Array(49 + 20, 14 + 20, 62 + 20, 25 + 20, 73 + 20, 38 + 20, 86 + 20);

/*these are the vertical positions of the different flatss for the keysignature in the
bass clef.*/
var flatHeights2 = new Array(261 - 23, 226 - 23, 274 - 23, 237 - 23, 285 - 23, 250 - 23, 297 - 23);

/*these are the horizonal positions of the different flats for the keysignature for both
clefs at once. both the treble and bass horizontal positions are the same.*/
var flatLefts = new Array(130, 160, 185, 210, 235, 260, 285);


/*place the flats keysignature on the web page based on `keysig`. This does both treble and bass
clef.*/
function placeFlats(keysig)
{
   /*the first `if` is used as an example.
   if `keysig`.b (b is the first flat), is flat, make the treble claf B flat visible,
   and the bass claf B flat visible.*/
   if(keysig.b == -1)
   {
      get('flats0').style.display = 'block';
      get('flats20').style.display = 'block';
   }
   if(keysig.e == -1)
   {
      get('flats1').style.display = 'block';
      get('flats21').style.display = 'block';
   }
   if(keysig.a == -1)
   {
      get('flats2').style.display = 'block';
      get('flats22').style.display = 'block';
   }
   if(keysig.d == -1)
   {
      get('flats3').style.display = 'block';
      get('flats23').style.display = 'block';
   }
   if(keysig.g == -1)
   {
      get('flats4').style.display = 'block';
      get('flats24').style.display = 'block';
   }
   if(keysig.c == -1)
   {
      get('flats5').style.display = 'block';
      get('flats25').style.display = 'block';
   }
   if(keysig.f == -1)
   {
      get('flats6').style.display = 'block';
      get('flats26').style.display = 'block';
   }
}



/*place the sharps keysignature on the web page based on `keysig`. This does both treble and
bass clef.*/
function placeSharps(keysig)
{
    /*the first `if` is used as an example.
   if `keysig`.f (f is the first sharp), is sharp, make the treble claf F sharp visible,
   and the bass claf F sharp visible.*/
   if(keysig.f == 1)
   {
      get('sharps0').style.display = 'block';
      get('sharps20').style.display = 'block';
   }
   if(keysig.c == 1)
   {
      get('sharps1').style.display = 'block';
      get('sharps21').style.display = 'block';
   }
   if(keysig.g == 1)
   {
      get('sharps2').style.display = 'block';
      get('sharps22').style.display = 'block';
   }
   if(keysig.d == 1)
   {
      get('sharps3').style.display = 'block';
      get('sharps23').style.display = 'block';
   }
   if(keysig.a == 1)
   {
      get('sharps4').style.display = 'block';
      get('sharps24').style.display = 'block';
   }
   if(keysig.e == 1)
   {
      get('sharps5').style.display = 'block';
      get('sharps25').style.display = 'block';
   }
   if(keysig.b == 1)
   {
      get('sharps6').style.display = 'block';
      get('sharps26').style.display = 'block';
   }
}

/*given a keysig `keysig`, place the sharos or flats of the keysignature on the web page.*/
function setKeySig(keysig)
{
   /*find the x and y offset of the staff off of the web page.*/
   var staffX = findPosX(get('staff'));
   var staffY = findPosY(get('staff'));

   /*position each treble clef flat relative to the staff using the positions specified
   in the arrays at the top of the script and hide the flats.*/
   for(var i = 0; i < flatHeights.length; i++)
   {
      get('flats' + i).style.left = staffX + flatLefts[i] + 'px';
      get('flats' + i).style.top = staffY + flatHeights[i] + 'px';
      get('flats' + i).style.display = 'none';
   }

   /*position each bass clef flat relative to the staff using the positions specified
   in the arrays at the top of the script and hide the flats.*/
   for(i = 0; i < flatHeights.length; i++)
   {
      get('flats2' + i).style.left = staffX + flatLefts[i] + "px";
      get('flats2' + i).style.top = staffY + flatHeights2[i] + "px";
      get('flats2' + i).style.display = 'none';
   }


   /*position each treble clef sharp relative to the staff using the positions specified
   in the arrays at the top of the script and hide the sharp.*/
   for(i = 0; i < sharpHeights.length; i++)
   {
      get('sharps' + i).style.left = staffX + sharpLefts[i] + "px";
      get('sharps' + i).style.top = staffY + sharpHeights[i] + "px";
      get('sharps' + i).style.display = 'none';
   }
   
   /*position each bass clef sharp relative to the staff using the positions specified
   in the arrays at the top of the script and hide the sharp.*/
   for(i = 0; i < sharpHeights.length; i++)
   {
      get('sharps2' + i).style.left = staffX + sharpLefts[i] + "px";
      get('sharps2' + i).style.top = staffY + sharpHeights2[i] + "px";
      get('sharps2' + i).style.display = 'none';
   }

   //if the keysig has at least one flat, place flats
   if(keysig.f == 1) placeSharps(keysig);
   //otherwise, if the keysig has at least one sharp, place sharps
   else if(keysig.b == -1) placeFlats(keysig);
}



/*place a note `semi` on the staff, given an x and y positon, and a staff x and y offset.*/
function setPos(semi, xPos, yPos, staffX, staffY)
{
   get('semi' + semi + 'con').style.left = (staffX + validPositionsX[xPos]) + "px";
   get('semi' + semi + 'con').style.top = (staffY + validPositionsY[yPos]) + "px";
}


/*given the name of a note on the web page, find out which chord it belongs to.*/
function getChord(semi)
{
   //get the x offset of the staff on the web page.
   var staffX = findPosX(get('staff'));
   /*get the x position of the note, and subtract the staff offset to get the position
   relative to the staff.*/
   var objX = findPosX(semi) - staffX;

   var chord = 0;
   for(var i = 0; i < validPositionsX.length; i++)
   {
      //if the x position of the note matches one of the valid positions
      if(validPositionsX[i] == objX)
      {
         //the chord is set to the index of the valid positions array
         chord = i;
         break;
      }
   }
   return chord;
}

/*given the name of a note on the web page, find out what it's correct pitch is.*/
function getPitch(semi)
{
   //get the y offset of the staff on the web page.
   var staffY = findPosY(get('staff'));
   /*get the y position of the note, and subtract the staff offset to get the position
   relative to the staff.*/
   var objY = findPosY(semi) - staffY;

   var pitch = 0;
   for(var i = 0; i < validPositionsY.length; i++)
   {
      //if the y position of the note matches one of the valid positions
      if(validPositionsY[i] == objY)
      {
         //the pitch is set to the index of the valid positions array
         pitch = i;
         break;
      }
   }
   return pitches[pitch];
}


/*given a vertical position, and the offset of the staff, this funtion finds the index
into the vertical valid positions array, which is nearest to the position specified.*/
function findValidIndexY(pos, offset)
{
   /*declare the range on either side of `pos` which we will include in our search for
   the correct index*/
   var smallPos = pos - 10, bigPos = pos + 10;
   var validIndex = 0;

   var validPos = validPositionsY[validIndex] + offset;

   //while the current valid position is not in the range (pos - 10, pos + 10)
   while( !( (smallPos < validPos) && (validPos < bigPos) ) )
   {
      validIndex++;
      /*if we have checked the entire valid positions array against the input `pos`,
      return the last index*/
      if(validIndex >= validPositionsY.length) return (validIndex - 1);

      validPos = validPositionsY[validIndex] + offset;
   }
   return validIndex;
}

/*given a horizontal position, and the offset of the staff, this funtion finds the index
into the horizontal valid positions array, which is nearest to the position specified.*/
function findValidIndexX(pos, offset)
{
   /*declare the range on either side of `pos` which we will include in our search for
   the correct index*/
   var smallPos = pos - 60, bigPos = pos + 60;
   var validIndex = 0;

   var validPos = validPositionsX[validIndex] + offset;

   //while the current valid position is not in the range (pos - 60, pos + 60)
   while( !( (smallPos < validPos) && (validPos < bigPos) ) )
   {
      validIndex++;
      /*if we have checked the entire valid positions array against the input `pos`,
      return the last index*/
      if(validIndex >= validPositionsX.length) return (validIndex - 1);

      validPos = validPositionsX[validIndex] + offset;
   }
   return validIndex;
}

//The following portion of code is used from quirksmode.org
//find the x position of an element on a web page.
function findPosX(obj)
{
   var curleft = 0;
   if(obj.offsetParent)
   {
      while(obj.offsetParent)
      {
         curleft += obj.offsetLeft;
         obj = obj.offsetParent;
      }
   }
   else if(obj.x) curleft += obj.x;

   return curleft;
}

//find the y position of an element on a web page.
function findPosY(obj)
{
   var curtop = 0;
   if(obj.offsetParent)
   {
      while(obj.offsetParent)
      {
         curtop += obj.offsetTop;
         obj = obj.offsetParent;
      }
   }
   else if(obj.y) curtop += obj.y;
   return curtop;
}
//end portion



//used in an array sort
function compareNumbers(a, b)
{
   return b - a;
}

//This function initializes chord1 and chord2 with their proper notes
// based on what notes the users has selected using the graphical interface
function setNotesOfChords(chord1, chord2, keysig)
{
   var output = "";


   //get the pitches of the 8 note on the web page
   var pitches = new Array(
   getPitch(get('semi1con')),
   getPitch(get('semi2con')),
   getPitch(get('semi3con')),
   getPitch(get('semi4con')),
   getPitch(get('semi5con')),
   getPitch(get('semi6con')),
   getPitch(get('semi7con')),
   getPitch(get('semi8con')));


   //get what chords the eight notes on the web page  belong to
   var chords = new Array(
   getChord(get('semi1con')),
   getChord(get('semi2con')),
   getChord(get('semi3con')),
   getChord(get('semi4con')),
   getChord(get('semi5con')),
   getChord(get('semi6con')),
   getChord(get('semi7con')),
   getChord(get('semi8con')));

   //2 arrays, 1 for each chord
   var chord1Pitches = new Array();
   var chord2Pitches = new Array();

   //place notes into the chord pitches array based on the `chords` array
   for(var i = 0; i < pitches.length; i++)
   {
      if(chords[i] == 0) chord1Pitches.push(pitches[i]);
      else chord2Pitches.push(pitches[i]);
   }


   //sort the pitches in descending order
   chord1Pitches.sort(compareNumbers);
   chord2Pitches.sort(compareNumbers);




   // check that there are 4 elements in both chord pitches arrays
   if(chord1Pitches.length < 4) output = output + "There aren't enough notes in chord 1.\n";
   if(chord1Pitches.length > 4) output = output + "There are too many notes in chord 1.\n";

   if(chord2Pitches.length < 4) output = output + "There aren't enough notes in chord 2.\n";
   if(chord2Pitches.length > 4) output = output + "There are too many notes in chord 2.\n";



   /*alter the values of `chord1Pitches` using any accidentals for that note,
   and the keysignature. Place the result into the correct part of the chird1 variable.*/
   chord1.s = convertAccKeySig(chord1Pitches[0] + 60, get('acc1i').value, keysig);
   chord1.a = convertAccKeySig(chord1Pitches[1] + 60, get('acc2i').value, keysig);
   chord1.t = convertAccKeySig(chord1Pitches[2] + 60, get('acc3i').value, keysig);
   chord1.b = convertAccKeySig(chord1Pitches[3] + 60, get('acc4i').value, keysig);


   /*alter the values of `chord2Pitches` using any accidentals for that note,
   and the keysignature. Place the result into the correct part of the chird1 variable.*/
   chord2.s = convertAccKeySig(chord2Pitches[0] + 60, get('acc5i').value, keysig);
   chord2.a = convertAccKeySig(chord2Pitches[1] + 60, get('acc6i').value, keysig);
   chord2.t = convertAccKeySig(chord2Pitches[2] + 60, get('acc7i').value, keysig);
   chord2.b = convertAccKeySig(chord2Pitches[3] + 60, get('acc8i').value, keysig);



   return output;
}



/*complete initialization of a chord.
This function initialises the triad parts of a chord.
It also initializes the name and inversion of the chord off the web page.
*/
function CIC(chord, keysig, whichChord)
{
   /*intialise the name and inversion of the chord using the input gathered by the
   webpage from the user.*/
   var temp = get('D' + whichChord).value + get('D' + (whichChord + 1)).value;

   //input into the chord the name and inversion
   var outChord = createInputChord(chord.b, chord.t, chord.a, chord.s, temp);

   //initialize the triad parts of the chord
   outChord.triad = getTriad(keysig, outChord.id, outChord.inv);
   outChord.setTriad = fixTriad(outChord.triad);

   return outChord;
}

/*this variable is used to indicate wether we are in note-raising mode or not.
See action1 for more information.*/
var raiseMode = 0;

function setRaise()
{
   raiseMode = 1;
}

/*this variable is shared between 2 functions. When a user wants to move a note,
they click the note [triggers action1]. The user then clicks where they want the
note to go [triggers secondAction].*/
var sb = null;



/*this function is attached by an onclick event to each note on the web page.
This function operates in two modes. If we are not in note-raising mode, this function saves
the note that was clicked into the sb variable.
If we are in note-raising mode, this function class the RaiseSemitone function with the
note that was clicked as the argument to thatr function.*/
function action1(e)
{
   /*stop the event from propagating to the staff, because the staff also has an onclick event
   handler, which we don't want to be called.*/
   if(!e) e = window.event;
   e.cancelBubble = true;
   if(e.stopPropagation) e.stopPropagation();



   //if in raise-mode, raiseSemitone
   if(raiseMode == 1)
   {
      raiseSemitone(this);
      raiseMode = 0;
   }
   else
   {
      sb = this;
   }
}



/*this function, given a note, raises it by a semitone, and displays the accidental on screen.*/
function raiseSemitone(sb)
{
   //this section of code is the same as the main code that is used to initialise the chord variables
   //declare chord variables
   var chord1 = new Chord(0, 0, 0, 0, 0, 0);
   var chord2 = new Chord(0, 0, 0, 0, 0, 0);

   //deckare & init keysig
   var keysig = createKeySignature((get('D70')).options[(get('D70')).selectedIndex].value,
    get('D71').options[(get('D71')).selectedIndex].value);

   //if keysig is not valid, alert the user
   if(keysig == 0)
   {
      alert("Please select a valid key signature");
      return;
   }
   //initialise parts of keysig
   calcBasedOnTonic(keysig);

   //initialise chord variables with the croeect notes from the web page
   var output = setNotesOfChords(chord1, chord2, keysig);

   //if the output isn't blank (i.e. no errors so far)
   if(output != "")
   {
      //set the output display to the output generated
      get('S1').value = output;
      return;
   }

   
   //initialize parts of the chord
   chord1 = CIC(chord1, keysig, 72);
   chord2 = CIC(chord2, keysig, 74);

   //display the keysignature to the user
   setKeySig(keysig);
   //end section


   //get the number of the note gathered
   var name = (getName(sb)).substring(4, 5);


   /*this part of the code aplies the keysig to the pitch, because the pitch is not
   currently uner any keysig.*/
   //get the pitch of the gathered note
   var pitch = getPitch(sb);
   //temporarily alter the pitch so that it is within an octave of middle C
   pitch = FO(pitch, 0);

   /*apply the keysignature to the pitch. based on the pitch of the note, add the
   keysignature for that note.*/
   switch(pitch)
   {
      case 0: pitch += keysig.c; break;
      case 2: pitch += keysig.d; break;
      case 4: pitch += keysig.e; break;
      case 5: pitch += keysig.f; break;
      case 7: pitch += keysig.g; break;
      case 9: pitch += keysig.a; break;
      case 11: pitch += keysig.b; break;
   }

   /*temporarily alter the pitch for the next bit of code so that it is within an octave
   of the tonic of the keysignature*/
   pitch = FO(pitch, keysig.tonic);


   //if the key signature is major run fixMajor, otherwise, run fixMinor
   if(keysig.Type == 1) fixMajor(keysig, name, pitch);
   else fixMinor(keysig, name, pitch);

   //move the accidental so that it is next to the note
   get('acc' + name + 'box').style.left = parseInt(sb.style.left) - 27 + "px";
   get('acc' + name + 'box').style.top = parseInt(sb.style.top) - 42 + "px";

   //nullify sb so that the accidental won't be applied twice in a row
   sb = null;
}


/*This function places an accidental on the webpage for a pitch based on the major
keysignature. The name is used to indicate which accidental on the webpage to display.*/
function fixMajor(keysig, name, pitch)
{
   //the first if is used as an example
   //if the pitch equals the tonic of the key
   if(pitch == keysig.tonic)
   {
      //if the tonic of the key is flattened
      if(keysig.tonic == -1)
      {
         //place a natural accidental
         get('acc' + name + 'i').value = " ";
         get('acc' + name + 'box').innerHTML = '<img src="natural.gif">';
      }
      //if the tonic of the key is natrual
      else if(keysig.tonic == 0)
      {
         //place a sharp accidental
         get('acc' + name + 'i').value = "#";
         get('acc' + name + 'box').innerHTML = '<img src="sharp.gif">';
      }
      //if the tonic of the key is sharp
      else
      {
         //place a double sharp accidental
         get('acc' + name + 'i').value = "x";
         get('acc' + name + 'box').innerHTML = '<img src="doublesharp.gif">';
      }
   }
   if(pitch == keysig.tonic + 2)
   {
      if(keysig.supt == -1)
      {
         get('acc' + name + 'i').value = " ";
         get('acc' + name + 'box').innerHTML = '<img src="natural.gif">';
      }
      else if(keysig.supt == 0)
      {
         get('acc' + name + 'i').value = "#";
         get('acc' + name + 'box').innerHTML = '<img src="sharp.gif">';
      }
      else
      {
         get('acc' + name + 'i').value = "x";
         get('acc' + name + 'box').innerHTML = '<img src="doublesharp.gif">';
      }
   }
   else if(pitch == keysig.tonic + 4)
   {
      if(keysig.medi == -1)
      {
         get('acc' + name + 'i').value = " ";
         get('acc' + name + 'box').innerHTML = '<img src="natural.gif">';
      }
      else if(keysig.medi == 0)
      {
         get('acc' + name + 'i').value = "#";
         get('acc' + name + 'box').innerHTML = '<img src="sharp.gif">';
      }
      else
      {
         get('acc' + name + 'i').value = "x";
         get('acc' + name + 'box').innerHTML = '<img src="doublesharp.gif">';
      }
   }
   else if(pitch == keysig.tonic + 5)
   {
      if(keysig.subd == -1)
      {
         get('acc' + name + 'i').value = " ";
         get('acc' + name + 'box').innerHTML = '<img src="natural.gif">';
      }
      else if(keysig.subd == 0)
      {
         get('acc' + name + 'i').value = "#";
         get('acc' + name + 'box').innerHTML = '<img src="sharp.gif">';
      }
      else
      {
         get('acc' + name + 'i').value = "x";
         get('acc' + name + 'box').innerHTML = '<img src="doublesharp.gif">';
      }
   }
   else if(pitch == keysig.tonic + 7)
   {
      if(keysig.domi == -1)
      {
         get('acc' + name + 'i').value = " ";
         get('acc' + name + 'box').innerHTML = '<img src="natural.gif">';
      }
      else if(keysig.domi == 0)
      {
         get('acc' + name + 'i').value = "#";
         get('acc' + name + 'box').innerHTML = '<img src="sharp.gif">';
      }
      else
      {
         get('acc' + name + 'i').value = "x";
         get('acc' + name + 'box').innerHTML = '<img src="doublesharp.gif">';
      }
   }
   else if(pitch == keysig.tonic + 9)
   {
      if(keysig.subm == -1)
      {
         get('acc' + name + 'i').value = " ";
         get('acc' + name + 'box').innerHTML = '<img src="natural.gif">';
      }
      else if(keysig.subm == 0)
      {
         get('acc' + name + 'i').value = "#";
         get('acc' + name + 'box').innerHTML = '<img src="sharp.gif">';
      }
      else
      {
         get('acc' + name + 'i').value = "x";
         get('acc' + name + 'box').innerHTML = '<img src="doublesharp.gif">';
      }
   }
   else if(pitch == keysig.tonic + 11)
   {
      if(keysig.lean == -1)
      {
         get('acc' + name + 'i').value = " ";
         get('acc' + name + 'box').innerHTML = '<img src="natural.gif">';
      }
      else if(keysig.lean == 0)
      {
         get('acc' + name + 'i').value = "#";
         get('acc' + name + 'box').innerHTML = '<img src="sharp.gif">';
      }
      else
      {
         get('acc' + name + 'i').value = "x";
         get('acc' + name + 'box').innerHTML = '<img src="doublesharp.gif">';
      }
   }
}



/*This function places an accidental on the webpage for a pitch based on the minor
keysignature. The name is used to indicate which accidental on the webpage to display.*/
function fixMinor(keysig, name, pitch)
{
   //the first if is used as an example
   //if the pitch equals the tonic of the key
   if(pitch == keysig.tonic)
   {
      //if the tonic of the key is flattened
      if(keysig.tonic == -1)
      {
         //place a natural accidental
         get('acc' + name + 'i').value = " ";
         get('acc' + name + 'box').innerHTML = '<img src="natural.gif">';
      }
      //if the tonic of the key is natrual
      else if(keysig.tonic == 0)
      {
         //place a sharp accidental
         get('acc' + name + 'i').value = "#";
         get('acc' + name + 'box').innerHTML = '<img src="sharp.gif">';
      }
      //if the tonic of the key is sharp
      else
      {
         //place a double sharp accidental
         get('acc' + name + 'i').value = "x";
         get('acc' + name + 'box').innerHTML = '<img src="doublesharp.gif">';
      }
   }
   if(pitch == keysig.tonic + 2)
   {
      if(keysig.supt == -1)
      {
         get('acc' + name + 'i').value = " ";
         get('acc' + name + 'box').innerHTML = '<img src="natural.gif">';
      }
      else if(keysig.supt == 0)
      {
         get('acc' + name + 'i').value = "#";
         get('acc' + name + 'box').innerHTML = '<img src="sharp.gif">';
      }
      else
      {
         get('acc' + name + 'i').value = "x";
         get('acc' + name + 'box').innerHTML = '<img src="doublesharp.gif">';
      }
   }
   else if(pitch == keysig.tonic + 3)
   {
      if(keysig.medi == -1)
      {
         get('acc' + name + 'i').value = " ";
         get('acc' + name + 'box').innerHTML = '<img src="natural.gif">';
      }
      else if(keysig.medi == 0)
      {
         get('acc' + name + 'i').value = "#";
         get('acc' + name + 'box').innerHTML = '<img src="sharp.gif">';
      }
      else
      {
         get('acc' + name + 'i').value = "x";
         get('acc' + name + 'box').innerHTML = '<img src="doublesharp.gif">';
      }
   }
   else if(pitch == keysig.tonic + 5)
   {
      if(keysig.subd == -1)
      {
         get('acc' + name + 'i').value = " ";
         get('acc' + name + 'box').innerHTML = '<img src="natural.gif">';
      }
      else if(keysig.subd == 0)
      {
         get('acc' + name + 'i').value = "#";
         get('acc' + name + 'box').innerHTML = '<img src="sharp.gif">';
      }
      else
      {
         get('acc' + name + 'i').value = "x";
         get('acc' + name + 'box').innerHTML = '<img src="doublesharp.gif">';
      }
   }
   else if(pitch == keysig.tonic + 7)
   {
      if(keysig.domi == -1)
      {
         get('acc' + name + 'i').value = " ";
         get('acc' + name + 'box').innerHTML = '<img src="natural.gif">';
      }
      else if(keysig.domi == 0)
      {
         get('acc' + name + 'i').value = "#";
         get('acc' + name + 'box').innerHTML = '<img src="sharp.gif">';
      }
      else
      {
         get('acc' + name + 'i').value = "x";
         get('acc' + name + 'box').innerHTML = '<img src="doublesharp.gif">';
      }
   }
   else if(pitch == keysig.tonic + 8)
   {
      if(keysig.subm == -1)
      {
         get('acc' + name + 'i').value = " ";
         get('acc' + name + 'box').innerHTML = '<img src="natural.gif">';
      }
      else if(keysig.subm == 0)
      {
         get('acc' + name + 'i').value = "#";
         get('acc' + name + 'box').innerHTML = '<img src="sharp.gif">';
      }
      else
      {
         get('acc' + name + 'i').value = "x";
         get('acc' + name + 'box').innerHTML = '<img src="doublesharp.gif">';
      }
   }
   else if(pitch == keysig.tonic + 10)
   {
      if(keysig.lean == -1)
      {
         get('acc' + name + 'i').value = " ";
         get('acc' + name + 'box').innerHTML = '<img src="natural.gif">';
      }
      else if(keysig.lean == 0)
      {
         get('acc' + name + 'i').value = "#";
         get('acc' + name + 'box').innerHTML = '<img src="sharp.gif">';
      }
      else
      {
         get('acc' + name + 'i').value = "x";
         get('acc' + name + 'box').innerHTML = '<img src="doublesharp.gif">';
      }
   }
}



//this function is triggered by the user clicking on the staff
function secondAction(e)
{
   //if the user hasn't clicked on the note yet, return
   if(sb == null) return;

   //the following portion gets the mouse position
   //The following portion of code is used from quirksmode.org
   var posx = 0;
   var posy = 0;

   if(!e) e = window.event;
   if(e.pageX || e.pageY)
   {
      posx = e.pageX;
      posy = e.pageY;
   }
   else if(e.clientX || e.clientY)
   {
      posx = e.clientX + document.body.scrollLeft;
      posy = e.clientY + document.body.scrollTop;
   }
   //end portion

   //get the horizontal offset of the staff
   var staffX = findPosX(get('staff'));
   /*set the position of the note (`sb`) to the nearest valid position. the -17 is used so
   that the center of the note is used, not the top-left corner.*/
   sb.style.left = validPositionsX[findValidIndexX(posx - 17, staffX)] + staffX + "px";

   //get the vertical offset of the staff
   var staffY = findPosY(get('staff'));
   /*set the position of the note (`sb`) to the nearest valid position. the -11 is used so
   that the center of the note is used, not the top-left corner.*/
   sb.style.top = validPositionsY[findValidIndexY(posy - 11, staffY)] + staffY + "px";

   //get the number if this note to use in the next bit of code
   var name = (getName(sb)).substring(4, 5);

   //move the accidental for this note number to the correct location/
   get('acc' + name + 'box').style.left = parseInt(sb.style.left) - 27 + 'px';
   get('acc' + name + 'box').style.top = parseInt(sb.style.top) - 42 + 'px';

   //set `sb` to null so that this function isn't called twice in a row by the user
   sb = null;
}


/*this function adds the onlick triggers to the notes and to the staff,
and sets the initial positions of the notes on the staff.*/
function addMouseOver()
{
   //add the onclick handlers
   get('staff').onclick = secondAction;
   get('semi1con').onclick = action1;
   get('semi2con').onclick = action1;
   get('semi3con').onclick = action1;
   get('semi4con').onclick = action1;
   get('semi5con').onclick = action1;
   get('semi6con').onclick = action1;
   get('semi7con').onclick = action1;
   get('semi8con').onclick = action1;


   //get offsets of the staff
   var staffX = findPosX(get('staff'));
   var staffY = findPosY(get('staff'));
   //position the notes
   setPos(1, 0, 0, staffX, staffY);
   setPos(2, 0, 2, staffX, staffY);
   setPos(3, 0, 11, staffX, staffY);
   setPos(4, 0, 18, staffX, staffY);
   setPos(5, 1, 0, staffX, staffY);
   setPos(6, 1, 3, staffX, staffY);
   setPos(7, 1, 12, staffX, staffY);
   setPos(8, 1, 14, staffX, staffY);

}

//this function erases all note raising
function resetRaise()
{
   //hide all accidentals
   for(var i = 1; i <= 8; i++)
   {
      get('acc' + i + 'i').value = 'none';
      get('acc' + i + 'box').innerHTML = '';
   }
}



//repositon the note to make sure it is where it belongs
function rePosSB(sb)
{
   //get the current position of `sb`
   var posx = parseInt(sb.style.left);
   var posy = parseInt(sb.style.top);

   //get the x offset of the staff
   var staffX = findPosX(get('staff'));
   //set the position of `sb` to the nearest valid x position
   sb.style.left = validPositionsX[findValidIndexX(posx, staffX)] + staffX + "px";

   //get the y offset of the staff
   var staffY = findPosY(get('staff'));
   //set the position of `sb` to the nearest valid y position
   sb.style.top = validPositionsY[findValidIndexY(posy, staffY)] + staffY + "px";

   //reposition sb to the new position
   var name = (getName(sb)).substring(4, 5);
   get('acc" + name + "box').style.left = parseInt(sb.style.left) - 27 + 'px';
   get('acc" + name + "box').style.top = parseInt(sb.style.top) - 42 + 'px';

   sb = null;
}

/*check the positions of the notes and keysignature and reposition them if nessacery.
Used for example, if an elemnt on the web page changes size, the staff is moved, and
so the notes must be moved as well.*/
function rePosition()
{
   rePosSB(get('semi1con'));
   rePosSB(get('semi2con'));
   rePosSB(get('semi3con'));
   rePosSB(get('semi4con'));
   rePosSB(get('semi5con'));
   rePosSB(get('semi6con'));
   rePosSB(get('semi7con'));
   rePosSB(get('semi8con'));
}
