package code
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.net.*;
	
	public class SumBubble extends MovieClip
	{
		private var myMgr:Object;
		
		/*
		* 	SumBubble is the object in the center of the screen, it holds
		*	the article's title and as much of the first paragraph that
		*	will fit.
		*/
		
		public function SumBubble(aSeed:String,mgr:Object)
		{
			// constructor code
			myMgr = mgr;
			var aPageXML:PageXML = new PageXML("http://en.wikipedia.org/w/api.php?action=query&prop=revisions&format=xml&rvprop=content&titles=" + aSeed,this);
		}
		
		//Called by aPageXML when it is done processing information, setTitle displays the data and
		//tries to keep the text within the bounds of the bubble as best it can
		//Inputs a string / no ouputs / uses the static WrapTextUtility from Roger Braunstein for word wrap
		public function setTitle(str:String):void
		{
			this.titleText.text = str;
			this.titleText.selectable = false;
			
			//Use Roger Braunstein's open source dynamic word wrap utility, see http://dispatchevent.org/roger/dynamic-text-wrapping-in-actionscript-3/
			var tempObj:MovieClip = myMgr.getCollisionGuard(2);
			WrapTextUtility.wrapText(titleText,tempObj);
			
			if (titleText.numLines > 2)
			{
				for (var i:int = 0; i < titleText.numLines-2; i++)
				{
					titleText.replaceText(titleText.getLineOffset(i+2),titleText.getLineOffset(i+2)+titleText.getLineLength(i+2),"");
				}
			}
		}
		
		//Called by aPageXML when it is done processing information, setSummary displays the data and
		//tries to keep the text within the bounds of the bubble as best it can.
		//Inputs a string / no ouputs / uses the static WrapTextUtility from Roger Braunstein for word wrap
		public function setSummary(str:String):void
		{
			this.summaryText.text = str;
			this.summaryText.selectable = false;
			
			//Use Roger Braunstein's open source dynamic word wrap utility, see http://dispatchevent.org/roger/dynamic-text-wrapping-in-actionscript-3/
			var tempObj:MovieClip = myMgr.getCollisionGuard(1);
			WrapTextUtility.wrapText(summaryText,tempObj);
		}
	}
}