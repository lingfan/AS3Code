package GameUI.Modules.Opera.View
{
	
	import GameUI.Modules.Opera.View.BlackBlock;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	public class PurdahPanel extends Sprite
	{
		public  var flag:int = 0;
		private var topBlock:BlackBlock;
		private var buttomBlock:BlackBlock;
		
		private var maskMc:Sprite;
	    public var talkHandler:Function;
		public var exited:Function;
		public function PurdahPanel()
		{
			
			
			
		}
		
		public function init():void {
			
			this.graphics.lineStyle(1,0,0);
			this.graphics.beginFill(0x000000,0);
			this.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
			this.graphics.endFill();
			addBlock();
		}
		
		
		
		private function addBlock():void {
			
//			topBlock = new BlackBlock(0,-130,stage.stageWidth,130,0);
			topBlock = new BlackBlock(stage.stageWidth,130);	
//			buttomBlock = new BlackBlock(0,stage.stageHeight,stage.stageWidth,130,1);
			buttomBlock = new BlackBlock(stage.stageWidth,130);
			topBlock.x = 0;
			topBlock.y = -130
			buttomBlock.textField.x = (buttomBlock.width - buttomBlock.textField.width) / 2;
			buttomBlock.textField.y = (buttomBlock.height - buttomBlock.textField.height/2) / 2;
			buttomBlock.x = 0;
			buttomBlock.y = stage.stageHeight;
			addChild(topBlock);
			addChild(buttomBlock);
			this.addEventListener(Event.ENTER_FRAME,onEnterFrame);
			this.addEventListener(MouseEvent.CLICK,talkHandler);
		}
		
		public function reSize():void{
			
			topBlock.width = stage.stageWidth;
			buttomBlock.width = stage.stageWidth;
			
			buttomBlock.x = 0;
			buttomBlock.y = stage.stageHeight - 130;
			buttomBlock.textField.x = (buttomBlock.width - buttomBlock.textField.width) / 2;
			buttomBlock.textField.y = (buttomBlock.height - buttomBlock.textField.height/2) / 2;
		}
		
		private function onEnterFrame(e:Event):void {
			if(flag==0){
				if(topBlock.y < 0){
					topBlock.y += 5;
				}
				if(buttomBlock.y > stage.stageHeight - 130){
					buttomBlock.y -= 5;
				}
				
				if(topBlock.y >= 0 && buttomBlock.y <=stage.stageHeight - 130){
					this.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
					
					this.buttomBlock.textField.visible = true;
					
				}
			}else {
				if(topBlock.y >-130){
					topBlock.y -= 5;
				}
				
				if(buttomBlock.y < stage.stageHeight){
					buttomBlock.y += 5;
				}
				
				if(topBlock.y <= -130 && buttomBlock.y >=stage.stageHeight){
					this.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
					if(exited != null){
						this.exited();
					}
					this.parent.removeChild(this);
					
					
				}
			}
			
			
		}
		
		
		
		public function talk(obj:Object):void {
			
			
			this.buttomBlock.setText(obj[3] as String);	
		}
		
		
		
		public function exit():void {
			this.flag = 1;
			this.addEventListener(Event.ENTER_FRAME,onEnterFrame);
		}
		
		
		
	
	}
}