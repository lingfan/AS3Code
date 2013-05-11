package GameUI.Modules.Screen
{
	import GameUI.ConstData.EventList;
	import GameUI.Modules.Screen.Data.ScreenData;
	import Controller.ScreenController;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class ScreenMediator extends Mediator
	{
		public static const NAME:String = "ScreenMediator";
		public function ScreenMediator()
		{
			super(NAME);
		}
		public override function listNotificationInterests():Array
		{
			return [EventList.INITVIEW,
				ScreenData.OPEN_SCREEN
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()){
				case EventList.INITVIEW:
					
					break;
				case ScreenData.OPEN_SCREEN:
					
					break;
			}
			//设置刷新屏蔽
			ScreenController.SetScreen();
		}
	}
}