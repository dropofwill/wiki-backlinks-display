package code
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.net.*;
	import flash.events.*;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;

	public class Spinner extends MovieClip
	{
		private var myMgr:Object;
		private var myLoader:URLLoader;
		private var wikiData:XML;
		private var wikiSeed:String;
		private var wikiSeedURL:String;
		private var blcontinue:String;
		private var blArray:Array = new Array();
		private var blLimitCounter:int = 36;
		private var blLimit:int = 36;
		private var linkToBack:int = 0;
		private var linkToAdd:int = 17;
		private var continueLoadDone:Boolean = false;
		private var spinnerBlArray:Array = new Array();
		private var spinHeadPos:int = 0;
		private var tempSpinHeadPos:int;

		/*
		*	Definitely the most complicated Class in the app, the Spinner takes the samme page as
		*	SumBubble has processes it for backLinks 36 at a time and displays them visually around
		*	the SumBubble. As it is rotated by the user it displays more backlinks, and loads them as
		*	necessary.
		*/

		public function Spinner(mgr:Object,seed:String)
		{
			// constructor code
			myMgr = mgr;
			wikiSeed = seed;

			wikiSeedURL = "http://en.wikipedia.org/w/api.php?format=xml&action=query&list=backlinks&bltitle=" + wikiSeed + "&bllimit=" + blLimit + "&blnamespace=0";
			var myRequest:URLRequest = new URLRequest(wikiSeedURL);
			myLoader = new URLLoader();
			myLoader.load(myRequest);
			myLoader.addEventListener(Event.COMPLETE,loadCompleted);
		}
		
		//Basic XML loader, takes the article's titles and pushes them to blArray
		//Then it adds the 18 SpinnerBLs and instantiates them with the first 17
		//Values, leaving one blank
		//Inputs a loader event with XML data / No Ouputs / Calls makeASpinnerBL
		private function loadCompleted(e:Event):void
		{
			wikiData = new XML(myLoader.data);

			for (var i:int=0; i<wikiData.descendants("bl").length(); i++)
			{
				blArray.push(wikiData.descendants("bl")[i].attribute("title").toString());
				//blArray.push(i); //Stub values to check what the hell is going on
				if (i == 0)
				{
					makeASpinnerBL("",(i*-20)-20);
				}
				else if (i <= 17 && i != 0)
				{
					makeASpinnerBL(blArray[i-1] ,(i*-20)-20);
				}
			}
		}
		
		//Called only on the first parse by loadCompleted, this makes the 18
		//reusable spinning textFields
		//Inputs the title of the article and the rotation it should be at relative to the Spinner
		//No Ouputs or function calls / Pushes them to spinnerBlArray
		private function makeASpinnerBL(aTitle:String,aRotation:int):void
		{
			var aSpinnerBL:SpinnerBL = new SpinnerBL(aTitle,this);
			aSpinnerBL.x = 0;
			aSpinnerBL.y = 0;
			aSpinnerBL.rotation = aRotation;
			spinnerBlArray.push(aSpinnerBL);
			addChild(aSpinnerBL);
		}
		
		//Called by the document class this is the "spinner" part of the Spinner object
		//Inputs a direction and then tweens in that direction 20 degrees / No Ouputs
		//Calls updateSpinnerBlUp/Down to keep track of what titles should be displayed
		public function rotateSpinner(dir:String):void
		{
			if (dir == "up")
			{
				if (blArray.length > 17)
				{
					updateSpinnerBlUp();
					var tempTweenU:Tween = new Tween(this,'rotation',Regular.easeInOut,this.rotation,this.rotation - 20,.3,true);
				}
			}
			else
			{
				if (blArray.length > 17)
				{
					updateSpinnerBlDown();
					var tempTweenD:Tween = new Tween(this,'rotation',Regular.easeInOut,this.rotation,this.rotation + 20,.3,true);
				}
			}
		}

		//Called by rotateSpinner these functions keep track of how the titles should be 
		//changing as it spins around.
		//
		//	spinHeadPos keeps track of which spinner is in the hidden position
		//	linksToAdd keeps track of which title to add when it is spinning clockwise
		// 	linksToBack keeps track of which title to add when it is spinning counter clockwise
		//	Checker keeps track of whether or not there are anything in linksToBack to add
		//	blLimitCounter keeps track of how many more titles are available before its time to load some more
		// 	blLimit is how many titles are added per load
		//
		//No Inputs / No Ouputs / Calls setters/getters from various SpinnerBLs and continuePastLimit() when it is time to load more titles
		private function updateSpinnerBlUp():void
		{
			if (linkToAdd <= 17)
			{
				spinnerBlArray[spinHeadPos].setText("");
			}
			else if (linkToBack >= -1)
			{
				if (blArray[linkToBack - 1] != null)
				{
					spinnerBlArray[spinHeadPos].setText(blArray[linkToBack-1]);
				}
			}

			var checker:Boolean = false;
			for (var c:int = 0; c < spinnerBlArray.length; c++)
			{
				if (spinnerBlArray[c].getTitle() != "")
				{
					checker = true;
					break;
				}
			}
			if (checker == true)
			{
				linkToBack--;
			}
			

			if (spinHeadPos > 0)
			{
				spinHeadPos--;
			}
			else if (spinHeadPos == 0)
			{
				spinHeadPos = 17;
			}
			if (linkToAdd > 0)
			{
				linkToAdd--;
			}
		}
		private function updateSpinnerBlDown():void
		{
			if (linkToAdd < blLimitCounter)
			{
				spinnerBlArray[spinHeadPos].setText(blArray[linkToAdd]);
				linkToAdd++;
				linkToBack++;
			}
			else
			{
				continuePastLimit();
				tempSpinHeadPos = spinHeadPos;
				blLimitCounter +=  blLimit;
			}

			if (spinHeadPos < 17)
			{
				spinHeadPos++;
			}
			else
			{
				spinHeadPos = 0;
			}
		}

		//Called to load more titles from updateSpinnerDown, which means a new xml request/load, it just parses the old XML to determine the url to request
		//No inputs/ouputs /Calls continueLoad()
		private function continuePastLimit():void
		{
			blcontinue = "&blcontinue=" + wikiData.descendants("query-continue").backlinks.attribute("blcontinue");
			continueLoad(blcontinue);
		}
		
		//Called by continuePastLimit does loads the new xml
		//Inputs the url string from continuePastLimit() / No Ouputs
		private function continueLoad(blcontinue):void
		{
			var aRequest:URLRequest = new URLRequest(wikiSeedURL + blcontinue);
			var continueLoader = new URLLoader();
			continueLoader.load(aRequest);
			continueLoader.addEventListener(Event.COMPLETE,continueCompleted);
		}
		
		//Grabs the XML and passes it on to continueParse
		//Input event with XML data / No ouput / Calls continueParse
		private function continueCompleted(e:Event):void
		{
			wikiData = new XML(e.target.data);
			continueParse(wikiData);
		}
		
		//Called by continueComplete, parses the xml for titles and pushes them to blArray, then adds the next one to the spinner
		//Inputs XML / No Ouputs / Calls a SpinnerBL's setter
		private function continueParse(myXML:XML):void
		{
			for (var i:int=0; i<myXML.descendants("bl").length(); i++)
			{
				blArray.push(myXML.descendants("bl")[i].attribute("title").toString());
			}
			spinnerBlArray[tempSpinHeadPos].setText(blArray[linkToAdd]);
			linkToAdd++;
			linkToBack++;
		}
		
		//Called by SpinnerBL, used to pass along a request to the document class to set up a new wiki page for the seed
		//Inputs a title String / No Ouputs / calls the initDiagram function in the Document Class
		public function spinnerBLRequest(str:String):void
		{
			if (str != "")
			{
				myMgr.initDiagram(str);
			}
		}

	}
}