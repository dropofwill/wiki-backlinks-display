package code
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.net.*;
	import flash.filters.GradientBevelFilter;
	import flash.utils.Timer;
    import flash.events.TimerEvent;
		
	
	public class Document extends MovieClip
	{
		/*
		*	This app takes XML data from the MediaWiki api for a given wikipedia page, parses it for the summary
		*	and title of the page and display this in a bubble on the center of the page. It then requests an XML
		*	document with a list of all the pages that link back to this page and visaully presents this information
		*	around the bubble.
		*/
		
		private var wikiSeed:String = "Music";
		private var diagramCounter:int = -1;
		private var spinnerArray:Array = new Array();
		private var sumBubbleArray:Array = new Array();
		
		private var defaultText = "Type the case-sensitive title of a wikipedia page here"
		private var anInput:InputBox;
		private var anInputButton,upButton,downButton:InputButton;
		private var focus:Boolean = false;
		private var delay:uint = 300;
		
		private var gradCover:GradShape = new GradShape();
		private var collisionGuard:CollisionWordWrap = new CollisionWordWrap();
		private var collisionGuard2:CollisionWordWrap2 = new CollisionWordWrap2();
   		
		public function Document()
		{
			// constructor code
			initUI();
			initDiagram(wikiSeed);
			addRandomExample();
		}
		
		//Makes the two components that use XML, deletes old ones from the display list if necessary
		//Inputs the Title of a wiki page, which is used by the other components to retrive data / No Outputs
		//Calls displayUI() to make sure UI elements are on top of the display list
		public function initDiagram(aSeed:String):void
		{
			if (diagramCounter >= 0)
			{
				removeChild(sumBubbleArray[diagramCounter]);
				removeChild(spinnerArray[diagramCounter]);
			}
			diagramCounter++;
			
			var aSumBubble:SumBubble = new SumBubble(aSeed,this);
			aSumBubble.x = stage.stageWidth/2;aSumBubble.y = stage.stageHeight/2;
			sumBubbleArray.push(aSumBubble);
			addChild(aSumBubble);
			
			var aSpinner:Spinner = new Spinner(this,aSeed);
			aSpinner.x = stage.stageWidth/2; aSpinner.y = stage.stageHeight/2;
			spinnerArray.push(aSpinner);
			addChild(aSpinner);
			
			displayUI();
		}
		
		//Instantiates, sets the properties of, and add events listeners for the apps various UI elements
		//No inputs/ouputs/function calls
		private function initUI():void
		{
			//Hides where the new elements are swapped
			gradCover.x = 640; gradCover.y = 425;
			
			//Event listener for keyboard input for rotating the spinner
			stage.addEventListener(KeyboardEvent.KEY_UP, arrowKey);
			
			//For the hitTest that the word wrap utility uses
			collisionGuard.x = stage.stageWidth/2; collisionGuard.y = stage.stageHeight/2;
			collisionGuard.alpha =0;
			addChildAt(collisionGuard,0);
			
			collisionGuard2.x = stage.stageWidth/2; collisionGuard2.y = (stage.stageHeight/2);
			collisionGuard2.alpha =0;
			addChildAt(collisionGuard2,1);
			
			//The input where the user enters a wikipedia page title
			anInput = new InputBox()
			anInput.x =10; anInput.y = stage.stageHeight-10;
			anInput.addEventListener(FocusEvent.FOCUS_IN, inputClear);
			anInput.addEventListener(FocusEvent.FOCUS_OUT, inputAdd);
			
			//The enter button for the anInput
			anInputButton = new InputButton();
			anInputButton.x = 30 + anInput.width; anInputButton.y = stage.stageHeight-(6+(anInputButton.height/2));
			anInputButton.addEventListener(MouseEvent.CLICK, newDiagram);
			
			//Buttons for rotating the spinner
			upButton = new InputButton();
			upButton.rotation -= 90; upButton.x = stage.stageWidth - 30; upButton.y = (stage.stageHeight/2) - 19;
			upButton.addEventListener(MouseEvent.CLICK,upClick);
			
			downButton = new InputButton();
			downButton.rotation += 90; downButton.x = stage.stageWidth - 30; downButton.y = (stage.stageHeight/2) + 19;
			downButton.addEventListener(MouseEvent.CLICK,downClick);
		}
		
		//Brings the UI elements to the top of the display list
		//No inputs/outputs/function calls
		private function displayUI():void
		{
			addChild(gradCover);
			addChild(anInput);
			addChild(anInputButton);
			addChild(upButton);
			addChild(downButton);
		}
		
		//Adds a random page title as an example for the user to try
		//No Inputs/ No Outputs / Calls a addRandomCompleted when the xml is loaded, which then updates the textField
		private function addRandomExample():void
		{
			var myRequest:URLRequest = new URLRequest("http://en.wikipedia.org/w/api.php?format=xml&action=query&list=random&rnlimit=1&rnnamespace=0");
			var myLoader = new URLLoader();
			myLoader.load(myRequest);
			myLoader.addEventListener(Event.COMPLETE,addRandomCompleted); 
		}
		private function addRandomCompleted(e:Event):void
		{
			var myXML = new XML(e.target.data);
			defaultText += ", e.g. " + myXML.query.random.page.attribute("title");
			anInput.setTextField(defaultText);
		}
		
		//Called by either MouseClick on anInputButton or the enter keystroke, makes a new diagram with whatever page is in the anInput
		//Inputs MouseEvent/No Ouputs
		//Calls initDiagram using the string within anInput
		private function newDiagram(e:MouseEvent):void
		{
			var tempStr:String = anInput.getTextField();
			initDiagram(tempStr);
		}
		//Called on enter keystroke while anInput is in focus
		//Inputs KeyboardEvent / no outputs / calls newDiagram
		private function enterKey(e:KeyboardEvent):void
		{
			if (e.keyCode == 13)
			{
				if (focus == true)
				{
					newDiagram(null);
				}
			}
		}
		
		//Called by either MouseClick on upButton or up arrow keystroke, rotates the spinner 20 degrees
		//Timer is to stop users from breaking the interface by clicking to fast
		//Inputs MouseEvent/No outputs
		//Calls the spinner's rotateSpinner function with the parameter "up"
		private function upClick(e:MouseEvent):void
		{
			upButton.removeEventListener(MouseEvent.CLICK,upClick);
			var aTimer:Timer = new Timer(delay,1);
			aTimer.start();
			aTimer.addEventListener(TimerEvent.TIMER_COMPLETE,upTimer);
			spinnerArray[diagramCounter].rotateSpinner("up");
		}
		private function upTimer(e:TimerEvent):void
		{
			upButton.addEventListener(MouseEvent.CLICK,upClick);
			stage.addEventListener(KeyboardEvent.KEY_UP,arrowKey);
		}
		
		
		//Called by either MouseClick on downButton or down arrow keystroke, rotates the spinner 20 degrees
		//Timer is to stop users from breaking the interface by clicking to fast
		//Inputs MouseEvent/No outputs
		//Calls the spinner's rotateSpinner function with the parameter "down"
		private function downClick(e:MouseEvent):void
		{
			downButton.removeEventListener(MouseEvent.CLICK,downClick);
			var aTimer:Timer = new Timer(delay,1);
			aTimer.start();
			aTimer.addEventListener(TimerEvent.TIMER_COMPLETE,downTimer);
			spinnerArray[diagramCounter].rotateSpinner("down");
		}
		private function downTimer(e:TimerEvent):void
		{
			downButton.addEventListener(MouseEvent.CLICK,downClick);
			stage.addEventListener(KeyboardEvent.KEY_UP,arrowKey);
		}
		//Called when the arrow keys are pressed
		//Inputs KeyboardEvent / no outputs / calls the upClick or downClick function
		private function arrowKey(e:KeyboardEvent):void
		{
			if (e.keyCode == 38)
			{
				upClick(null);
				stage.removeEventListener(KeyboardEvent.KEY_UP,arrowKey);
			}
			else if (e.keyCode == 40)
			{
				downClick(null);
				stage.removeEventListener(KeyboardEvent.KEY_UP,arrowKey);
			}
		}
		
		//Clears the inputBox on focus
		//Inputs FocusEvent / No Outputs / Calls the anInput's textField getter/setter function
		private function inputClear(e:FocusEvent):void
		{
			if (anInput.getTextField() == defaultText)
			{
				anInput.setTextField("");
			}
			focus = true;
			stage.addEventListener(KeyboardEvent.KEY_DOWN,enterKey);
		}
		//Places the default text back if the field is left blank
		//Inputs FocusEvent / No Outputs / Calls the anInput's textField getter/setter function
		private function inputAdd(e:FocusEvent):void
		{
			if (anInput.getTextField() == "")
			{
				anInput.setTextField(defaultText);
			}
			focus = false;
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,enterKey);
		}
		
		//Called by a sumBubble object, used for wordWrap purposes
		//Inputs an integer 1 for the summaries guard, any other for the title's, Returns the appropriate MovieClip
		public function getCollisionGuard(i:int):MovieClip
		{
			if (i ==1)
			{
				return collisionGuard;
			}
			else
			{
				return collisionGuard2;
			}
		}
	}
}