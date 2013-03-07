package code
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.MouseEvent;

	public class SpinnerBL extends MovieClip
	{
		private var myMgr:Object;
		
		public function SpinnerBL(aTitle:String,mgr:Object)
		{
			// constructor code
			myMgr = mgr;
			myTitle.text = aTitle;
			myTitle.selectable = false;
			
			this.addEventListener(MouseEvent.CLICK,newRequest);
		}
		
		//Tells the Document Class through the Spinner class to use a new wikipage
		private function newRequest(e:MouseEvent):void
		{
			myMgr.spinnerBLRequest(myTitle.text);
		}
		
		public function setText(str:String):void
		{
			myTitle.text = str;
		}
		
		public function getTitle():String
		{
			return myTitle.text;
		}

	}

}