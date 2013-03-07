package code
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.net.*;

	public class PageXML extends Sprite
	{
		private var myXML:XML;
		private var myMgr:Object;
		
		private var paraArray:Array = new Array();
		private var aPageTitle:String = "Loading Title...";
		private var dataSet:String;
		private var myLoader:URLLoader;
		private var seedURLString:String;
		
		/*
		*   PageXML takes care of all the dirty work for the sumBubble object
		*   loading and parsing the wiki page it is given and returning the 
		*	to the best of its ability the summary of the article.
		*/
		
		public function PageXML(seedURL:String,mgr:Object)
		{
			// constructor code
			myMgr = mgr;
			var myRequest:URLRequest = new URLRequest(seedURL);
			myLoader = new URLLoader( );
			myLoader.load(myRequest);
			myLoader.addEventListener(Event.COMPLETE,loadCompleted);
		}
		
		//Takes the loaded XML callls the necessary functions to parse it down and
		//then sends the data to the sumBubble.
		//Input Event with XML data / No Output / Calls internal functions as well as sumBubble's setters
		private function loadCompleted(e:Event):void
		{
			myXML = new XML(myLoader.data);
			aPageTitle = myXML.query.pages.page.attribute("title");
			myMgr.setTitle(aPageTitle);
			getData(myXML.query.pages.page.revisions.rev.toString());
			if (paraArray[0] != null)
			{
				if (paraArray[0].match(/==.*?==/) != null)
				{
					myMgr.setSummary("This article doesn't seem to have a summary.");
				}
				else if (paraArray[0].match(/__NOTOC__/) != null)
				{
					myMgr.setSummary("This article doesn't seem to have a summary.");
				}
				else
				{
					myMgr.setSummary(paraArray[0].toString());
				}
			}
			else if (dataSet.match("#REDIRECT|#redirect") != null)
			{
				myMgr.setSummary("This is a redirect page, try: " + exitRedirects(dataSet) + " instead.")
			}
			else
			{
				myMgr.setSummary("There doesn't seem to be anything here. Try double checking your spelling, remember that links are case-sensitive.");
			}
		}
		
		//A function that uses some of the Regular Expression functions to return the
		//first paragraph of a given wiki article
		//Input a wiki article in String form / No Outputs / Calls a ton of functions
		private function getData(str:String):void
		{
			dataSet = removeFiles(str);
			dataSet = removeMLinks(dataSet);
			dataSet = removeLinks(dataSet);
			dataSet = removeRefs(dataSet);
			dataSet = removeInfoboxes(dataSet);
			dataSet = removeDoubleBoxes(dataSet);
			dataSet = removeSingleBoxes(dataSet);
			dataSet = removeItalics(dataSet);
			dataSet = removeBold(dataSet);
			dataSet = removeAllTags(dataSet);
			dataSet = removeComments(dataSet);
			dataSet = removeExtraSpace(dataSet);
			dataSet = cleanRegexErrors(dataSet);
			
			paraArray = returnParagraphs(dataSet);
		}
		
		//The following are the functions that use Regular Expressions to strip the
		//wiki page of a single type of content. They are far from perfect due to the 
		//unpredictability of wiki content.
		
		private function exitRedirects(str:String):String
		{
			return str.replace(/(#REDIRECT|#redirect)/gi,"");
		}
		
		private function returnParagraphs(str:String):Array
		{
			return str.match(/.+\n/g);
		}
		
		private function removeComments(str:String):String
		{
			return str.replace(/<!--.*?-->/gs,"");
		}
		
		private function removeAllTags(str:String):String
		{
			return str.replace(/<.*?>/g,"");
		}
		
		private function removeExtraSpace(str:String):String
		{
			return str.replace(/ \n\n/g,"");
		}
		
		private function removeBold(str:String):String
		{
			return str.replace(/'''(.*?)'''/g,"$1");
		}

		private function removeItalics(str:String):String
		{
			return str.replace(/''(.*?)''/g,"$1");
		}

		private function removeFiles(str:String):String
		{
			return str.replace(/\[\[.*?:.*\]\]\n/g,"");
		}

		private function removeInfoboxes(str:String):String
		{
			return str.replace(/\{\{[I|i]nfobox.*?\}\}\n\n/gs,"");
		}

		private function removeDoubleBoxes(str:String):String
		{
			return str.replace(/\{\{.*?\}\}/gs,"");
		}
		
		private function removeSingleBoxes(str:String):String
		{
			return str.replace(/{.*?}/gs,"");
		}

		private function removeLinks(str:String):String
		{
			return str.replace(/\[\[([^|\]]+)\]\]/gs,"$1");
		}

		private function removeMLinks(str:String):String
		{
			return str.replace(/\[\[.[^\]]*?\|([^|]+?)\]\]/gs,"$1");
		}

		private function removeRefs(str:String):String
		{
			return str.replace(/<ref.*?>.*?<\/ref>/gs,"$1");
		}

		private function cleanRegexErrors(str:String):String
		{
			return str.replace(/\$1/g,"");
		}
	}
}