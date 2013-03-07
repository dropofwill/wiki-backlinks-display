package code {
	
	import flash.display.MovieClip;
	import flash.sampler.StackFrame;
	
	
	public class InputBox extends MovieClip {
		
		
		public function InputBox() {
			// constructor code
		}
		
		public function getTextField():String
		{
			return this.InputBoxText.text;
		}
		
		public function setTextField(str:String):void
		{
			this.InputBoxText.text = str;
		}
	}
	
}
