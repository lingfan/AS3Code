package GameUI.Modules.Master.Mediator
{
	import GameUI.Modules.Hint.Events.HintEvents;
	import GameUI.Modules.Master.Command.BottomButtonController;
	import GameUI.Modules.Master.Data.MasterData;
	import GameUI.Modules.Master.Proxy.YoungStudent;
	import GameUI.Modules.Master.View.StudentApplyCell;
	import GameUI.Proxy.DataProxy;
	import GameUI.View.Components.countDown.CountDownText;
	
	import Net.ActionSend.TutorSend;
	
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class StudentApplyListMediator extends Mediator
	{
		public static const NAME:String = "StudentApplyListMediator";
		
		private var cellContainer:Sprite = new Sprite();
		private var yellowFrame:Shape;
		private var selectStudent:YoungStudent;
		private var refreshDownTxt:CountDownText;
		private var getOutTimer:Timer = new Timer(200, 1);	//物品取出计时器
		private var reqestTimer:Timer;									//请求数据计时器
		
		private var currentPage:int = 1;
		private var totalPage:int = 1;
		private var bottomBtnControl:BottomButtonController;
		private var aData:Array = new Array( 10 );
		private var aCurList:Array;					//当前数据列表
		private var dataProxy:DataProxy;
		
		public function StudentApplyListMediator(mediatorName:String=null, viewComponent:Object=null)
		{
			super( NAME, viewComponent );
		}
		
		public function get main_mc():MovieClip
		{
			return this.viewComponent as MovieClip;
		}
		
		public override function listNotificationInterests():Array
		{
			return [
							MasterData.MASTER_STU_UI_INITVIEW,
							MasterData.START_SHOW_MAS_PAGE,
							MasterData.CLEAR_MASTER_PANEL_PAGE,
							MasterData.REC_STU_APPLY_LIST_DATA,
							MasterData.DELETE_STUDENT_APPLY
						];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch ( notification.getName() )
			{
				case MasterData.MASTER_STU_UI_INITVIEW:
					initUI();
				break;
				case MasterData.START_SHOW_MAS_PAGE:
					if ( notification.getBody().curPage == 2 )
					{
						showUI();
					}
				break;
				case MasterData.CLEAR_MASTER_PANEL_PAGE:
					if ( notification.getBody().curPage == 2 )
					{
						clearUI();
					}
				break;
				case MasterData.REC_STU_APPLY_LIST_DATA:
					if ( this.main_mc.currentFrame != 3 ) return;
					var sObj:Object = notification.getBody();
					aCurList = [];
					aCurList = sObj.allStudent as Array;
					totalPage = sObj.pages;
					if ( totalPage == 0 ) totalPage = 1;
//					totalPage = Math.ceil( aCurList.length/14 );
					aData[ currentPage - 1 ] = aCurList.concat();
					updataList();
				break;
				case MasterData.DELETE_STUDENT_APPLY:
					requestData( 21 );
				break;
			}
		}
		
		private function initUI():void
		{
			createFrame( 643,21 );
			cellContainer.x = 10;
			cellContainer.y = 80;
			main_mc.addChild( cellContainer );
			
			bottomBtnControl = new BottomButtonController( 2 );
			bottomBtnControl.x = 124;
			bottomBtnControl.y = 420;
			bottomBtnControl.refreshFun = refreshUI;
			
			dataProxy = facade.retrieveProxy( DataProxy.NAME ) as DataProxy;
		}
		
		private function showUI():void
		{
			bottomBtnControl.listen();
			main_mc.addChild( bottomBtnControl );
			bottomBtnControl.fourBtnVisble = false;
			bottomBtnControl._mentor = null;
			currentPage = 1; 
			
			( main_mc.left_btn as SimpleButton ).addEventListener( MouseEvent.CLICK,goLeft );
			( main_mc.right_btn as SimpleButton ).addEventListener(MouseEvent.CLICK,goRight );
			
			clearContainer();
			initBottomPage();
			checkRequest();
			initTimer();
		}
		
		private function clickCellHandler( cell:StudentApplyCell ):void
		{
			cell.addChild( yellowFrame );
			yellowFrame.x = 0;
			yellowFrame.y = 0;
			bottomBtnControl._mentor = cell.youngStudent;
			bottomBtnControl.fourBtnVisble = true;
		}
		
		//请求数据
		private function checkRequest():void
		{
			if ( !aData[ currentPage - 1 ] )
			{
				requestData( 21 );
			}
			else
			{
				aCurList = aData[ currentPage - 1 ];
				updataList();
			}
		}
		
		private function initTimer():void
		{
			if ( !reqestTimer )
			{
//				reqestTimer = new Timer( 1800 * 1000,1 );
				reqestTimer = new Timer( 1000,1 );
				reqestTimer.addEventListener( TimerEvent.TIMER_COMPLETE,timerComplete );
				reqestTimer.start();
			}
		}
		
		private function timerComplete( evt:TimerEvent ):void
		{
			for ( var i:uint=0; i<aData.length; i++ )
			{
				aData[ i ] = null;
			}
			if ( dataProxy.masterPanelIsOpen )
			{
				reqestTimer.start();
			}
			else
			{
				reqestTimer.removeEventListener( TimerEvent.TIMER_COMPLETE,timerComplete );
				reqestTimer = null;
			}
		}
		
		private function clearUI():void
		{
			clearContainer();
			
			( main_mc.left_btn as SimpleButton ).removeEventListener(MouseEvent.CLICK,goLeft );
			( main_mc.right_btn as SimpleButton ).removeEventListener(MouseEvent.CLICK,goRight );
			
			if ( bottomBtnControl && main_mc.contains( bottomBtnControl ) )
			{
				bottomBtnControl.gc();
				main_mc.removeChild( bottomBtnControl );
			}
		}
		
		private function createFrame( fWidth:uint,fHeight:uint ):void
		{
			yellowFrame = new Shape();
			yellowFrame.graphics.clear();
			yellowFrame.graphics.lineStyle( 1,0xffff00 );
			yellowFrame.graphics.lineTo( 0,0 );
			yellowFrame.graphics.lineTo( fWidth,0 );
			yellowFrame.graphics.lineTo( fWidth,fHeight );
			yellowFrame.graphics.lineTo( 0,fHeight );
			yellowFrame.graphics.lineTo( 0,0 );
		}
		
		private function initBottomPage():void
		{
			( main_mc.page_txt as TextField ).text = GameCommonData.wordDic[ "mod_her_med_lea_vie_1" ] + currentPage + "/" + totalPage + GameCommonData.wordDic[ "mod_her_med_lea_vie_2" ];     //第         页
			( main_mc.page_txt as TextField ).mouseEnabled = false;
		}
		
		private function goLeft(evt:MouseEvent):void
		{
			if ( currentPage > 1 )
			{
				currentPage --;
				initBottomPage();
				clearContainer();
				bottomBtnControl.fourBtnVisble = false;
				checkRequest();
			}
		}
		
		private function goRight(evt:MouseEvent):void
		{
			if ( currentPage < totalPage )
			{
				if ( !startTimer() ) return;
				currentPage ++;
				initBottomPage();
				clearContainer();
				bottomBtnControl.fourBtnVisble = false;
				checkRequest();
			}
		}
		
		private function requestData( action:uint ):void
		{
			var obj:Object = new Object();
			obj.action = action;
			obj.amount = 14;
			obj.pageIndex = currentPage;
			obj.mentorId = 0;
			TutorSend.sendTutorAction( obj );
		}
		
		private function updataList():void
		{
			clearContainer();
			initBottomPage();
			var cell:StudentApplyCell;
			for ( var i:uint=0; i<aCurList.length; i++ )
			{
				cell = new StudentApplyCell( aCurList[ i ] );
				cell.y = i * 23;
				cell.clickFun = clickCellHandler;
				cellContainer.addChild( cell );
			}
		}
		
		private function refreshUI():void
		{
			requestData( 21 );
		}
		
		//调用外部接口  
		private function deleteStudent( evt:MouseEvent ):void
		{
			if ( isMyself() ) return;
		}
		
		//当前选中的是不是自己
		private function isMyself():Boolean
		{
			if ( selectStudent && selectStudent.id == GameCommonData.Player.Role.Id )
			{
				return true;
			}
			return false;
		}
		
		private function clearContainer():void
		{
			var des:*;
			while ( cellContainer.numChildren > 0 )
			{
				des = cellContainer.removeChildAt( 0 );
				if ( des is StudentApplyCell )
				{
					( des as StudentApplyCell ).gc();
				}
				des = null;
			}
		}
		
		//操作延时器
		private function startTimer():Boolean
		{
			if(getOutTimer.running) 
			{
				facade.sendNotification(HintEvents.RECEIVEINFO, {info:GameCommonData.wordDic[ "mod_dep_pro_ite_sta" ], color:0xffff00});//"请稍后"
				return false;
			} 
			else 
			{
				getOutTimer.reset();
				getOutTimer.start();
				return true;
			}
		}
		
	}
}