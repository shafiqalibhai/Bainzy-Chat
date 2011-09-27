function ChatUI(inMC) {
	this.mc = inMC;
	this.mc.chatUI = this;
	
	_global.FlashChatNS.chatUI = this;
	_global.FlashChatNS.BigSkin_Loaded = false;
	
	this.mc.loader = new MovieClipLoader();
	this.mc.loader.addListener(this.mc);
	
	this.selfUserId      = null;
	this.selfUserRole    = null;
	this.selfUserGender  = null;
	
	this.selfRoomId      = null;
	
	this.selfInitialized = false;
	this.firstInit       = false;
	
	this.layoutMinWidth = this.DEFAULT_LAYOUT_MIN_WIDTH;
	this.layoutLeftPaneMinWidth = 0;
	this.layoutMinHeight = this.DEFAULT_LAYOUT_MIN_HEIGHT;
	
	this.floodIntervalTime = this.getTimeMilis();
	this.gagIntervalTime = 0;
	
	//settings.
	this.settings = null;
	//languages.
	this.languages = null;
	this.selectedLanguage = null;
	//keeps reference to 'initial skin' object. it is initialized at flash startup by 
	//'setInitialSkin(...)' call from chat manager. initial skin is used to draw login box only.
	this.initialSkin = null;
	this.initialBigSkin = null;
	this.initialText = null;
	//keeps an 'id' of initial language. it is used to set up language chooser in login box.
	this.initialLanguageId = null;

	this.rooms = new Object();
	this.users = new Object();
	
	//default position of panels
	this.userListPosition     = this.USERLIST_POSITION_RIGHT;
	this.optionPanelPosition  = this.OPTIONPANEL_POSITION_BOTTOM;
	this.userList_XScale = null;
	this.userList_XScalePrev = null;
	this.optionPanel_YScale = null;
	this.optionPanel_YScalePrev = null;
	
	//create dialog holder
	this.mc.createEmptyMovieClip('dialogHolder', 15000);
	this.mc.dialogHolder.baseDepth = 4; //0,1,2,3 layers is reserved for pane windows when docked
	this.mc.dialogHolder.currentDepth = 4;
	this.mc.dialogHolder.depthHash = new Object();
	
	this.privateBoxManager = new CPrivateBoxManager(this.mc.dialogHolder, Stage.width, Stage.height);
	this.privateBoxManager.setPrivateBoxHandler('onPrivateBoxSend', this);

	this.dialogManager = new CDialogManager(this.mc.dialogHolder, Stage.width, Stage.height);
	this.dialogManager.setHandler('onNewDialogShow', this);
	
	//userList init
	this.userListPane = this.dialogManager.createPane('userList');
	this.mc.userList = this.userListPane.setContent('CustomListView');
	this.userListPane.setDockState(false);
	
	//inputTextArea init
	this.inputTextAreaPane = this.dialogManager.createPane('inputTextArea');
	var inputTextArea = this.inputTextAreaPane.setContent('InputTextArea', this, 'postAtachment');
	
	this.mc.sendBtn = inputTextArea.sendBtn;
	this.mc.optionPanel = inputTextArea.optionPanel;
	this.mc.msgTxt = inputTextArea.msgTxt;
	this.mc.msgTxtBackground = inputTextArea.msgTxtBackground;
	this.mc.optionPanelBG = inputTextArea.optionPanelBG;
	
	this.inputTextAreaPane.setDockState(false);
	
	//------------------------------------------------------------------------------------------------------//
	this.inputTextAreaPane.processSmile = function( inSmi )
	{
		this.content_mc.mc.msgTxt.text += inSmi;
		
		_global.FlashChatNS.chatUI.sendButtonEnabled = true;
		_global.FlashChatNS.chatUI.enableSendButton();
		_global.FlashChatNS.chatUI.setInputFocus();
	};
	
	this.inputTextAreaPane.processCloseSmile = function()
	{
		this.content_mc.mc.optionPanel.btn_smileDropDown.setEnabled(true);
		this.content_mc.mc.optionPanel.btn_smileDropDown.setValue(false);
		_global.FlashChatNS.chatUI.soundObj.attachSound('ComboListOpenClose');
	};
	//------------------------------------------------------------------------------------------------------//
	
	this.listener = null;
	
	this.sendButtonEnabled = false;
	this.waitingForResponse = false;
	
	this.mc.logOffBtn.setClickHandler('processLogOffButton', this);
	//this.mc.logOffBtn.setStyleProperty('textAlign', 'right');
	
	this.mc.createEmptyMovieClip('userMenuContainer', 35000);

	this.smileDropDownCloserIntervalId = null;
	this.setInputFocusIntervalId = null;
	this.inactivityIntervalId = null;
	this.bigSkinIntervalId = null;
	this.callModuleFuncId = null;
	
	this.mc.backgroundImageHolder.attachMovie('Image', 'image', 0);
	this.mc.backgroundImageHolder.createEmptyMovieClip('mask', 1);
	this.mc.backgroundImageHolder.mask.drawRect2(0, 0, 1, 1, 0, 0, 100, 0xffffff, 100);
	this.mc.backgroundImageHolder.setMask(this.mc.backgroundImageHolder.mask);
	
	this.mc.backgroundImageHolder.image.setHandler('imageLoaded', this.mc);
	this.mc.imageLoaded = function(inImg)
	{
		_global.FlashChatNS.chatUI.resizeImageBG(this.backgroundImageHolder.image);
	}
	
	//chat window attach
	this.mc.smileTextHolder.depth = 0;
	this.mc.chatLog = this.mc.smileTextHolder.attachMovie('SmileText', 'chatLog', this.mc.smileTextHolder.depth++);	

	this.soundObj = new SoundEngine( _level0.ini["sound_options"], _level0.ini["sound"], this );
	
	this.setControlsVisible(false);
	this.setControlsEnabled(false);
	
	//dbg( _level0.ini["sound"] );

	//if focus target is null, focus will return to main input box. otherwise, focus will
	//go to the textfield, specified in 'focusTarget'. used to transfer focus to private popup boxes.
	this.focusTarget = null;

	//*****************************************************************************************
	//pre-cache slow dialogs.
	/*var tmpDialog = this.dialogManager.createDialog('PropertiesBox');
	this.dialogManager.releaseDialog(tmpDialog);
	var tmpDialog = this.dialogManager.createDialog('SoundPropertiesBox');
	this.dialogManager.releaseDialog(tmpDialog);
	//this call clears dialog manager 'bounds cache'. if clear() implementation will be changed,
	//i.e. it will remove all pre-cached dialogs from memory, the above code will lose sense.
	this.dialogManager.clear();*/
	//*****************************************************************************************
	
	//COMENT
	this.createModule();
}

//CONSTANTS.
ChatUI.prototype.SPACER = 5;
ChatUI.prototype.OP_SPACER = 3;

ChatUI.prototype.DEFAULT_LAYOUT_MIN_WIDTH = 410;
ChatUI.prototype.DEFAULT_LAYOUT_MIN_HEIGHT = 280;

ChatUI.prototype.USER_MENU_PRIVATE_MESSAGE = 'Private message';
ChatUI.prototype.USER_MENU_INVITE = 'Invite';
ChatUI.prototype.USER_MENU_IGNORE = 'Ignore';
ChatUI.prototype.USER_MENU_UNIGNORE = 'Unignore';
ChatUI.prototype.USER_MENU_BAN = 'Ban';
ChatUI.prototype.USER_MENU_UNBAN = 'Unban';
ChatUI.prototype.USER_MENU_PROFILE = 'Profile';
ChatUI.prototype.USER_MENU_FILE_SHARE = 'Share File';//--- share menu label

ChatUI.prototype.USER_STATE_HERE = 1;
ChatUI.prototype.USER_STATE_BUSY = 2;
ChatUI.prototype.USER_STATE_AWAY = 3;
ChatUI.prototype.USER_STATE_LIST = [[ChatUI.prototype.USER_STATE_HERE, 'Here'], [ChatUI.prototype.USER_STATE_BUSY, 'Busy'], [ChatUI.prototype.USER_STATE_AWAY, 'Away']];

ChatUI.prototype.USERLIST_POSITION_RIGHT = 1;
ChatUI.prototype.USERLIST_POSITION_LEFT  = 2;
ChatUI.prototype.USERLIST_POSITION_DOCKABLE = 3;
ChatUI.prototype.OPTIONPANEL_POSITION_BOTTOM = 1;
ChatUI.prototype.OPTIONPANEL_POSITION_TOP    = 2;
ChatUI.prototype.OPTIONPANEL_POSITION_DOCKABLE = 3;
ChatUI.prototype.DRAG_FRAME_COLOR = 0x000000;
ChatUI.prototype.DRAG_FRAME_THICKNESS = 2;

//PUBLIC METHODS.
ChatUI.prototype.postAtachment = function(inObj)
{ 
	this.setControlsVisible(false);
	this.setControlsEnabled(false);
	
	//---userList--------------------------------------------------------------------------------------//
	this.mc.userList.addListener(this);
	this.mc.userList.setPressHandler(this, 'processDragFrame');
	//---optionPanelBG---------------------------------------------------------------------------------//
	this.mc.optionPanelBG.onPress = function()
	{
		_global.FlashChatNS.chatUI.processDragFrame(this._parent._parent._parent);
	}
	//---create-user-list-resizer----------------------------------------------------------------------//
	this.mc.createEmptyMovieClip('customListView_resizer', 10000);
	this.mc.customListView_resizer.onPress    = this.resizer_onPress;
	this.mc.customListView_resizer.onRelease  = this.mc.customListView_resizer.onReleaseOutside = this.resizer_onRelease;
	this.mc.customListView_resizer.onRollOver = this.showStretcher;
	this.mc.customListView_resizer.onRollOut  = this.hideStretcher;
	this.mc.customListView_resizer.owner = this.mc;
	this.mc.customListView_resizer.symbolName = 'userList';
	//---create-input-text-area-resizer----------------------------------------------------------------------//
	this.mc.createEmptyMovieClip('inputTextArea_resizer', 10100);
	this.mc.inputTextArea_resizer.onPress    = this.resizer_onPress;
	this.mc.inputTextArea_resizer.onRelease  = this.mc.inputTextArea_resizer.onReleaseOutside = this.resizer_onRelease;
	this.mc.inputTextArea_resizer.onRollOver = this.showStretcher;
	this.mc.inputTextArea_resizer.onRollOut  = this.hideStretcher;
	this.mc.inputTextArea_resizer.owner = this.mc;
	this.mc.inputTextArea_resizer.symbolName = 'inputTextArea';
	//-------------------------------------------------------------------------------------------------//
	
	this.mc.roomChooser.setChangeHandler('onRoomChanged', this);
	
	//this fixes a bug in MM component. there where an error in original 'onTextChange' method
	//that caused component to behave strange when deleteing text with DELETE key and cursor in 0 pos.
	this.mc.msgTxt.onTextChange = function(){
		if(this.maskingFunction!=undefined){
			var len = this.text.length;
			var index = Selection.getCaretIndex()-1;
			if (index != -1) {
				var char = this.text.substring(index,index+1);
				char = this.maskingScope[this.maskingFunction](char, index, this.text);
				if(char=="") Selection.setSelection(index,index);
				this.text= this.text.slice(0,index)+char+this.text.slice(index+1,len);
			} else {
				//simply call masking function.
				this.maskingScope[this.maskingFunction](null, 0, this.text);
			}
		}
		this.onChanged();
	};
	var initialTF = this.mc.msgTxt.getNewTextFormat();
	initialTF.size = _level0.ini.text.itemToChange.mainChat.fontSize;
	this.mc.msgTxt.setTextFormat(initialTF);
	this.mc.msgTxt.setNewTextFormat(initialTF);
	//this.mc.msgTxt.setMaskingFunction('inputTextMask', this);
	
	this.mc.msgTxt.textfield_txt.onChanged = this.smileTextOnChanged;
	
	this.mc.msgTxt.background = false;
	this.mc.msgTxt.textfield_txt.border = false;
	
	this.mc.msgTxt.textfield_txt.onSetFocus = function() 
	{	var p = _global.FlashChatNS.chatUI.mc;
		p.roomChooser.myOnKillFocus();
		this._parent.borderColor = this._skin.bodyText;
		
		p.chatUI.textController.onTextFieldSetFocus();
	};
	this.mc.msgTxt.textfield_txt.onKillFocus = function() 
	{
		var p = _global.FlashChatNS.chatUI.mc;
		this._parent.borderColor = this._skin.borderColor;
		p.chatUI.textController.onTextFieldKillFocus();
	};
	
	this.mc.addRoomBtn.setClickHandler('processAddRoom', this);
	this.mc.sendBtn.setClickHandler('processSend', this);
	
	//this.mc.optionPanel.statusLabel.autoSize = 'right';
	this.mc.optionPanel.bellLabel.autoSize = 'left';
	for (var i = 0; i < this.USER_STATE_LIST.length; i ++) {
		this.mc.optionPanel.userState.addItem(this.USER_STATE_LIST[i][1], this.USER_STATE_LIST[i]);
	}
	this.mc.optionPanel.userState.setChangeHandler('onUserStateChanged', this);
	
	this.mc.optionPanel.colorChooser.setChangeHandler('onUserColorChanged', this);

	this.mc.optionPanel.btnSkinProperties.setClickHandler('processTabbedProperties', this);
	this.mc.optionPanel.btnClear.setClickHandler('processClear', this);	
	this.mc.optionPanel.btnSave.setClickHandler('processSave', this);
	this.mc.optionPanel.btnHelp.setClickHandler('processHelp', this);
	this.mc.optionPanel.btnBell.setClickHandler('processBell', this);
	
	this.mc.optionPanel.smileDropDown.setItemSymbol('SmileDropDownCustomItem');
	this.mc.optionPanel.smileDropDown.setChangeHandler('onSmileDropDownChanged', this);
	this.mc.optionPanel.smileDropDown.setClickHandler('onSmileDropDownCliked', this);
	
	this.mc.optionPanel.btn_smileDropDown.setClickHandler('onSmileDropDownClikedArea', this);

	
	//set text controler
	var t = this.textController = new EditController(this.mc);
	t.setTargetTextField( this.mc.msgTxt );
	
	// Bold Button
	t.bindComponent(this.mc.optionPanel.bold_ib,"bold","Button");
	
	// Italic Button
	t.bindComponent(this.mc.optionPanel.italic_ib,"italic","Button");
};

ChatUI.prototype.drawRect = function(x1,y1,x2,y2,l_gauge,l_color,l_alpha,fill_color,fill_alpha,sourceObj)
{
	//trace('x1 ' + x1 + ' y1 ' + y1 + ' x2 ' + x2 + ' y2 ' + y2);
	//trace('l_gauge ' + l_gauge + ' l_color ' + l_color + ' l_alpha ' + l_alpha + ' fill_color ' + fill_color + ' fill_alpha ' + fill_alpha + ' sourceObj ' + sourceObj);
	
	if (arguments.length < 4){	return; } 
	
	if (arguments.length < 7 && arguments.length > 4)
		sourceObj.lineStyle(l_gauge, l_color);
	else sourceObj.lineStyle(l_gauge, l_color, l_alpha);
	
	if(fill_color != undefined && fill_alpha != undefined && fill_alpha >= 0)
		sourceObj.beginFill(fill_color,fill_alpha);
	
	sourceObj.moveTo(x1,y1);
	sourceObj.lineTo(x2,y1);
	sourceObj.lineTo(x2,y2);
	sourceObj.lineTo(x1,y2);
	sourceObj.lineTo(x1,y1);
	
	if(fill_color != undefined && fill_alpha != undefined)
		sourceObj.endFill();
};
//------------------------------------------------------------------------------------------------------------//
ChatUI.prototype.showStretcher = function()
{
	var o = this.owner; // the grid
	
	// hide the mouse, attach and show the cursor
	Mouse.hide();
	if (o.stretcher == undefined) o.attachMovie("ResizeIcon", "stretcher", 30100);
	if(this.symbolName == 'userList')
		o.stretcher.gotoAndStop('horizontal');
	else if(this.symbolName == 'inputTextArea')
		o.stretcher.gotoAndStop('vertical');
	
	// place the cursor at the mouse
	o.stretcher._x = o._xmouse;
	o.stretcher._y = o._ymouse;
	o.stretcher._visible = true;

	// add a mouseMove for owner to get the cursor to follow the mouse
	o.onMouseMove = function()
	{
		stretcher._x = _xmouse;
		stretcher._y = _ymouse;
		updateAfterEvent();
	}
};

ChatUI.prototype.hideStretcher = function()
{
	this.owner.stretcher._visible = false;
	delete this.owner.onMouseMove;
	Mouse.show();
};
//---resize_line_mc_onPress
ChatUI.prototype.resizer_onPress = function()
{
	var o = this.owner; 
	
	// make the bar, synch to the mouse
	o.createEmptyMovieClip('stretchBar', 30050);
	o.stretchBar.clear(); 
	
	if(this.symbolName == 'userList')
	{ 
		o.chatUI.drawRect(0,0,o.chatUI.DRAG_FRAME_THICKNESS/2,Stage.height, 0,o.chatUI.DRAG_FRAME_COLOR,100, o.chatUI.DRAG_FRAME_COLOR,100, o.stretchBar);
		o.stretchBar._x = o._xmouse;	
		this.oldX = o.stretchBar._x;
	}
	else if(this.symbolName == 'inputTextArea')	
	{
		o.chatUI.drawRect(0,0,Stage.width,o.chatUI.DRAG_FRAME_THICKNESS/2, 0,o.chatUI.DRAG_FRAME_COLOR,100, o.chatUI.DRAG_FRAME_COLOR,100, o.stretchBar);
		o.stretchBar._y = o._ymouse;	
		this.oldY = o.stretchBar._y;
	}

	o.stretchBar._visible = true;
	
	var symName = this.symbolName;
	// keep the bar in synch with the mouse
	o.onMouseMove = function()
	{
		stretcher._x = _xmouse;
		stretcher._y = _ymouse;
		
		if(symName == 'userList')
		{ 
			var min_width = this.chatUI.settings.layout.userList.minWidth;
			if (min_width == -1) min_width = Stage.width * 0.1;
			
			if(this.chatUI.userListPosition == this.chatUI.USERLIST_POSITION_RIGHT)
			{ 
				var min_w = Stage.width - min_width - this.chatUI.SPACER; 
				var max_w = this.chatUI.layoutLeftPaneMinWidth; 
				stretchBar._x = Math.min(Math.max(_xmouse, max_w), min_w);
			}
			else if(this.chatUI.userListPosition == this.chatUI.USERLIST_POSITION_LEFT)
			{
				var min_w = min_width + this.chatUI.SPACER;
				var max_w = this.chatUI.layoutLeftPaneMinWidth;
				stretchBar._x = Math.max(Math.min(_xmouse, Stage.width - max_w), min_w);
			}
		}
		else if(symName == 'inputTextArea')
		{
			var min_height = this.chatUI.inputTextAreaPane.content_obj.minHeight;
			if (min_height == undefined) min_width = Stage.height * 0.1;
			
			if(this.chatUI.optionPanelPosition == this.chatUI.OPTIONPANEL_POSITION_BOTTOM)
			{ 
				//special modules
				var m14   = _level0.ini.module.anchors[14];
				if(m14 != null)
				{
					var holder14 = this.chatUI.getModuleHolder(m14);
					var mod14    = holder14['module_' + m14];
					min_height   = mod14._height + this.chatUI.SPACER;
				}
				//special modules
				var min_h = Stage.height - min_height - this.chatUI.SPACER; 
				var max_h = Stage.height - Stage.height / 2; 
				stretchBar._y = Math.min(Math.max(_ymouse, max_h), min_h);
			}
			else if(this.chatUI.optionPanelPosition == this.chatUI.OPTIONPANEL_POSITION_TOP)
			{
				var min_h = min_height + this.chatUI.SPACER + this.chatUI.preff_op_top_y;
				var max_h = Stage.height / 2; 
				stretchBar._y = Math.max(Math.min(_ymouse, max_h), min_h);
			}
		}
		updateAfterEvent();
	}
};
//---resize_line_mc_onRelease
ChatUI.prototype.resizer_onRelease = function()
{
	var o = this.owner; 
	
	if(this.symbolName == 'userList')
	{ 
		var percent = Stage.width / 100.0;
		if (o.chatUI.userList_XScale == undefined)
		{ 
			if(o.chatUI.settings.layout.userList.relWidth != -1)
				o.chatUI.userList_XScale = o.chatUI.settings.layout.userList.relWidth;
			if(o.chatUI.settings.layout.userList.width != -1)
				o.chatUI.userList_XScale = o.chatUI.settings.layout.userList.width / percent;
		}
		
		if(o.chatUI.userListPosition == o.chatUI.USERLIST_POSITION_RIGHT)
		{ 
			o.chatUI.userList_XScale += ((o.userList.paneWindow._x - o.stretchBar._x) / percent );
		}
		else if(o.chatUI.userListPosition == o.chatUI.USERLIST_POSITION_LEFT)
		{ 
			var dim = o.userList.paneWindow.getSize();
			o.chatUI.userList_XScale += ((o.stretchBar._x - (dim.width + o.userList.paneWindow._x)) / percent );
		}
		
		if(o.chatUI.settings.layout.userList.relWidth != -1)
			o.chatUI.settings.user.layout.userList.relWidth = o.chatUI.userList_XScale;
		if(o.chatUI.settings.layout.userList.width != -1)
			o.chatUI.settings.user.layout.userList.width = o.chatUI.userList_XScale * percent;
			
		o.chatUI.userList_XScalePrev = o.chatUI.userList_XScale;
		
		//save_user_settings
		o.chatUI.saveUserSettings();
	}
	else if(this.symbolName == 'inputTextArea')
	{
		var pane = o.chatUI.inputTextAreaPane; 
		var percent = Stage.height / 100.0;
		
		if (o.chatUI.optionPanel_YScale == undefined)
		{ 
			o.chatUI.optionPanel_YScale = pane.content_obj.minHeight / percent;
		}
		
		if(o.chatUI.optionPanelPosition == o.chatUI.OPTIONPANEL_POSITION_BOTTOM)
		{ 
			o.chatUI.optionPanel_YScale += ((pane._y - o.stretchBar._y) / percent );
		}
		else if(o.chatUI.optionPanelPosition == o.chatUI.OPTIONPANEL_POSITION_TOP)
		{ 
			var dim = pane.getSize();
			o.chatUI.optionPanel_YScale += ((o.stretchBar._y - (dim.height + pane._y)) / percent );
		}
		
		o.chatUI.optionPanel_YScalePrev = o.chatUI.optionPanel_YScale;
		
		o.chatUI.settings.user.layout.inputBox.YScale = o.chatUI.optionPanel_YScale;
		//save_user_settings
		o.chatUI.saveUserSettings();
	}
	
	// kill the bar and cursor
	o.stretchBar._visible = false;
	this.onRollOut();
	
	o.chatUI.onResize();
};
//------------------------------------------------------------------------------------------------------------//
ChatUI.prototype.processDragPane = function(sourceObj)
{ 
	var parent = _global.FlashChatNS.chatUI;
	var creator = parent.dialogManager.dialogHolder;
	var dim = sourceObj.getSize();
	
	if(sourceObj.symbolName == 'userList')
	{ 
		var point = { x : sourceObj.dragframe._x, y : sourceObj.dragframe._y};
		sourceObj.localToGlobal(point);
				
		var ret = parent.glueDropPane(Stage.width, dim.width, point.x, sourceObj.symbolName);
		
		var ULWidth  = Stage.width * parent.userList_XScale / 100.0;
		var ULHeight = parent.preff_ul_height + parent.preff_ul_topY + parent.SPACER;
		
		if( ret > 0 )
		{ 
			sourceObj.dragframe._visible = false;
			
			if(creator.pane_presizer_ul == undefined)
				creator.createEmptyMovieClip('pane_presizer_ul', sourceObj.getDepth()-1);
			creator.pane_presizer_ul.clear();		
			
			if(ret == parent.USERLIST_POSITION_LEFT)
			{ 
				creator.pane_presizer_ul.pos = parent.USERLIST_POSITION_LEFT;
				parent.drawRect(parent.SPACER, parent.preff_ul_topY + parent.SPACER, ULWidth, ULHeight, parent.DRAG_FRAME_THICKNESS, parent.DRAG_FRAME_COLOR,100, 0xACACAC,-1, creator.pane_presizer_ul);
			}
			else if(ret == parent.USERLIST_POSITION_RIGHT)	
			{ 
				creator.pane_presizer_ul.pos = parent.USERLIST_POSITION_RIGHT;
				parent.drawRect(Stage.width - ULWidth - parent.SPACER, parent.preff_ul_topY + parent.SPACER, Stage.width - parent.SPACER, ULHeight, parent.DRAG_FRAME_THICKNESS, parent.DRAG_FRAME_COLOR,100, 0xACACAC,-1, creator.pane_presizer_ul);
			}
		}
		else
		{
			creator.pane_presizer_ul.removeMovieClip();
			sourceObj.dragframe._visible = true;
		}
	}
	else if(sourceObj.symbolName == 'inputTextArea')
	{
		var ULWidth  = 0;
		var OPWidth  = parent.preff_op_width;
		var OPHeight = parent.preff_op_height;
		var OPTopY   = parent.preff_op_top_y;
		
		var point = { x : sourceObj.dragframe._x, y : sourceObj.dragframe._y};
		sourceObj.localToGlobal(point);
		
		var ret = parent.glueDropPane(Stage.height, dim.height, point.y, sourceObj.symbolName, OPTopY);
		
		if(parent.userListPosition != parent.USERLIST_POSITION_DOCKABLE)
			ULWidth  = Stage.width * parent.userList_XScale / 100.0;
		
		if( ret > 0 )
		{ 
			sourceObj.dragframe._visible = false;
			
			if(creator.pane_presizer_op == undefined)
				creator.createEmptyMovieClip('pane_presizer_op', sourceObj.getDepth()-1);
			creator.pane_presizer_op.clear();	
			
			var ul_pos = 1;
			if(parent.userListPosition != parent.USERLIST_POSITION_DOCKABLE)
			{ 
				if ( point.x < (Stage.width - dim.width) / 2 ) 
				{ 
					creator.pane_presizer_op.ul_pos = parent.USERLIST_POSITION_RIGHT;
					ul_pos = 1;
				}
				else	if (point.x >= (Stage.width - dim.width)/ 2)
				{ 
					creator.pane_presizer_op.ul_pos = parent.USERLIST_POSITION_LEFT;
					ul_pos = 2;
				}
				else
				{ 
					creator.pane_presizer_op.ul_pos = parent.userListPosition;
					if(creator.pane_presizer_op.ul_pos == parent.USERLIST_POSITION_RIGHT)
						ul_pos = 1;
					else if(creator.pane_presizer_op.ul_pos == parent.USERLIST_POSITION_LEFT)
						ul_pos = 2;
				}
			}
			
			if(ret == parent.OPTIONPANEL_POSITION_TOP)
			{ 
				creator.pane_presizer_op.pos = parent.OPTIONPANEL_POSITION_TOP;
				
				if(ul_pos == 1)
					parent.drawRect(parent.SPACER, OPTopY+parent.SPACER, OPWidth, OPHeight+OPTopY+parent.SPACER, parent.DRAG_FRAME_THICKNESS, parent.DRAG_FRAME_COLOR,100, 0xACACAC,-1, creator.pane_presizer_op);	
				else if(ul_pos == 2)	
					parent.drawRect(ULWidth+2*parent.SPACER, OPTopY+parent.SPACER, OPWidth+ULWidth+parent.SPACER, OPHeight+OPTopY+parent.SPACER, parent.DRAG_FRAME_THICKNESS, parent.DRAG_FRAME_COLOR,100, 0xACACAC,-1, creator.pane_presizer_op);
			}
			else if(ret == parent.OPTIONPANEL_POSITION_BOTTOM)	
			{ 
				creator.pane_presizer_op.pos = parent.OPTIONPANEL_POSITION_BOTTOM;
			
				if(ul_pos == 1)
					parent.drawRect(parent.SPACER, Stage.height-(OPHeight+parent.SPACER), OPWidth, Stage.height-parent.SPACER, parent.DRAG_FRAME_THICKNESS, parent.DRAG_FRAME_COLOR,100, 0xACACAC,-1, creator.pane_presizer_op);
				else if(ul_pos == 2)	
					parent.drawRect(ULWidth+2*parent.SPACER, Stage.height-(OPHeight+parent.SPACER), OPWidth+ULWidth+parent.SPACER, Stage.height-parent.SPACER, parent.DRAG_FRAME_THICKNESS, parent.DRAG_FRAME_COLOR,100, 0xACACAC,-1, creator.pane_presizer_op);
			}
		}
		else
		{
			creator.pane_presizer_op.removeMovieClip();
			sourceObj.dragframe._visible = true;
		}
	}
};
//------------------------------------------------------------------------------------------------------------//
ChatUI.prototype.processDropPane = function(sourceObj)
{
	var parent = _global.FlashChatNS.chatUI;
	var creator = parent.dialogManager.dialogHolder;
	
	if(sourceObj.symbolName == 'userList')
	{
		if(creator.pane_presizer_ul != undefined)
		{
			sourceObj.setDockState(false);
			parent.dialogManager.paneToBack(sourceObj.symbolName);
			
			parent.userListPosition = creator.pane_presizer_ul.pos;
			creator.pane_presizer_ul.removeMovieClip();
			
			parent.onResize();
		}
	}
	else if(sourceObj.symbolName == 'inputTextArea')
	{
		if(creator.pane_presizer_op != undefined)
		{
			sourceObj.setDockState(false);
			parent.dialogManager.paneToBack(sourceObj.symbolName);
			
			parent.optionPanelPosition = creator.pane_presizer_op.pos;
			
			if(parent.userListPosition != parent.USERLIST_POSITION_DOCKABLE)
				parent.userListPosition = creator.pane_presizer_op.ul_pos;
			
			creator.pane_presizer_op.removeMovieClip();
			
			parent.onResize();
		}
	}
	
	parent.settings.user.layout.inputBox.position = parent.optionPanelPosition;
	parent.settings.user.layout.userList.position = parent.userListPosition;
		
	//save_user_settings
	parent.saveUserSettings();
};
//------------------------------------------------------------------------------------------------------------//
ChatUI.prototype.processDragFrame = function(sourceObj)
{
	var x0 = sourceObj._x, y0 = sourceObj._y;
	var w = sourceObj._width, h = sourceObj._height;
	
	var dim = sourceObj.getSize();
	if(dim != undefined)
	{
		w = dim.width;
		h = dim.height;
	};

	//create
	var creator = this.mc.dialogHolder;
	creator.createEmptyMovieClip('dragFrame', 5000);
	
	//paint
	var thickness = this.mc.chatUI.DRAG_FRAME_THICKNESS;
	var lcolor    = this.mc.chatUI.DRAG_FRAME_COLOR;
	with (creator.dragFrame)
	{ 
		lineStyle( thickness, lcolor, 100 );
		moveTo( 0, 0 );
		lineTo( w, 0); 
		lineTo( w, h);
		lineTo( 0, h);
		lineTo( 0, 0);
	}
	
	creator.dragFrame.sourceObjName = sourceObj.symbolName;
	creator.dragFrame.parent = this;
	
	//handle coordinate changes
	creator.dragFrame.onEnterFrame = function()
	{	 
		if(this.sourceObjName == 'userList')
		{ 
			this._x = this.parent.glueDropFrame(Stage.width, this._width, this._x);
		}
		else if(this.sourceObjName == 'inputTextArea')
		{
			if( this.parent.userListPosition != this.parent.USERLIST_POSITION_DOCKABLE &&
			    this.parent.settings.layout.showUserList)
			{ 
				this._x = this.parent.glueDropFrame(Stage.width, this._width, this._x);
			}
				
			this._y = this.parent.glueDropFrame(Stage.height, this._height, this._y);
		}
	}
		
	//stop drag
	creator.dragFrame.onMouseUp = function()
	{
		this.stopDrag();
		this._visible = false;
		
		if(this.sourceObjName == 'userList')
		{
			if (this._x < 20) 
			{ 
				this.parent.userListPosition = this.parent.USERLIST_POSITION_LEFT;
				this.parent.userListPane.setDockState(false);
			}
			else if (this._x > (Stage.width - this._width)) 
			{ 
				this.parent.userListPosition = this.parent.USERLIST_POSITION_RIGHT;
				this.parent.userListPane.setDockState(false);
			}
			else if(this._x != this.parent.userListPane._x)
			{ 
				this.parent.userListPosition = this.parent.USERLIST_POSITION_DOCKABLE;
				this.parent.userListPane.setDockState(true, {x : this._x, y : this._y});
				this.parent.userListPane.sendToFront();
				this.parent.userListPane.setMoveHandler('processDragPane', this.parent);
				this.parent.userListPane.setMouseUpHandler('processDropPane', this.parent);
			}
		}
		else if(this.sourceObjName == 'inputTextArea')
		{
			if( this.parent.userListPosition != this.parent.USERLIST_POSITION_DOCKABLE )
			{ 
				if (this._x < 20) this.parent.userListPosition = this.parent.USERLIST_POSITION_RIGHT;
				if (this._x > (Stage.width - this._width)) this.parent.userListPosition = this.parent.USERLIST_POSITION_LEFT;
			}
			
			if (this._y < 20) 
			{ 
				this.parent.optionPanelPosition = this.parent.OPTIONPANEL_POSITION_TOP;
				this.parent.inputTextAreaPane.setDockState(false);
			}
			else	if (this._y > (Stage.height - this._height))
			{ 
				this.parent.optionPanelPosition = this.parent.OPTIONPANEL_POSITION_BOTTOM;
				this.parent.inputTextAreaPane.setDockState(false);
			}
			else if(this._y != this.parent.inputTextAreaPane._y)
			{
				this.parent.optionPanelPosition = this.parent.OPTIONPANEL_POSITION_DOCKABLE;
				this.parent.inputTextAreaPane.setDockState(true, {x : this._x, y : this._y});
				this.parent.inputTextAreaPane.sendToFront();
				this.parent.inputTextAreaPane.setMoveHandler('processDragPane', this.parent);
				this.parent.inputTextAreaPane.setMouseUpHandler('processDropPane', this.parent);
			}
		}
		
		this.parent.settings.user.layout.inputBox.position = this.parent.optionPanelPosition;
		this.parent.settings.user.layout.userList.position = this.parent.userListPosition;
		
		//save_user_settings
		this.parent.saveUserSettings();
		
		this.parent.onResize();
		
		delete(this.onMouseUp);
		delete(this.onEnterFrame); 
	}
	
	creator.dragFrame._x = x0;
	creator.dragFrame._y = y0;
	
	//begin drag
	creator.dragFrame.startDrag(false, 0, 0, Stage.width - w, Stage.height - h);
};

ChatUI.prototype.glueDropPane = function(stage_len, this_len, set_value, symbolName, inDd) {
	var max_diff = 50;
	var dd = (inDd != undefined)? inDd : 0;
	
	//left or top
	var bool1 = 0;
	if(set_value < (max_diff + dd))
	{ 
		if( symbolName == 'userList' )	
			bool1 = this.USERLIST_POSITION_LEFT;
		else if( symbolName == 'inputTextArea' )
			bool1 = this.OPTIONPANEL_POSITION_TOP;
	}
		
	//right or bottom
	var bool2 = 0;
	if((set_value + this_len) > (stage_len - max_diff))
	{ 
		if( symbolName == 'userList' )	
			bool2 = this.USERLIST_POSITION_RIGHT;
		else if( symbolName == 'inputTextArea' )
			bool2 = this.OPTIONPANEL_POSITION_BOTTOM;
	}
	
	return (bool1 + bool2);	
};
	

ChatUI.prototype.glueDropFrame = function(stage_len, this_len, set_value) {
	var max_diff = 40, min_diff = 20, zero_diff = 5, ret_value = set_value;
	
	//left or top
	if( set_value < max_diff && set_value > min_diff) ret_value = zero_diff;
	else if( set_value > zero_diff && set_value < min_diff) ret_value = max_diff;
	
	//right or bottom
	max_diff  = stage_len - 40 - this_len;
	min_diff  = stage_len - 20 - this_len;
	zero_diff = stage_len - 5 - this_len;
		
	if( set_value > max_diff && set_value < min_diff) ret_value = zero_diff;
	else	if( set_value < zero_diff && set_value > min_diff) ret_value = max_diff;
	
	return (ret_value);
};

//INCOMING SERVER MESSAGES.
ChatUI.prototype.loggedin = function(inSelfUserId, inSelfUserRole, inSelfUserGender) {
	//trace('LOGIN : ID ' + inSelfUserId + ' ROLE ' + inSelfUserRole + ' GEN ' + inSelfUserGender)
	
	if (inSelfUserId == null) {
		this.error('ChatUI: loggedin: invalid self user id [' + inSelfUserId + '].');
		return;
	}
	
	this.dialogManager.showPane('userList');
	this.dialogManager.showPane('inputTextArea');
	//module
	for(var i = 0; i < _level0.ini.module.length; i++)
	{
		var holder = this.getModuleHolder(i);
		if(_level0.ini.module[i].anchor == -1)
		{
			this.dialogManager.showPane('modulePane_'+i);
			this['modulePane_'+i].setContentObject(
							{
								//minWidth  : Math.max(holder['module_'+i].bWidth, _level0.ini.module[i].float_w), 
								//minHeight : Math.max(holder['module_'+i].bHeight, _level0.ini.module[i].float_h)
								minWidth  : holder['module_'+i].bWidth,
								minHeight : holder['module_'+i].bHeight
							});
			
			this['modulePane_'+i].setSize(Number(_level0.ini.module[i].float_w), Number(_level0.ini.module[i].float_h));
			this['modulePane_'+i]._x = Number(_level0.ini.module[i].float_x);
			this['modulePane_'+i]._y = Number(_level0.ini.module[i].float_y);
		}
	}
	
	this.selfUserId     = inSelfUserId;
	this.selfUserRole   = inSelfUserRole;
	
	this.selfUserGender = inSelfUserGender;

	this.setControlsEnabled(true);
		
	this.soundObj.attachSound('InitialLogin');
};

ChatUI.prototype.loggedout = function(inText) {
	var bytes = inText.split('!#@#!');
	if(bytes.length == 3)
	{
		inText = bytes[0];
		
		var toUser = this.getUser(this.selfUserId);
		var user   = this.getUser(Number(bytes[1]));
		var text   = bytes[2];
		
		this.callModuleFunc('mOnUserBannedByIP', {username : toUser.label, mastername : user.label, msg : text}, -1);
		//trace('Banned user ' + toUser.label + ' master ' + user.label + ' msg ' + text);
	}
	
	this.selfUserId = null;
	this.selfInitialized = false;
	this.layoutMinWidth = this.DEFAULT_LAYOUT_MIN_WIDTH;
	this.layoutMinHeight = this.DEFAULT_LAYOUT_MIN_HEIGHT;
	this.mc.txtSelfUserName.txt.htmlText = '';
	for (var id in this.rooms) {
		delete this.rooms[id];
		this.rooms[id] = null;
	}
	
	for (var id in this.users) {
		delete this.users[id];
		this.users[id] = null;
	}
	
	this.mc.roomChooser.removeAll();
	
	this.mc.chatLog.clear();
	this.mc.privateLog.clear();
	
	if (this.settings.layout.showUserList) {
		this.mc.userList.removeAll();
	}
	
	//open all module floating windows if it was closed
	for(var i = 0; i < _level0.ini.module.length; i++)
	{
		if(_level0.ini.module[i].path == '') continue;
		if(_level0.ini.module[i].anchor == -1) //floating window
		{
			this['modulePane_'+i].onMinimize(true);
		}	
	}
	
	this.mc.msgTxt.text = '';
	this.dialogManager.clear();
	this.privateBoxManager.clear();
	
	this.dialogManager.hideAllPanes();
		
	this.setControlsVisible(false);
	//this.setControlsEnabled(false);
	
	if(!this.firstInit)
	{ 
		this.setInitialBigSkin(this.initialBigSkin);
		this.setInitialSkin(this.initialSkin);
		this.setInitialText(this.initialText);
	}
	else this.firstInit = false;
	
	this.settings = null;

	if ((this.languages == null) || (this.languages.length == 0)) {
		this.error('ChatUI: loggedout: language list is empty.');
	}
	if (this.initialLanguageId == null) {
		this.error('ChatUI: loggedout: initial language id is empty.');
	}
	var initialLanguage = this.languages[0];
	
	//serach for initial language using id.
	for (var i = 0; i < this.languages.length; i ++) {
		if (this.languages[i].id == this.initialLanguageId) {
			initialLanguage = this.languages[i];
			break;
		}
	}
	
	//XXX01 need to release all open dialog(s).
	
	var loginBox = this.dialogManager.createDialog('LoginBox');
	loginBox.setHandler('onLoginBoxCompleted', this);
	loginBox.setLabelText(inText);
	
	loginBox.setLanguageList(this.languages);
	loginBox.setLanguageTarget(this);
	loginBox.setSelectedLanguage(initialLanguage);
	/*
	var languageSO = SharedObject.getLocal('chat_language');
	if (languageSO.data.language != null) {
		this.selectedLanguage = languageSO.data.language;
		if (this.selectedLanguage == null) {
			trace('ChatUI: loggedout: selected language is empty.');
		} else {
			loginBox.setSelectedLanguage(this.selectedLanguage);
		}
	}
	*/
	this.dialogManager.showDialog(loginBox);
};

ChatUI.prototype.roomAdded = function(id, label) {
	/*
	if (isNaN(parseInt(id))) {
		this.error('ChatUI: roomAdded: invalid id [' + id + '].');
	}
	*/
	
	label = label.trim();
	
	if (label == null || label.length == 0) {
		this.error('ChatUI: roomAdded: label is empty.');
		return;
	}
	if (this.settings == null) {
		return;
	}
	
	if (this.rooms[id] != null) {
		//if there is a 'dummy' room already, just set room label and process as usual.
		if (this.rooms[id].label == null) {
			this.rooms[id].label = label;
			this.rooms[id].isprivate = true;
		} else {
			return;
		}
	} else {
		this.rooms[id] = new Room(id, label, this);
	}
	
	if(!this.settings.layout.isSingleRoomMode) this.mc.roomChooser.addItem(label, this.rooms[id]);
	if( this.settings.layout.showUserList) 
	{ 
		this.mc.userList.addItem(this.rooms[id]);
		this.mc.userList.setSize(this.mc.userList.listWidth, this.mc.userList.listHeight);
	}
};

ChatUI.prototype.setRoomLock = function( id, inLock ) {
	var room = this.rooms[id];
	if(room != null) 
	{
		var ref = this.mc.userList.getItemRef( room );
		ref.setLock( inLock );
	}
};

/*
ChatUI.prototype.notCreated = function(textId) {
	if (this.settings == null) {
		return;
	}
	//this.setControlsEnabled(false);
	
	var promptBox = this.dialogManager.createDialog('PromptBox');
	var labelText = this.selectedLanguage.dialog.misc.roomnotcreated + '\n' + this.selectedLanguage.messages[textId];
	promptBox.setLabelTextVisible(true);
	promptBox.setInputTextVisible(false);
	promptBox.setRightButtonVisible(false);
	promptBox.setValidateRightButton(false);
	promptBox.setCloseButtonEnabled(true);
	promptBox.setLeftButtonLabel(this.selectedLanguage.dialog.common.okBtn);
	promptBox.setLabelText(labelText);
	promptBox.setHandler('onNotCreatedCompleted', this);
	this.dialogManager.showDialog(promptBox);
};
*/

ChatUI.prototype.removeRoom = function(id) {
	if (this.settings == null) {
		return;
	}
	if (this.rooms[id] == null) {
		this.error('ChatUI: removeRoom: room not found for this id [' + id + '].');
		return;
	}
	//remove from user list and room chooser only if this is not a 'dummy' room.
	if (this.rooms[id].label != null) {
		if (this.settings.layout.showUserList) {
			this.userListClearRoom(this.rooms[id]);
			var userListIdx = this.getItemIdx(this.rooms[id]);
			if (userListIdx == -1) {
				this.error('ChatUI: removeRoom: room with id [' + id + '] not found in user list.');
				return;
			} else {
				this.mc.userList.removeItemAt(userListIdx);
			}
		}
		for (var i = 0; i < this.mc.roomChooser.getLength(); i ++) {
			if (this.mc.roomChooser.getItemAt(i).data == this.rooms[id]) {
				this.mc.roomChooser.removeItemAt(i);
				break;
			}
		}
		
		if(!this.rooms[id].isprivate)
		{ 
			delete this.rooms[id];
			this.rooms[id] = null;
		}
		else this.rooms[id].label = null;
	}
};

ChatUI.prototype.userAdded = function(id, label, roomid, ucolor, ustate, timestamp, roles, gender, portrait,showmsg) {
	if (id == null) {
		this.error('ChatUI: userAdded: invalid id [' + id + '].');
		return;
	}
	if (label == null) {
		this.error('ChatUI: userAdded: label is empty.');
		return;
	}
	if (this.settings == null) {
		return;
	}
	if (this.getUser(id) != null) {
		return;
	}
	
	label = this.formatUserName(label);
	
	if(ucolor == undefined) ucolor = this.settings.skin.preset[this.settings.skin.defaultSkin].recommendedUserColor;
	if(ustate == undefined) ustate = this.USER_STATE_HERE;

	var user = new User(id, label, ucolor, ustate, roles, gender, this);
	user.setPortrait(portrait);
	
	//if room was not found for new user, we create a 'dummy' room with label==null.
	if (this.rooms[roomid] == null) 
	{
		this.rooms[roomid] = new Room(roomid, null, this);
	}
	var room = this.rooms[roomid];
	
	//trace('ChatUI: userAdded: room: ' + room);
	//trace('ChatUI: userAdded: user: ' + user);
	
	//check if it is not a 'dummy' room.
	if ((room.label != null) && this.settings.layout.showUserList) 
	{
		this.userListClearRoom(room);
	}
	
	this.users[id] = user;
	var not_in_room = (this.selfUserId != id && this.getRoomForUser(this.selfUserId) == null);
	if(!room.lock || not_in_room)
	{
		room.addUser(user);
	}	
	//trace('ChatUI: userAdded: room.users: ' + room.users);

	if (id == this.selfUserId) 
	{
		if (room.label == null) 
		{
			this.error('ChatUI: userAdded: self user cannot be added to a \'dummy\' room.');
		}
		
		this.selfRoomId = roomid;
		for (var i = 0; i < this.mc.roomChooser.getLength(); i ++) 
		{
			if (this.mc.roomChooser.getItemAt(i).data.id == this.selfRoomId) 
			{
				this.mc.roomChooser.setChangeHandler(null);
				this.mc.roomChooser.setSelectedIndex(i);
				this.mc.roomChooser.setChangeHandler('onRoomChanged', this);
				break;
			}
		}
		
		if(!room.lock) 
		{
			room.setOpened(true);
		}
		
		var welcomeStr = this.selectedLanguage.desktop.welcome;
		welcomeStr = this.replace(welcomeStr, 'USER_LABEL', label);
		this.mc.txtSelfUserName.txt.htmlText = welcomeStr;
		
		//!!!refresh
		setTextProperty('font', this.settings.user.text.itemToChange.title.fontFamily, this.mc.txtSelfUserName.txt, true);
		setTextProperty('size', this.settings.user.text.itemToChange.title.fontSize, this.mc.txtSelfUserName.txt, true);
		this.applyTitleStyle(this.settings.user.skin);
		//!!!refresh
		
		if(!room.lock)
		{
			this.addClientMessage(this.selectedLanguage.messages.selfenterroom, null, room, true, timestamp, true);
		}	
		
		this.callModuleFunc('mOnUserLogin', {username : user.label}, -1);
		
		if(room.lock)
		{
			this.onRoomChanged();
		}	
	}
	else
	{
		this.sendAvatar('mainchat', this.settings.user.avatars, true, id);
		this.sendAvatar('room', this.settings.user.avatars, true, id);
	}
	
	var img = this.settings.user.profile.nick_image;
	if(!this.settings.allowPhoto) 
	{
		var self_user = this.getUser(this.selfUserId);
		img = self_user.getPortrait();	
	}	
	this.listener.sendPhoto(img);
	
	if(!room.lock)
	{
		//check if it is not a 'dummy' room.
		if ((room.label != null) && this.settings.layout.showUserList) 
		{
			//if this is logging in process and if user list is in autoExpand mode, open this room.
			if (!this.selfInitialized && this.settings.userListAutoExpand) 
			{
				room.setOpened(true);
			}
			this.userListUpdateRoom(room);
		}
	
		if (this.selfInitialized && (id != this.selfUserId) && (room.id == this.selfRoomId)) 
		
			if (room.label == null) 
			{
				this.error('ChatUI: userAdded: self room cannot be added a \'dummy\' one.');
			}
			if( showmsg != false)
			{
				this.addClientMessage(this.selectedLanguage.messages.enterroom, user, room, true, timestamp);
				this.soundObj.attachSound('OtherUserEnters');
				this.soundObj.start();
			}
	}
	else
	{
		this.setControlsEnabled(true);
	}	
	
	this.setInputFocus();
};

ChatUI.prototype.userRemoved = function(id, timestamp) {
	if (id == null) {
		this.error('ChatUI: userRemoved: invalid id [' + id + '].');
		return;
	}
	if (this.settings == null) {
		return;
	}
	var room = this.getRoomForUser(id);
	if (room == null) {
		return;
	}
	//check if it is not a 'dummy' room.
	if ((room.label != null) && this.settings.layout.showUserList) {
		this.userListClearRoom(room);
	}
	var user = room.getUser(id);
	room.removeUser(id);
	this.users[id] = null;
	this.privateBoxManager.removeForUser(user);

	if ((room.getUserCount() == 0) || (id == this.selfUserId)) {
		room.setOpened(false);
	}
	//check if it is not a 'dummy' room.
	if ((room.label != null) && this.settings.layout.showUserList) {
		this.userListUpdateRoom(room);
	}

	if (room.id == this.selfRoomId) {
		//it is an error to be self room a 'dummy' one.	
		if (room.label == null) {
			this.error('ChatUI: userRemoved: self user cannot be removed from a \'dummy\' room.');
			return;
		}
		
		this.soundObj.attachSound('LeaveRoom');
		this.soundObj.start();
		
		if (id != this.selfUserId) {
			this.addClientMessage(this.selectedLanguage.messages.leaveroom, user, room, true, timestamp);
		}
	}
	
	this.setInputFocus();
};

ChatUI.prototype.userMovedTo = function(id, roomid, timestamp) {
	if (id == null) {
		this.error('ChatUI: userMovedTo: invalid id [' + id + '].');
		return;
	}
	if (this.settings == null) {
		return;
	}
	var user = this.getUser(id);
	if (user == null) {
		return;
	}
	
	if(
		this.rooms[roomid].lock && 
		this.users[id] != null && 
		this.getRoomForUser(id) == null
	  )
		this.rooms[roomid].addUser(this.users[id]);
	
	//remove user from old room.
	var oldRoom = this.getRoomForUser(id);
	if (oldRoom == null) {
		return;
	}
	
	//check if it is not a 'dummy' oldRoom.
	if ((oldRoom.label != null) && this.settings.layout.showUserList) {
		this.userListClearRoom(oldRoom);
	}
	oldRoom.removeUser(id);

	if ((oldRoom.getUserCount() == 0) || (id == this.selfUserId)) {
		oldRoom.setOpened(false);
	}
	//check if it is not a 'dummy' oldRoom.
	if ((oldRoom.label != null) && this.settings.layout.showUserList) {
		this.userListUpdateRoom(oldRoom);
	}

	if (oldRoom.id == this.selfRoomId) {
		//it is an error to be self room a 'dummy' one.	
		if (oldRoom.label == null) {
			this.error('ChatUI: userMovedTo: self user cannot be removed from a \'dummy\' newRoom.');
			return;
		}
		
		this.soundObj.attachSound('LeaveRoom');
		this.soundObj.start();
		
		if (id != this.selfUserId) {
			this.addClientMessage(this.selectedLanguage.messages.leaveroom, user, oldRoom, true, timestamp);
		}
	}
	//add user to new room.
	
	//if room was not found for new user, we create a 'dummy' room with label==null.
	if (this.rooms[roomid] == null) {
		this.rooms[roomid] = new Room(roomid, null, this);
	}
	var newRoom = this.rooms[roomid];
	//check if it is not a 'dummy' newRoom.
	if ((newRoom.label != null) && this.settings.layout.showUserList) {
		this.userListClearRoom(newRoom);
	}
	newRoom.addUser(user);
	
	if (id == this.selfUserId) {
		//it is an error to be self room a 'dummy' one.	
		if (newRoom.label == null) {
			this.error('ChatUI: userMovedTo: self user cannot be added to a \'dummy\' newRoom.');
			return;
		}
		this.selfRoomId = roomid;
		for (var i = 0; i < this.mc.roomChooser.getLength(); i ++) {
			if (this.mc.roomChooser.getItemAt(i).data.id == this.selfRoomId) {
				this.mc.roomChooser.setChangeHandler(null);
				this.mc.roomChooser.setSelectedIndex(i);
				this.mc.roomChooser.setChangeHandler('onRoomChanged', this);
				break;
			}
		}
		newRoom.setOpened(true);

		this.addClientMessage(this.selectedLanguage.messages.selfenterroom, null, newRoom, true, timestamp);
		
		this.callModuleFunc('mOnRoomChanged', {room : newRoom.label}, -1);
	}
	//check if it is not a 'dummy' newRoom.
	if ((newRoom.label != null) && this.settings.layout.showUserList) {
		this.userListUpdateRoom(newRoom);
		
		if(id == this.selfUserId)
		{
			for(var i = 0; i < newRoom.users.length; i++)
			{
				var mc_ref = this.mc.userList.getItemRef( newRoom.users[i] );
				if(mc_ref.blink_type == 1) 
				{
					mc_ref.stopBlinking(1);
				}
			}	
		}
	}

	if (this.selfInitialized && (id != this.selfUserId) && (newRoom.id == this.selfRoomId)) {
		if (newRoom.label == null) {
			this.error('ChatUI: userMovedTo: self newRoom cannot be added a \'dummy\' one.');
		}
		this.addClientMessage(this.selectedLanguage.messages.enterroom, user, newRoom, true, timestamp);
		this.soundObj.attachSound('OtherUserEnters');
		this.soundObj.start();
	}
	else if(id == this.selfUserId) 
	{
		this.soundObj.attachSound('EnterRoom');
		this.setControlsEnabled(true);
	}	
	
	this.setInputFocus();
};

ChatUI.prototype.formatUserName = function(inUserName) {
	var username = replaceHTMLSpecChars(inUserName);
	
	var usernam = str_replace(username,"<b>","");
		usernam = str_replace(usernam,"</b>","");
		usernam = str_replace(usernam,"<i>","");
		usernam = str_replace(usernam,"</i>","");
		usernam = str_replace(usernam,"<B>","");
		usernam = str_replace(usernam,"</B>","");
		usernam = str_replace(usernam,"<I>","");
		usernam = str_replace(usernam,"</I>","");
		
	username = str_replace(username, usernam, areplaceHTMLSpecChars(usernam));	
	
	return username;
}

//args - additional optional argument.
ChatUI.prototype.messageAddedTo = function(senderid, receiverid, roomid, text, label, args, timestamp) {
	if (senderid == null) {
		this.error('ChatUI: messageAddedTo: invalid senderid [' + senderid + '].');
		return;
	}
	/*
	if (isNaN(parseInt(roomid))) {
		this.error('ChatUI: messageAddedTo: invalid room id [' + roomid + '].');
		return;
	}
	*/
	if (text == null) {
		this.error('ChatUI: messageAddedTo: text is empty.');
		return;
	}
	if (this.settings == null) {
		return;
	}
	if (this.waitingForResponse) {
		this.waitingForResponse = false;
		this.enableSendButton();
	}

	//If label is set then use it to show the message. Also, use self color as a message color.
	var toshow = '';
	
	var sender = this.getUser(senderid);
	var user = (label != null)? label : sender.label;
	var lbl = this.settings.labelFormat;
	
	if(user != null)
	{
		lbl = _global.str_replace(lbl, 'USER', user);
		lbl = _global.str_replace(lbl, 'TIMESTAMP', this.getCurrentTime(timestamp));
	}
	else return;
		
	//we do not check here for sender==null, because it is OK with message received in response to 'back'
	//command.

	//if we have a private message (roomid==0) and if private chat log is disabled, 
	//try to find a user for this private session.
	var privateSessionUser = null;
	if ((roomid == 0) && !this.settings.layout.showPrivateLog) 
	{
		if (senderid != this.selfUserId) 
		{
			privateSessionUser = this.getUser(senderid);
		} 
		else if ((receiverid != this.selfUserId) && (receiverid != null)) 
		{
			privateSessionUser = this.getUser(receiverid);
		} 
		else if ((senderid == receiverid) && (senderid == this.selfUserId))
		{
			privateSessionUser = this.getUser(senderid);
		}
		
		//if we were able to detect user for private session, check if private box is already
		//opened for this user. if not - open it explicitly.
		if(privateSessionUser != null)
		{ 	
			if (
				!this.privateBoxManager.existsForUser(privateSessionUser) || 
				(this.settings.liveSupportMode && this.selfUserRole == privateSessionUser.ROLE_CUSTOMER)
			   ) 
			{
				this.privateBoxManager.createPrivateBox(privateSessionUser);
				privateSessionUser.minIconVisible = true;
			}
			else if(this.privateBoxManager.getUserPrivateBox(privateSessionUser).state == 'minimized')
			{
				//if listbox minimized
				if(!this.userListPane.content_mc._visible)
				{
					//this.userListPane.startBlinking(0);
				}
				
				var privateSessionRoom = this.getRoomForUser(privateSessionUser.id);
				var mc_ref = null;
				if( privateSessionRoom.getOpened())
				{ 
					mc_ref = this.mc.userList.getItemRef( privateSessionUser );
				}
				else
				{
					privateSessionUser.minIconVisible = true;
					privateSessionUser.blink_id       = -1;
					mc_ref = this.mc.userList.getItemRef( privateSessionRoom )
				}
				
				mc_ref.startBlinking(0);
				//this.privateBoxManager.maximizeForUser(privateSessionUser);
			}
		}	
	}
	
	var messageColor = null;
	//set 'system' color for the message if it is marked as 'urgent', i.e. was sent using /me command.
	if (args == 'isUrgent')
	{
		messageColor = this.settings.user.skin.bodyText;
		toshow = sender.label + ' ' + text;
		lbl    = '';
	} 
	else
	{
		if (label != null)
		{
			var selfUser = this.getUser(this.selfUserId);
			var color = (sender != undefined)? sender.color : selfUser.color;
			messageColor = color;
		} else
		{
			messageColor = sender.color;
		}
		toshow = text;
	}
	
	//dirty solutuion. true indicates that message was sent to message log inside one of open
	//popup private dialogs. added primarily not to break message processing code below.
	var messageShown = false;
	//if privateSessionUser is not empty, send message to private box manager.
	if (privateSessionUser != null) 
	{
		this.privateBoxManager.addMessageForUser(privateSessionUser, lbl, toshow, messageColor, senderid);
	} 
	else 
	{
		if ((roomid == 0) && this.settings.layout.showPrivateLog) 
		{ 
			this.mc.privateLog.addText(lbl, toshow, messageColor, senderid);
		} 
		else 
		{
			if ((this.selfRoomId == roomid) || (roomid == 0)) 
			{
				this.mc.chatLog.addText(lbl, toshow, messageColor, senderid);
			}
		}
	}
	//this.setInputFocus();
	
	//trace("------> " + toshow);
	
	if ( senderid != this.selfUserId )
	{
		if(roomid == 0)
		{ 
			//private message received
			this.soundObj.attachSound('PrivateMessageReceived');
		}
		else if (roomid == this.selfRoomId)
		{
			//public message received
			this.soundObj.attachSound('ReceiveMessage');
			this.soundObj.start();
		}
		
		if(Selection.getFocus() == null && this.settings.splashWindow) 
			this.mc.getURL("javascript:setFocus();");
	}
};

ChatUI.prototype.invitedTo = function(userid, roomid, text) {
	if (userid == null) {
		this.error('ChatUI: invitedTo: invalid userid [' + userid + '].');
		return;
	}
	/*
	if (isNaN(parseInt(roomid))) {
		this.error('ChatUI: invitedTo: invalid room id [' + roomid + '].');
		return;
	}
	*/
	if (text == null) {
		this.error('ChatUI: invitedTo: text is empty.');
		return;
	}
	if (this.settings == null) {
		return;
	}
	//this.setControlsEnabled(false);
	
	var promptBox = this.dialogManager.createDialog('PromptBox');
	var user = this.getUser(userid);
	if (user == null) {
		return;
	}
	var room = this.rooms[roomid];
	if (room.label == null) {
		this.error('ChatUI: invitedTo: \'dummy\' room encountered.');
	}
	//var labelText = 'User \'' + user.label + '\' invited you to room \'' + room.label + '\':\n' + text;
	
	var labelText = this.selectedLanguage.dialog.invitenotify.userinvited;
	labelText = this.replace(labelText, 'USER_LABEL', user.label);
	labelText = this.replace(labelText, 'ROOM_LABEL', room.label);
	if ((text == '') || (text == null)) {
		labelText += '.';
	} else {
		labelText += ':\n' + text;
	}
	
	promptBox.setResizable(true);
	promptBox.setLabelTextVisible(true);
	promptBox.setInputTextVisible(true);
	promptBox.setRightButtonVisible(true);
	promptBox.setValidateRightButton(true);
	promptBox.setCloseButtonEnabled(false);
	promptBox.setLeftButtonLabel(this.selectedLanguage.dialog.invitenotify.acceptBtn);
	promptBox.setRightButtonLabel(this.selectedLanguage.dialog.invitenotify.declineBtn);
	promptBox.setLabelText(labelText);
	promptBox.setHandler('onInvitedToCompleted', this);
	promptBox.setUserData([userid, roomid]);
	this.dialogManager.showDialog(promptBox);
	
	this.soundObj.attachSound('InvitationReceived');
};

ChatUI.prototype.invitationAccepted = function(userid, roomid, text) {
	if (userid == null) {
		this.error('ChatUI: invitationAccepted: invalid userid [' + userid + '].');
		return;
	}
	/*
	if (isNaN(parseInt(roomid))) {
		this.error('ChatUI: invitationAccepted: invalid room id [' + roomid + '].');
		return;
	}
	*/
	if (text == null) {
		this.error('ChatUI: invitationAccepted: text is empty.');
		return;
	}
	if (this.settings == null) {
		return;
	}
	//this.setControlsEnabled(false);
	
	var promptBox = this.dialogManager.createDialog('PromptBox');
	var user = this.getUser(userid);
	if (user == null) {
		return;
	}
	var room = this.rooms[roomid];
	if (room.label == null) {
		this.error('ChatUI: invitationAccepted: \'dummy\' room encountered.');
		return;
	}
	
	//var labelText = 'User \'' + user.label + '\' accepted your invitation to room \'' + room.label + '\':\n' + text;
	var labelText = this.selectedLanguage.dialog.misc.invitationaccepted;
	labelText = this.replace(labelText, 'USER_LABEL', user.label);
	labelText = this.replace(labelText, 'ROOM_LABEL', room.label);
	if ((text == '') || (text == null)) {
		labelText += '.';
	} else {
		labelText += ':\n' + text;
	}
	
	promptBox.setLabelTextVisible(true);
	promptBox.setInputTextVisible(false);
	promptBox.setRightButtonVisible(false);
	promptBox.setValidateRightButton(false);
	promptBox.setCloseButtonEnabled(true);
	promptBox.setLeftButtonLabel(this.selectedLanguage.dialog.common.okBtn);
	promptBox.setLabelText(labelText);
	promptBox.setHandler('onInvitationAcceptedCompleted', this);
	this.dialogManager.showDialog(promptBox);
};

ChatUI.prototype.invitationDeclined = function(userid, roomid, text) {
	if (userid == null) {
		this.error('ChatUI: invitationDeclined: invalid userid [' + userid + '].');
		return;
	}
	/*
	if (isNaN(parseInt(roomid))) {
		this.error('ChatUI: invitationDeclined: invalid room id [' + roomid + '].');
		return;
	}
	*/
	if (text == null) {
		this.error('ChatUI: invitationDeclined: text is empty.');
		return;
	}
	if (this.settings == null) {
		return;
	}
	//this.setControlsEnabled(false);

	var promptBox = this.dialogManager.createDialog('PromptBox');
	var user = this.getUser(userid);
	if (user == null) {
		return;
	}
	var room = this.rooms[roomid];
	if (room.label == null) {
		this.error('ChatUI: invitationDeclined: \'dummy\' room encountered.');
		return;
	}
	
	//var labelText = 'User \'' + user.label + '\' declined your invitation to room \'' + room.label + '\':\n' + text;
	var labelText = this.selectedLanguage.dialog.misc.invitationdeclined;
	labelText = this.replace(labelText, 'USER_LABEL', user.label);
	labelText = this.replace(labelText, 'ROOM_LABEL', room.label);
	if ((text == '') || (text == null)) {
		labelText += '.';
	} else {
		labelText += ':\n' + text;
	}
	
	promptBox.setLabelTextVisible(true);
	promptBox.setInputTextVisible(false);
	promptBox.setRightButtonVisible(false);
	promptBox.setValidateRightButton(false);
	promptBox.setCloseButtonEnabled(true);
	promptBox.setLeftButtonLabel(this.selectedLanguage.dialog.common.okBtn);
	promptBox.setLabelText(labelText);
	promptBox.setHandler('onInvitationDeclinedCompleted', this);
	this.dialogManager.showDialog(promptBox);
};

ChatUI.prototype.ignored = function(fromUserId, toUserId, text) {
	if (fromUserId == null) {
		this.error('ChatUI: ignored: invalid fromUserId [' + fromUserId + '].');
		return;
	}
	if (toUserId == null) {
		this.error('ChatUI: ignored: invalid toUserId [' + toUserId + '].');
		return;
	}
	if (text == null) {
		this.error('ChatUI: ignored: text is empty.');
		return;
	}
	if (this.settings == null) {
		return;
	}

	//this.setControlsEnabled(false);
	
	var toUser = this.getUser(toUserId);
	if (toUser == null) {
		this.error('ChatUI: ignored: toUser not found.');
		return;
	}
	
	if (toUserId == this.selfUserId) {
		
		var promptBox = this.dialogManager.createDialog('PromptBox');
		var user = this.getUser(fromUserId);
		if (user == null) {
			return;
		}
			
		//var labelText = 'You were ignored by user \'' + user.label + '\':\n' + text;
		var labelText = this.selectedLanguage.dialog.misc.ignored;
		labelText = this.replace(labelText, 'USER_LABEL', user.label);
		if ((text == '') || (text == null)) {
			labelText += '.';
		} else {
			labelText += ':\n' + text;
		}
			
		promptBox.setLabelTextVisible(true);
		promptBox.setInputTextVisible(false);
		promptBox.setRightButtonVisible(false);
		promptBox.setValidateRightButton(false);
		promptBox.setCloseButtonEnabled(true);
		promptBox.setLeftButtonLabel(this.selectedLanguage.dialog.common.okBtn);
		promptBox.setLabelText(labelText);
		promptBox.setHandler('onIgnoredCompleted', this);
		this.dialogManager.showDialog(promptBox);
	}
	else toUser.setIgnored(true);
};

ChatUI.prototype.unignored = function(fromUserId, toUserId, text) {
	if (fromUserId == null) {
		this.error('ChatUI: unignored: invalid fromUserId [' + fromUserId + '].');
		return;
	}
	if (toUserId == null) {
		this.error('ChatUI: unignored: invalid toUserId [' + toUserId + '].');
		return;
	}
	if (text == null) {
		this.error('ChatUI: unignored: text is empty.');
		return;
	}
	if (this.settings == null) {
		return;
	}

	//this.setControlsEnabled(false);

	var toUser = this.getUser(toUserId);
	if (toUser == null) {
		this.error('ChatUI: unignored: toUser not found.');
		return;
	}
	
	if (toUserId == this.selfUserId) {
		var promptBox = this.dialogManager.createDialog('PromptBox');
		var user = this.getUser(fromUserId);
		if (user == null) {
			return;
		}
			
		//var labelText = 'You were unignored by user \'' + user.label + '\':\n' + text;
		var labelText = this.selectedLanguage.dialog.misc.unignored;
		labelText = this.replace(labelText, 'USER_LABEL', user.label);
		if ((text == '') || (text == null)) {
			labelText += '.';
		} else {
			labelText += ':\n' + text;
		}
			
		promptBox.setLabelTextVisible(true);
		promptBox.setInputTextVisible(false);
		promptBox.setRightButtonVisible(false);
		promptBox.setValidateRightButton(false);
		promptBox.setCloseButtonEnabled(true);
		promptBox.setLeftButtonLabel(this.selectedLanguage.dialog.common.okBtn);
		promptBox.setLabelText(labelText);
		promptBox.setHandler('onUnignoredCompleted', this);
		this.dialogManager.showDialog(promptBox);
	}
	else toUser.setIgnored(false);
};

ChatUI.prototype.banned = function(fromUserId, toUserId, bantype, text) {
	if (fromUserId == null) {
		this.error('ChatUI: banned: invalid fromUserId [' + fromUserId + '].');
		return;
	}
	if (toUserId == null) {
		this.error('ChatUI: banned: invalid toUserId [' + toUserId + '].');
		return;
	}
	if (bantype == null) {
		this.error('ChatUI: banned: bantype is empty.');
		return;
	}
	if (text == null) {
		this.error('ChatUI: banned: text is empty.');
		return;
	}
	if (this.settings == null) {
		return;
	}

	//this.setControlsEnabled(false);

	var toUser = this.getUser(toUserId);
	if (toUser == null) {
		this.error('ChatUI: banned: toUser not found.');
		return;
	}
	
	toUser.setBanned(true);

	if (toUserId == this.selfUserId) {
		var promptBox = this.dialogManager.createDialog('PromptBox');
		var user = this.getUser(fromUserId);
		if (user == null) {
			return;
		}
			
		var labelText = this.selectedLanguage.dialog.misc.banned;
		var repl = user.label;
		if(fromUserId == toUserId) repl = 'MODULE';
		labelText = this.replace(labelText, 'USER_LABEL', repl);
		if ((text == '') || (text == null)) {
			labelText += '.';
		} else {
			labelText += ':\n' + text;
		}
		
		promptBox.setLabelTextVisible(true);
		promptBox.setInputTextVisible(false);
		promptBox.setRightButtonVisible(false);
		promptBox.setValidateRightButton(false);
		promptBox.setCloseButtonEnabled(true);
		promptBox.setLeftButtonLabel(this.selectedLanguage.dialog.common.okBtn);
		promptBox.setLabelText(labelText);
		promptBox.bantype = bantype;
		promptBox.setHandler('onBannedCompleted', this);
		this.dialogManager.showDialog(promptBox);
	}
};

ChatUI.prototype.unbanned = function(fromUserId, toUserId, text) {
	if (fromUserId == null) {
		this.error('ChatUI: unbanned: invalid fromUserId [' + fromUserId + '].');
		return;
	}
	if (toUserId == null) {
		this.error('ChatUI: unbanned: invalid toUserId [' + toUserId + '].');
		return;
	}
	if (text == null) {
		this.error('ChatUI: unbanned: text is empty.');
		return;
	}
	if (this.settings == null) {
		return;
	}

	//this.setControlsEnabled(false);

	var toUser = this.getUser(toUserId);
	if (toUser == null) {
		this.error('ChatUI: unbanned: toUser not found.');
		return;
	}
	toUser.setBanned(false);

	if (toUserId == this.selfUserId) {
		var promptBox = this.dialogManager.createDialog('PromptBox');
		var user = this.getUser(fromUserId);
		if (user == null) {
			return;
		}

		//var labelText = 'You were unbanned by user \'' + user.label + '\':\n' + text;
		var labelText = this.selectedLanguage.dialog.misc.unbanned;
		labelText = this.replace(labelText, 'USER_LABEL', user.label);
		if ((text == '') || (text == null)) {
			labelText += '.';
		} else {
			labelText += ':\n' + text;
		}
			
		promptBox.setLabelTextVisible(true);
		promptBox.setInputTextVisible(false);
		promptBox.setRightButtonVisible(false);
		promptBox.setValidateRightButton(false);
		promptBox.setCloseButtonEnabled(true);
		promptBox.setLeftButtonLabel(this.selectedLanguage.dialog.common.okBtn);
		promptBox.setLabelText(labelText);
		promptBox.setHandler('onUnbannedCompleted', this);
		this.dialogManager.showDialog(promptBox);
	}
};

ChatUI.prototype.confirm = function(fromUserId, toUserId, inReply) {
	if (fromUserId == null) {
		this.error('ChatUI: confirm: invalid fromUserId [' + fromUserId + '].');
		return;
	}
	if (toUserId == null) {
		this.error('ChatUI: confirm: invalid toUserId [' + toUserId + '].');
		return;
	}
	if (inReply == null) {
		this.error('ChatUI: confirm: reply is empty.');
		return;
	}
	if (this.settings == null) {
		return;
	}
	
	if (toUserId == this.selfUserId) {
		var user = this.getUser(fromUserId);
		if (user == null) {
			return;
		}
		var promptBox = this.dialogManager.createDialog('PromptBox');
		
		var rply = inReply.split(',');
		var labelText = '';
		switch(rply[0])
		{
			case 'gag' :
				labelText = this.selectedLanguage.dialog.misc.gagconfirm;				
				labelText = this.replace(labelText, 'MINUTES', rply[1]);
				break;
			case 'alrt' : 
				labelText = this.selectedLanguage.dialog.misc.alertconfirm;				
				break;
			case 'flsh_a': 
				labelText = this.selectedLanguage.dialog.misc.file_accepted;
				break;
						
			case 'flsh_d': 
				labelText = this.selectedLanguage.dialog.misc.file_declined;
				break;
		}		
		
		labelText = this.replace(labelText, 'USER_LABEL', user.label);
	
		promptBox.setLabelTextVisible(true);
		promptBox.setInputTextVisible(false);
		promptBox.setRightButtonVisible(false);
		promptBox.setValidateRightButton(false);
		promptBox.setCloseButtonEnabled(true);
		promptBox.setLeftButtonLabel(this.selectedLanguage.dialog.common.okBtn);
		promptBox.setLabelText(labelText);
		promptBox.setHandler('onConfirmCompleted', this);
		this.dialogManager.showDialog(promptBox);
	}
};

ChatUI.prototype.gag = function(fromUserId, toUserId, minutes) {
	if (fromUserId == null) {
		this.error('ChatUI: gag: invalid fromUserId [' + fromUserId + '].');
		return;
	}
	if (toUserId == null) {
		this.error('ChatUI: gag: invalid toUserId [' + toUserId + '].');
		return;
	}
	if (minutes == null) {
		this.error('ChatUI: gag: minutes is empty.');
		return;
	}
	if (this.settings == null) {
		return;
	}
	
	if (toUserId == this.selfUserId) {
		var promptBox = this.dialogManager.createDialog('PromptBox');
		
		var user = this.getUser(fromUserId);
		if (user == null) {
			return;
		}
		
		var labelText = this.selectedLanguage.dialog.misc.gag;
		labelText = this.replace(labelText, 'DURATION', minutes);
		
		promptBox.setUserData(user);
		
		promptBox.setLabelTextVisible(true);
		promptBox.setInputTextVisible(false);
		promptBox.setRightButtonVisible(false);
		promptBox.setValidateRightButton(false);
		promptBox.setCloseButtonEnabled(true);
		promptBox.setLeftButtonLabel(this.selectedLanguage.dialog.common.okBtn);
		promptBox.setLabelText(labelText);
		promptBox.setHandler('onGagCompleted', this);
		this.dialogManager.showDialog(promptBox);
		
		this.floodIntervalTime = this.getTimeMilis();
		this.gagIntervalTime = minutes;
	}
};

ChatUI.prototype.ungagged = function(fromUserId, toUserId, text) {
	if (fromUserId == null) {
		this.error('ChatUI: ungagged: invalid fromUserId [' + fromUserId + '].');
		return;
	}
	if (toUserId == null) {
		this.error('ChatUI: ungagged: invalid toUserId [' + toUserId + '].');
		return;
	}
	if (text == null) {
		this.error('ChatUI: ungagged: text is empty.');
		return;
	}
	if (this.settings == null) {
		return;
	}

	if (toUserId == this.selfUserId && this.gagIntervalTime != 0) {
		
		this.gagIntervalTime = 0;
		
		var promptBox = this.dialogManager.createDialog('PromptBox');
		var user = this.getUser(fromUserId);
		if (user == null) {
			return;
		}

		//var labelText = 'You were ungagged by user \'' + user.label + '\':\n' + text;
		var labelText = this.selectedLanguage.dialog.misc.ungagged;
		labelText = this.replace(labelText, 'USER_LABEL', user.label);
		if ((text == '') || (text == null)) {
			labelText += '.';
		} else {
			labelText += ':\n' + text;
		}
			
		promptBox.setLabelTextVisible(true);
		promptBox.setInputTextVisible(false);
		promptBox.setRightButtonVisible(false);
		promptBox.setValidateRightButton(false);
		promptBox.setCloseButtonEnabled(true);
		promptBox.setLeftButtonLabel(this.selectedLanguage.dialog.common.okBtn);
		promptBox.setLabelText(labelText);
		promptBox.setHandler('onUngaggedCompleted', this);
		this.dialogManager.showDialog(promptBox);
	}
};

ChatUI.prototype.alertWindow = function(text) {
	var promptBox = this.dialogManager.createDialog('PromptBox');
		
	var labelText = '';
	if ((text != '') || (text != null)) labelText = text;
		
	promptBox.setUserData(user);
		
	promptBox.setLabelTextVisible(true);
	promptBox.setInputTextVisible(false);
	promptBox.setRightButtonVisible(false);
	promptBox.setValidateRightButton(false);
	promptBox.setCloseButtonEnabled(true);
	promptBox.setLeftButtonLabel(this.selectedLanguage.dialog.common.okBtn);
	promptBox.setLabelText(labelText);
		
	promptBox.setHandler('onAlertCompleted', this);
	
	this.dialogManager.showDialog(promptBox);
};

ChatUI.prototype.alert = function(fromUserId, toUserId, text, args) {
	if (fromUserId == null) {
		this.error('ChatUI: alert: invalid fromUserId [' + fromUserId + '].');
		return;
	}
	if (toUserId == null) {
		this.error('ChatUI: alert: invalid toUserId [' + toUserId + '].');
		return;
	}
	if (text == null) {
		this.error('ChatUI: alert: text is empty.');
		return;
	}
	if (this.settings == null) {
		return;
	}


	if (toUserId == this.selfUserId) {
		var promptBox = this.dialogManager.createDialog('PromptBox');
		
		var user = this.getUser(fromUserId);
		if (user == null) {
			return;
		}

		var labelText = this.selectedLanguage.dialog.misc.alert;
		if(args == 'calrt') labelText = this.selectedLanguage.dialog.misc.chatalert;
		
		if ((text != '') || (text != null)) labelText += text;
		
		promptBox.setUserData(user);
		
		promptBox.setLabelTextVisible(true);
		promptBox.setInputTextVisible(false);
		promptBox.setRightButtonVisible(false);
		promptBox.setValidateRightButton(false);
		promptBox.setCloseButtonEnabled(true);
		promptBox.setLeftButtonLabel(this.selectedLanguage.dialog.common.okBtn);
		promptBox.setLabelText(labelText);
		
		if(args == 'ralrt')
			promptBox.setHandler('onRoomAlertCompleted', this);
		else	if(args == 'calrt')
			promptBox.setHandler('onChatAlertCompleted', this);
		else	
			promptBox.setHandler('onAlertCompleted', this);
		
		this.dialogManager.showDialog(promptBox);
	}
};

ChatUI.prototype.roomAlert = function(fromUserId, text)
{
	var user = this.getUser(this.selfUserId);
	if(!this.settings.showConfirmation && this.selfUserId == fromUserId) return;
	if(user.getBanned()) return;
	
	this.alert(fromUserId, this.selfUserId, text, 'ralrt');
};

ChatUI.prototype.chatAlert = function(fromUserId, text)
{
	if(!this.settings.showConfirmation && this.selfUserId == fromUserId) return;
	
	this.alert(fromUserId, this.selfUserId, text, 'calrt');
};

ChatUI.prototype.userStateChanged = function(userid, state) {
	if (userid == null) {
		this.error('ChatUI: userStateChanged: invalid userid [' + userid + '].');
		return;
	}
	if (state == null) {
		this.error('ChatUI: userStateChanged: state is empty.');
		return;
	}
	if (this.settings == null) {
		return;
	}
	var room = this.getRoomForUser(userid);
	if (room == null) {
		return;
	}
	
	var user = room.getUser(userid);
	user.setState(state);
	room.sortUsers();	
	
	if (!this.selfInitialized && (userid == this.selfUserId)) {
		this.selfInitialized = true;
	}
	if (room.getOpened() && this.settings.layout.showUserList) {
		this.userListUpdateUser(user);
	}
	
	if(this.settings.listOrder == 'STATUS' || this.settings.listOrder == 'MOD_STATUS')
	{ 
		this.userListUpdateRoom(room, true);
	}
	
	this.setInputFocus();
};

ChatUI.prototype.userColorChanged = function(userid, color) {
	if (userid == null) {
		this.error('ChatUI: userColorChanged: invalid userid [' + userid + '].');
		return;
	}
	if (color == null) {
		this.error('ChatUI: userColorChanged: color is empty.');
		return;
	}
	if (this.settings == null) {
		return;
	}
	var room = this.getRoomForUser(userid);
	
	if (room == null) {
		return;
	}
	var user = room.getUser(userid);
	
	user.setColor(color);
	if (userid == this.selfUserId) {
		//commented out. input text color does not depend on user color now.
		//this.mc.msgTxt.textColor = color;
		//this.privateBoxManager.setTextColor(color);
		this.settings.user.userColor = color;
		
		//save_user_settings
		this.saveUserSettings();
		
		this.setColored(this.settings.user.userColor);
	}
	if (room.getOpened() && this.settings.layout.showUserList) {
		this.userListUpdateUser(user);
	}
};

ChatUI.prototype.bellRang = function(userid, timestamp) {
	if (userid == null) {
		this.error('ChatUI: bellRang: invalid userid [' + userid + '].');
		return;
	}
	if (this.settings == null) {
		return;
	}
	var user = this.getUser(userid);
	this.addClientMessage(this.selectedLanguage.messages.bellrang, user, null, true, timestamp);
	
	this.soundObj.attachSound('RingBell');
	this.soundObj.start();
};

ChatUI.prototype.back = function(numb) {
	this.addClientMessage('/back ' + numb, null, null, true, null);
};

ChatUI.prototype.backtime = function(numb) {
	this.addClientMessage('/backtime ' + numb, null, null, true, null);
};

ChatUI.prototype.errorAlert = function(inTextId, inUserId, inRoomId) {
	var txt = this.selectedLanguage.messages[inTextId];
	
	if (inUserId != null) {
		var user = this.getUser(inUserId);
		txt = this.replace(txt, 'USER_LABEL', user.label);
	}
	if (inRoomId != null) {
		var room = this.rooms[inRoomId];
		if (room.label == null) {
			this.error('ChatUI: alert: \'dummy\' room encountered.');
		}
		txt = this.replace(txt, 'ROOM_LABEL', room.label);
	}
	
	var promptBox = this.dialogManager.createDialog('PromptBox');
	promptBox.setLabelTextVisible(true);
	promptBox.setInputTextVisible(false);
	promptBox.setRightButtonVisible(false);
	promptBox.setValidateRightButton(false);
	promptBox.setCloseButtonEnabled(true);
	promptBox.setLeftButtonLabel(this.selectedLanguage.dialog.common.okBtn);
	
	promptBox.setLabelText(txt);
	if(inTextId == 'locked') promptBox.setHandler('onInvalidPassCompleted', this);
	else promptBox.setHandler('onRoomAlertCompleted', this);
	this.dialogManager.showDialog(promptBox);
};

ChatUI.prototype.userNotify = function(inUserId) {
	var user = new User();
	if(this.selfUserRole == user.ROLE_ADMIN)
	{
		var inUser = this.getUser(inUserId);
		var room = this.getRoomForUser(inUserId);
		var mc_ref = null;
		
		inUser.blink_id   = -1;
		inUser.blink_type = 1;
		if( room.getOpened() )
		{ 
			mc_ref = this.mc.userList.getItemRef( inUser );
		}
		else
		{
			mc_ref = this.mc.userList.getItemRef( room );
		}
		
		mc_ref.startBlinking(1);
	}
};

//END INCOMING SERVER MESSAGES.

ChatUI.prototype.addListener = function(inListener) {
	this.listener = inListener;
};

ChatUI.prototype.setSettings = function(inSettings) {
	//validate settings. all minimum sizes should be specified, for every configurable element
	//there should be either relative or absolute size given too.
	//process skins.
	var errorString = '';
	if (inSettings.layout.showUserList) {
		if (inSettings.layout.userList.minWidth == -1) {
			errorString += 'minimum size was not specified for user list\n';
		}
		if ((inSettings.layout.userList.width == -1) && (inSettings.layout.userList.relWidth == -1)) {
			errorString += 'neither relative nor absiolute size was not specified for user list\n';
		}
	}
	if (inSettings.layout.showPublicLog) {
		if (inSettings.layout.publicLog.minHeight == -1) {
			errorString += 'minimum size was not specified for public log\n';
		}
		if ((inSettings.layout.publicLog.height == -1) && (inSettings.layout.publicLog.relHeight == -1)) {
			errorString += 'neither relative nor absiolute size was not specified for public log\n';
		}
	}
	if (inSettings.layout.showPrivateLog) {
		if (inSettings.layout.privateLog.minHeight == -1) {
			errorString += 'minimum size was not specified for private log\n';
		}
		if ((inSettings.layout.privateLog.height == -1) && (inSettings.layout.privateLog.relHeight == -1)) {
			errorString += 'neither relative nor absiolute size was not specified for private log\n';
		}
		
		//---------------------------------------------------------------------------------------------------//
		this.mc.privateLog = this.mc.smileTextHolder.attachMovie('SmileText', 'privateLog', this.mc.smileTextHolder.depth++);	
		//---------------------------------------------------------------------------------------------------//
	}
	if (inSettings.layout.showInputBox) {
		if (inSettings.layout.inputBox.minHeight == -1) {
			errorString += 'minimum size was not specified for input box\n';
		}
		if ((inSettings.layout.inputBox.height == -1) && (inSettings.layout.inputBox.relHeight == -1)) {
			errorString += 'neither relative nor absiolute size was not specified for input box\n';
		}
	}
	if (!inSettings.layout.showPublicLog && !inSettings.layout.showPrivateLog && !inSettings.layout.showInputBox) {
		errorString += 'at least public log, private log or input box should be enabled\n';
	}
	
	if (errorString != '') {
		this.settings = null;
		trace(errorString);
		this.loggedout(this.selectedLanguage.desktop.invalidsettings);
		return;
	}
	this.settings = inSettings;
	
	var settingsSO = SharedObject.getLocal('chat_settings_' + this.selfUserId);
	
	if (settingsSO.data.user != null ) 
	{
		this.settings.user = settingsSO.data.user;
		if(this.settings.user.bigSkin == undefined) 
			this.settings.user.bigSkin = this.settings.bigSkin.preset[this.settings.bigSkin.defaultSkin];
		if(this.settings.user.skin == undefined) 
			this.settings.user.skin = this.settings.skin.preset[this.settings.skin.defaultSkin];
		if(this.settings.user.skin.headline == undefined) 
		{
			this.settings.user.skin.headline = -1;
			this.settings.user.skin.userListItem = -1;
			this.settings.user.skin.controlsBackground = -1;
		}
		if(this.settings.user.skin.scrollBG == undefined)
		{
			this.settings.user.skin.scrollBG = -1;
			this.settings.user.skin.scrollerBG = -1;
			this.settings.user.skin.scrollBGPress = -1;
			this.settings.user.skin.scrollBorder = -1;
		}
		if(this.settings.user.skin.buttonPress == undefined)
		{
			this.settings.user.skin.closeButtonBorder = -1;
			this.settings.user.skin.buttonPress = -1;
			this.settings.user.skin.minimizeButtonBorder = -1;
		}	
		if(this.settings.user.text == undefined)
			this.settings.user.text = this.settings.text;
		if(this.settings.user.sound == undefined)
			this.settings.user.sound = this.settings.sound;
		if(this.settings.user.profile == undefined)
		{
			this.settings.user.profile = new Object();
			this.settings.user.profile.nick_image = '';
		}	
			
		if(this.settings.user.layout == undefined)	
		{ 
			this.settings.user.layout = new Object();
			this.settings.user.layout.inputBox = this.settings.layout.inputBox;
			this.settings.user.layout.userList = this.settings.layout.userList;
		}
		else
		{
			if(this.settings.user.layout.inputBox.position != this.OPTIONPANEL_POSITION_DOCKABLE)
			{ 
				this.settings.layout.inputBox = this.settings.user.layout.inputBox;
			}
			else this.settings.user.layout.inputBox = this.settings.layout.inputBox;
			
			if(this.settings.user.layout.userList.position != this.USERLIST_POSITION_DOCKABLE)
			{ 
				this.settings.layout.userList = this.settings.user.layout.userList;
			}
			else this.settings.user.layout.userList = this.settings.layout.userList;
		}
		
		this.settings.user.avatars = this.getAvatar();
		
		
		if(this.settings.user.avatars.splashWindow != undefined)
			this.settings.splashWindow = this.settings.user.avatars.splashWindow;
	} 
	else 
	{
		this.settings.user.skin = this.settings.skin.preset[this.settings.skin.defaultSkin];
		this.settings.user.bigSkin = this.settings.bigSkin.preset[this.settings.bigSkin.defaultSkin];
		this.settings.user.sound = this.settings.sound;
		this.settings.user.text = this.settings.text;	
		this.settings.user.avatars = this.getAvatar();
		this.settings.user.avatars.splashWindow = this.settings.splashWindow;
		this.settings.user.layout = new Object();
		this.settings.user.layout.inputBox = this.settings.layout.inputBox;
		this.settings.user.layout.userList = this.settings.layout.userList;
		this.settings.user.profile = new Object();
		this.settings.user.profile.nick_image = '';
		this.saveUserSettings();
	}

	
	_global.FlashChatNS.selectedSkin = this.settings.user.skin.id;
	
	this.sendAvatar('mainchat', this.settings.user.avatars, true);
	this.sendAvatar('room', this.settings.user.avatars, true);
	if(this.settings.allowPhoto) this.listener.sendPhoto(this.settings.user.profile.nick_image);
		
	var width_scale = 0;
	if (this.settings.layout.userList.relWidth != -1)
		width_scale = this.settings.layout.userList.relWidth;
	if (this.settings.layout.userList.width != -1)
		width_scale = (this.settings.layout.userList.width / Stage.width) * 100;
	this.userList_XScale = this.userList_XScalePrev = width_scale;
		
	if(this.settings.layout.inputBox.YScale != undefined)	
	{ 
		this.optionPanel_YScale = this.optionPanel_YScalePrev = this.settings.layout.inputBox.YScale;
	}
	
	if (this.settings.user.userColor == null) {
		this.settings.user.userColor = this.settings.user.skin.recommendedUserColor;
	}
	
	
	//-------------------------------------------------------------------------------------------------------//	
	//calculate minimum layout width and height.
	var leftPaneMinWidth = 0;
	var leftPaneMinHeight = this.mc.txtSelfUserName.txt._height;

	//analize and layout option panel (layout is done only once for OP).
	var optionPanelWidth = this.layoutOptionPanel();
	if (optionPanelWidth == 0) {
		this.settings.layout.showOptionPanel = false;
	}

	//analize left pane (containing room chooser, public/private logs, option panel and input text).
	if (!this.settings.layout.isSingleRoomMode) {
		//require min 50 pixels for room chooser.
		var roomChooserMinWidth = this.mc.roomLabel._width + 50;
		if (this.settings.layout.allowCreateRoom) {
			roomChooserMinWidth += this.SPACER + this.mc.addRoomBtn._width;
		}
		if ((leftPaneMinWidth == 0) || (roomChooserMinWidth > leftPaneMinWidth)) {
			leftPaneMinWidth = roomChooserMinWidth;
		}
		leftPaneMinHeight += this.SPACER + this.mc.roomChooser._height;
	}
	if (this.settings.layout.showPublicLog) {
		//require min 100 pixels for public log.
		var publicLogMinWidth = 100;
		var publicLogMinHeight = this.settings.layout.publicLog.minHeight;
		if ((this.settings.layout.publicLog.height != -1) && (this.settings.layout.publicLog.height > publicLogMinHeight)) {
			publicLogMinHeight = this.settings.layout.publicLog.height;
		}
		if ((leftPaneMinWidth == 0) || (publicLogMinWidth > leftPaneMinWidth)) {
			leftPaneMinWidth = publicLogMinWidth;
		}
		leftPaneMinHeight += this.SPACER + publicLogMinHeight;
		
		this.mc.chatLog.setMinWidth(leftPaneMinWidth);
	}
	if (this.settings.layout.showPrivateLog) {
		//require min 100 pixels for private log.
		var privateLogMinWidth = 100;
		var privateLogMinHeight = this.settings.layout.privateLog.minHeight;
		if ((this.settings.layout.privateLog.height != -1) && (this.settings.layout.privateLog.height > privateLogMinHeight)) {
			privateLogMinHeight = this.settings.layout.privateLog.height;
		}
		if ((leftPaneMinWidth == 0) || (privateLogMinWidth > leftPaneMinWidth)) {
			leftPaneMinWidth = privateLogMinWidth;
		}
		leftPaneMinHeight += this.SPACER + privateLogMinHeight;
		
		this.mc.privateLog.setMinWidth(leftPaneMinWidth);
	}
	
	var inputTextAreaMinHeight = 0;
	if (this.settings.layout.showOptionPanel) {
		var optionPanelMinWidth = optionPanelWidth + this.SPACER;
		var optionPanelMinHeight = this.mc.optionPanel._height;
		if ((leftPaneMinWidth == 0) || (optionPanelMinWidth > leftPaneMinWidth)) {
			leftPaneMinWidth = optionPanelMinWidth;
		}
		
		inputTextAreaMinHeight += this.SPACER + optionPanelMinHeight;
		leftPaneMinHeight += this.SPACER + optionPanelMinHeight;
	}
	if (this.settings.layout.showInputBox) {
		//require min 100 pixels for input box.
		var inputBoxMinWidth = 100 + this.SPACER + this.mc.sendBtn._width;
		var inputBoxMinHeight = this.settings.layout.inputBox.minHeight;
		if ((this.settings.layout.inputBox.height != -1) && (this.settings.layout.inputBox.height > inputBoxMinHeight)) {
			inputBoxMinHeight = this.settings.layout.inputBox.height;
		}
		if ((leftPaneMinWidth == 0) || (inputBoxMinWidth > leftPaneMinWidth)) {
			leftPaneMinWidth = inputBoxMinWidth;
		}
		
		inputTextAreaMinHeight += this.SPACER + inputBoxMinHeight;
		leftPaneMinHeight += this.SPACER + inputBoxMinHeight;
		this.mc.msgTxt.setMaxChars(this.settings.maxMessageSize);
	}

	//analize right pane (containing user list).
	var rightPaneMinWidth = 0;
	if (this.settings.layout.showUserList) {
		rightPaneMinWidth = this.settings.layout.userList.minWidth;
	}
	var rightPaneMinHeight = 0;
	if (this.settings.layout.showUserList) {
		//require min 100 pixels for user list height.
		rightPaneMinHeight = 100;
		if ((this.settings.layout.userList.width != -1) && (this.settings.layout.userList.width > rightPaneMinWidth)) {
			rightPaneMinWidth = this.settings.layout.userList.width;
		}
	}

	this.layoutMinWidth = 3 * this.SPACER + leftPaneMinWidth + rightPaneMinWidth;
	this.layoutLeftPaneMinWidth = leftPaneMinWidth;
	this.layoutMinHeight = 2 * this.SPACER + Math.max(leftPaneMinHeight, rightPaneMinWidth);
	
	//trace('minimum dimension for this layout: ' + this.layoutMinWidth + ',' + this.layoutMinHeight);

	this.mc.chatLog.setMaxMessageCount(this.settings.maxMessageCount);
	this.mc.privateLog.setMaxMessageCount(this.settings.maxMessageCount);
	this.fillSmieDropdown(this.settings.smiles, this.mc.optionPanel.smileDropDown, true);
	
	//-------------------------------------------------------------------------------------------------------//
	
	this.mc.optionPanel.colorChooser.setValue(this.settings.user.userColor);
	
	//set to position
	this.userListPosition     = this.settings.layout.userList.position;
	this.optionPanelPosition  = this.settings.layout.inputBox.position;
	
	var obj1 = new Object();
	obj1.dockWidth  = this.settings.layout.userList.dockWidth;
	obj1.dockHeight = this.settings.layout.userList.dockHeight; 
	obj1.minWidth   = 150;
	obj1.minHeight  = 100;
	this.userListPane.setContentObject(obj1);
	
	var obj2 = new Object();
	obj2.dockWidth  = 100;
	obj2.dockHeight = 100; 
	obj2.minWidth   = (optionPanelWidth > 0)? 2*this.SPACER + optionPanelWidth : 200;
	obj2.minHeight  = this.SPACER + inputTextAreaMinHeight;
	obj2.op_visible = (optionPanelWidth > 0);
	this.inputTextAreaPane.setContentObject(obj2);	
	
	_global.FlashChatNS.SKIN_NAME = this.settings.user.bigSkin.swf_name;
	
	this.applySkin(this.settings.user.skin);
		
	this.applyBigSkin(this.settings.user.bigSkin)
	this.applySoundProperties(this.settings.user.sound);
	this.applyTextProperties(this.settings.user.text.itemToChange);
	this.privateBoxManager.setSettings(this.settings);
	
	this.mc.skinBackground._visible = true;
	this.setControlsVisible(true);
	
	this.inactivityIntervalId = setInterval(this.logout, this.settings.inactivityInterval * 1000, this);

	this.onResize();
	
	
};

ChatUI.prototype.logout = function(chatUI)
{
	clearInterval(chatUI.inactivityIntervalId);
	chatUI.listener.logout();
};

//sets list of all available languages. however, it is possible that language data will be truncated
//in this list. only filds required to display login box may be present at this point.
//full language us set in setLanguage(...) method. 
ChatUI.prototype.setLanguages = function(inLanguageList) {
	this.languages = inLanguageList;
	var languageTemplate = new CLanguage();
	for (var i = 0; i < this.languages.length; i ++) {
		this.copyObjectTree(languageTemplate, this.languages[i]);
	}
};

//sets and applies active lanuage.
ChatUI.prototype.setLanguage = function(inLanguage) {
	//we do not do additional check here if given language is a member of language list, specified 
	//before.
	this.setSelectedLanguage(inLanguage);
	this.applyLanguage(this.selectedLanguage);
};

//sets an initial skin for UI. this skin is used to display login box. usually it will be
//the defaultSkin in global settings. however, it should not contain background images.
ChatUI.prototype.setInitialSkin = function(inInitialSkin) {
	this.initialSkin = inInitialSkin;
	this.applySkin(this.initialSkin);
};

//sets an initial theme for UI. this theme is used to display login box. usually it will be
//the defaultSkin in global settings. however, it should not contain background images.
ChatUI.prototype.setInitialBigSkin = function(inInitialBigSkin) {
	this.initialBigSkin = inInitialBigSkin;
	this.applyBigSkin(this.initialBigSkin);
};

//sets an initial text properties for UI(i.e. fontSize, fontFamily, ...). this properties is used to display login box. usually it will be
//the defaultSkin in global settings. however, it should not contain background images.
ChatUI.prototype.setInitialText = function(inInitialText) {
	this.initialText = inInitialText;
	var tmpObj = new Object();
	for(var itm in this.initialText)
	{
		tmpObj[itm] = new Object();
		tmpObj[itm].fontSize   = this.initialText[itm].size;	
		tmpObj[itm].fontFamily = this.initialText[itm].font;
		tmpObj[itm].presence   = this.initialText[itm].presence;
	}
	tmpObj.myTextColor = this.initialText.myTextColor;
	
	this.applyTextProperties(tmpObj);
};

//sets 'initial language' internal field. initial language is used to set up language chooser in
//login box only. because during first login language objects may be incomplete, we use 'id'
//instead of language object.
ChatUI.prototype.setInitialLanguageId = function(inInitialLanguageId) {
	this.initialLanguageId = inInitialLanguageId;
};

//PRIVATE METHODS.

//sets 'selectedLanguage' internal variable and saves selected language to local shared object.
ChatUI.prototype.setSelectedLanguage = function(language) {
	this.selectedLanguage = language;
	/*
	var languageSO = SharedObject.getLocal('chat_language');
	delete languageSO.data.language;
	languageSO.data.language = null;
	languageSO.flush();
	languageSO.data.language = this.selectedLanguage;
	languageSO.flush();
	*/
};

ChatUI.prototype.onLoginBoxCompleted = function(control) {
	this.listener.login(control.getUserName(), control.getPassword(), this.selectedLanguage.id);
	this.dialogManager.releaseDialog(control);
};

ChatUI.prototype.onDialogCompleted = function() {
	if(this.dialogManager.dialogList.length == 0)
		this.setControlsEnabled(true);
}

ChatUI.prototype.onNotCreatedCompleted = function(control) {
	this.dialogManager.releaseDialog(control);
	this.onDialogCompleted();
};

ChatUI.prototype.onInvitedToCompleted = function(control) {
	var text = control.getEnteredText();
	var userid = control.getUserData()[0];
	var roomid = control.getUserData()[1];
	if (!control.canceled()) {
		this.listener.acceptInvitationTo(userid, roomid, text);
		
		for (var i = 0; i < this.mc.roomChooser.getLength(); i ++)
		{
			if (this.mc.roomChooser.getItemAt(i).data.id == roomid)
			{
				this.mc.roomChooser.setSelectedIndex(i);
				break;
			}
		}
		//autochange room
		this.listener.inviteMoveTo(roomid);
	} else {
		this.listener.declineInvitationTo(userid, roomid, text);
	}
	this.dialogManager.releaseDialog(control);
	this.onDialogCompleted();
};

ChatUI.prototype.onInvitationAcceptedCompleted = function(control) {
	this.dialogManager.releaseDialog(control);
	this.onDialogCompleted();
};

ChatUI.prototype.onInvitationDeclinedCompleted = function(control) {
	this.dialogManager.releaseDialog(control);
	this.onDialogCompleted();
};

ChatUI.prototype.onIgnoredCompleted = function(control) {
	this.dialogManager.releaseDialog(control);
	this.onDialogCompleted();
};

ChatUI.prototype.onUnignoredCompleted = function(control) {
	this.dialogManager.releaseDialog(control);
	this.onDialogCompleted();
};

ChatUI.prototype.onBannedCompleted = function(control) {
	this.soundObj.attachSound('UserBannedBooted');
	this.dialogManager.releaseDialog(control);
	this.onDialogCompleted();
};

ChatUI.prototype.onUnbannedCompleted = function(control) {
	this.dialogManager.releaseDialog(control);
	this.onDialogCompleted();
};

ChatUI.prototype.onUngaggedCompleted = function(control) {
	this.dialogManager.releaseDialog(control);
	this.onDialogCompleted();
};

ChatUI.prototype.onConfirmCompleted = function(control) {
	this.dialogManager.releaseDialog(control);
	this.onDialogCompleted();
};

ChatUI.prototype.onInvalidPassCompleted = function(control) {
	for (var i = 0; i < this.mc.roomChooser.getLength(); i ++)
	{
		if (this.mc.roomChooser.getItemAt(i).data.id == this.selfRoomId)
		{
			this.mc.roomChooser.setChangeHandler(null);
			this.mc.roomChooser.setSelectedIndex(i);
			this.mc.roomChooser.setChangeHandler('onRoomChanged', this);
			break;
		}
	}
	
	this.dialogManager.releaseDialog(control);
	this.onDialogCompleted();
};

ChatUI.prototype.onAlertCompleted = function(control) {
	//send confirmation
	if(this.settings.showConfirmation)
		this.listener.confirm(control.getUserData().id, '', 'alrt');
	
	this.dialogManager.releaseDialog(control);
	this.onDialogCompleted();
};

ChatUI.prototype.onRoomAlertCompleted = function(control) {
	this.dialogManager.releaseDialog(control);
	this.onDialogCompleted();
};

ChatUI.prototype.onChatAlertCompleted = function(control) {
	this.dialogManager.releaseDialog(control);
	this.onDialogCompleted();
};
 
ChatUI.prototype.onGagCompleted = function(control) {
	//send confirmation
	if(this.settings.showConfirmation)
		this.listener.confirm(control.getUserData().id, this.gagIntervalTime, 'gag');
	
	this.dialogManager.releaseDialog(control);
	this.onDialogCompleted();
};

ChatUI.prototype.showRoomPassPromt = function(inRoomId) {
	var room = this.rooms[inRoomId];
	
	if(room.lock)
	{
		var promptBox = this.dialogManager.createDialog('PromptBox');
		
		var labelText = '';
		var isInput   = false;
		var usrData   = new Object();
		
		usrData.lock  = true;
		usrData.id    = inRoomId;
		
		labelText = this.selectedLanguage.messages.roomlock;
		isInput   = true;
		promptBox.txtInputText.password = true;
		
		promptBox.setLabelTextVisible(true);
		promptBox.setInputTextVisible(isInput);
		promptBox.setRightButtonVisible(false);
		promptBox.setValidateRightButton(false);
		promptBox.setCloseButtonEnabled(true);
		promptBox.setLeftButtonLabel(this.selectedLanguage.dialog.common.okBtn);
		promptBox.setLabelText(labelText);
		promptBox.setUserData(usrData);
		promptBox.setHandler('onRoomChangedCompleted', this);
		this.dialogManager.showDialog(promptBox);
	}
}

ChatUI.prototype.onRoomChanged = function(control) {
	var room = this.mc.roomChooser.getSelectedItem().data;
	var usr_cnt = room.getUserCount()
	
	if(room.id == this.selfRoomId && room.lock)
	{
		this.showRoomPassPromt(room.id);
	}
	//check for 'maxUsersPerRoom'
	else if(usr_cnt >= this.settings.maxUsersPerRoom)
	{
		var promptBox = this.dialogManager.createDialog('PromptBox');
		
		var labelText = '';
		var isInput   = false;
		var usrData   = new Object();
		
		labelText = this.selectedLanguage.dialog.misc.roomisfull;
		labelText = this.replace(labelText, 'ROOM_LABEL', room.label);
		
		promptBox.setLabelTextVisible(true);
		promptBox.setInputTextVisible(isInput);
		promptBox.setRightButtonVisible(false);
		promptBox.setValidateRightButton(false);
		promptBox.setCloseButtonEnabled(true);
		promptBox.setLeftButtonLabel(this.selectedLanguage.dialog.common.okBtn);
		promptBox.setLabelText(labelText);
		promptBox.setUserData(usrData);
		promptBox.setHandler('onRoomChangedCompleted', this);
		this.dialogManager.showDialog(promptBox);
	}
	else if(room.lock)
	{
		this.showRoomPassPromt(room.id);	
	}
	else
	{ 
		this.listener.moveTo(room.id);	
	}
	
	this.setInputFocus();
};

ChatUI.prototype.onRoomChangedCompleted = function(inControl)
{
	this.setControlsEnabled(true);
	
	inControl.txtInputText.password = false;
	this.dialogManager.releaseDialog(inControl);
	
	var usrData = inControl.getUserData();
		
	if(usrData.lock && !inControl.isCanceled)
	{
		this.listener.moveTo(usrData.id, inControl.getEnteredText());	
	}
	else
	{
		for (var i = 0; i < this.mc.roomChooser.getLength(); i ++)
		{
			if (this.mc.roomChooser.getItemAt(i).data.id == this.selfRoomId)
			{
				this.mc.roomChooser.setChangeHandler(null);
				this.mc.roomChooser.setSelectedIndex(i);
				this.mc.roomChooser.setChangeHandler('onRoomChanged', this);
				break;
			}
		}
	}	
};

ChatUI.prototype.resizeImageBG = function(inImg) {
	if(
		_global.FlashChatNS.preff_image_width  != undefined && 
		_global.FlashChatNS.preff_image_height != undefined
	  )
	{ 	
		
		var w = _global.FlashChatNS.preff_image_width;
		if (w < Stage.width) w = Stage.width;
		
		var h = _global.FlashChatNS.preff_image_height;
		if (h < Stage.height) h = Stage.height;
		
		inImg.image_mc._width  = w;
		inImg.image_mc._height = h;
	}
}

ChatUI.prototype.onResize = function() {
	//trace('ON RESIZE ' + (this.settings == null));
	
	var stageWidth = Stage.width;
	var stageHeight = Stage.height;
	
	this.resizeImageBG(this.mc.backgroundImageHolder.image);
	
	if (stageWidth < this.layoutMinWidth) {
		stageWidth = this.layoutMinWidth;
	}
	if (stageHeight < this.layoutMinHeight) {
		stageHeight = this.layoutMinHeight;
	}

	//position dialog boxes.
	this.dialogManager.fixDialogPositions(stageWidth, stageHeight);
	//END position dialog boxes.

	//validate position of private boxes
	this.privateBoxManager.setStageSize(stageWidth, stageHeight);
	//END validate position of private boxes

	this.mc.backgroundImageHolder.mask._width = stageWidth;
	this.mc.backgroundImageHolder.mask._height = stageHeight;

	//position skin background.
	this.mc.skinBackground._width  = stageWidth;
	this.mc.skinBackground._height = stageHeight;

	//bail out if ui was not initialized yet.
	if (this.settings == null) {
		return;
	}

	this.mc.txtSelfUserName._x = this.SPACER;
	this.mc.txtSelfUserName._y = 0;
	
	//-----------------------------------------------------------------------------------------------------//
	if(this.mc.txtSelfUserName.txt.htmlText == '') 
		this.mc.txtSelfUserName.txt.htmlText = 'Welcome';
	var title_height = this.mc.txtSelfUserName.txt._height;
	if(this.mc.logOffBtn.getLabel().toUpperCase() != 'X') 
		title_height = Math.max(title_height, this.mc.logOffBtn._height + 4);
	if(this.mc.titleBG == undefined) 
	{ 
		var depth = this.mc.dummy_title_mc.getDepth();
		this.mc.dummy_title_mc._visible = false;
		this.mc.titleBG = this.mc.createEmptyMovieClip('titleBG_test', depth);
		
		this.mc.titleBG.myWidth  = stageWidth;
		this.mc.titleBG.myHeight = title_height;
		var headline_color = (this.settings.user.skin['headline'] < 0)? this.settings.user.skin['dialogTitle'] : this.settings.user.skin['headline'];
		fillHGradient(this.mc.titleBG, headline_color);
		
		this.mc.txtSelfUserName.txt.autoSize = 'left';
		this.mc.roomLabel.autoSize = 'left';
	}
	else
	{ 
		this.mc.titleBG._width  = stageWidth;
		this.mc.titleBG._height = title_height;
	}
	//-----------------------------------------------------------------------------------------------------//	
	var currentY = this.mc.txtSelfUserName._y + this.mc.titleBG._height;
	var top_Y = currentY;

	this.mc.txtSelfUserName.txt._y = (this.mc.titleBG._height - this.mc.txtSelfUserName.txt._height) / 2;	
	
	if(this.mc.logOffBtn.getLabel().toUpperCase() == 'X')
	{ 
		this.mc.logOffBtn.setSize(this.mc.titleBG._height - 5, this.mc.titleBG._height - 5);
		this.mc.logOffBtn._y = 2.5;
	}
	else 
	{ 
		this.mc.logOffBtn.setSize(this.mc.logOffBtn._width, this.mc.logOffBtn._height);
		this.mc.logOffBtn._y = (this.mc.titleBG._height - this.mc.logOffBtn._height) / 2;
	}
		
	this.mc.logOffBtn._x = stageWidth - this.mc.logOffBtn._width - this.SPACER;
	
	//----inner option panel alignment--------------------------------------------------------------//
	var op_w = this.layoutOptionPanel();
	this.layoutLeftPaneMinWidth = op_w + this.SPACER;
	//----------------------------------------------------------------------------------------------//
		
	var userListWidth = 0, userListWidthTemp = 0;
	if (this.settings.layout.showUserList &&  this.userListPosition != this.USERLIST_POSITION_DOCKABLE) {
		
		var width_scale = 0;
		if(this.userList_XScale != undefined)
		{ 
			width_scale = this.userList_XScale;
		}
		
		if(this.userList_XScalePrev != undefined && this.userList_XScalePrev > this.userList_XScale)
		{ 
			width_scale = this.userList_XScalePrev;
		}
			
		userListWidth = userListWidthTemp = stageWidth * width_scale / 100.0;
		
		//limit user list width to satisfy layoutLeftPaneMinWidth constraint.
		userListWidth = Math.min(stageWidth - 2 * this.SPACER - this.layoutLeftPaneMinWidth, userListWidth);
		if (this.settings.layout.userList.minWidth != -1) {
			userListWidth = Math.max(userListWidth, this.settings.layout.userList.minWidth);
		}
		
		this.preff_ul_topY = currentY;
		this.preff_ul_height = stageHeight - 2 * this.SPACER - currentY;
		
		if(this.userList_XScale != undefined)
		{ 
			if(userListWidth != userListWidthTemp && this.userList_XScalePrev < this.userList_XScale) 
				this.userList_XScalePrev = this.userList_XScale;
			
			this.userList_XScale = userListWidth / stageWidth * 100;
		}
		
		this.mc.userList.paneWindow.setSize(userListWidth, this.preff_ul_height);
		
		this.mc.customListView_resizer._visible = true;
		this.mc.customListView_resizer.clear();
		this.drawRect(0,0,this.SPACER,this.mc.userList._height, 1,0xA2AAAA,0, 0xACACAC, 0, this.mc.customListView_resizer);
		//---move userList to (_x,_y)------------------------------------------------------------//
		if (this.userListPosition == this.USERLIST_POSITION_LEFT)
		{ 
			this.mc.userList.paneWindow._x = this.SPACER;
			this.mc.customListView_resizer._x = this.mc.userList.paneWindow._x + userListWidth;
		}
		else if(this.userListPosition == this.USERLIST_POSITION_RIGHT)
		{ 
			this.mc.userList.paneWindow._x = stageWidth - (this.SPACER + userListWidth);
			this.mc.customListView_resizer._x = this.mc.userList.paneWindow._x - this.SPACER;
		}
		//---------------------------------------------------------------------------------------//
		this.mc.userList.paneWindow._y = this.mc.customListView_resizer._y = currentY + this.SPACER;
	}
	else if(this.userListPosition == this.USERLIST_POSITION_DOCKABLE)
	{
		this.mc.customListView_resizer._visible = false;
	}
	else 
	{ 
		this.mc.customListView_resizer._visible = false;
		this.mc.userList.paneWindow._x = 0;
		this.mc.userList.paneWindow._y = 0;
	}

	var availableWidth = stageWidth - userListWidth - this.SPACER;
	var roomChooserAvailableWidth = availableWidth;

	var createRoomHeight = 0;
	if (this.settings.layout.allowCreateRoom && !this.settings.layout.isSingleRoomMode) {
		
		//---------------------------------------------------------------------------------------//
		if (this.userListPosition == this.USERLIST_POSITION_LEFT)
		{ 
			this.mc.addRoomBtn._x = stageWidth - (this.SPACER + this.mc.addRoomBtn._width);
			roomChooserAvailableWidth = this.mc.addRoomBtn._x - (this.mc.userList.paneWindow._x + userListWidth);
		}
		else if(this.userListPosition == this.USERLIST_POSITION_RIGHT ||
		        this.userListPosition == this.USERLIST_POSITION_DOCKABLE)
		{
			this.mc.addRoomBtn._x = availableWidth - this.SPACER - this.mc.addRoomBtn._width;
			roomChooserAvailableWidth = this.mc.addRoomBtn._x;
		}
		
		//---------------------------------------------------------------------------------------//
		this.mc.addRoomBtn._y = currentY + this.SPACER;
		createRoomHeight = this.mc.addRoomBtn._height + this.SPACER;
	}

	var roomChooserHeight = 0;
	if (!this.settings.layout.isSingleRoomMode) {
		
		//---------------------------------------------------------------------------------------//
		if (this.userListPosition == this.USERLIST_POSITION_LEFT)
		{
			this.mc.roomLabel._x =  this.mc.userList.paneWindow._x + userListWidth + this.SPACER;
			roomChooserAvailableWidth -= (this.SPACER + this.mc.roomLabel._width);
		}
		else if(this.userListPosition == this.USERLIST_POSITION_RIGHT ||
		        this.userListPosition == this.USERLIST_POSITION_DOCKABLE)
		{ 
			this.mc.roomLabel._x = this.SPACER;
			roomChooserAvailableWidth -= (this.mc.roomLabel._x + this.mc.roomLabel._width);
		}
		//---------------------------------------------------------------------------------------//
		
		this.mc.roomLabel._y = currentY + this.SPACER;
		this.mc.roomChooser._x = this.mc.roomLabel._x + this.mc.roomLabel._width + this.SPACER;
		this.mc.roomChooser._y = currentY + this.SPACER;
		roomChooserHeight = this.mc.roomChooser._height + this.SPACER;
	}
	
	currentY += Math.max(createRoomHeight, roomChooserHeight);
	top_Y = currentY;
	this.preff_op_top_y = top_Y;
	
	var availableHeight = stageHeight - currentY;

	if (this.settings.layout.showPublicLog) {
		availableHeight -= this.SPACER;
	}
	if (this.settings.layout.showPrivateLog) {
		availableHeight -= this.SPACER;
	}
	
	if(this.optionPanelPosition != this.OPTIONPANEL_POSITION_DOCKABLE)
	{ 
		if (this.settings.layout.showOptionPanel) {
			availableHeight -= (this.SPACER + this.mc.optionPanel._height);
		}
		if (this.settings.layout.showInputBox) {
			availableHeight -= this.SPACER;
		}
	}
	
	availableHeight -= this.SPACER;
	var totalBoxHeight = availableHeight;

	var publicLogHeight = null;
	var privateLogHeight = null;
	var inputBoxHeight = null;

	var unresolvedHeightDefList = new Array();
	if (this.settings.layout.showPublicLog) {
		unresolvedHeightDefList.push([this.settings.layout.publicLog.relHeight, this.settings.layout.publicLog.height, this.settings.layout.publicLog.minHeight]);
	}
	if (this.settings.layout.showPrivateLog) {
		unresolvedHeightDefList.push([this.settings.layout.privateLog.relHeight, this.settings.layout.privateLog.height, this.settings.layout.privateLog.minHeight]);
	}
	if (this.settings.layout.showInputBox && this.optionPanelPosition != this.OPTIONPANEL_POSITION_DOCKABLE)
	{
		unresolvedHeightDefList.push([this.settings.layout.inputBox.relHeight, this.settings.layout.inputBox.height, this.settings.layout.inputBox.minHeight]);
	}

	var heightList = this.distributeLengths(unresolvedHeightDefList, availableHeight);
	
	//special modules
	var m13 = _level0.ini.module.anchors[13];
	var m14 = _level0.ini.module.anchors[14];
	var m13_h = 0;
	var m14_h = 0;
	if(m13 != null) 
	{
		var holder13 = this.getModuleHolder(m13);
		var mod13    = holder13['module_' + m13];
	}
	if(m14 != null)
	{
		var holder14 = this.getModuleHolder(m14);
		var mod14    = holder14['module_' + m14];
	}
	//special modules	
	
	if (this.settings.layout.showPublicLog) {
		if(m13 != null) m13_h = heightList[0] / 3;
		if(m14 != null) m14_h = heightList[0] / 3;
		publicLogHeight = heightList[0] - m13_h - m14_h;
		heightList.splice(0, 1);
	}
	
	if (this.settings.layout.showPrivateLog) {
		privateLogHeight = heightList[0];
		heightList.splice(0, 1);
	}
	
	if (this.settings.layout.showInputBox && this.optionPanelPosition != this.OPTIONPANEL_POSITION_DOCKABLE)
	{
		inputBoxHeight = heightList[0];
		heightList.splice(0, 1);

		if(this.optionPanel_YScale != undefined)
		{ 
			var dif = 0;
			if(this.settings.layout.showOptionPanel)
			{
				dif = (this.mc.optionPanel._height + 3*this.SPACER) / stageHeight * 100.0;
			}
			
			if(this.optionPanel_YScale > this.optionPanel_YScalePrev)
				this.optionPanel_YScale = this.optionPanel_YScalePrev;
			
			var newBoxHeight = (this.optionPanel_YScale - dif) * stageHeight / 100.0;
			if(newBoxHeight < this.mc.optionPanel._height) 
			{ 
				newBoxHeight = this.mc.optionPanel._height;
				if(this.optionPanel_YScale < this.optionPanel_YScalePrev)
					this.optionPanel_YScalePrev = this.optionPanel_YScale;
			}
			
			if(this.settings.layout.showPublicLog)
				publicLogHeight += (inputBoxHeight - newBoxHeight);
			else if(this.settings.layout.showPrivateLog)
				privateLogHeight += (inputBoxHeight - newBoxHeight); 
				
			inputBoxHeight = newBoxHeight;
		}
	}
	
	//---------------------------------------------------------------------------------------//
	var left_indent;
	if (this.userListPosition == this.USERLIST_POSITION_LEFT)
	{ 
		left_indent = this.SPACER + this.mc.userList.paneWindow._x + userListWidth;
	}
	else if(this.userListPosition == this.USERLIST_POSITION_RIGHT ||
	        this.userListPosition == this.USERLIST_POSITION_DOCKABLE)
	{ 
		left_indent = this.SPACER;
	}
	//---------------------------------------------------------------------------------------//
	
	if (this.settings.layout.showPublicLog) {
		this.mc.chatLog._x = left_indent;
		
		if (
			this.optionPanelPosition == this.OPTIONPANEL_POSITION_BOTTOM || 
			this.optionPanelPosition == this.OPTIONPANEL_POSITION_DOCKABLE 
		   )
		{ 
			this.mc.chatLog._y = currentY + this.SPACER;
		}
		
		this.mc.chatLog.setSize(availableWidth - 2 * this.SPACER, publicLogHeight);
		currentY = this.mc.chatLog._y + this.mc.chatLog._height;
		
		if(m13 != null) 
		{
			if(mod13.mOnModuleWindowResize == null)
			{
				mod13._height = m13_h - this.SPACER;
				mod13._width  = availableWidth - 2 * this.SPACER;
			}
			else
			{
				_global.FlashChatNS.chatUI.callModuleFunc('mOnModuleWindowResize', {width : availableWidth - 2 * this.SPACER, height : m13_h - this.SPACER}, m13);
			}
			currentY += m13_h;
		}	
		if(m14 != null) 
		{	
			if(mod14.mOnModuleWindowResize == null)
			{
				mod14._height = m14_h - this.SPACER;
				mod14._width = availableWidth - 2 * this.SPACER;
			}
			else
			{
				_global.FlashChatNS.chatUI.callModuleFunc('mOnModuleWindowResize', {width : availableWidth - 2 * this.SPACER, height : m14_h - this.SPACER}, m14);
			}	
		}
	}
	//trace('chat log: ' + this.mc.chatLog._y + ',' + this.mc.chatLog._height);
	
	if (this.settings.layout.showPrivateLog) {
		this.mc.privateLog._x = left_indent;
		
		if (
			this.optionPanelPosition == this.OPTIONPANEL_POSITION_BOTTOM || 
			this.optionPanelPosition == this.OPTIONPANEL_POSITION_DOCKABLE
		   )
		{ 
			this.mc.privateLog._y = currentY + this.SPACER;	
		}	
		
		this.mc.privateLog.setSize(availableWidth - 2 * this.SPACER, privateLogHeight);
		currentY = this.mc.privateLog._y + this.mc.privateLog._height;
	}
	//trace('private log: ' + this.mc.privateLog._y + ',' + this.mc.privateLog._height);
	
	var op_x = -1, op_y, op_h;
	
	var op_dim   = {x : 0, y : 0};
	var msg_dim  = {x : 0, y : 0};
	var send_dim = {x : 0, y : 0};
	
	if(this.optionPanelPosition != this.OPTIONPANEL_POSITION_DOCKABLE)
	{ 
		if (this.settings.layout.showOptionPanel)
		{
			if (this.optionPanelPosition == this.OPTIONPANEL_POSITION_BOTTOM)
			{ 
				op_dim.y = currentY + this.SPACER;
			}
			else if(this.optionPanelPosition == this.OPTIONPANEL_POSITION_TOP)
			{ 
				op_dim.y = top_Y + this.SPACER;
			}
			
			op_dim.x = left_indent; 
			currentY = op_dim.y + this.mc.optionPanel._height;
			
			op_x = op_dim.x;
			op_y = op_dim.y;
			op_h = this.mc.optionPanel._height;
			if (!this.settings.layout.showInputBox) op_h += this.SPACER;
			
			top_Y = op_y + op_h;
		}
		//trace('option panel: ' + this.mc.optionPanel._y + ',w = ' + this.mc.optionPanel._width);
		
		if (this.settings.layout.showInputBox)
		{
			if (this.optionPanelPosition == this.OPTIONPANEL_POSITION_BOTTOM)
			{ 
				msg_dim.y = currentY + this.SPACER;
			}
			else if(this.optionPanelPosition == this.OPTIONPANEL_POSITION_TOP)
			{ 
				msg_dim.y = top_Y + this.SPACER;
			}
			
			msg_dim.x = left_indent;
			
			//---------------------------------------------------------------------------------------//
			if (this.userListPosition == this.USERLIST_POSITION_LEFT)
			{ 
				send_dim.x = stageWidth - this.SPACER - this.mc.sendBtn._width;
			}
			else if(this.userListPosition == this.USERLIST_POSITION_RIGHT ||
			        this.userListPosition == this.USERLIST_POSITION_DOCKABLE)
			{ 
				send_dim.x = availableWidth - this.SPACER - this.mc.sendBtn._width;
			}
			
			var btn_width = this.mc.sendBtn._width; 
			//---------------------------------------------------------------------------------------//
			var btn_h = (this.inputTextAreaPane.content_obj.minHeight > inputBoxHeight)? inputBoxHeight : this.inputTextAreaPane.content_obj.minHeight;
			this.mc.sendBtn.setSize(this.mc.sendBtn.width, btn_h);
			this.mc.msgTxtBackground._height = inputBoxHeight - this.SPACER/2 - 1;
			send_dim.x += btn_width - this.mc.sendBtn._width;
			
			var w = 0;
			if(this.userListPosition == this.USERLIST_POSITION_LEFT)
			{ 
				w = stageWidth - 4 * this.SPACER - userListWidth - this.mc.sendBtn._width;
				this.mc.inputTextArea_resizer._x = userListWidth + 2*this.SPACER;
				
			}else if(this.userListPosition == this.USERLIST_POSITION_RIGHT ||
			         this.userListPosition == this.USERLIST_POSITION_DOCKABLE)
			{ 
				w = send_dim.x - 2 * this.SPACER;
				this.mc.inputTextArea_resizer._x = this.SPACER;
			}
			
			var html_txt = this.mc.msgTxt.htmlText;
			html_txt = html_txt.split("> ").join(">&nbsp;");
			this.mc.msgTxt.setSize(w, inputBoxHeight - this.SPACER/2);
			this.mc.msgTxt.htmlText = html_txt;
			this.mc.msgTxtBackground._width = w - 1;
			
			if(!this.settings.layout.showOptionPanel)
			{
				op_x = msg_dim.x;
				op_y = msg_dim.y;
				op_w = this.mc.msgTxt._width + this.mc.sendBtn._width;
				op_h = this.mc.msgTxt._height;
			}
			else
			{
				var mw = (send_dim.x - msg_dim.x) + this.mc.sendBtn._width;
				op_w = mw;
				op_h = this.mc.msgTxt._height + (msg_dim.y - op_dim.y);	
			}
			
			this.mc.inputTextArea_resizer._visible = true;
			this.mc.inputTextArea_resizer.clear();
			this.drawRect(0,0,op_w,this.SPACER, 1,0xA2AAAA,0, 0xACACAC, 0, this.mc.inputTextArea_resizer);
			
			if (this.optionPanelPosition == this.OPTIONPANEL_POSITION_BOTTOM)
				this.mc.inputTextArea_resizer._y = op_y - this.SPACER;
			else if(this.optionPanelPosition == this.OPTIONPANEL_POSITION_TOP)
				this.mc.inputTextArea_resizer._y = op_y + op_h - this.SPACER;
		}
		//trace('input box: ' + this.mc.msgTxt._y + ',' + this.mc.msgTxt._height + ',' + + this.mc.msgTxt._width);
	}
	else
	{
		this.mc.inputTextArea_resizer._visible = false;
		if(this.settings.layout.showOptionPanel || this.settings.layout.showInputBox)
		{ 
			var dim = this.inputTextAreaPane.getSize();
			op_w = this.layoutOptionPanel() + 2*this.SPACER;
			
			if(op_w == 2*this.SPACER) this.inputTextAreaPane.setSize(dim.width, dim.height);
			else if( this.inputTextAreaPane.content_obj.minWidth != op_w)
			{
				this.inputTextAreaPane.content_obj.minWidth = op_w;
				this.inputTextAreaPane.setSize(op_w, dim.height);
			}
			
			
		}
	}
	
	this.preff_op_width = stageWidth - userListWidth - 2*this.SPACER;
	
	//resize optionPanelBG
	if(op_x != -1) 
	{
		op_x -= this.SPACER;
		op_y -= this.SPACER;
		op_w += this.SPACER;
		op_h += this.SPACER;
		
		if(!this.settings.layout.showInputBox) op_w = this.preff_op_width;
		
		this.optionPanel_YScale = op_h / stageHeight * 100;
		if(this.optionPanel_YScalePrev == undefined) this.optionPanel_YScalePrev = this.optionPanel_YScale;
		
		this.preff_op_width  = op_w;
		this.preff_op_height = op_h;
		
		this.inputTextAreaPane._x = op_x;
		this.inputTextAreaPane._y = op_y;
		this.inputTextAreaPane.setSize(op_w, op_h);
		
		this.mc.optionPanelBG._x = 0;
		this.mc.optionPanelBG._y = this.SPACER;
		this.mc.optionPanelBG._width = op_w;
		this.mc.optionPanelBG._height = op_h - 2*this.SPACER;
		
		op_dim.x   -= op_x;
		op_dim.y   -= op_y;
		msg_dim.x  -= op_x;
		msg_dim.y  -= op_y;
		send_dim.x -= op_x;
		
		this.mc.optionPanel._x = op_dim.x;
		this.mc.optionPanel._y = op_dim.y;
		
		this.mc.msgTxt._x = msg_dim.x;
		this.mc.msgTxt._y = msg_dim.y;
		
		this.mc.msgTxtBackground._x = msg_dim.x;
		this.mc.msgTxtBackground._y = this.mc.msgTxt._y;
		
		this.mc.sendBtn._x = send_dim.x;
		this.mc.sendBtn._y = msg_dim.y;
		
		if(this.optionPanelPosition == this.OPTIONPANEL_POSITION_TOP)
		{ 
			top_Y = op_y + op_h;
			if (this.settings.layout.showPublicLog)
			{ 
				this.mc.chatLog._y = top_Y;
				top_Y = this.mc.chatLog._y + this.mc.chatLog._height
			}
			
			if (this.settings.layout.showPrivateLog)
			{ 
				this.mc.privateLog._y =  top_Y + this.SPACER;	
				top_Y = this.mc.privateLog._y + this.mc.privateLog._height;
			}
		}
	}
	else
	{
		this.mc.optionPanelBG._visible = false;
	}
	
	this.alignModule(-1);
	
	if (!this.settings.layout.isSingleRoomMode) {
		this.mc.roomChooser.setSize(roomChooserAvailableWidth - 2 * this.SPACER);
		updateAfterEvent();
	}	
	
	this.setInputFocus();
};

ChatUI.prototype.processLogOffButton = function() {
	this.soundObj.attachSound('Logout');
	this.listener.logout();
};

ChatUI.prototype.processAddRoom = function() {
	//this.setControlsEnabled(false);

	var createRoomBox = this.dialogManager.createDialog('CreateRoomBox');
	createRoomBox.setHandler('onCreateRoomCompleted', this);
	createRoomBox.setCloseButtonEnabled(true);
	this.dialogManager.showDialog(createRoomBox);
};

ChatUI.prototype.onCreateRoomCompleted = function(control) {
	this.setControlsEnabled(true);
	if (!control.canceled()) {
		this.listener.createRoom(control.getEnteredText(), control.isPublic(), control.getEnteredPass());
	}
	this.dialogManager.releaseDialog(control);
};

ChatUI.prototype.onInviteBoxCompleted = function(control) {
	this.setControlsEnabled(true);
	if (!control.canceled()) {
		var userid = control.getUserData().id;
		var selectedRoom = control.getSelectedRoom();
		var enteredText = control.getEnteredText();
		this.listener.inviteUserTo(userid, selectedRoom.id, enteredText);
	}
	this.dialogManager.releaseDialog(control);
};

ChatUI.prototype.onIgnoreCompleted = function(control) {
	this.setControlsEnabled(true);
	if (!control.canceled()) {
		var userid = control.getUserData().id;
		var enteredText = control.getEnteredText();
		this.listener.ignoreUser(userid, enteredText);
	}
	this.dialogManager.releaseDialog(control);
};

ChatUI.prototype.onUnignoreCompleted = function(control) {
	this.setControlsEnabled(true);
	if (!control.canceled()) {
		var userid = control.getUserData().id;
		var enteredText = control.getEnteredText();
		this.listener.unignoreUser(userid, enteredText);
	}
	this.dialogManager.releaseDialog(control);
};

ChatUI.prototype.onBanCompleted = function(control) {
	this.setControlsEnabled(true);
	if (!control.canceled()) {
		var userid = control.getUserData().id;
		var enteredText = control.getEnteredText();
		var bantype = control.getBanType();
		var selectedRoom = control.getSelectedRoom()
		/*
		var usr = this.getUser(userid);
		usr.setBanned(true);
		*/
		this.listener.banUser(userid, bantype, selectedRoom.id, enteredText);
	}
	this.dialogManager.releaseDialog(control);
};

ChatUI.prototype.onUnbanCompleted = function(control) {
	this.setControlsEnabled(true);
	if (!control.canceled()) {
		var userid = control.getUserData().id;
		var enteredText = control.getEnteredText();
		/*
		var usr = this.getUser(userid);
		usr.setBanned(false);
		*/
		this.listener.unbanUser(userid, enteredText);
	}
	this.dialogManager.releaseDialog(control);
};

ChatUI.prototype.setControlsEnabled = function(inEnabled) {
	this.mc.roomChooser.setEnabled(inEnabled);
	this.mc.addRoomBtn.setEnabled(inEnabled);
	this.mc.logOffBtn.setEnabled(inEnabled);
	this.mc.sendBtn.setEnabled(inEnabled);
	if(this.mc.msgTxt.type != undefined)
		this.mc.msgTxt.type = (inEnabled)? 'input' : 'dynamic';
	this.mc.userList.setEnabled(inEnabled);
	
	if(!this.userListPane.dockState)
	{
		this.mc.customListView_resizer.enabled = (inEnabled);
		this.mc.customListView_resizer._visible = (inEnabled);
	}	
	if(!this.inputTextAreaPane.dockState) 
	{
		this.mc.inputTextArea_resizer.enabled = (inEnabled);
		this.mc.inputTextArea_resizer._visible  = (inEnabled);
	}	
	
	if (this.settings.layout.showOptionPanel) {
		this.mc.optionPanel.btnSkinProperties.setEnabled(inEnabled);
		this.mc.optionPanel.btnClear.setEnabled(inEnabled);
		
		this.mc.optionPanel.colorChooser.setEnabled(inEnabled);
		this.mc.optionPanel.btn_smileDropDown.setEnabled(inEnabled);
		this.mc.optionPanel.btnSave.setEnabled(inEnabled);
		this.mc.optionPanel.btnHelp.setEnabled(inEnabled);
		this.mc.optionPanel.btnBell.enabled = inEnabled;
		this.mc.optionPanel.bold_ib.setEnabled(inEnabled);
		this.mc.optionPanel.italic_ib.setEnabled(inEnabled);
		
		this.mc.optionPanel.smileDropDown.setEnabled(inEnabled);
		this.mc.optionPanel.userState.setEnabled(inEnabled);
		this.mc.optionPanelBG.enabled = (inEnabled);
	}
	
	if(this.settings.layout.showOptionPanel == false && this.settings.layout.showInputBox == false)
		this.mc.optionPanelBG._visible = false;
	
	this.mc.chatLog.setEnabled(inEnabled);
	this.mc.privateLog.setEnabled(inEnabled);

	this.mc.userMenuContainer.userMenu.removeMovieClip();
	this.userListPane.setEnabled(inEnabled);
	this.inputTextAreaPane.setEnabled(inEnabled);
	
	//module
	for(var i = 0; i < this.settings.module.length; i++)
	{
		var holder = this.getModuleHolder(i);
		holder['module_'+i].enabled = inEnabled;
		
		var m = this['modulePane_'+i];
		if(m != null) 
			m.setEnabled(inEnabled);
			
	}	
	
	this.privateBoxManager.setEnabled(inEnabled);
	//workaround problem of stupid MM comboboxes.
	//this.mc.privateBoxHolder.swapDepths(inEnabled ? 40000 : 10000);

	if (inEnabled) {
		this.inputTextMask(null);
		Key.addListener(this);
		this.setInputFocus();
	} else {
		Key.removeListener(this);
	}
};

ChatUI.prototype.setControlsVisible = function(inVisible) {
	this.mc.txtSelfUserName._visible = inVisible;
	this.mc.titleBG._visible = inVisible;
	this.mc.roomLabel._visible = inVisible && !this.settings.layout.isSingleRoomMode;
	this.mc.roomChooser._visible = inVisible && !this.settings.layout.isSingleRoomMode;
	this.mc.addRoomBtn._visible = inVisible && this.settings.layout.allowCreateRoom && !this.settings.layout.isSingleRoomMode;
	this.mc.logOffBtn._visible = inVisible && this.settings.layout.showLogout;
	this.mc.chatLog._visible = inVisible && this.settings.layout.showPublicLog;
	this.mc.privateLog._visible = inVisible && this.settings.layout.showPrivateLog;
	this.mc.optionPanel._visible = inVisible && this.settings.layout.showOptionPanel;
	this.mc.sendBtn._visible = inVisible && this.settings.layout.showInputBox;
	this.mc.msgTxt._visible = inVisible && this.settings.layout.showInputBox;
	this.mc.msgTxtBackground._visible = inVisible && this.settings.layout.showInputBox;
	this.mc.userList._visible = inVisible && this.settings.layout.showUserList;

	//module
	for(var i = 0; i < this.settings.module.length; i++)
	{
		var holder = this.getModuleHolder(i);
		holder['module_'+i]._visible = inVisible;
	}
	
	this.mc.userMenuContainer.userMenu.removeMovieClip();

	this.setInputFocus();
};

ChatUI.prototype.processSend = function() {
	clearInterval(this.inactivityIntervalId);
	this.inactivityIntervalId = setInterval(this.logout, this.settings.inactivityInterval * 1000, this);
	
	var presentTime = this.getTimeMilis();
	var interval = (this.gagIntervalTime == 0) ? (this.settings.floodInterval * 1000) : (this.gagIntervalTime * 60000);
	
	if((presentTime - this.floodIntervalTime) <= interval) 
	{ 
		this.mc.msgTxt.multiline = false;
		this.setInputFocus();
		return;
	}
	
	this.mc.msgTxt.multiline = true;
	this.floodIntervalTime = presentTime;
	this.gagIntervalTime = 0;
	
	var msg = this.mc.msgTxt.text;
	var htmlmsg = this.mc.msgTxt.htmlText;
	this.mc.msgTxt.text = '';
	
	var toUserName = null;
	if (!this.ircProcessCommand(msg)) 
	{
		if (this.settings.layout.showInputBox && this.settings.layout.allowPrivateMessage) {
			toUserName = this.parseUserName(msg);
		}
		var toUser = null;
		if (toUserName != null) {
			toUser = this.findUserByName(toUserName);
			
			if (toUser == null) {
				var labelText = this.selectedLanguage.dialog.misc.usernotfound;
				labelText = this.replace(labelText, 'USER_LABEL', toUserName);
				this.showMessageBox(labelText);
				return;
			}
			msg = msg.substring(2 + toUserName.length);
		}
		this.waitingForResponse = true;
		
		var msgtxt = this.removeTags(htmlmsg);
		var user = this.getUser(this.selfUserId);
		if(this.selfUserRole != user.ROLE_ADMIN)
		{ 
			msgtxt = this.replace(msgtxt, ':admin:', '');
			msgtxt = this.replace(msgtxt, ':mod:', '');
		}	
		if(toUser == null)
		{ 
			
			var room = this.rooms[this.selfRoomId];
			var msgtxt2 = this.callModuleFunc('mOnSendMsg', {username : user.label, room : room.label, msg : msgtxt}, -1);
			if(msgtxt2 != undefined) msgtxt = msgtxt2; 
		}	
		
		
		this.listener.sendMessageTo(toUser == null ? 0 : toUser.id, toUser == null ? this.selfRoomId : 0, msgtxt);
		
		this.soundObj.attachSound('SubmitMessage');
		this.soundObj.start();
	}
		
	this.sendButtonEnabled = false;
	this.enableSendButton();
	
	this.inputTextMask(null);
	this.setInputFocus();
	return;
};

ChatUI.prototype.removeTags = function(txt)
{ 
	if(txt.toUpperCase().indexOf("<P ALIGN=")>-1 && txt.toUpperCase().indexOf("<FONT FACE=")>-1)
	{
		var end_str = "</FONT></P>";
		var arr = txt.split(end_str);
		var ret_val = "";
		for(var itm = 0; itm < arr.length; itm++)
		{ 
			k = 2;
			for(var i=0; i < arr[itm].length; i++)
			{
				if(arr[itm].charAt(i) == ">")
				{ 
					k--;
					if(k <= 0) break;
				}			
			}
			
			ret_val += arr[itm].substring(i+1, txt.length - end_str.length)
			if(i > 0 &&  arr.length > 2 && itm < (arr.length - 2)) ret_val += "<br>";
		}
		
		return ret_val;
	}
	
	return txt;
}

ChatUI.prototype.getItemIdx = function(inItem) {
	for (var i = 0; i < this.mc.userList.getLength(); i ++) {
		if (this.mc.userList.getItemAt(i) == inItem) {
			return i;
		}
	}
	return -1;
};

ChatUI.prototype.error = function(s) {
	trace('ChatUI: ERROR: ' + s);
};

ChatUI.prototype.onUserStateChanged = function() {
	this.listener.setState(this.mc.optionPanel.userState.getSelectedItem().data[0]);
	this.setInputFocus();
};

ChatUI.prototype.onUserColorChanged = function() {
	this.listener.setColor(this.mc.optionPanel.colorChooser.getValue());
	//this.applyUserColor4Msg(this.mc.optionPanel.colorChooser.getValue());
	this.setInputFocus();
};

ChatUI.prototype.onSmileDropDownCliked = function(){ 
	this.soundObj.attachSound('ComboListOpenClose');
};

ChatUI.prototype.onSmileDropDownClikedArea = function(){ 
	var xy = new Object({x : this.mc.optionPanel.btn_smileDropDown._x, y : this.mc.optionPanel.btn_smileDropDown._y});
	this.mc.optionPanel.localToGlobal(xy);
	this.inputTextAreaPane.globalToLocal(xy);
	
	this.processSmiliesArea(this.inputTextAreaPane, 
							this.inputTextAreaPane.getNextHighestDepth(), 
							xy.x, 
							xy.y, 
							this.mc.optionPanel.btn_smileDropDown._height, 
							this.inputTextAreaPane._x, 
							this.inputTextAreaPane._y);
						
	this.mc.optionPanel.btn_smileDropDown.setEnabled(false);	
	this.soundObj.attachSound('ComboListOpenClose');
};

ChatUI.prototype.processSmiliesArea = function(inHolder, inDepth, inX, inY, inH, inRX, inRY)
{
	/*
	var SmiliesArea = this.dialogManager.createPane('SmiliesArea');
	SmiliesArea.setDockState(true);
	SmiliesArea.setContent('SmiliesArea');
	this.dialogManager.showPane('SmiliesArea');
	*/
	
	var smi_area = inHolder.attachMovie('SmiliesArea', 'SmiliesArea', inDepth);
	smi_area.setPosition(inX, inY, inH, inRX, inRY);
	smi_area.setHandler('processSmile', inHolder);
	smi_area.setCloseHandler('processCloseSmile', inHolder);
};

ChatUI.prototype.onSmileDropDownChanged = function() {
	if (this.mc.optionPanel.smileDropDown.getSelectedIndex() != 0) {
		this.mc.msgTxt.text += this.mc.optionPanel.smileDropDown.getSelectedItem().data.patternStr;
		this.inputTextMask(null);
		this.smileDropDownCloserIntervalId = setInterval(this.smileDropDownCloserTick, 10, this);
		this.setInputFocus();
	}
};

ChatUI.prototype.smileDropDownCloserTick = function(inChatUI) {
	inChatUI.mc.optionPanel.smileDropDown.setSelectedIndex(0);
	clearInterval(inChatUI.smileDropDownCloserIntervalId);
}

ChatUI.prototype.processTabbedProperties = function() {
	var tabbedPropertiesBox = this.dialogManager.createDialog('TabbedPropertiesBox');
	tabbedPropertiesBox.setHandler('onTabbedPropertiesCompleted', this);
	tabbedPropertiesBox.setCloseButtonEnabled(true);
	tabbedPropertiesBox.setSettings(this.settings);
	tabbedPropertiesBox.setParent(this);
	this.dialogManager.showDialog(tabbedPropertiesBox);
	
	this.tabbedPropertiesBox = tabbedPropertiesBox;
};

ChatUI.prototype.processClear = function() {
	this.ircProcessCommand('/clear');
};

ChatUI.prototype.processSave = function() {
	this.listener.saveChat();
	this.setInputFocus();
};

ChatUI.prototype.processHelp = function() {
	if ((this.settings.helpUrl == null) || (this.settings.helpUrl == '')) {
		this.listener.requestHelpText();
	} else {
		this.mc.getURL(this.settings.helpUrl, '_blank');
	}
};

ChatUI.prototype.setHelpText = function(inHelpText) {
	var helpBox = this.dialogManager.createDialog('HTMLBox');
	helpBox.setHandler('onHelpCompleted', this);
	helpBox.setCloseButtonEnabled(true);
	this.dialogManager.showDialog(helpBox);
	helpBox.setHTMLText( _global.replaceHTMLSpecChars(inHelpText));
};

ChatUI.prototype.processBell = function() {
	this.listener.ringBell();
};

ChatUI.prototype.onProfileCompleted = function(control) {
	this.setControlsEnabled(true);
	this.dialogManager.releaseDialog(control);
	this.setInputFocus();
};

ChatUI.prototype.setUserProfileText = function(inUserId, inProfileText) {
	this.mc.getURL(inProfileText, '_blank');
	/*
	var profileBox = this.dialogManager.createDialog('HTMLBox');
	//store user id inside profile dialog.
	profileBox.setHandler('onProfileCompleted', this);
	profileBox.setCloseButtonEnabled(true);
	this.dialogManager.showDialog(profileBox);
	profileBox.setHTMLText(inProfileText);
	*/
};

ChatUI.prototype.onTabbedPropertiesCompleted = function(control) {
	this.setControlsEnabled(true);
	
	if(!control.canceled())
	{ 
		if(control.themesTab != undefined)
		{
			this.settings.user.skin = control.themesTab.getSelectedSkin();
			this.settings.user.bigSkin = control.themesTab.getSelectedBigSkin();
		}		
		if(control.soundsTab != undefined)
		{ 
			this.settings.user.sound = control.soundsTab.getSelectedSoundProperties();
			this.applySoundProperties(this.settings.user.sound);
		}
		if(control.textTab != undefined)
		{
			this.settings.user.text.itemToChange = control.textTab.getSelectedTextProperties();
			this.setSelectedLanguage(control.textTab.getSelectedLanguage());
		}
		if(control.effectsTab != undefined)
		{ 
			var skin = control.effectsTab.getSelectedSkin();
			this.settings.user.skin.showBackgroundImages = skin.showBackgroundImages;
			this.settings.user.skin.uiAlpha = skin.uiAlpha;
			var avatars = control.effectsTab.getSelectedEffectsProperties();
			this.settings.splashWindow = avatars.splashWindow;
			this.sendAvatar('mainchat', avatars);
			this.sendAvatar('room', avatars);
			this.settings.user.avatars = avatars;
			
			if(this.settings.allowPhoto)
			{
				this.settings.user.profile.nick_image = control.effectsTab.nick_image;
				this.listener.sendPhoto(control.effectsTab.nick_image);
			}	
		}
		
		//save_user_settings
		this.saveUserSettings();
	}	
		
	this.dialogManager.releaseDialog(control);
	this.tabbedPropertiesBox = null;
};

ChatUI.prototype.getAvatar = function() {
	var user = new User();	
	
	var ret_val = new Object();
	var templ   = new CAvatars();
	
	trace('this.selfUserGender: ' + this.selfUserGender)
	for(var i in this.settings.avatars.user.male.room)
		trace('key: ' + i + ', value: ' + this.settings.avatars.user.male.room[i]);
			
	
	switch(Number(this.selfUserRole))
	{
		case user.ROLE_USER : 
		case user.ROLE_CUSTOMER : 
			if(this.selfUserGender == user.GENDER_MALE)//			
				ret_val = this.settings.avatars.user.male;
				
				else 	if(this.selfUserGender == user.GENDER_FEMALE)
				ret_val = this.settings.avatars.user.female;
			else 
			{ 
				ret_val = templ.user.male;
				ret_val.mainchat.default_value = SmileTextConst.patternList[0][1];
				ret_val.mainchat.default_state = false; 
				ret_val.room.default_value = SmileTextConst.patternList[0][1];
				ret_val.room.default_state = false;
			}	
			break;
		case user.ROLE_ADMIN :
			if(this.selfUserGender == user.GENDER_MALE)
				ret_val = this.settings.avatars.admin.male;
			else 	if(this.selfUserGender == user.GENDER_FEMALE)
				ret_val = this.settings.avatars.admin.female;
			else 
			{ 
				ret_val = this.settings.avatars.admin.male;
				/*
				ret_val = templ.user.male;
				ret_val.mainchat.default_value = SmileTextConst.patternList[0][1];
				ret_val.mainchat.default_state = false; 
				ret_val.room.default_value = SmileTextConst.patternList[0][1];
				ret_val.room.default_state = false;
				*/
			}
			break;
		case user.ROLE_MODERATOR :
			if(this.selfUserGender == user.GENDER_MALE)
				ret_val = this.settings.avatars.moderator.male;
			else if(this.selfUserGender == user.GENDER_FEMALE)
				ret_val = this.settings.avatars.moderator.female;
			else 
				ret_val = this.settings.avatars.moderator.male;
			break;	
		default:
			ret_val = templ.user.male;
			ret_val.mainchat.default_value = SmileTextConst.patternList[0][1];
			ret_val.mainchat.default_state = false; 
			ret_val.room.default_value = SmileTextConst.patternList[0][1];
			ret_val.room.default_state = false;
			break;
	}
	
	ret_val.gender = this.selfUserGender;
	ret_val.role = this.selfUserRole;
	
	
	if(
		this.settings.user.avatars == undefined || 	
		this.settings.user.avatars.gender != ret_val.gender ||
		this.settings.user.avatars.role != ret_val.role ||
		this.settings.user.avatars.mainchat.allow_override != ret_val.mainchat.allow_override ||
		this.settings.user.avatars.room.allow_override != ret_val.room.allow_override
	  ) 
		return(ret_val);
	else  
		return(this.settings.user.avatars);
};

ChatUI.prototype.sendAvatar = function(inType, inAvatars, inFlag, toUserId) {
	
	if(this.settings.layout.toolbar.smilies == 0) return;
	
	if(this.settings.user.avatars[inType].default_state != inAvatars[inType].default_state ||  
		this.settings.user.avatars[inType].default_value != inAvatars[inType].default_value ||
		inFlag
	)
	{ 
		if(inAvatars[inType].default_state == true)
		{ 
			var obj = this.findSmile('patternIcon', inAvatars[inType].default_value);
			this.listener.sendAvatar(inType, obj.patternStr, toUserId);
		}
		else if(!inFlag)
		{
			this.listener.sendAvatar(inType, '', toUserId);
		}
	}
};

ChatUI.prototype.setGender = function(fromUserId, text)
{ 
	if (fromUserId == null) {
		this.error('ChatUI: setGender: invalid fromUserId [' + fromUserId + '].');
		return;
	}
	
	if (this.settings == null) {
		return;
	}
	
	if(fromUserId == this.selfUserId)
	{ 
		this.selfUserGender = text;
		
		this.settings.user.avatars = this.getAvatar();
			
		if( text != '')
		{ 
			var obj = this.findSmile('patternIcon', this.settings.user.avatars['mainchat'].default_value);
			this.listener.sendAvatar('mainchat', obj.patternStr, null);
		
			obj = this.findSmile('patternIcon', this.settings.user.avatars['room'].default_value);
			this.listener.sendAvatar('room', obj.patternStr, null);
		}
		else
		{
			this.listener.sendAvatar('mainchat', '', null);
			this.listener.sendAvatar('room', '', null);
		}	
	}	
};

ChatUI.prototype.setAvatar = function(inType, fromUserId, toUserId, text)
{ 
	if (fromUserId == null) {
		this.error('ChatUI: setAvatar: invalid fromUserId [' + fromUserId + '].');
		return;
	}
	
	if (text == null) {
		this.error('ChatUI: setAvatar: text is empty.');
		return;
	}
	if (this.settings == null) {
		return;
	}
	
	var user = this.getUser(fromUserId);
	if (user == null) {
		return;
	}
	
	var t = ''; 
	if(inType == 'mavt') t = 'mainchat';
	else t = 'room';
	var old_avatar = user.getAvatar(); 
	user.setAvatar(t, text);
	
	if(t == 'room') this.mc.userList.refreshItems();
	else if(t == 'mainchat')
	{ 
		if(this.settings.layout.showPrivateLog) this.mc.privateLog.changeAvatar(fromUserId);
		this.mc.chatLog.changeAvatar(fromUserId);
		this.privateBoxManager.setAvatar(fromUserId);
	}
};

ChatUI.prototype.setPhoto = function(fromUserId, toUserId, text)
{ 
	if (fromUserId == null) {
		this.error('ChatUI: setAvatar: invalid fromUserId [' + fromUserId + '].');
		return;
	}
	
	if (this.settings == null) {
		return;
	}
	
	var user = this.getUser(fromUserId);
	
	if (user == null) {
		return;
	}
	
	if (text == null) text = '';
		
	if(this.settings.allowPhoto)
		user.setFCPortrait(text);
	else
		user.setPortrait(text);
	
	//_global.FlashChatNS.chatUI.mc.msgTxt.htmlText += 'Set photo ' + user + '<br>';
	//!!! add for private msg box
	var pb = this.privateBoxManager.getUserPrivateBox(user);
	pb.setUser(user);
};

ChatUI.prototype.onHelpCompleted = function(control) {
	this.setControlsEnabled(true);
	this.dialogManager.releaseDialog(control);
	this.setInputFocus();
};

//room listener implementation.
ChatUI.prototype.onRoomStateChange = function(inRoom) {
	this.soundObj.attachSound('RoomOpenClose');
	
	if (this.settings.layout.showUserList) {
		this.userListClearRoom(inRoom);
	}
	inRoom.setOpened(!inRoom.getOpened());
	if (this.settings.layout.showUserList) {
		this.userListUpdateRoom(inRoom);
		if(inRoom.blink_type == 1)
		{
			
		}
	}
	this.setInputFocus();
};
//END room listener implementation.

ChatUI.prototype.onUserMinIconClick = function(inItem){ 
	this.privateBoxManager.maximizeForUser(inItem);
}

//user listener implementation.
ChatUI.prototype.onUserClick = function(inUser, inMouseX, inMouseY, inButtonX, inButtonY, inButtonWidth, inButtonHeight) {
	//self clicking
	if(inUser.id == this.selfUserId && this.settings.hideSelfPopup) return;
	
	var labelList = new Array();
	var activeList = new Array();
	
	if (this.settings.layout.showInputBox && this.settings.layout.allowPrivateMessage) {
		labelList.push(this.USER_MENU_PRIVATE_MESSAGE);
	}
	if (this.settings.layout.allowInvite) {
		if (!this.settings.layout.isSingleRoomMode) {
			labelList.push(this.USER_MENU_INVITE);
		}
	}
	
	//---share add to user menu
	if (this.settings.layout.allowFileShare)
	{
		labelList.push(this.USER_MENU_FILE_SHARE);
	}	
	//---
	
	if (this.settings.layout.allowIgnore && inUser.roles != inUser.ROLE_ADMIN) {
		if (inUser.getIgnored()) {
			labelList.push(this.USER_MENU_UNIGNORE);
		} else {
			labelList.push(this.USER_MENU_IGNORE);
		}
	}
	if (this.settings.layout.allowBan) {
		labelList.push(this.USER_MENU_BAN);
		if (inUser.getBanned()) {
			labelList.push(this.USER_MENU_UNBAN);
		}
	}
	if (this.settings.layout.allowProfile) {
		labelList.push(this.USER_MENU_PROFILE);
	}

	for (var i = 0; i < labelList.length; i ++) {
		activeList.push(true);
	}
	
	this.mc.userMenuContainer.attachMovie('UserMenu', 'userMenu', 0);
	var userMenu = this.mc.userMenuContainer.userMenu;
	userMenu.setup(labelList, activeList, this, inUser);
	userMenu._x = inMouseX;
	userMenu._y = inMouseY;
	if (userMenu._x + userMenu._width > Stage.width) {
		userMenu._x -= userMenu._width;
	}
	if (userMenu._y + userMenu._height > Stage.height) {
		userMenu._y -= userMenu._height;
	}
};
//END user listener implementation.

ChatUI.prototype.onUserMenuMouseOver = function() {
	this.soundObj.attachSound('UserMenuMouseOver');
}

//user menu listener implementation.
ChatUI.prototype.onUserMenuClick = function(inUser, inMenuItem) {
	switch(inMenuItem) {
		case this.USER_MENU_PRIVATE_MESSAGE :
			/*
			var currentUserName = this.parseUserName(this.mc.msgTxt.text);
			if (currentUserName == null) {
				this.mc.msgTxt.text = '/' + inUser.label + ':' + this.mc.msgTxt.text;
			} else {
				this.mc.msgTxt.text = '/' + inUser.label + ':' + this.mc.msgTxt.text.substring(2 + currentUserName.length);
			}
			this.setInputFocus();
			*/
			this.privateBoxManager.createPrivateBox(inUser);
			break;
		case this.USER_MENU_INVITE :
			//this.setControlsEnabled(false);

			var inviteBox = this.dialogManager.createDialog('InviteBox');
			inviteBox.setHandler('onInviteBoxCompleted', this);
			inviteBox.setUserData(inUser);
			var roomList = new Array();
			for (var i = 0; i < this.mc.roomChooser.getLength(); i ++) {
				roomList.push(this.mc.roomChooser.getItemAt(i).data);
			}
			inviteBox.setRoomList(roomList);
			inviteBox.setSelectedRoom(this.rooms[this.selfRoomId]);
			this.dialogManager.showDialog(inviteBox);
			break;
		case this.USER_MENU_IGNORE :
			//this.setControlsEnabled(false);

			var promptBox = this.dialogManager.createDialog('PromptBox');
			promptBox.dialog_name = 'ignorebox';
			promptBox.setResizable(true);
			promptBox.setLabelTextVisible(true);
			promptBox.setInputTextVisible(true);
			promptBox.setRightButtonVisible(false);
			promptBox.setValidateRightButton(false);
			promptBox.setCloseButtonEnabled(true);
			promptBox.setLeftButtonLabel(this.selectedLanguage.dialog.ignore.ignoreBtn);
			promptBox.setHandler('onIgnoreCompleted', this);
			promptBox.setLabelText(this.selectedLanguage.dialog.ignore.ignoretext);
			promptBox.setUserData(inUser);
			this.dialogManager.showDialog(promptBox);
			break;
		case this.USER_MENU_UNIGNORE :
			//this.setControlsEnabled(false);

			var promptBox = this.dialogManager.createDialog('PromptBox');
			promptBox.setResizable(true);
			promptBox.setLabelTextVisible(true);
			promptBox.setInputTextVisible(true);
			promptBox.setRightButtonVisible(false);
			promptBox.setValidateRightButton(false);
			promptBox.setCloseButtonEnabled(true);
			promptBox.setLeftButtonLabel(this.selectedLanguage.dialog.unignore.unignoreBtn);
			promptBox.setHandler('onUnignoreCompleted', this);
			promptBox.setLabelText(this.selectedLanguage.dialog.unignore.unignoretext);
			promptBox.setUserData(inUser);
			this.dialogManager.showDialog(promptBox);
			break;
		case this.USER_MENU_BAN :
			//this.setControlsEnabled(false);

			var banBox = this.dialogManager.createDialog('BanBox');
			banBox.setCloseButtonEnabled(true);
			banBox.setHandler('onBanCompleted', this);
			banBox.setUserData(inUser);
			var roomList = new Array();
			for (var i = 0; i < this.mc.roomChooser.getLength(); i ++) {
				roomList.push(this.mc.roomChooser.getItemAt(i).data);
			}
			
			banBox.setRoomList(roomList);
			banBox.setSelectedRoom(this.getRoomForUser(inUser.id));
			this.dialogManager.showDialog(banBox);
			break;
		case this.USER_MENU_UNBAN :
			//this.setControlsEnabled(false);

			var promptBox = this.dialogManager.createDialog('PromptBox');
			promptBox.setResizable(true);
			promptBox.setLabelTextVisible(true);
			promptBox.setInputTextVisible(true);
			promptBox.setRightButtonVisible(false);
			promptBox.setValidateRightButton(false);
			promptBox.setCloseButtonEnabled(true);
			promptBox.setLeftButtonLabel(this.selectedLanguage.dialog.unban.unbanBtn);
			promptBox.setHandler('onUnbanCompleted', this);
			promptBox.setLabelText(this.selectedLanguage.dialog.unban.unbantext);
			promptBox.setUserData(inUser);
			this.dialogManager.showDialog(promptBox);
			break;
		case this.USER_MENU_PROFILE :
			this.listener.requestUserProfileText(inUser.id);
			break;
		
		case this.USER_MENU_FILE_SHARE ://---share handle click
			var the_url = _root._url.substr(0, _root._url.lastIndexOf('/')) + '/';
			var room = this.getRoomForUser(this.selfUserId);			
			var arg = 'userid=' + this.selfUserId + 
					'&toid='   + inUser.id +
					'&roomid=' + room['id'] + 
					'&lang=' +  this.selectedLanguage['id']+
					'&connid=' + this.listener.connid;					
						
			getURL("javascript:openWindow('"+the_url+"sharefile.php?"+arg+"', 'shareFileWindow', '',480,220 )");
			break;
	}
};
//END user menu listener implementation.

ChatUI.prototype.getRoomForUser = function(userid) {
	for (var roomId in this.rooms) {
		if (this.rooms[roomId].containsUser(userid)) {
			return this.rooms[roomId];
		}
	}
	
	//this.error('ChatUI: getRoomForUser: room not found for user id [' + userid + '].');
	
	return null;
};

//returns room for given label. null, if room was not found.
ChatUI.prototype.findRoomByLabel = function(inLabel) {
	for (var roomId in this.rooms) {
		if (this.rooms[roomId].label.toLowerCase() == inLabel.toLowerCase()) {
			return this.rooms[roomId];
		}
	}
	return null;
};

ChatUI.prototype.getUser = function(userid) {
	if(this.users[userid] != null)
		return this.users[userid];	
	
	var room = this.getRoomForUser(userid);
	if (room == null) {
		return null;
	}
	return room.getUser(userid);
};

ChatUI.prototype.findUserByName = function(inUserName) {
	var user = null;
	for (var id in this.rooms) {
		user = this.rooms[id].getUserByName(inUserName);
		if (user != null) {
			break;
		}
	}
	return user;
};

//parses input string in attempt to find 'to username' template in the following format:
// /<to_username>:
//returns found user name or null.
ChatUI.prototype.parseUserName = function(txt) {
	if (txt.charAt(0) != '/') {
		return null;
	}
	var colonIdx = txt.indexOf(':');
	if (colonIdx == -1) {
		return null;
	}
	var userName = txt.substring(1, colonIdx);
	if (userName == '') {
		return null;
	} else {
		return userName;
	}
};


ChatUI.prototype.smileTextOnChanged = function()
{
	_global.FlashChatNS.chatUI.soundObj.attachSound('PressButton');
	_global.FlashChatNS.chatUI.inputTextMask(null);
}

//analyzes contents of input text field and enables/disables 'send' button.
ChatUI.prototype.inputTextMask = function(inChar) 
{
	this.mc.roomChooser.myOnKillFocus();
	
	if(this.isSpecialLanguage())
	{ 
		this.mc.msgTxt.multiline = false;
	}
	
	var userName = null;
	if (this.settings.layout.showInputBox && this.settings.layout.allowPrivateMessage) {
		userName = this.parseUserName(this.mc.msgTxt.text);
	}
	var userNameLength = userName == null ? 0 : userName.length + 2;
	this.sendButtonEnabled = this.isSpecialLanguage();

	var isEmpty = true;
	for (var i = 0; i < this.mc.msgTxt.text.length; i ++) {
		if (this.mc.msgTxt.text.charAt(i) != '\r')  {
			isEmpty = false;
			break;
		}
	}

	if (!isEmpty) //&& (!Key.isDown(Key.ENTER) || Key.isDown(Key.SHIFT))) 
	{
		this.sendButtonEnabled = this.mc.msgTxt.text.length > userNameLength;
	}
	
	this.enableSendButton();
	if (Key.isDown(Key.SHIFT) && Key.isDown(Key.ENTER)) {
		this.mc.msgTxt.multiline = true;
		return '\n';
	}
	
	if(this.mc.msgTxt.text.charAt(0) == '\r')
	{
		this.mc.msgTxt.text = "";
	}
	
	return (!Key.isDown(Key.SHIFT) && Key.isDown(Key.ENTER) ? '' : inChar);
};

//tracks ctrl-enter key sequences to submit message. check if focus was in main input box.
ChatUI.prototype.onKeyDown = function() 
{	
	if(Selection.getFocus() == ('' + this.mc.msgTxt.textfield_txt))
	{ 
		if(this.isSpecialLanguage())
		{
			if(Key.isDown(Key.CONTROL) && Key.isDown(Key.ENTER))
			{ 
				this.processSend();
			}
		}
		else	if (!Key.isDown(Key.SHIFT) && Key.isDown(Key.ENTER) && this.mc.sendBtn.getEnabled() && this.settings.layout.showInputBox) 
		{
			
			
			this.processSend();
		}
		
		if(Key.isDown(Key.SHIFT) && Key.isDown(Key.ENTER)) this.mc.msgTxt.multiline = true;
	}
};

ChatUI.prototype.userListClearRoom = function(inRoom) {
	if (!this.settings.layout.showUserList) {
		return;
	}
	//XXX01 avu: check if specified room is not 'dummy'. If true, return.
	if (inRoom.label == null) {
		this.error('ChatUI: userListClearRoom: called for dummy room [' + inRoom.id + '].');
		return;
	}

	this.mc.userList.allow_paint = false;
	if (this.settings.layout.isSingleRoomMode) 
	{
		this.mc.userList.removeAll();
	} 
	else 
	{
		if (inRoom.getOpened()) 
		{
			var roomIdx = this.getItemIdx(inRoom);
			this.mc.userList.removeItemsAt(roomIdx + 1, roomIdx + inRoom.getUserCount());
		}
	}
	
	this.mc.userList.allow_paint = true;
};

ChatUI.prototype.userListUpdateRoom = function(inRoom, isRemove) {	
	if (!this.settings.layout.showUserList) return;	
	
	//XXX01 avu: check if specified room is not 'dummy'. If true, return.
	if (inRoom.label == null)
	{
		this.error('ChatUI: userListUpdateRoom: called for dummy room [' + inRoom.id + '].');
		return;
	}
	
	
	if (this.settings.layout.isSingleRoomMode)
	{
		this.mc.userList.addItemsAt(0, inRoom.users);
		this.mc.userList.paint();
	}
	else
	{
		var roomIdx = this.getItemIdx(inRoom);
		this.mc.userList.allow_paint = !inRoom.getOpened();
		this.mc.userList.replaceItemAt(roomIdx, inRoom);
		if (inRoom.getOpened())
		{
			if(isRemove == true) this.userListClearRoom(inRoom);
			this.mc.userList.allow_paint = true;
			this.mc.userList.addItemsAt(roomIdx + 1, inRoom.users);
			this.mc.userList.paint();
		}
	}
};

ChatUI.prototype.userListUpdateUser = function(inUser) {
	if (!this.settings.layout.showUserList) {
		return;
	}
	var userIdx = this.getItemIdx(inUser);
	this.mc.userList.allow_paint = false;
	this.mc.userList.replaceItemAt(userIdx, inUser);
	this.mc.userList.allow_paint = true;
};

ChatUI.prototype.getUserStateLabel = function(inState) {
	for (var i = 0; i < this.USER_STATE_LIST.length; i ++) {
		if (this.USER_STATE_LIST[i][0] == inState) {
			return this.USER_STATE_LIST[i][1];
		}
	}
};

//this function takes an array of length constraint definitions, total available length and returns
//and array of calculated lenghts that satisfies specified constraint.
//length constraint is a 3-dimensional array: [relLength, length, minLength].
//minLength is required.
ChatUI.prototype.distributeLengths = function(inLengthDefList, inTotalLength) {
	//trace('ChatUI: distributeLengths: inLengthDefList: ' + inLengthDefList);
	//trace('ChatUI: distributeLengths: inTotalLength: ' + inTotalLength);
	var finalLengthList = new Array(inLengthDefList.length);
	var unresolvedLengthDefList = new Array();
	var unresolvedTotalLength = inTotalLength;
	//resolve elements with specified absolute lengths.
	for (var i = 0; i < inLengthDefList.length; i ++) {
		if (inLengthDefList[i][1] != -1) {
			finalLengthList[i] = Math.max(inLengthDefList[i][1], inLengthDefList[i][2]);
			unresolvedTotalLength -= finalLengthList[i];
		} else {
			unresolvedLengthDefList.push(inLengthDefList[i]);
		}
	}
	var unresolvedLengthList = new Array(unresolvedLengthDefList.length);

	while (true) 
	{
		var unresolvedRelTotalLength = 0;
		var recalc = false;
		var tempUnresolvedLengthList = new Array(unresolvedLengthDefList.length);
		for (var i = 0; i < unresolvedLengthDefList.length; i ++) {
			if (unresolvedLengthList[i] == null) {
				unresolvedRelTotalLength += unresolvedLengthDefList[i][0];
			}
		}
		for (var i = 0; i < unresolvedLengthDefList.length; i ++) {
			if (unresolvedLengthList[i] == null) {
				tempUnresolvedLengthList[i] = unresolvedTotalLength * unresolvedLengthDefList[i][0] / unresolvedRelTotalLength;
				if (tempUnresolvedLengthList[i] < unresolvedLengthDefList[i][2]) {
					unresolvedLengthList[i] = unresolvedLengthDefList[i][2];
					unresolvedTotalLength -= unresolvedLengthList[i];
					recalc = true;
					break;
				}
			}
		}
		if (!recalc) {
			for (var i = 0; i < unresolvedLengthDefList.length; i ++) {
				if (unresolvedLengthList[i] == null) {
					unresolvedLengthList[i] = tempUnresolvedLengthList[i];
				}
			}
			delete tempUnresolvedLengthList;
			break;
		}
		delete tempUnresolvedLengthList;
	};

	var unresolvedIdx = 0;
	for (var i = 0; i < inLengthDefList.length; i ++) {
		if (finalLengthList[i] == null) {
			finalLengthList[i] = unresolvedLengthList[unresolvedIdx];
			unresolvedIdx ++;
		}
	}

	return finalLengthList;
};

ChatUI.prototype.setObjectTextProperty = function(propName, val, targetObj, nForce){ 
	
	switch(targetObj)
	{
		case "mainChat" :
			setTextProperty(propName, val, this.mc.msgTxt.textfield_txt, true);
			setTextProperty(propName, val, this.mc.chatLog.smile_txt, true);
			setTextProperty(propName, val, this.mc.privateLog.smile_txt, true);
			
			this.privateBoxManager.applyTextProperty(propName, val, targetObj);
			
			this.mc.chatLog.setFont(val, propName);
			this.mc.privateLog.setFont(val, propName);
			break;
		case "interfaceElements" : 
			var firstChar = propName.substring(0,1);
			firstChar = firstChar.toUpperCase();
			var propName2 = 'text' + firstChar + (propName.substring(1,propName.length));
			
			if(globalStyleFormat[propName2] != val)
			{ 
				setTextProperty(propName, val, this.mc.roomLabel, true);
				this.mc.userList.applyTextProperty(propName, val);
				
				this.dialogManager.applyTextProperty(propName, val);
				this.privateBoxManager.applyTextProperty(propName, val, targetObj);
				
				globalStyleFormat[propName2] = val;
				globalStyleFormat.setApplyChangesHandler(this, 'onResize');
				globalStyleFormat.applyChanges();
			}
			break;
		case "title" :  
			if( setTextProperty(propName, val, this.mc.txtSelfUserName.txt, true) && nForce)
			{ 
				this.onResize();
			}
			break;
		case "myTextColor" :
			this.setColored(this.settings.user.userColor, !val);	
			break;
	}
}

ChatUI.prototype.applyTextProperties = function(inTextProp, nForce){ 
	for(var itm in inTextProp)
	{
		if(itm == 'myTextColor')
		{
			this.setObjectTextProperty('', inTextProp[itm], itm, nForce);
		}
		else
		{ 
			this.setObjectTextProperty('font', inTextProp[itm].fontFamily, itm, nForce);
			this.setObjectTextProperty('size', inTextProp[itm].fontSize, itm, nForce);
		}
	}
}

ChatUI.prototype.setColored = function(inColor, inVal){ 
	this.mc.chatLog.setColored(inColor, inVal);
	this.mc.privateLog.setColored(inColor, inVal);
	
	for(var i = 0; i < this.privateBoxManager.privateBoxList.length; i++)
		this.privateBoxManager.privateBoxList[i].log.setColored(inColor, inVal, true);
		
	this.mc.userList.setColored(inColor, inVal);
}

ChatUI.prototype.applyBigSkin = function(inBigSkin){ 
	_global.FlashChatNS.BIG_SKIN_NAME = inBigSkin.swf_name;
	this.mc.logOffBtn.setSkinId(inBigSkin.swf_name);
	
	var load_dir = 'looks/'; 
	
	switch(inBigSkin.swf_name)
	{
		case 'default_skin'  : 
			this.applyBigSkinCycle(inBigSkin);
		break;
		case 'xp_skin'       : 
			if(_global.xpLook == undefined)
			{ 
				this.mc.onLoadComplete = function(target_mc) 
				{ 
					if(_global.XPLook != undefined)
					{ 
						_global.xpLook = new XPLook();
						this.chatUI.bigSkinIntervalId = setInterval(this.chatUI.applyBigSkinTicker, 5, this, inBigSkin);
					}
					else this.loader.loadClip(load_dir + 'xpLook.swf', target_mc);
				}
				this.mc.createEmptyMovieClip('XPLook_mc', this.mc.getNextHighestDepth());
				this.mc.loader.loadClip(load_dir + 'xpLook.swf', this.mc.XPLook_mc);
				
				_global.FlashChatNS.BigSkin_Loaded = false;
			}
			else this.applyBigSkinCycle(inBigSkin);
			break;
		case 'gradient_skin' : 
			this.applyBigSkinCycle(inBigSkin);
		break;
		case 'aqua_skin'     : 
			if(_global.aquaLook == undefined)
			{ 
				this.mc.onLoadComplete = function(target_mc) 
				{ 
					if(_global.AquaLook != undefined)
					{ 
						_global.aquaLook = new AquaLook();
						this.chatUI.bigSkinIntervalId = setInterval(this.chatUI.applyBigSkinTicker, 5, this, inBigSkin);
					}
					else this.loader.loadClip(load_dir + 'aquaLook.swf', target_mc);
				}
				this.mc.createEmptyMovieClip('AquaLook_mc', this.mc.getNextHighestDepth());
				this.mc.loader.loadClip(load_dir + 'aquaLook.swf', this.mc.AquaLook_mc);
				
				_global.FlashChatNS.BigSkin_Loaded = false;
			}
			else this.applyBigSkinCycle(inBigSkin);
			break;
	}
}

ChatUI.prototype.applyBigSkinTicker = function(inTarget, inBigSkin)
{
	inTarget.chatUI.applyBigSkinCycle(inBigSkin);
	
	clearInterval(inTarget.chatUI.bigSkinIntervalId);
	inTarget.chatUI.bigSkinIntervalId = null;
}

ChatUI.prototype.applyBigSkinCycle = function(inBigSkin)
{ 
	_global.FlashChatNS.BigSkin_Loaded = true;
	
	for(var i = 0; i < _global.FlashChatNS.components_arr.length; i++)
	{
		_global.FlashChatNS.components_arr[i].setSkin(inBigSkin.swf_name);
	}
}

ChatUI.prototype.applySkin = function(inSkin, skinCh) {
	if (skinCh != undefined) this.mc.optionPanel.colorChooser.setValue(inSkin.recommendedUserColor);
		
	//------------------------------------------------------------------------------------------------------//
	var faceRGBEnabled = inSkin.button;
	var borderRGBEnabled = inSkin.buttonBorder;
	
	var primaryRGB = darker(borderRGBEnabled);
	
	var edgeRGBBrighter = borderRGBEnabled; 
	var edgeRGBBrightest = brighter(edgeRGBBrighter); 
	var edgeRGBDarker = darker(primaryRGB); 
	var edgeRGBDarkest = darker(primaryRGB); 		
	
	var buttonTextDarker = darker(inSkin.buttonText);
	var controlsBackground = brighter(inSkin.background);
	var controlsBackgroundBrighter = brighter(controlsBackground);
	var controlsBackgroundDarker   = ex_darker(controlsBackground, 0.6); 
	
	//buttons
	globalStyleFormat.highlight = edgeRGBBrightest;
	globalStyleFormat.highlight3D = edgeRGBBrighter;
	globalStyleFormat.shadow = edgeRGBDarker;
	globalStyleFormat.darkshadow = edgeRGBDarkest;
	globalStyleFormat.face = faceRGBEnabled;
	
	globalStyleFormat.face_press = (inSkin.buttonPress < 0)? faceRGBEnabled : inSkin.buttonPress;

	//close and min buttons
	globalStyleFormat.faceClose        = (inSkin.closeButton < 0)?		globalStyleFormat.face : inSkin.closeButton;
	globalStyleFormat.faceClose_press  = (inSkin.closeButtonPress < 0)?	globalStyleFormat.face : inSkin.closeButtonPress;
	globalStyleFormat.highlightClose   = (inSkin.closeButtonBorder < 0)?	globalStyleFormat.highlight : brighter(brighter(inSkin.closeButtonBorder));
	globalStyleFormat.highlight3DClose = (inSkin.closeButtonBorder < 0)?	globalStyleFormat.highlight3D : brighter(inSkin.closeButtonBorder);
	globalStyleFormat.shadowClose      = (inSkin.closeButtonBorder < 0)?	globalStyleFormat.shadow : darker(darker(inSkin.closeButtonBorder));
	globalStyleFormat.darkshadowClose  = (inSkin.closeButtonBorder < 0)?	globalStyleFormat.darkshadow : darker(darker(inSkin.closeButtonBorder));
	globalStyleFormat.arrowClose       = (inSkin.closeButtonArrow < 0)?	inSkin.buttonText : inSkin.closeButtonArrow;	
		
	globalStyleFormat.faceMin          = (inSkin.minimizeButton < 0)?		globalStyleFormat.face : inSkin.minimizeButton;
	globalStyleFormat.faceMin_press    = (inSkin.minimizeButtonPress < 0)?	globalStyleFormat.face : inSkin.minimizeButtonPress;
	globalStyleFormat.highlightMin     = (inSkin.minimizeButtonBorder < 0)?	globalStyleFormat.highlight : brighter(brighter(inSkin.minimizeButtonBorder));
	globalStyleFormat.highlight3DMin   = (inSkin.minimizeButtonBorder < 0)?	globalStyleFormat.highlight3D : brighter(inSkin.minimizeButtonBorder);
	globalStyleFormat.shadowMin        = (inSkin.minimizeButtonBorder < 0)?	globalStyleFormat.shadow : darker(darker(inSkin.minimizeButtonBorder));
	globalStyleFormat.darkshadowMin    = (inSkin.minimizeButtonBorder < 0)?	globalStyleFormat.darkshadow : darker(darker(inSkin.minimizeButtonBorder));
	
	//these properties are responsible for disabled state of slider component (at least).
	globalStyleFormat.disabledHighlight = darker(edgeRGBBrightest);
	globalStyleFormat.disabledHighlight3D = darker(edgeRGBBrighter);
	globalStyleFormat.disabledShadow = darker(edgeRGBDarker);
	globalStyleFormat.disabledDarkshadow = darker(edgeRGBDarkest);
	globalStyleFormat.disabledFace = darker(faceRGBEnabled);
		
	//comboboxes and scrolls
	globalStyleFormat.scrollTrack = (inSkin.scrollerBG < 0)?		darker(controlsBackground) : inSkin.scrollerBG;
	globalStyleFormat.scrollFace = (inSkin.scrollBG < 0)?			faceRGBEnabled : inSkin.scrollBG;
	globalStyleFormat.scrollFacePress = (inSkin.scrollBGPress < 0)? faceRGBEnabled : inSkin.scrollBGPress;
	globalStyleFormat.scrollBorder = (inSkin.scrollBorder < 0)?	borderRGBEnabled : inSkin.scrollBorder;
	globalStyleFormat.scrollBorder = (inSkin.id == 'xp' && _global.FlashChatNS.SKIN_NAME == 'gradient_skin')?  globalStyleFormat.face : globalStyleFormat.scrollBorder;
	globalStyleFormat.selection = globalStyleFormat.scrollFace;
	
	globalStyleFormat.textColor = inSkin.buttonText;
	globalStyleFormat.textSelected = (globalStyleFormat.selection != inSkin.buttonText)? inSkin.buttonText : undefined;
	globalStyleFormat.textDisabled = buttonTextDarker;
	globalStyleFormat.arrow = inSkin.buttonText;
	globalStyleFormat.background = (inSkin.controlsBackground < 0)? controlsBackground : inSkin.controlsBackground;
	globalStyleFormat.backgroundDisabled = controlsBackgroundBrighter;
	globalStyleFormat.backgroundBorder = (_global.FlashChatNS.SKIN_NAME == 'xp_skin')? globalStyleFormat.highlight : controlsBackgroundDarker;
	
	//check box
	globalStyleFormat.check = (inSkin.check < 0)? 0x000000 : inSkin.check;
	
	globalStyleFormat.applyChanges();
	
	this.applyBackgroundColor(inSkin)
	this.applyBackground(inSkin);
	this.applyTitleStyle(inSkin);
	this.applyLogNOptionPanelStyle(inSkin);
	this.applyUserListStyle(inSkin);
	this.applyDialogStyle(inSkin);
};

ChatUI.prototype.applyControlsBackground = function(inSkin) {
	var controlsBackground = brighter(inSkin.background);
	var controlsBackgroundBrighter = brighter(controlsBackground);
	
	globalStyleFormat.background = controlsBackground;
	globalStyleFormat.backgroundDisabled = controlsBackgroundBrighter;
	
	globalStyleFormat.applyChanges();
}

ChatUI.prototype.applyBackgroundColor = function(inSkin) {
	var c = new Color(this.mc.skinBackground);
	c.setRGB(inSkin.background);
}

ChatUI.prototype.applyDialogStyle = function(inSkin) {
	var uiAlpha;
	if (((this.selfUserId == null) && !inSkin.showBackgroundImagesOnLogin) || !inSkin.showBackgroundImages || (inSkin.backgroundImage == null) || (inSkin.backgroundImage == ''))
	{
		uiAlpha = inSkin.uiAlpha; //100
	} 
	else
	{
		uiAlpha = inSkin.uiAlpha;
	}
	
	
	if(this.mc.titleBG != undefined) 
	{
		var headline_color = (inSkin.headline < 0)? inSkin.dialogTitle : inSkin.headline;
		fillHGradient(this.mc.titleBG_test, headline_color);
	}	
	
	
	var dialogStyle = this.getDialogStyleObject(inSkin, uiAlpha);
	this.dialogManager.setStyle(dialogStyle);
	this.privateBoxManager.setStyle(dialogStyle);
}

ChatUI.prototype.getDialogStyleObject = function(inSkin, uiAlpha) {
	var dialogStyle = new Object();
	
	dialogStyle.id = inSkin.id;
	dialogStyle.buttonText = inSkin.buttonText;
	dialogStyle.dialog = inSkin.dialog;
	dialogStyle.dialogBrighter = brighter(brighter(inSkin.dialog));
	dialogStyle.dialogdarker = darker(darker(inSkin.dialog));
	dialogStyle.dialogTitle = inSkin.dialogTitle;
	dialogStyle.bodyText = inSkin.bodyText;
	dialogStyle.borderColor = inSkin.borderColor;
	dialogStyle.dialogBackgroundImage = inSkin.dialogBackgroundImage;
	dialogStyle.showBackgroundImages = inSkin.showBackgroundImages;
	dialogStyle.showBackgroundImagesOnLogin = inSkin.showBackgroundImagesOnLogin;
	dialogStyle.inputBoxBackground = inSkin.inputBoxBackground;
	dialogStyle.uiAlpha = uiAlpha;
	dialogStyle.privateLogBackground = inSkin.privateLogBackground;
	
	return(dialogStyle);
}

ChatUI.prototype.applyUserListStyle = function(inSkin) {
	if (this.settings.layout.showUserList) {
		var style = new Object();
		style.borderColor = inSkin.borderColor;
		style.userListBackground = inSkin.userListBackground;
		style.uiAlpha = inSkin.uiAlpha;
		style.userBackground = (inSkin.userListItem < 0)? brighter(inSkin.background) : inSkin.userListItem;
		style.userBackgroundDarker = (inSkin.userListItem < 0)? darker(inSkin.roomBackground) : darker(darker(inSkin.userListItem));
		style.roomBackground = inSkin.roomBackground;
		style.roomBackgroundBrighter = brighter(inSkin.roomBackground);
		style.roomBackgroundDarker = darker(inSkin.roomBackground);
		style.roomText = inSkin.roomText;
		style.roomTextDarker = darker(inSkin.roomText);
		style.enterRoomNotify = inSkin.enterRoomNotify;
		style.userTextColor = inSkin.recommendedUserColor;
		_global.FlashChatNS.userListStyle = style;
		this.mc.userList.setStyle(style);
	}
}

ChatUI.prototype.applyTitleStyle = function(inSkin) {
	//this.mc.txtSelfUserName.txt.textColor = inSkin.titleText;
	setTextProperty('color', inSkin.titleText, this.mc.txtSelfUserName.txt, true);
}

ChatUI.prototype.applyUserColor4Msg = function(inColor) {
	this.mc.msgTxt.textfield_txt.textColor = inColor;
}

ChatUI.prototype.applyLogNOptionPanelStyle = function(inSkin) {
	this.mc.chatLog.setBorderColor(inSkin.borderColor);
	this.mc.privateLog.setBorderColor(inSkin.borderColor);
	
	//input text color does not depend on user color now.
	this.mc.msgTxt.textfield_txt.textColor = inSkin.buttonText;
	//this.applyUserColor4Msg(this.settings.user.userColor);
	this.mc.msgTxt.borderColor = inSkin.borderColor;
	this.mc.msgTxt.textfield_txt._skin = inSkin;
		
	this.mc.roomLabel.textColor = inSkin.bodyText;
	//this.mc.optionPanel.statusLabel.textColor = inSkin.bodyText;
	
	c = new Color(this.mc.optionPanel.btnBellIcon);
	c.setRGB(inSkin.bodyText);
	this.mc.optionPanel.bellLabel.textColor = inSkin.bodyText;
	
	//set color for bold and italic button icon
	c = new Color(this.mc.optionPanel.bold_ib.getIcon());
	c.setRGB(inSkin.buttonText);
	c = new Color(this.mc.optionPanel.italic_ib.getIcon());
	c.setRGB(inSkin.buttonText);
}

ChatUI.prototype.applyBackground = function(inSkin) {
	var uiAlpha;
	if (((this.selfUserId == null) && !inSkin.showBackgroundImagesOnLogin) || !inSkin.showBackgroundImages || (inSkin.backgroundImage == null) || (inSkin.backgroundImage == '')) {
		this.mc.backgroundImageHolder.image.clear();
		uiAlpha = inSkin.uiAlpha; //100
	} else {
		uiAlpha = inSkin.uiAlpha;
		this.mc.backgroundImageHolder.image.loadImage(inSkin.backgroundImage);
	}
	
	this.mc.chatLog.setBackgroundColor(inSkin.publicLogBackground, uiAlpha);
	this.mc.privateLog.setBackgroundColor(inSkin.privateLogBackground, uiAlpha);
	c = new Color(this.mc.msgTxtBackground);
	c.setRGB(inSkin.inputBoxBackground);
	this.mc.msgTxtBackground._alpha = uiAlpha;
	
	if (this.settings.layout.showUserList) {
		var style = new Object();
		style.userListBackground = inSkin.userListBackground;
		style.uiAlpha = uiAlpha;
		style.userBackground = (inSkin.userListItem < 0)? brighter(inSkin.background) : inSkin.userListItem;
		style.userBackgroundDarker = (inSkin.userListItem < 0)? darker(inSkin.roomBackground) : darker(darker(inSkin.userListItem));
		style.roomBackground = inSkin.roomBackground;
		style.roomBackgroundBrighter = brighter(inSkin.roomBackground);
		style.roomBackgroundDarker = darker(inSkin.roomBackground);
		style.roomText = inSkin.roomText;
		style.roomTextDarker = darker(inSkin.roomText);
		this.mc.userList.setAlpha(style);
	}

	var dialogStyle = this.getDialogStyleObject(inSkin, uiAlpha);
	this.dialogManager.setBackground(dialogStyle);
	this.privateBoxManager.setBackground(dialogStyle);
};

ChatUI.prototype.applySoundProperties = function(inSoundProperties) {
	this.soundObj.setVolume(inSoundProperties.volume);
	this.soundObj.setPan(inSoundProperties.pan);
};

ChatUI.prototype.applyLanguage = function(inLanguage, inForce) 
{
	//trace('APPLY LANGUAGE ');
	//dbg(inLanguage);
	
	for (var i = 0; i < this.languages.length; i ++) {
		if (this.languages[i].id == inLanguage.id) {
			this.languages[i] = inLanguage;
			break;
		}
	}
	
	this.listener.getLanguage(inLanguage.id, true);
	
	var selfUser = this.getUser(this.selfUserId);
	if (selfUser != null) {
		var welcomeStr = inLanguage.desktop.welcome;
		welcomeStr = this.replace(welcomeStr, 'USER_LABEL', selfUser.label);
		this.mc.txtSelfUserName.txt.htmlText = welcomeStr;
		
		//!!!refresh
		setTextProperty('font', this.settings.user.text.itemToChange.title.fontFamily, this.mc.txtSelfUserName.txt, true);
		setTextProperty('size', this.settings.user.text.itemToChange.title.fontSize, this.mc.txtSelfUserName.txt, true);
		this.applyTitleStyle(this.settings.user.skin);
		//!!!refresh
	}
		
	this.mc.roomLabel.text = inLanguage.desktop.room;
	//this.mc.optionPanel.statusLabel.text = inLanguage.desktop.myStatus;
	this.mc.addRoomBtn.setLabel(inLanguage.desktop.addRoomBtn);
	this.mc.optionPanel.btnSkinProperties.setLabel(inLanguage.desktop.skinBtn);
	this.mc.optionPanel.btnClear.setLabel(inLanguage.desktop.clearBtn);
	this.mc.optionPanel.btnSave.setLabel(inLanguage.desktop.saveBtn);
	this.mc.sendBtn.setLabel(inLanguage.desktop.sendBtn);
	//setting label of 'help' button. this button supports autosize, thus we need to 
	this.applyButtonLabel(this.mc.optionPanel.btnHelp, inLanguage.desktop.helpBtn);
	//setting label of 'logoff' button.
	this.applyButtonLabel(this.mc.logOffBtn, inLanguage.desktop.logOffBtn);
	
	this.mc.optionPanel.bellLabel.text = inLanguage.desktop.ringTheBell;

	//XXX01 avu: ay out option panel. we do not update minimum layout parameters, in hope that
	//language will not be assigned in runtime. otherwise we need to do the same stuff we do
	//in setSettings method and call layout manager than.
	this.layoutOptionPanel();

	ChatUI.prototype.USER_MENU_PRIVATE_MESSAGE = inLanguage.usermenu.privatemessage;
	ChatUI.prototype.USER_MENU_INVITE = inLanguage.usermenu.invite;
	ChatUI.prototype.USER_MENU_IGNORE = inLanguage.usermenu.ignore;
	ChatUI.prototype.USER_MENU_UNIGNORE = inLanguage.usermenu.unignore;
	ChatUI.prototype.USER_MENU_BAN = inLanguage.usermenu.ban;
	ChatUI.prototype.USER_MENU_UNBAN = inLanguage.usermenu.unban;
	ChatUI.prototype.USER_MENU_PROFILE = inLanguage.usermenu.profile;
	ChatUI.prototype.USER_MENU_FILE_SHARE = inLanguage.usermenu.fileshare;

	ChatUI.prototype.USER_STATE_LIST.splice(0);
	ChatUI.prototype.USER_STATE_LIST.states = new Object();
	var ind = 4;
	for(var sts in inLanguage.status)
	{
		var state_index = 0;
		switch(sts)
		{
			case 'here' : 
				state_index = this.USER_STATE_HERE;
				break;
			case 'busy' : 
				state_index = this.USER_STATE_BUSY;
				break;
			case 'away' : 
				state_index = this.USER_STATE_AWAY;
				break;
			default :
				state_index = ind;
				ind++;
				break;
		}
		
		ChatUI.prototype.USER_STATE_LIST.push( [state_index, inLanguage.status[sts]]);
		ChatUI.prototype.USER_STATE_LIST.states[state_index] = inLanguage.status[sts];
	}

	var state = this.mc.optionPanel.userState.getEnabled();
	this.mc.optionPanel.userState.setEnabled(true);
	this.mc.optionPanel.userState.setChangeHandler(null);
	this.mc.optionPanel.userState.removeAll();
	var here_ind = 0;
	for (var i = 0; i < this.USER_STATE_LIST.length; i++) {
		if(this.USER_STATE_LIST[i][0] == 1) here_ind = i;
		this.mc.optionPanel.userState.addItem(this.USER_STATE_LIST[i][1], this.USER_STATE_LIST[i]);
	}
	this.mc.optionPanel.userState.setChangeHandler('onUserStateChanged', this);
	this.mc.optionPanel.userState.setSelectedIndex(here_ind);
	
	this.mc.optionPanel.userState.setEnabled(state);
	
	this.mc.optionPanel.smileDropDown.replaceItemAt(0, inLanguage.desktop.selectsmile);
	this.mc.optionPanel.smileDropDown.setSelectedIndex(0);

	this.mc.userList.setLanguage(inLanguage);
	this.dialogManager.applyLanguage(inLanguage);
	this.privateBoxManager.applyLanguage(inLanguage);
	
	if(inForce) this.onResize();

};

ChatUI.prototype.saveUserSettings = function() {
	//trace('SAVE USER SETTINGS');
	var settingsSO = SharedObject.getLocal('chat_settings_' + this.selfUserId);
	
	delete settingsSO.data.user;
	settingsSO.data.user = null;
	settingsSO.flush();
	settingsSO.data.user = this.settings.user;
	settingsSO.flush();
};

//this methods starts thread that moves focus to input text field.
ChatUI.prototype.setInputFocus = function() {
	if (this.setInputFocusIntervalId != null) {
		clearInterval(this.setInputFocusIntervalId);
		this.setInputFocusIntervalId = null;
	}
	
	this.setInputFocusIntervalId = setInterval(this.setInputFocusTick, 10, this);
};

ChatUI.prototype.setInputFocusTick = function(inChatUI) 
{
	var focusTarget = (inChatUI.focusTarget == null ? inChatUI.mc.msgTxt.textfield_txt : inChatUI.focusTarget);
	
	//trace('TXT >> |' + inChatUI.mc.msgTxt.text + '|');
	//inChatUI.mc.msgTxt.text = inChatUI.replace(inChatUI.mc.msgTxt.text, '\r', '');
		
	var is_visible = inChatUI.dialogManager.dialogList[0]._visible;
	for(var i = 0; i < inChatUI.privateBoxManager.privateBoxList.length; i++)
		if( inChatUI.privateBoxManager.privateBoxList[i]._visible )
		{	 
			is_visible = true;
			break;
		}
	
	if(! is_visible && eval(Selection.getFocus()) != focusTarget)
	{ 
		//trace('GET FOCUS ' + Selection.getFocus() + ' targ ' + focusTarget);
		
		var max_len = 1000;
		Selection.setFocus(focusTarget);
		Selection.setSelection(max_len, max_len);
	}
	
	inChatUI.focusTarget = null;
	
	clearInterval(inChatUI.setInputFocusIntervalId);
	inChatUI.setInputFocusIntervalId = null;	
};

ChatUI.prototype.replace = function(inStr, inSearchStr, inReplaceStr) {
	var tokenList = inStr.split(inSearchStr);
	var res = '';
	for (var i = 0; i < tokenList.length - 1; i ++) {
		res += tokenList[i] + inReplaceStr;
	}
	res += tokenList[tokenList.length - 1];
	return res;
};

ChatUI.prototype.findSmile = function(inKey, inValue)
{
	for (var i = 0; i < SmileTextConst.patternList.length; i++)
	{
		var obj = new Object();
		obj.patternStr = SmileTextConst.patternList[i][0];
		obj.patternIcon = SmileTextConst.patternList[i][1];
		obj.iconWidth = SmileTextConst.patternList[i][2];
		obj.iconHeight = SmileTextConst.patternList[i][3];
		obj.image = SmileTextConst.patternList[i][4];
		
		if(obj[inKey] == inValue) return obj;
	}
};

ChatUI.prototype.fillSmieDropdown = function(inSmiles, inComboBox, isLabeled) {
	inComboBox.removeAll();
	if(isLabeled) inComboBox.addItem(this.selectedLanguage.desktop.selectsmile);
	
	var prev_smi = '';
	var user = this.getUser(this.selfUserId);
	for (var i = 0; i < SmileTextConst.patternList.length; i ++) {
		
		if(
			this.selfUserRole != user.ROLE_ADMIN &&
			this.selfUserRole != user.ROLE_MODERATOR &&
			this.settings.avatars.mod_only.list.indexOf(SmileTextConst.patternList[i][1]) != -1 &&
			isLabeled == false
		  ) 
		  { 
			//trace('bool ' + this.settings.avatars.mod_only.list.indexOf(SmileTextConst.patternList[i][1]))
			//trace('pat ' + SmileTextConst.patternList[i][1] + ' list ' + this.settings.avatars.mod_only.list);
			continue;
		  }	
		
		if ( prev_smi != SmileTextConst.patternList[i][1])
		{
			var obj = new Object();
			obj.patternStr = SmileTextConst.patternList[i][0];
			obj.patternIcon = SmileTextConst.patternList[i][1];
			obj.iconWidth = SmileTextConst.patternList[i][2];
			obj.iconHeight = SmileTextConst.patternList[i][3];
			obj.image = SmileTextConst.patternList[i][4];
			
			var str = (isLabeled)? obj.patternStr : '';
			inComboBox.addItem(str, obj);
		}
		
		prev_smi = SmileTextConst.patternList[i][1];
	}
};

ChatUI.prototype.addClientMessage = function(inMsg, inUser, inRoom, inPublic, inTimestamp, store) {
	if(inUser) inMsg = this.replace(inMsg, 'USER_LABEL', inUser.label);
	if(inRoom) inMsg = this.replace(inMsg, 'ROOM_LABEL', inRoom.label);
	inMsg = this.replace(inMsg, 'TIMESTAMP', this.getCurrentTime(inTimestamp));
	
	if (inPublic) {
		this.mc.chatLog.addText('', inMsg, this.settings.user.skin.enterRoomNotify);
	} else {
		this.mc.privateLog.addText('', inMsg, this.settings.user.skin.enterRoomNotify);
	}
	
	if(store != undefined)
	{
		this.interfaceElements_txt = inRoom.label;
		this.inUser_txt = inUser;
		this.timestamp_txt = inTimestamp;
	}
};

ChatUI.prototype.getTimeMilis = function() {
	var timevar = new Date();
	return (timevar.getTime());
}

ChatUI.prototype.getCurrentTime = function(inTimestamp) {
	return inTimestamp;
};

ChatUI.prototype.enableSendButton = function() {
	this.mc.sendBtn.setEnabled(this.sendButtonEnabled);
};

ChatUI.prototype.getAlphaColor = function(inFgc, inBgc, inAlpha) {
	var bgcObj = RGB2Obj(inBgc);
	var fgcObj = RGB2Obj(inFgc);
	
	var res = new Object();
	res.r = bgcObj.r * (1 - inAlpha) + fgcObj.r * inAlpha;
	res.g = bgcObj.g * (1 - inAlpha) + fgcObj.g * inAlpha;
	res.b = bgcObj.b * (1 - inAlpha) + fgcObj.b * inAlpha;
	return  Obj2RGB(res);
};

ChatUI.prototype.copyObjectTree = function(inSrc, inDest) {
	for (var fname in inSrc) {
		var val = inSrc[fname];
		if (inDest[fname] == null) {
			if ((typeof val) == 'object') {
				inDest[fname] = new Object();
			} else {
				inDest[fname] = val;
			}
		}
		if ((typeof val) == 'object') {
			this.copyObjectTree(inSrc[fname], inDest[fname]);
		}
	}
};

ChatUI.prototype.showMessageBox = function(inText) {
	var promptBox = this.dialogManager.createDialog('PromptBox');
	promptBox.setLabelTextVisible(true);
	promptBox.setInputTextVisible(false);
	promptBox.setRightButtonVisible(false);
	promptBox.setValidateRightButton(false);
	promptBox.setCloseButtonEnabled(true);
	promptBox.setLeftButtonLabel(this.selectedLanguage.dialog.common.okBtn);
	promptBox.setLabelText(inText);
	promptBox.setHandler('onMessageBoxCompleted', this);
	this.dialogManager.showDialog(promptBox);
};

ChatUI.prototype.onMessageBoxCompleted = function(control) {
	this.setControlsEnabled(true);
	this.dialogManager.releaseDialog(control);
};


//IRC-like command processing.

//does parsing and processing of input string. if it appears to be valid irc command, runs it
//and returns true. returns false otherwise.
ChatUI.prototype.ircProcessCommand = function(inStr, inSup) {
	var commandObj = this.ircParseCommand(inStr);
	if (commandObj == null) {
		return false;
	}
	
	var command = commandObj.command.toLowerCase();
		
	var sett = new Array();
	var usr  = new User();
	
	if(this.selfUserRole == usr.ROLE_MODERATOR)
	{
		sett = this.settings.mods.toLowerCase().split(',');
	}
	else if(this.selfUserRole != usr.ROLE_ADMIN)
	{
		sett = this.settings.disabledIRC.toLowerCase().split(',');
	}	
	
	for(var i = 0; i < sett.length; i++)
	{
		if(sett[i] == command) return false;
	}	
	
	if (inSup == undefined) inSup = 0;
	
	//admin commands
	var comm = 'alert,roomalert,chatalert,gag,ungag,kick,boot,ban,banip,startbot,killbot,addbot,removebot,teach,unteach,showbots';
	if(
		comm.indexOf(command) != -1 && 
		this.selfUserRole != usr.ROLE_ADMIN && this.selfUserRole != usr.ROLE_MODERATOR && 
		inSup == 0
	  ) 
		return false;
	
	switch (command) {
		case 'away' :
			var selfUser = this.getUser(this.selfUserId);
			var newUserState = null;
			if (selfUser.getState() == this.USER_STATE_AWAY) {
				newUserState = this.USER_STATE_HERE;
			} else {
				newUserState = this.USER_STATE_AWAY;
			}
			if (newUserState != null) {
				for (var i = 0; i < this.mc.optionPanel.userState.getLength(); i ++) {
					if (this.mc.optionPanel.userState.getItemAt(i).data[0] == newUserState) {
						this.mc.optionPanel.userState.setSelectedIndex(i);
						break;
					}
				}
			}
			break;
		case 'here' :
			var selfUser = this.getUser(this.selfUserId);
			if (selfUser.getState() != this.USER_STATE_HERE) {
				for (var i = 0; i < this.mc.optionPanel.userState.getLength(); i ++) {
					if (this.mc.optionPanel.userState.getItemAt(i).data[0] == this.USER_STATE_HERE) {
						this.mc.optionPanel.userState.setSelectedIndex(i);
						break;
					}
				}
			}
			break;
		case 'busy' :
			var selfUser = this.getUser(this.selfUserId);
			var newUserState = null;
			if (selfUser.getState() == this.USER_STATE_BUSY) {
				newUserState = this.USER_STATE_HERE;
			} else {
				newUserState = this.USER_STATE_BUSY;
			}
			if (newUserState != null) {
				for (var i = 0; i < this.mc.optionPanel.userState.getLength(); i ++) {
					if (this.mc.optionPanel.userState.getItemAt(i).data[0] == newUserState) {
						this.mc.optionPanel.userState.setSelectedIndex(i);
						break;
					}
				}
			}
			break;
		case 'back' :
			this.listener.back(Number(commandObj.args));
			break;
		case 'backtime' :
			this.listener.backtime(Number(commandObj.args));
			break;
		case 'clear' :
			this.mc.chatLog.clear();
			this.mc.privateLog.clear();
			break;
		case 'clearpublic' :
			this.mc.chatLog.clear();
			break;
		case 'clearprivate' :
			this.mc.privateLog.clear();
			break;
		case 'invite' :
			if (this.settings.layout.allowInvite) {
				var args = this.ircParseUserName(commandObj.args);
				if (args != null) {
					user = this.findUserByName(args.userName);
					if (user == null) {
						this.userNotFoundPopup(args);
					} else {
						var userid = user.id;
						this.listener.inviteUserTo(userid, this.selfRoomId, '');
					}
				}
			}
			break;
		case 'part' :
		case 'quit' :
		case 'logout' :
			this.listener.logout();
			break;
		case 'version' :
			var labelText = this.selectedLanguage.desktop.version + ': ' + this.settings.version;
			this.showMessageBox(labelText);
			break;
		case 'ignore' :
			if (this.settings.layout.allowIgnore || inSup == 7) {
				var args = this.ircParseUserName(commandObj.args);
				if (args != null) {
					user = this.findUserByName(args.userName);
					if (user == null) {
						this.userNotFoundPopup(args);
					} else {
						var userid = user.id;
						this.listener.ignoreUser(userid, '');
					}
				}
			}
			break;
		case 'kick' :
		case 'boot' :
			if (this.settings.layout.allowBan || inSup) {
				var args = this.ircParseUserName(commandObj.args);
				if (args != null) {
					user = this.findUserByName(args.userName);
					if (user == null) {
						this.userNotFoundPopup(args);
					} else {
						var room = this.getRoomForUser(user.id);
						
						var userid = user.id;
						var enteredText = args.params == null ? '' : args.params;
						var bantype = 1; //ban from room
						var selectedRoom = room;
						this.listener.banUser(userid, bantype, selectedRoom.id, enteredText, inSup);
					}
				}
			}
			break;
		case 'ban' :
			if (this.settings.layout.allowBan || inSup == 7) {
				var args = this.ircParseUserName(commandObj.args);
				if (args != null) {
					user = this.findUserByName(args.userName);
					if (user == null) {
						this.userNotFoundPopup(args);
					} else {
						var room = this.getRoomForUser(user.id);
						var userid = user.id;
						var enteredText = args.params == null ? '' : args.params;
						var bantype = 2; //ban from chat
						var selectedRoom = room;
						this.listener.banUser(userid, bantype, selectedRoom.id, enteredText, inSup);
					}
				}
			}
			break;
		case 'banip' :
			if (this.settings.layout.allowBan || inSup == 7) {
				var args = this.ircParseUserName(commandObj.args);
				if (args != null) {
					user = this.findUserByName(args.userName);
					if (user == null) {
						this.userNotFoundPopup(args);
					} else {
						var room = this.getRoomForUser(user.id);
						
						var userid = user.id;
						var enteredText = args.params == null ? '' : args.params;
						var bantype = 3; //ban by ip
						var selectedRoom = room;
						this.listener.banUser(userid, bantype, selectedRoom.id, enteredText, inSup);
					}
				}
			}
			break;
		case 'broadcast' :
			//XXX01 avu: this is a dirty check if current user is a moderator.
			if (this.settings.layout.allowBan || inSup == 7) {
				if (commandObj.args != null) {
					this.waitingForResponse = true;
					this.listener.sendMessageTo(0, 0, commandObj.args, '', inSup);
					this.soundObj.attachSound('SubmitMessage');
					this.soundObj.start();
				}
			}
			break;
		case 'me' :
			if (commandObj.args != null) {
				this.waitingForResponse = true;
				this.listener.sendMessageTo(0, this.selfRoomId, commandObj.args, 'isUrgent');

				this.soundObj.attachSound('SubmitMessage');
				this.soundObj.start();
			}
			break;
		case 'join' :
			if (commandObj.args != null) {
				var room = this.findRoomByLabel(commandObj.args.trim());
				if(room.id == this.selfRoomId) break;
				if (room == null) {
					var labelText = this.selectedLanguage.dialog.misc.roomnotfound;
					labelText = this.replace(labelText, 'ROOM_LABEL', commandObj.args);
					this.showMessageBox(labelText);
				} else {
					for (var i = 0; i < this.mc.roomChooser.getLength(); i ++) {
						if (this.mc.roomChooser.getItemAt(i).data.id == room.id) {
							this.mc.roomChooser.setSelectedIndex(i);
							break;
						}
					}
				}
			}
			break;
		case 'alert' :
			var args = this.ircParseUserName(commandObj.args);
			
			if (args != null)
			{
				user = this.findUserByName(args.userName);
				if (user == null)
				{
					this.userNotFoundPopup(args);
				}
				else
				{
					var userid = user.id;
					var enteredText = args.params == null ? '' : args.params;
					this.listener.alert(userid, enteredText, inSup);
				}
			}
			break;
		case 'roomalert' :
			if (commandObj.args != null)
			{ 
				this.listener.roomAlert(this.selfRoomId, commandObj.args, inSup);
			}
			break;
		case 'chatalert' :
			if (commandObj.args != null)
			{ 
				this.listener.chatAlert(commandObj.args, inSup);
			}
			break;
		case 'gag' : 
			var minutes = commandObj.args.substr(0, commandObj.args.indexOf(' '));
			if(minutes == '' || isNaN(minutes) || minutes <= 0) break;
			
			var args = this.ircParseUserName(commandObj.args.substr(commandObj.args.indexOf(' ')+1));
			
			if (args != null)
			{
				user = this.findUserByName(args.userName);
				if (user == null)
				{
					this.userNotFoundPopup(args);
				}
				else
				{
					var userid = user.id;
					this.listener.gag(userid, minutes, inSup);
				}
			}
			break;
		case 'ungag' : 
			var args = this.ircParseUserName(commandObj.args);
			if (args != null)
			{
				user = this.findUserByName(args.userName);
				if (user == null)
				{
					this.userNotFoundPopup(args);
				}
				else
				{
					var userid = user.id;
					this.listener.ungag(userid, inSup);
				}
			}
			break;
		//bots commands
		case 'startbot' :
			/*
			var args = this.ircParseBotArgs(commandObj.args)
			if (args.login != '')
			{
				var room = this.findRoomByLabel(args.room);
				var roomid = (room.id == undefined)? 0 : room.id;
				this.listener.startBot(args.login, roomid);
			}
			*/
			if (commandObj.args != null)
			{
				this.listener.startBot(commandObj.args, this.selfRoomId, inSup);
			}
			break;
		case 'killbot' :
			var args = this.ircParseUserName(commandObj.args);
			if (args != null)
			{
				user = this.findUserByName(args.userName);
				if (user == null)
				{
					this.userNotFoundPopup(args);
				}
				else
				{
					this.listener.killBot(args.userName, inSup);
				}
			}
			break;
		case 'addbot' :
			/*
			var args = this.ircParseBotArgs(commandObj.args)
			if (args.login != '')
			{
				this.listener.addBot(args.login, args.bot);
			}
			*/
			if (commandObj.args != null)
			{
				this.listener.addBot(commandObj.args, 'Bot', inSup);
			}
			break;
		case 'removebot' :
			if (commandObj.args != null)
			{
				this.listener.removeBot(commandObj.args, inSup);
			}	
			break;	
		case 'teach' :
			var args = this.ircParseUserName(commandObj.args);
			if (args != null)
			{
				this.listener.teachBot(args.userName, args.params, inSup);
			}	
			break;
		case 'unteach' :
			var args = this.ircParseUserName(commandObj.args);	
			if (args != null)
			{
				this.listener.unTeachBot(args.userName, args.params, inSup);
			}	
			break;
		case 'showbots' :
			this.listener.showBots(inSup);
			break;
		//Veronica added IRC
		case '?' : 
		case 'rooms' :
		case 'showbans' :
		case 'msg' :
		case 'query' :
		case 'names' :
		case 'showignores' :
		case 'sos' :
			this.callModuleFunc('mOnIRC', {irc : inStr}, -1);
			return false;
			break;
		//---
		
		
		default :
			return false;
	}
	
	this.callModuleFunc('mOnIRC', {irc : inStr}, -1);
	return true;
};

ChatUI.prototype.userNotFoundPopup = function(args) {
	var labelText = this.selectedLanguage.dialog.misc.usernotfound;
	var username = args.userName;
	if(args.userName == null || args.userName == 'null' || args == null) 
	{ 
		username = '';
	}
		
	labelText = this.replace(labelText, 'USER_LABEL', username);
	this.showMessageBox(labelText);
};

//parses given string and returns object with 2 fields: 'command' and 'args'.
//if command has no arguments 'args' is null.
//if no command was found in input string, function returns null.
ChatUI.prototype.ircParseCommand = function(inStr) {
	if ((inStr == null) || (inStr == '') || (inStr.charAt(0) != '/')) {
		return null;
	}
	var endCommandIdx = inStr.indexOf(' ');
	var command = null;
	var args = null;
	if (endCommandIdx > 0) {
		command = inStr.substring(1, endCommandIdx);
		var startArgsIdx = endCommandIdx;
		while ((startArgsIdx < inStr.length) && (inStr.charAt(startArgsIdx) == ' ')) {
			startArgsIdx ++;
		}
		var endArgsIdx = inStr.length -1;
		while ((endArgsIdx > -1) && (inStr.charAt(endArgsIdx) == ' ')) {
			endArgsIdx --;
		}
		if (endArgsIdx >= startArgsIdx) {
			args = inStr.substring(startArgsIdx, endArgsIdx + 1);
		}
	} else {
		command = inStr.substring(1);
	}
	if (command == '') {
		return null;
	}
	var obj = new Object();
	if(command.indexOf('gag') == 0)
	{ 
		args = command.substr(3) + ' ' + args; 
		command = 'gag';
	}
	
	obj.command = command;
	obj.args = args;

	return obj;
};

//parses input arguments to find user name and additional parameters (if any).
//user name may be encolsed in double quotes.
//returns an object with 2 fields: 'userName' and 'params'. if no additional parameters
//were found, 'params' is null. if no user name was found, or if input string has bad syntax,
//function returns null.
ChatUI.prototype.ircParseUserName = function(inStr) {
	if ((inStr == null) || (inStr == '') || (inStr.charAt(0) == ' ')) {
		return null;
	}
	var userName = null;
	var params = null;
	var startParamsIdx = null;
	if (inStr.charAt(0) == '"') {
		var closingQuoteIdx = inStr.indexOf('"', 2);
		if (closingQuoteIdx == -1) {
			return null;
		}
		if ((closingQuoteIdx < inStr.length - 1) && (inStr.charAt(closingQuoteIdx + 1) != ' ')) {
			return null;
		}
		userName = inStr.substring(1, closingQuoteIdx);
		if (closingQuoteIdx < inStr.length - 1) {
			startParamsIdx = closingQuoteIdx + 1;
		}
	} else {
		var endUserNameIdx = inStr.indexOf(' ');
		if (endUserNameIdx > 0) {
			userName = inStr.substring(0, endUserNameIdx);
			startParamsIdx = endUserNameIdx + 1;
		} else {
			userName = inStr;
		}
	}
	if (userName == '') {
		return null;
	}
	if (startParamsIdx != null) {
		while ((startParamsIdx < inStr.length) && (inStr.charAt(startParamsIdx) == ' ')) {
			startParamsIdx ++;
		}
		var endParamsIdx = inStr.length - 1;
		while ((endParamsIdx >= startParamsIdx) && (inStr.charAt(endParamsIdx) == ' ')) {
			endParamsIdx --;
		}
		if (endParamsIdx >= startParamsIdx) {
			params = inStr.substring(startParamsIdx, endParamsIdx + 1);
		}
	}
	var obj = new Object();
	obj.userName = userName;
	obj.params = params;
	return obj;
};

ChatUI.prototype.ircParseBotArgs = function(inStr) {
	var ret = {login : '', pass : '', room : '', bot : ''};
	var arr = inStr.split('"');
	for(var i = 0; i < arr.length; )
	{
		var arg = arr[i].toLowerCase();
		arg = arg.trim();
		switch(arg){
			case 'l=':
			case 'login=':
				ret.login = arr[i+1];
				i+=2;
				break;
			case 'p=':
			case 'password=':
				ret.pass = arr[i+1];
				i+=2;
				break;
			case 'r=':
			case 'room=':
				ret.room = arr[i+1];
				i+=2;
				break;
			case 'b=':
			case 'bot=':
				ret.bot = arr[i+1];
				i+=2;
				break;
			default:
				i++;
				break;
		}
	}
	
	return(ret);
}

//END IRC-like command processing.

//applies specified label to a push button. resizes button according to label width.
ChatUI.prototype.applyButtonLabel = function(inButton, inLabel) 
{
	//var labelSize = inButton.textStyle.getTextExtent(inLabel);
	//var dim = testText(inButton.fLabel_mc.labelField, inLabel);
	//trace('w ' + dim.width + ' h ' + dim.height);
	//inButton.setSize(Math.max(20, dim.width + 10), dim.height);
	inButton.setLabel(inLabel);
};

//dialog manager handler.
ChatUI.prototype.onNewDialogShow = function(inManager) {
	this.setControlsEnabled(false);
};
//END dialog manager handler.

//private nox handler.
ChatUI.prototype.onPrivateBoxSend = function(inPrivateBox) {
	clearInterval(this.inactivityIntervalId);
	this.inactivityIntervalId = setInterval(this.logout, this.settings.inactivityInterval * 1000, this);
	
	this.waitingForResponse = true;
	this.focusTarget = inPrivateBox.getFocusTarget();
	this.listener.sendMessageTo(inPrivateBox.getUser().id, 0, inPrivateBox.getMessage());

	this.soundObj.attachSound('SubmitMessage');
	this.soundObj.start();
};
//END private nox handler.

//analize and layout option panel. returns option panel width.
ChatUI.prototype.layoutOptionPanel = function() {
	var optionPanelWidth = 0;
	if (this.settings.layout.showOptionPanel) {
		
		var op = new Array();
		for(var itm in this.settings.layout.toolbar) op.push(itm);
		for(var i = op.length-1; i >= 0; i--)
		{ 
			switch(op[i])
			{
				case 'status':
					if (this.settings.layout.toolbar.status)
					{
						this.mc.optionPanel.userState._x = optionPanelWidth;
						optionPanelWidth += this.mc.optionPanel.userState._width;
					}
					this.mc.optionPanel.userState._visible = this.settings.layout.toolbar.status;
					break;
				case 'skin':
					if (this.settings.layout.toolbar.skin)
					{
						this.mc.optionPanel.btnSkinProperties._x = optionPanelWidth + (optionPanelWidth == 0 ? 0 : this.OP_SPACER);
						optionPanelWidth += this.mc.optionPanel.btnSkinProperties._width + this.OP_SPACER;
					}
					this.mc.optionPanel.btnSkinProperties._visible = this.settings.layout.toolbar.skin;
					break;
				case 'color':
					if (this.settings.layout.toolbar.color)
					{
						this.mc.optionPanel.colorChooser._x = optionPanelWidth + (optionPanelWidth == 0 ? 0 : this.OP_SPACER);
						optionPanelWidth += this.mc.optionPanel.colorChooser._width + this.OP_SPACER;
					}
					this.mc.optionPanel.colorChooser._visible = this.settings.layout.toolbar.color;
					break;
				case 'save':
					if (this.settings.layout.toolbar.save)
					{
						this.mc.optionPanel.btnSave._x = optionPanelWidth + (optionPanelWidth == 0 ? 0 : this.OP_SPACER);
						optionPanelWidth += this.mc.optionPanel.btnSave._width + this.OP_SPACER;
					}
					this.mc.optionPanel.btnSave._visible = this.settings.layout.toolbar.save;
					break;
				case 'help':
					if (this.settings.layout.toolbar.help)
					{
						this.mc.optionPanel.btnHelp._x = optionPanelWidth + (optionPanelWidth == 0 ? 0 : this.OP_SPACER);
						optionPanelWidth += this.mc.optionPanel.btnHelp._width + this.OP_SPACER;
					}
					this.mc.optionPanel.btnHelp._visible = this.settings.layout.toolbar.help;
					break;
				case 'smilies':
					if (this.settings.layout.toolbar.smilies != 0)
					{
						var trg = null;					
						if(this.settings.layout.toolbar.smilies == 1) 
						{
							trg = this.mc.optionPanel.smileDropDown;
							this.mc.optionPanel.btn_smileDropDown._visible = false;
						}	
						else 
						{
							trg = this.mc.optionPanel.btn_smileDropDown;
							this.mc.optionPanel.smileDropDown._visible = false;
						}	
					
						trg._x = optionPanelWidth + (optionPanelWidth == 0 ? 0 : this.OP_SPACER);
						optionPanelWidth += trg._width + this.OP_SPACER;
					}
					else
					{
						this.mc.optionPanel.smileDropDown._visible = false;
						this.mc.optionPanel.btn_smileDropDown._visible = false;
					}	
						
					this.mc.chatLog.setShowSmilies(this.settings.layout.toolbar.smilies != 0);
					
					//align bold and italic buttons
					this.mc.optionPanel.bold_ib._x = optionPanelWidth + (optionPanelWidth == 0 ? 0 : this.OP_SPACER);
					optionPanelWidth += this.mc.optionPanel.bold_ib._width + this.OP_SPACER;
					
					this.mc.optionPanel.italic_ib._x = optionPanelWidth + (optionPanelWidth == 0 ? 0 : this.OP_SPACER);
					optionPanelWidth += this.mc.optionPanel.italic_ib._width + this.OP_SPACER;
					break;
				case 'clear':
					if (this.settings.layout.toolbar.clear)
					{
						this.mc.optionPanel.btnClear._x = optionPanelWidth + (optionPanelWidth == 0 ? 0 : this.OP_SPACER);
						optionPanelWidth += this.mc.optionPanel.btnClear._width + this.OP_SPACER;
					}
					this.mc.optionPanel.btnClear._visible = this.settings.layout.toolbar.clear;
					break;
				case 'bell':
					if (this.settings.layout.toolbar.bell)
					{
						this.mc.optionPanel.bellLabel._x = optionPanelWidth + (optionPanelWidth == 0 ? 0 : this.OP_SPACER);
						optionPanelWidth += this.mc.optionPanel.bellLabel._width + this.OP_SPACER;
						this.mc.optionPanel.btnBell._x = optionPanelWidth + (optionPanelWidth == 0 ? 0 : this.OP_SPACER);
						this.mc.optionPanel.btnBellIcon._x = this.mc.optionPanel.btnBell._x;
						optionPanelWidth += this.mc.optionPanel.btnBell._width + this.OP_SPACER;
					}
					this.mc.optionPanel.bellLabel._visible = this.settings.layout.toolbar.bell;
					this.mc.optionPanel.btnBell._visible = this.settings.layout.toolbar.bell;
					this.mc.optionPanel.btnBellIcon._visible = this.settings.layout.toolbar.bell;
					break;
			}
		}
	}
	return optionPanelWidth;
};

ChatUI.prototype.isSpecialLanguage = function(inLanguage) {
	var sett = this.settings;
	if(this.settings == null) sett = _level0.ini;
	if(inLanguage == undefined) inLanguage = this.selectedLanguage.id;
		
	for(var itm in sett.special_language)
	{ 
		if(sett.special_language[itm] == inLanguage) return true; 
	}	
	return false;
};

ChatUI.prototype.loadAvatarBG = function(str)
{
	var _arr = str.split('!#@#!');
	
	var imageURL = _arr[0].substr(_arr[0].indexOf('./') + 2);
	var action_type = _arr[1];
	
	switch(action_type)
	{ 
		case '0':
			break;
		case '1':
			break;
		case '2':
			break;
		case '3': case '4':
			if(this.settings.user.skin.id == _global.FlashChatNS.selectedSkin)
			{ 
				this.settings.user.skin.backgroundImage = imageURL;
				this.settings.user.skin.dialogBackgroundImage = imageURL;
			}
			
			this.settings.user.skin.customBg = action_type;
			
			for(var i = 0; i < this.settings.skin.preset.length; i++)
			{
				if(action_type == 4 || this.settings.skin.preset[i].id == _global.FlashChatNS.selectedSkin)
				{
					this.settings.skin.preset[i].backgroundImage = imageURL;
					this.settings.skin.preset[i].dialogBackgroundImage = imageURL;
					if(this.settings.skin.preset[i].id == _global.FlashChatNS.selectedSkin)
					{ 
						this.applyBackground(this.settings.skin.preset[i]);
					}	
				}
			}
			
			break;
	}
};

ChatUI.prototype.loadPhoto = function(str)
{
	if(this.tabbedPropertiesBox != null)
	{
		this.tabbedPropertiesBox.effectsTab.doLoadImage(str);	
	}
};

//---share
ChatUI.prototype.fileShare = function(str)
{
	var _arr = str.split('!#@#!');
	
	var promptBox = this.dialogManager.createDialog('PromptBox');		
	
	promptBox['_shr'] = _arr;
	
	promptBox.setResizable(false);
	promptBox.setLabelTextVisible(true);
	promptBox.setInputTextVisible(false);
	promptBox.setRightButtonVisible(true);
	promptBox.setValidateRightButton(true);
	promptBox.setCloseButtonEnabled(false);
	promptBox.setLeftButtonLabel(this.selectedLanguage.dialog.invitenotify.acceptBtn);
	promptBox.setRightButtonLabel(this.selectedLanguage.dialog.invitenotify.declineBtn);
	promptBox.setLabelText(_arr[0]);
	promptBox.setHandler('onFileShareCompleted', this);
	this.dialogManager.showDialog(promptBox);	
};

ChatUI.prototype.onFileShareCompleted = function(control)
{
	var conf_type = 'flsh_a';
	if (!control.canceled())
	{ 
		var filename = control['_shr'][1];
		filename = filename.split('%').join('%25');
		
		getURL(filename, "_blank");
		conf_type = 'flsh_a';
	}else 
	{
		conf_type = 'flsh_d';
	}	
		
	//---cng1
	if(this.settings.showConfirmation && Number(control['_shr'][3]) > 0) this.listener.confirm(control['_shr'][2], '', conf_type); 
	
	this.setControlsEnabled(true);
	delete control._shr;
	this.dialogManager.releaseDialog(control);
};

ChatUI.prototype.setMainchatAvatar = function(inSmile, inVal)
{
	var obj = this.findSmile('patternIcon', inSmile);
	var str = (inVal)? obj.patternStr : '';
	
	var user = this.getUser(this.selfUserId);
	if(inVal != true) user.setAvatar('mainchat', '');
	else user.setAvatar('mainchat', obj.patternStr);
	
	if(this.settings.layout.showPrivateLog) this.mc.privateLog.changeAvatar(this.selfUserId);
	this.mc.chatLog.changeAvatar(this.selfUserId);
	this.privateBoxManager.setAvatar(this.selfUserId);
};

ChatUI.prototype.setRoomlistAvatar = function(inSmile, inVal)
{
	var user = this.getUser(this.selfUserId);
	var obj = this.findSmile('patternIcon', inSmile);
	
	if(inVal != true) user.setAvatar('room', '');
	else user.setAvatar('room', obj.patternStr);
	
	this.mc.userList.refreshItems();
};

ChatUI.prototype.getModuleHolder = function(inIndex)
{
	var i = inIndex;
	var holder = null;
	if(_level0.ini.module[i].anchor == -1)
		holder = this.mc;
	else if(_level0.ini.module[i].anchor >= 0 && _level0.ini.module[i].anchor <= 4)
		holder = this.mc.userList;	
	else if(_level0.ini.module[i].anchor >= 5 && _level0.ini.module[i].anchor <= 7)
		holder = this.mc;
	else if(_level0.ini.module[i].anchor >= 8 && _level0.ini.module[i].anchor <= 12)
		holder = this.mc.smileTextHolder;
	else if(_level0.ini.module[i].anchor >= 13 && _level0.ini.module[i].anchor <= 14)
		holder = this.mc;
	
		
	return holder;	
};

ChatUI.prototype.createModule = function()
{	
	//trace('Deph ' + this.mc.getInstanceAtDepth( this.mc.txtSelfUserName.getDepth() - 1) );
	//trace('Deph ' + this.mc.getInstanceAtDepth( this.mc.chatLog.getDepth() - 1) );
	
	//module
	for(var i = 0; i < _level0.ini.module.length; i++)
	{
		if(_level0.ini.module[i].path == '' || (_level0.ini.module[i].anchor >= 0 && _level0.ini.module[i].anchor <= 4) ) 
		{
		}
		else
		{
			var modDepth = this.mc.dummy_title_mc.getDepth() + 20*(i+1);//title corners
			var holder   = this.getModuleHolder(i);
			
			if(_level0.ini.module[i].anchor > 7 && _level0.ini.module[i].anchor < 13)
			{
				modDepth = this.mc.chatLog.getDepth() - (i+1);//log list corners
			}	
			
			if(_level0.ini.module[i].anchor == -1) //floating window
			{
				this['modulePane_'+i] = this.dialogManager.createPane('modulePane_'+i);
				this['modulePane_'+i].id = i;
				this['modulePane_'+i].setDockState(true);
				holder['module_'+i] = this['modulePane_'+i].createContentMC('module_'+i, 1);
					
				this['modulePane_'+i].onResizeWindow = function()
				{
					//var dim = this.getSize();
					//_global.FlashChatNS.chatUI.callModuleFunc('mOnModuleWindowResize', {width : dim.width, height : (dim.height - this.dbTop._height - 1)}, this.id);
				};	
			}
			else
			{
				holder['module_'+i] = holder.createEmptyMovieClip('module_'+i, modDepth);
				holder['module_'+i]._x = -10000;
				holder['module_'+i].id = i;
			}
			
			holder['module_'+i].loadMovie(_level0.ini.module[i].path);	
			
			holder.createEmptyMovieClip('module_loader_'+i, modDepth-100*(i+1));
			holder['module_loader_'+i].item = holder['module_'+i];
			holder['module_loader_'+i].shell = this;
			holder['module_loader_'+i].id = i;
			holder['module_loader_'+i].onEnterFrame = function()
			{
				var bloaded = this.item.getBytesLoaded();
				var btotal  = this.item.getBytesTotal();
				
				if(btotal > 10 && bloaded >= btotal) 
				{			
					delete this.onEnterFrame;
					this.onEnterFrame = undefined;
				
					this.item.bWidth  = this.item._width;
					this.item.bHeight = this.item._height;
					
					if(_level0.ini.module[this.id].anchor == -1) 
					{
						this.item.createEmptyMovieClip('mask', 2);
						this.item.mask.drawRect2(0, 0, 1, 1, 0.1, 0xffffff, 100, 0xffffff, 100);
						this.item.setMask(this.item.mask);
					}
						
					this.shell.alignModule(this.id);//realign
					
					removeMovieClip(this);
				}
			}
		}	
	}
};

//***********************************************************************************************************
_global.callChatFunc = function(thetype, args)
{
	var chatUI = _global.FlashChatNS.chatUI;
	if(chatUI.selfUserId == null) return;
	switch( thetype.toLowerCase() )
	{
		case "changeroom" : 
			var room = chatUI.findRoomByLabel(args.room);
			chatUI.listener.moveTo(room.id, args.password);	
		break;
		case "logout" : 
			chatUI.processLogOffButton();	
		break;
		case "alert" : 
			chatUI.alertWindow(args.text);	
		break;
		case "irc" :
			if (args.args == undefined) args.args = '';
			var comm = args.irc + ' ' + args.args;
			if(!chatUI.ircProcessCommand(comm))
			{
				chatUI.listener.sendMessageTo(0, chatUI.selfRoomId, comm);
			}
		break;
		case "admin_irc" :
			if (args.args == undefined) args.args = '';
			var comm = args.irc + ' ' + args.args;
			if(!chatUI.ircProcessCommand(comm, 7))
			{
				chatUI.listener.sendMessageTo(0, chatUI.selfRoomId, comm, '', 7);
			}
		break;
		case "banbyip" : case "ban_ip" : 
			var user = chatUI.findUserByName(args.username);
			var room = this.getRoomForUser(user.id);
			chatUI.listener.banUser(user.id, 3, room.id, args.msg, 7);
		break;
	}
};

ChatUI.prototype.callModuleFunc = function(thetype, args, mod)
{ 	
	var from = 0;
	var to   = _level0.ini.module.length;
	if(mod != -1 && mod != null)
	{
		from = mod;
		to = mod+1;
	}	
	
	//module
	var retval = '';
	for(var i = from; i < to; i++)
	{
		var holder = this.getModuleHolder(i);
		var mod = holder['module_'+i];

		if(mod != undefined)
		{
			if(thetype == 'mOnModuleWindowResize')
			{
				mod.id = i;
				mod.thetype = thetype;
				mod.args = args; 
				delete(mod['loader_'+mod.thetype].onEnterFrame);
				var f = mod.createEmptyMovieClip('loader_'+mod.thetype, mod.getNextHighestDepth());
				f.mod = mod;
				f.cnt = 0;
				f.onEnterFrame = function()
				{
					if(this.mod[this.mod.thetype] != undefined)
						this.mod[this.mod.thetype](this.mod.args);
							
					if(this.cnt++ > 7) 
						delete(this.onEnterFrame);
				}
			}	
			else
			{
				retval = mod[thetype](args);
			}
		}	
	}
	
	if(retval.length != 0) return retval;
};

//*************************************************************************************************************
ChatUI.prototype.alignModule = function(mod)
{	
	var from = 0;
	var to   = _level0.ini.module.length;
	if(mod != -1 && mod != null)
		from = to = mod;
	
	//module
	for(var i = from; i < to; i++)
	{
		var holder = this.getModuleHolder(i);
		var mod = holder['module_'+i];
		
		switch (_level0.ini.module[i].anchor)
		{
			case 5: 
				mod._x = this.mc.titleBG._x;
				mod._y = this.mc.titleBG._y;
				break;
			case 6: 
				mod._x = this.mc.titleBG._x + (this.mc.titleBG._width - mod._width) / 2;
				mod._y = this.mc.titleBG._y;
				break;
			case 7: 
				mod._x = this.mc.logOffBtn._x - mod._width - this.SPACER;
				mod._y = this.mc.titleBG._y;
				break;
			case 8: 
				mod._x = this.mc.chatLog._x;
				mod._y = this.mc.chatLog._y;
				break;
			case 9: 
				mod._x = this.mc.chatLog._x + this.mc.chatLog.width - mod._width;
				mod._y = this.mc.chatLog._y;
				break;
			case 10: 
				mod._x = this.mc.chatLog._x + this.mc.chatLog.width - mod._width;
				mod._y = this.mc.chatLog._y + this.mc.chatLog.height - mod._height;
				break;
			case 11: 
				mod._x = this.mc.chatLog._x;
				mod._y = this.mc.chatLog._y + this.mc.chatLog.height - mod._height;
				break;
			case 12: 
				mod._x = this.mc.chatLog._x + (this.mc.chatLog.width - mod._width) / 2;
				mod._y = this.mc.chatLog._y + (this.mc.chatLog.height - mod._height) / 2;
				break;
			case 13: 
			case 14: 
				var my = (
							_level0.ini.module[i].anchor == 13 || 
							this.inputTextAreaPane.dockState ||
							this.optionPanelPosition == this.OPTIONPANEL_POSITION_TOP
						  )? 
						  this.mc.chatLog._y + this.mc.chatLog.height + this.SPACER : this.inputTextAreaPane._y + this.inputTextAreaPane.dialogHeight;
				mod._x = this.mc.chatLog._x;
				mod._y = my;
				break;
		}
	}	
};
