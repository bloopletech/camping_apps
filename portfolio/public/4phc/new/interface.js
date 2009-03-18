//Script copyright (c) 2005 BR Fletcher & R Williams
//Portions of the code in this file are from www.quirksmode.org
//BUILD 7/19/2005 12:57PM

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
var pitches = new Array(19, 17, 16, 14, 12, 11, 9, 7, 5, 4, 2, 0, -1, -3, -5, -7, -8, -10, -12, -13, -15, -17, -19);


var validPositionsX = new Array(348, 470);


var sharpHeights = new Array(1 + 20, 38 + 20, 0, 25 + 20, 62 + 20, 14 + 20, 49 + 20);
var sharpHeights2 = new Array(213 - 23, 250 - 23, 202 - 23, 237 - 23, 274 - 23, 226 - 23, 261 - 23);
var sharpLefts = new Array(130, 160, 185, 210, 235, 260, 285);

var flatHeights = new Array(49 + 20, 14 + 20, 62 + 20, 25 + 20, 73 + 20, 38 + 20, 86 + 20);
var flatHeights2 = new Array(261 - 23, 226 - 23, 274 - 23, 237 - 23, 285 - 23, 250 - 23, 297 - 23);
var flatLefts = new Array(130, 160, 185, 210, 235, 260, 285);


function placeFlats(keysig)
{
   if(keysig.b == -1)
   {
      document.all.flats0.style.display = "";
      document.all.flats20.style.display = "";
   }
   if(keysig.e == -1)
   {
      document.all.flats1.style.display = "";
      document.all.flats21.style.display = "";
   }
   if(keysig.a == -1)
   {
      document.all.flats2.style.display = "";
      document.all.flats22.style.display = "";
   }
   if(keysig.d == -1)
   {
      document.all.flats3.style.display = "";
      document.all.flats23.style.display = "";
   }
   if(keysig.g == -1)
   {
      document.all.flats4.style.display = "";
      document.all.flats24.style.display = "";
   }
   if(keysig.c == -1)
   {
      document.all.flats5.style.display = "";
      document.all.flats25.style.display = "";
   }
   if(keysig.f == -1)
   {
      document.all.flats6.style.display = "";
      document.all.flats26.style.display = "";
   }
}


function placeSharps(keysig)
{
   if(keysig.f == 1)
   {
      document.all.sharps0.style.display = "";
      document.all.sharps20.style.display = "";
   }
   if(keysig.c == 1)
   {
      document.all.sharps1.style.display = "";
      document.all.sharps21.style.display = "";
   }
   if(keysig.g == 1)
   {
      document.all.sharps2.style.display = "";
      document.all.sharps22.style.display = "";
   }
   if(keysig.d == 1)
   {
      document.all.sharps3.style.display = "";
      document.all.sharps23.style.display = "";
   }
   if(keysig.a == 1)
   {
      document.all.sharps4.style.display = "";
      document.all.sharps24.style.display = "";
   }
   if(keysig.e == 1)
   {
      document.all.sharps5.style.display = "";
      document.all.sharps25.style.display = "";
   }
   if(keysig.b == 1)
   {
      document.all.sharps6.style.display = "";
      document.all.sharps26.style.display = "";
   }
}

function setKeySig(keysig)
{
   var staffX = findPosX(document.all.staff);
   var staffY = findPosY(document.all.staff);

   for(var i = 0; i < flatHeights.length; i++)
   {
      eval("document.all.flats" + i + ".style.left = staffX + flatLefts[" + i + "];");
      eval("document.all.flats" + i + ".style.top = staffY + flatHeights[" + i + "];");
      eval("document.all.flats" + i + ".style.display = 'none';");
   }
   for(var i = 0; i < flatHeights.length; i++)
   {
      eval("document.all.flats2" + i + ".style.left = staffX + flatLefts[" + i + "];");
      eval("document.all.flats2" + i + ".style.top = staffY + flatHeights2[" + i + "];");
      eval("document.all.flats2" + i + ".style.display = 'none';");
   }


   for(var i = 0; i < sharpHeights.length; i++)
   {
      eval("document.all.sharps" + i + ".style.left = staffX + sharpLefts[" + i + "];");
      eval("document.all.sharps" + i + ".style.top = staffY + sharpHeights[" + i + "];");
      eval("document.all.sharps" + i + ".style.display = 'none';");
   }
   for(var i = 0; i < sharpHeights.length; i++)
   {
      eval("document.all.sharps2" + i + ".style.left = staffX + sharpLefts[" + i + "];");
      eval("document.all.sharps2" + i + ".style.top = staffY + sharpHeights2[" + i + "];");
      eval("document.all.sharps2" + i + ".style.display = 'none';");
   }

   //alert(keysig.b);

   if(keysig.f == 1)
   {
      placeSharps(keysig);
   }
   else if(keysig.b == -1)
   {
      placeFlats(keysig);
   }
}



function setPos(semi, xPos, yPos, staffX, staffY)
{
   eval("document.all.semi" + semi + "con.style.left = staffX + validPositionsX[xPos]");
   eval("document.all.semi" + semi + "con.style.top = staffY + validPositionsY[yPos]");
}

function getChord(semi)
{
   var staffX = findPosX(document.all.staff);
   var objX = findPosX(semi) - staffX;

   var chord = 0;
   for(var i = 0; i < validPositionsX.length; i++)
   {
      if(validPositionsX[i] == objX)
      {
         chord = i;
         break;
      }
   }
   return chord;
}

function getPitch(semi)
{
   var staffY = findPosY(document.all.staff);
   var objY = findPosY(semi) - staffY;

   var pitch = 0;
   for(var i = 0; i < validPositionsY.length; i++)
   {
      if(validPositionsY[i] == objY)
      {
         pitch = i;
         break;
      }
   }
   return pitches[pitch];
}


function findValidIndexY(pos, offset)
{
   var smallPos = pos - 10, bigPos = pos + 10;
   var validIndex = 0;

   var validPos = validPositionsY[validIndex] + offset;

   while( !( (smallPos < validPos) && (validPos < bigPos) ) )
   {
      validIndex++;
      if(validIndex >= validPositionsY.length)
      {
         return (validIndex - 1);
      }
      validPos = validPositionsY[validIndex] + offset;
   }
   return validIndex;
}

function findValidIndexX(pos, offset)
{
   var smallPos = pos - 60, bigPos = pos + 60;
   var validIndex = 0;

   var validPos = validPositionsX[validIndex] + offset;

   while( !( (smallPos < validPos) && (validPos < bigPos) ) )
   {
      validIndex++;
      if(validIndex >= validPositionsX.length)
      {
         return (validIndex - 1);
      }
      validPos = validPositionsX[validIndex] + offset;
   }
   return validIndex;
}


function findPosX(obj)
{
   var curleft = 0;
   if (obj.offsetParent)
   {
      while (obj.offsetParent)
      {
         curleft += obj.offsetLeft;
         obj = obj.offsetParent;
      }
   }
   else if (obj.x)
      curleft += obj.x;
   return curleft;
}

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
   else if(obj.y)
      curtop += obj.y;
   return curtop;
}




function compareNumbers(a, b)
{
   return b - a;
}

//This function initializes chord1 and chord2 with their proper notes
// based on what notes the users has selected using the graphical interface
function setNotesOfChords(chord1, chord2, keysig, srcDoc)
{
   //alert(srcDoc.all.D70.selectedIndex);
   var output = "";


   var pitches = new Array(
   getPitch(srcDoc.all.semi1con),
   getPitch(srcDoc.all.semi2con),
   getPitch(srcDoc.all.semi3con),
   getPitch(srcDoc.all.semi4con),
   getPitch(srcDoc.all.semi5con),
   getPitch(srcDoc.all.semi6con),
   getPitch(srcDoc.all.semi7con),
   getPitch(srcDoc.all.semi8con));


   var chords = new Array(
   getChord(srcDoc.all.semi1con),
   getChord(srcDoc.all.semi2con),
   getChord(srcDoc.all.semi3con),
   getChord(srcDoc.all.semi4con),
   getChord(srcDoc.all.semi5con),
   getChord(srcDoc.all.semi6con),
   getChord(srcDoc.all.semi7con),
   getChord(srcDoc.all.semi8con));

   var chord1Pitches = new Array();
   var chord2Pitches = new Array();

   for(var i = 0; i < pitches.length; i++)
   {
      if(chords[i] == 0)
      {
         chord1Pitches.push(pitches[i]);
      }
      else
      {
         chord2Pitches.push(pitches[i]);
      }
   }

   chord1Pitches.sort(compareNumbers);
   chord2Pitches.sort(compareNumbers);
   //alert("chord1Pitches: " + chord1Pitches);




   if(chord1Pitches.length < 4)
   {
      output = output + "There aren't enough notes in chord 1.\n";
   }
   if(chord1Pitches.length > 4)
   {
      output = output + "There are too many notes in chord 1.\n";
   }



   if(chord2Pitches.length < 4)
   {
      output = output + "There aren't enough notes in chord 2.\n";
   }
   if(chord2Pitches.length > 4)
   {
      output = output + "There are too many notes in chord 2.\n";
   }



   chord1.s = convertAccKeySig(chord1Pitches[0] + 60, srcDoc.all.acc1i.value, keysig);
   chord1.a = convertAccKeySig(chord1Pitches[1] + 60, srcDoc.all.acc2i.value, keysig);
   chord1.t = convertAccKeySig(chord1Pitches[2] + 60, srcDoc.all.acc3i.value, keysig);
   chord1.b = convertAccKeySig(chord1Pitches[3] + 60, srcDoc.all.acc4i.value, keysig);


   chord2.s = convertAccKeySig(chord2Pitches[0] + 60, srcDoc.all.acc5i.value, keysig);
   chord2.a = convertAccKeySig(chord2Pitches[1] + 60, srcDoc.all.acc6i.value, keysig);
   chord2.t = convertAccKeySig(chord2Pitches[2] + 60, srcDoc.all.acc7i.value, keysig);
   chord2.b = convertAccKeySig(chord2Pitches[3] + 60, srcDoc.all.acc8i.value, keysig);



   return output;
}



function CIC(chord, keysig, whichChord)
{
   var temp = "";
   eval("temp = document.all.D" + whichChord +
     ".options[document.all.D" + whichChord +
     ".selectedIndex].value + document.all.D" + (whichChord + 1) +
     ".options[document.all.D" + (whichChord + 1) +
     ".selectedIndex].value");

   var outChord = createInputChord(chord.b, chord.t, chord.a, chord.s, temp);

   outChord.triad = getTriad(keysig, outChord.id, outChord.inv);
   outChord.setTriad = fixTriad(outChord.triad);

   return outChord;
}


var raiseMode = 0;

function setRaise()
{
   raiseMode = 1;
}

var sb = null;
function action1(who, e)
{
   if (!e) var e = window.event;
   e.cancelBubble = true;
   if (e.stopPropagation) e.stopPropagation();



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



function raiseSemitone(sb)
{
   var chord1 = new Chord(0, 0, 0, 0, 0, 0);
   var chord2 = new Chord(0, 0, 0, 0, 0, 0);

   var keysig = createKeySignature(document.forms[0].D70.options[document.forms[0].D70.selectedIndex].value,
    document.forms[0].D71.options[document.forms[0].D71.selectedIndex].value);
   if(keysig == 0)
   {
      alert("Please select a valid key signature");
      return;
   }
   calcBasedOnTonic(keysig);

   output = setNotesOfChords(chord1, chord2, keysig, document);

   if(output != "")
   {
      document.forms[0].S1.value = output;
      return;
   }

   chord1 = CIC(chord1, keysig, 72);
   chord2 = CIC(chord2, keysig, 74);

   setKeySig(keysig);


   var name = sb.name.substring(4, 5);
   var pitch = getPitch(sb);
   pitch = FO(pitch, 0);

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

   pitch = FO(pitch, keysig.tonic);


   if(keysig.Type == 1) fixMajor(keysig, name, pitch);
   else fixMinor(keysig, name, pitch);

   eval("document.all.acc" + name + "box.style.left = parseInt(sb.style.left) - 27;");
   eval("document.all.acc" + name + "box.style.top = parseInt(sb.style.top) - 42;");
   //alert(eval("document.all.acc" + name + "box.innerHTML;"));
   sb = null;
}


function fixMajor(keysig, name, pitch)
{
   if(pitch == keysig.tonic)
   {
      if(keysig.tonic == -1)
      {
         eval("document.all.acc" + name + "i.value = \" \";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"natural.gif\">';");
      }
      else if(keysig.tonic == 0)
      {
         eval("document.all.acc" + name + "i.value = \"#\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"sharp.gif\">';");
      }
      else
      {
         eval("document.all.acc" + name + "i.value = \"x\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"doublesharp.gif\">';");
      }
   }
   if(pitch == keysig.tonic + 2)
   {
      if(keysig.supt == -1)
      {
         eval("document.all.acc" + name + "i.value = \" \";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"natural.gif\">';");
      }
      else if(keysig.supt == 0)
      {
         eval("document.all.acc" + name + "i.value = \"#\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"sharp.gif\">';");
      }
      else
      {
         eval("document.all.acc" + name + "i.value = \"x\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"doublesharp.gif\">';");
      }
   }
   else if(pitch == keysig.tonic + 4)
   {
      if(keysig.medi == -1)
      {
         eval("document.all.acc" + name + "i.value = \" \";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"natural.gif\">';");
      }
      else if(keysig.medi == 0)
      {
         eval("document.all.acc" + name + "i.value = \"#\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"sharp.gif\">';");
      }
      else
      {
         eval("document.all.acc" + name + "i.value = \"x\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"doublesharp.gif\">';");
      }
   }
   else if(pitch == keysig.tonic + 5)
   {
      if(keysig.subd == -1)
      {
         eval("document.all.acc" + name + "i.value = \" \";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"natural.gif\">';");
      }
      else if(keysig.subd == 0)
      {
         eval("document.all.acc" + name + "i.value = \"#\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"sharp.gif\">';");
      }
      else
      {
         eval("document.all.acc" + name + "i.value = \"x\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"doublesharp.gif\">';");
      }
   }
   else if(pitch == keysig.tonic + 7)
   {
      if(keysig.domi == -1)
      {
         eval("document.all.acc" + name + "i.value = \" \";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"natural.gif\">';");
      }
      else if(keysig.domi == 0)
      {
         eval("document.all.acc" + name + "i.value = \"#\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"sharp.gif\">';");
      }
      else
      {
         eval("document.all.acc" + name + "i.value = \"x\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"doublesharp.gif\">';");
      }
   }
   else if(pitch == keysig.tonic + 9)
   {
      if(keysig.subm == -1)
      {
         eval("document.all.acc" + name + "i.value = \" \";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"natural.gif\">';");
      }
      else if(keysig.subm == 0)
      {
         eval("document.all.acc" + name + "i.value = \"#\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"sharp.gif\">';");
      }
      else
      {
         eval("document.all.acc" + name + "i.value = \"x\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"doublesharp.gif\">';");
      }
   }
   else if(pitch == keysig.tonic + 11)
   {
      if(keysig.lean == -1)
      {
         eval("document.all.acc" + name + "i.value = \" \";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"natural.gif\">';");
      }
      else if(keysig.lean == 0)
      {
         eval("document.all.acc" + name + "i.value = \"#\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"sharp.gif\">';");
      }
      else
      {
         eval("document.all.acc" + name + "i.value = \"x\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"doublesharp.gif\">';");
      }
   }
}




function fixMinor(keysig, name, pitch)
{
   if(pitch == keysig.tonic)
   {
      if(keysig.tonic == -1)
      {
         eval("document.all.acc" + name + "i.value = \" \";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"natural.gif\">';");
      }
      else if(keysig.tonic == 0)
      {
         eval("document.all.acc" + name + "i.value = \"#\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"sharp.gif\">';");
      }
      else
      {
         eval("document.all.acc" + name + "i.value = \"x\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"doublesharp.gif\">';");
      }
   }
   if(pitch == keysig.tonic + 2)
   {
      if(keysig.supt == -1)
      {
         eval("document.all.acc" + name + "i.value = \" \";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"natural.gif\">';");
      }
      else if(keysig.supt == 0)
      {
         eval("document.all.acc" + name + "i.value = \"#\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"sharp.gif\">';");
      }
      else
      {
         eval("document.all.acc" + name + "i.value = \"x\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"doublesharp.gif\">';");
      }
   }
   else if(pitch == keysig.tonic + 3)
   {
      if(keysig.medi == -1)
      {
         eval("document.all.acc" + name + "i.value = \" \";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"natural.gif\">';");
      }
      else if(keysig.medi == 0)
      {
         eval("document.all.acc" + name + "i.value = \"#\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"sharp.gif\">';");
      }
      else
      {
         eval("document.all.acc" + name + "i.value = \"x\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"doublesharp.gif\">';");
      }
   }
   else if(pitch == keysig.tonic + 5)
   {
      if(keysig.subd == -1)
      {
         eval("document.all.acc" + name + "i.value = \" \";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"natural.gif\">';");
      }
      else if(keysig.subd == 0)
      {
         eval("document.all.acc" + name + "i.value = \"#\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"sharp.gif\">';");
      }
      else
      {
         eval("document.all.acc" + name + "i.value = \"x\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"doublesharp.gif\">';");
      }
   }
   else if(pitch == keysig.tonic + 7)
   {
      if(keysig.domi == -1)
      {
         eval("document.all.acc" + name + "i.value = \" \";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"natural.gif\">';");
      }
      else if(keysig.domi == 0)
      {
         eval("document.all.acc" + name + "i.value = \"#\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"sharp.gif\">';");
      }
      else
      {
         eval("document.all.acc" + name + "i.value = \"x\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"doublesharp.gif\">';");
      }
   }
   else if(pitch == keysig.tonic + 8)
   {
      if(keysig.subm == -1)
      {
         eval("document.all.acc" + name + "i.value = \" \";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"natural.gif\">';");
      }
      else if(keysig.subm == 0)
      {
         eval("document.all.acc" + name + "i.value = \"#\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"sharp.gif\">';");
      }
      else
      {
         eval("document.all.acc" + name + "i.value = \"x\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"doublesharp.gif\">';");
      }
   }
   else if(pitch == keysig.tonic + 10)
   {
      //alert("keysig.tonic + 10");
      if(keysig.lean == -1)
      {
         eval("document.all.acc" + name + "i.value = \" \";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"natural.gif\">';");
      }
      else if(keysig.lean == 0)
      {
         eval("document.all.acc" + name + "i.value = \"#\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"sharp.gif\">';");
      }
      else
      {
         eval("document.all.acc" + name + "i.value = \"x\";");
         eval("document.all.acc" + name + "box.innerHTML = '<img src=\"doublesharp.gif\">';");
      }
   }
}




function secondAction(e)
{
//yakyak();
   if(sb == null)
   {
      return;
   }
   var posx = 0;
   var posy = 0;
   if (!e) var e = window.event;
   if (e.pageX || e.pageY)
   {
      posx = e.pageX;
      posy = e.pageY;
   }
   else if (e.clientX || e.clientY)
   {
      posx = e.clientX + document.body.scrollLeft;
      posy = e.clientY + document.body.scrollTop;
   }
   var staffX = findPosX(document.all.staff);
   sb.style.left = validPositionsX[findValidIndexX(posx - 17, staffX)] + staffX;

   var staffY = findPosY(document.all.staff);
   sb.style.top = validPositionsY[findValidIndexY(posy - 11, staffY)] + staffY;

   var name = sb.name.substring(4, 5);
   //alert(name);
   eval("document.all.acc" + name + "box.style.left = parseInt(sb.style.left) - 27;");
   eval("document.all.acc" + name + "box.style.top = parseInt(sb.style.top) - 42;");

   sb = null;
}


function addMouseOver()
{
   document.all.staff.onclick = secondAction;
   document.all.semi1con.onclick = action1;
   document.all.semi2con.onclick = action1;
   document.all.semi3con.onclick = action1;
   document.all.semi4con.onclick = action1;
   document.all.semi5con.onclick = action1;
   document.all.semi6con.onclick = action1;
   document.all.semi7con.onclick = action1;
   document.all.semi8con.onclick = action1;



   var staffX = findPosX(document.all.staff);
   var staffY = findPosY(document.all.staff);
   setPos(1, 0, 0, staffX, staffY);
   setPos(2, 0, 2, staffX, staffY);
   setPos(3, 0, 11, staffX, staffY);
   setPos(4, 0, 18, staffX, staffY);
   setPos(5, 1, 0, staffX, staffY);
   setPos(6, 1, 3, staffX, staffY);
   setPos(7, 1, 12, staffX, staffY);
   setPos(8, 1, 14, staffX, staffY);

}


function resetRaise()
{
   for(var i = 1; i <= 8; i++)
   {
      eval("document.all.acc" + i + "i.value = 'none';");
      eval("document.all.acc" + i + "box.innerHTML = '';");
   }
}



function rePosSB(sb)
{
   var posx = 0;
   var posy = 0;

   posx = parseInt(sb.style.left);
   posy = parseInt(sb.style.top);
   var staffX = findPosX(document.all.staff);
   sb.style.left = validPositionsX[findValidIndexX(posx, staffX)] + staffX;

   var staffY = findPosY(document.all.staff);
   sb.style.top = validPositionsY[findValidIndexY(posy, staffY)] + staffY;

   var name = sb.name.substring(4, 5);
   //alert(name);
   eval("document.all.acc" + name + "box.style.left = parseInt(sb.style.left) - 27;");
   eval("document.all.acc" + name + "box.style.top = parseInt(sb.style.top) - 42;");

   sb = null;
}

function rePosition()
{
   rePosSB(document.all.semi1con);
   rePosSB(document.all.semi2con);
   rePosSB(document.all.semi3con);
   rePosSB(document.all.semi4con);
   rePosSB(document.all.semi5con);
   rePosSB(document.all.semi6con);
   rePosSB(document.all.semi7con);
   rePosSB(document.all.semi8con);
   //alert("cvbcbvc");
}