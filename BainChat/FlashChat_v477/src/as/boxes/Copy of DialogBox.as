#initclip 9

_global.DialogBox = function() {
		
	this.dialogWidth = this._width;
	this.dialogHeight = this._height;
	this._xscale = 100;
	this._yscale = 100;
	
	this.preff_size = new Object({width : 0, height : 0});
	
	this.setSize(this.dialogWidth, this.dialogHeight);
	
	this.resizable = false;
	this.closeButtonEnabled = true;
	this.dialogEnabled = true;
	this.draggable = true;
	this.isResizing = false;

	this.handlerFunctionName = null;
	this.handlerObj = null;
	
	this.mouseDownHandlerFunctionName = null;
	this.mouseDownHandlerObj = null;
	
	this.MoveHandlerFunctionName = null;
	this.MoveHandlerObj = null;
	
	this.mouseUpHandlerFunctionName = null;
	this.mouseUpHandlerObj = null;

	this.style = null;

	this.userData = null;
	
	this.dragframe = this.createEmptyMovieClip('dragframe', 1111);
	
	this.background.attachMovie('Image', 'image', 1);
	
	this.background.image.setHandler('imageLoaded', this);
	
	this.background.createEmptyMovieClip('mask', 2);
	this.background.mask.drawRect2(0, 0, 1, 1, 0.1, 0xffffff, 100, 0xffffff, 100);
	this.background.image.setMask(this.background.mask);
	
	this.background.createEmptyMovieClip('btn_dummy', 0);
	var btn = this.background['btn_dummy'];
	btn._alpha = 0;
	btn.lineStyle(0.1, 0xff0000);
	btn.beginFill(0xff0000);
	btn.moveTo(0, 0);
	btn.lineTo(100, 0);
	btn.lineTo(100, 100);
	btn.lineTo(0, 100);
	btn.lineTo(0, 0);
	btn.endFill();
	btn.useHandCursor = false;
	//empty handler that converts movie clip into button.
	btn.onRelease = function() {};

	this.createEmptyMovieClip('border', 1);
	
	//hide minimize button
	this.minButtonVisible = false;
	this.blink_id = null;
	
	this.resizeBackground();
};

_global.DialogBox.prototype = new MovieClip();

_global.DialogBox.prototype.BOTTOM_RIGHT_HIT_AREA = 12;
_global.DialogBox.prototype.DRAG_FRAME_COLOR      = 0x000000;
_global.DialogBox.prototype.DRAG_FRAME_THICKNESS  = 2;
//PUBLIC METHODS.

_global.DialogBox.prototype.setHandler = function(inHandlerFunctionName, inHandlerObj) {
	this.handlerFunctionName = inHandlerFunctionName;
	this.handlerObj = inHandlerObj;
};

_global.DialogBox.prototype.setMouseDownHandler = function(inMouseDownHandlerFunctionName, inMouseDownHandlerObj) {
	this.mouseDownHandlerFunctionName = inMouseDownHandlerFunctionName;
	this.mouseDownHandlerObj = inMouseDownHandlerObj;
};

_global.DialogBox.prototype.setMouseUpHandler = function(inMouseUpHandlerFunctionName, inMouseUpHandlerObj) {
	this.mouseUpHandlerFunctionName = inMouseUpHandlerFunctionName;
	this.mouseUpHandlerObj = inMouseUpHandlerObj;
};

_global.DialogBox.prototype.setMoveHandler = function(inMoveHandlerFunctionName, inMoveHandlerObj) {
	this.MoveHandlerFunctionName = inMoveHandlerFunctionName;
	this.MoveHandlerObj = inMoveHandlerObj;
};

_global.DialogBox.prototype.getSize = function() {
	var dimensions = new Object();
	dimensions.width = this.dialogWidth;
	dimensions.height = this.dialogHeight;
	return dimensions;
};

_global.DialogBox.prototype.setSize = function(inWidth, inHeight) {
	if(inWidth == undefined || inHeight == undefined) return;
	
	if (inWidth < 50) {
		inWidth = 50;
	}
	if (inHeight < this.dbLeft._y) {
		inHeight = this.dbLeft._y;
	}
	
	if(this.preff_size.width == 0) this.preff_size.width  = 50;
	if(this.preff_size.height == 0) this.preff_size.height = this.dbLeft._y;
		
	this.dialogWidth = inWidth;
	this.dialogHeight = inHeight;
	this.dbTop._x = this.dbLeft._width;
	
	if(!this.minButtonVisible)
	{ 
		this.dbTop._width = this.dialogWidth - this.dbLeft._width - this.dbRight._width;
		this.dbTopRight._x = this.dbTop._x + this.dbTop._width;
	}
	else
	{ 
		this.dbTop._width = this.dialogWidth - this.dbLeft._width - this.dbRight._width - this.dbMinTopRight._width + 1;
		this.dbMinTopRight._x = this.dbTop._x + this.dbTop._width - 1;
		this.dbTopRight._x =  this.dbMinTopRight._x + this.dbMinTopRight._width;
	}
	
	this.dbLeft._y = this.dbTop._height;
	this.dbLeft._height = this.dialogHeight - this.dbTop._height - this.dbBottomLeft._height + 0.5;

	this.dbCenter._x = this.dbLeft._width;
	this.dbCenter._y = this.dbTop._height;
	this.dbCenter._width = this.dialogWidth - this.dbLeft._width - this.dbRight._width;
	this.dbCenter._height = this.dialogHeight - this.dbTop._height - this.dbBottom._height;

	this.dbRight._x = this.dialogWidth - this.dbRight._width;
	this.dbRight._y = this.dbTopRight._height;
	this.dbRight._height = this.dialogHeight - this.dbTopRight._height - this.dbBottomRight._height + 0.5;
	
	this.dbBottomLeft._y = this.dialogHeight - this.dbBottomLeft._height;

	this.dbBottom._y = this.dialogHeight - this.dbBottom._height;
	this.dbBottom._width = this.dialogWidth - this.dbBottomLeft._width - this.dbBottomRight._width;

	this.dbBottomRight._x = this.dialogWidth - this.dbBottomRight._width;
	this.dbBottomRight._y = this.dialogHeight - this.dbBottomRight._height;

	this.drawBorder();

	this.resizeBackground();
};

_global.DialogBox.prototype.setEnabled = function(inDialogEnabled) {
	this.dialogEnabled = inDialogEnabled;
	this.setCloseButtonEnabled(this.closeButtonEnabled);
};

_global.DialogBox.prototype.getEnabled = function() {
	return this.dialogEnabled;
};

_global.DialogBox.prototype.setDraggable = function(inDraggable) {
	this.draggable = inDraggable;
};

_global.DialogBox.prototype.setResizable = function(inResizable) {
	this.resizable = inResizable;
};

_global.DialogBox.prototype.setCloseButtonEnabled = function(inEnabled) {
	this.closeButtonEnabled = inEnabled;
	this.dbTopRight.trBtn.btnClose.setEnabled(this.closeButtonEnabled && this.dialogEnabled);
};

_global.DialogBox.prototype.setUserData = function(inUserData) {
	this.userData = inUserData;
};

_global.DialogBox.prototype.getUserData = function() {
	return this.userData;
};

_global.DialogBox.prototype.initialized = function() {
	return (this.dbTopRight.trBtn.btnClose.setEnabled != null && _global.FlashChatNS.BigSkin_Loaded);
};

_global.DialogBox.prototype.applyStyle = function(inStyle) {
	this.style = inStyle;

	this.setMCColor(this.dbTopLeft, this.style.dialogTitle);
	this.setMCColor(this.dbTop, this.style.dialogTitle);
	this.setMCColor(this.dbTopRight.bkg, this.style.dialogTitle);
	this.setMCColor(this.dbMinTopRight.bkg, this.style.dialogTitle);
	this.setMCColor(this.dbLeft, this.style.dialog);
	this.setMCColor(this.dbCenter, this.style.dialog);
	this.setMCColor(this.dbRight, this.style.dialog);
	this.setMCColor(this.dbBottomLeft, this.style.dialog);
	this.setMCColor(this.dbBottom, this.style.dialog);
	this.setMCColor(this.dbBottomRight, this.style.dialog);
	
	this.drawBorder();

	this.applyBackground(this.style);
};

_global.DialogBox.prototype.applyBackground = function(inStyle) {
	this.style = inStyle;
	this.applyCustomBackground(this.style.dialogBackgroundImage);
};

_global.DialogBox.prototype.applyCustomBackground = function(inImageURL) {
	if (!this.style.showBackgroundImages || (inImageURL == null) || (inImageURL == '')) {
		this.background.image.clear();
	} else {
		this.background.image.loadImage(inImageURL);
	}
};

//PRIVATE METHODS.

_global.DialogBox.prototype.drawBorder = function() {
	var x1 = this.dbBottomRight._x, y1 = this.dbBottomRight._y;
	var x2 = width = x1 + this.dbBottomRight._width;
	var y2 = height = y1 + this.dbBottomRight._height;
		
	//hiding title according to login settings as in config.php
	var dbBorderTop=0;
	if((_level0.ini.login.title=='false') and (this.dialog_name == 'loginbox'))
	{
		dbBorderTop = this.dbTop._height;
	}
	//hiding title according to login settings as in config.php ends here	
	this.border.clear();
	this.border.lineStyle(1, this.style.dialogBrighter, 100);
	this.border.moveTo(0, height);
	this.border.lineTo(0, dbBorderTop);
	this.border.lineTo(width, dbBorderTop);
	this.border.lineStyle(2, this.style.dialogDarker, 100);
	this.border.moveTo(width, dbBorderTop+1);
	this.border.lineTo(width, height);
	this.border.lineTo(1, height);
	
	//paint resizable corner
	if (this.resizable) {
		
		var line = { 
					c0 : this.style.dialogBrighter, 
					c1 : this.style.dialogDarker, 
					c2 : this.style.dialogDarker, 
					c3 : this.style.dialog
				};
		
		var x, y;
		
		for(var i = 12; i > 0; i--)
		{
			x = (x2 - 2.5) - i;
			y = (y2 - 3) + (i - 12);
			this.border.moveTo(x, y);
			for(var j = 0; j < i; j++)
			{
				var alpha = 100;
				if((j%4) == 3 || j == 3) alpha = 0;
				
				if(j > 3) this.border.lineStyle(1, line["c" + (j%4)], alpha);
				else this.border.lineStyle(1, line["c" + j], alpha);
				
				if(j < (i-1))
				{ 
					this.border.lineTo(x + j + 0.5, y);	
					this.border.moveTo(x + j + 1, y);
				}
				else
				{
					this.border.lineTo(x + j + 0.5, y);	
					this.border.moveTo(x + j + 0.5, y);
				}
			}
		}
	}
};

_global.DialogBox.prototype.setMCColor = function(inMC, inColor) {
	var c = new Color(inMC);
	c.setRGB(inColor);
};

_global.DialogBox.prototype.imageLoaded = function()
{
	_global.FlashChatNS.chatUI.resizeImageBG(this.background.image);	
};

_global.DialogBox.prototype.resizeBackground = function() {
	this.background.mask._width = this.dbRight._x + this.dbRight._width;
	this.background.mask._height = this.dbBottom._y + this.dbBottom._height - this.dbCenter._y;
	
	this.background['btn_dummy']._y = - this.dbCenter._y;
	this.background['btn_dummy']._width = this.background.mask._width;
	this.background['btn_dummy']._height = this.dbBottom._y + this.dbBottom._height;
};

_global.DialogBox.prototype.initializeDialog = function() {
	this.dbTopRight.trBtn.btnClose.setEnabled(this.closeButtonEnabled);
	this.dbTopRight.trBtn.btnClose.setClickHandler('onClose', this);
};

_global.DialogBox.prototype.sendToFront = function() {
	//send to front
	var depth = this.getDepth();
	if(depth != this._parent.currentDepth)
	{ 
		if(depth < 4 && this._parent.getInstanceAtDepth(this._parent.currentDepth) != undefined)
		{
			this._parent.currentDepth++;
			this._parent.depthHash[this._parent.currentDepth] = true;
			this._parent.currentDepth++;
			this._parent.depthHash[this._parent.currentDepth] = true;
		}
		
		this.swapDepths(this._parent.currentDepth);
	}
};

_global.DialogBox.prototype.onMouseDown = function() {
	if (!this.dialogEnabled) {
		return;
	}
	
	var left_x = this.dbTopRight._x;
	if(this.minButtonVisible) left_x = this.dbMinTopRight._x;
	
	if ((this._xmouse >= 0) &&
		(this._xmouse <= left_x) &&
		(this._ymouse >= 0) &&
		(this._ymouse <= this.dbLeft._y) &&
		(this.dockState != false))
	{
		this.sendToFront();
		
		if (this.draggable) {
			//old version of dragging
			//this.startDrag(false);
			
			//new version
			this.dragframe.onMouseUp = function()
			{
				var parent = this._parent;
				
				var point = { x : this._x, y : this._y};
				parent.localToGlobal(point);
				
				this.stopDrag();
				
				parent._x = point.x;
				parent._y = point.y;
				
				this._x = 0;
				this._y = 0;
				
				parent.onMouseUp();
				
				this.clear();
				delete(this.onMouseUp);
			}
			
			this.dragframe._visible = true;
			this.dragframe.drawRect2(0, 0, this.dialogWidth, this.dialogHeight, this.DRAG_FRAME_THICKNESS, this.DRAG_FRAME_COLOR, 100);
			this.dragframe.startDrag(false);
			
			this.onEnterFrame = function()
			{
				this.MoveHandlerObj[this.MoveHandlerFunctionName](this);
			}
		}
	}
	
	if (this.resizable && this.bottomRightHit(this._xmouse, this._ymouse)) {
		this.isResizing = true;
	}
	if (this.getEnabled() && (this.mouseDownHandlerObj != null)) {
		this.mouseDownHandlerObj[this.mouseDownHandlerFunctionName](this);
	}
};

_global.DialogBox.prototype.onMouseUp = function() {
	this.isResizing = false;
	//old version of dragging
	//this.stopDrag();
	
	delete (this.onEnterFrame);
	
	this.mouseUpHandlerObj[this.mouseUpHandlerFunctionName](this);
	
	//fix dialog position in the end of dragging so that title bar is always visible.
	if (this._x + this.dialogWidth - this.dbTopRight._width < 10) {
		this._x = 10 - this.dialogWidth + this.dbTopRight._width;
	}
	if (this._x + 10 > Stage.width) {
		this._x = Stage.width - 10;
	}
	if (this._y < 0) {
		this._y = 0;
	}
	if (this._y + 10 > Stage.height) {
		this._y = Stage.height - 10;
	}
};

_global.DialogBox.prototype.onMouseMove = function() {
	this.background['btn_dummy'].useHandCursor = false;
	if (!this.dialogEnabled) {
		return;
	}
	if (this.resizable) {
		if (this.bottomRightHit(this._xmouse, this._ymouse)) {
			this.background['btn_dummy'].useHandCursor = true;
		}
		if (this.isResizing) {
			
			this.dragframe.onMouseUp = function()
			{
				this._parent.onMouseUp();
				
				this._parent.setSize(this._xmouse, this._ymouse);	
				
				this._x = 0;
				this._y = 0;
				
				this._parent.onResizeWindow();
				
				this.clear();
				delete(this.onMouseUp);
			}
			
			this.dragframe._visible = true;	
			this.dragframe.clear();
			
			var dim = new Object({w : this._xmouse, h : this._ymouse});
			if(this._xmouse < this.preff_size.width)  dim.w = this.preff_size.width;
			if(this._ymouse < this.preff_size.height) dim.h = this.preff_size.height;
			
			this.dragframe.drawRect2(0, 0, dim.w, dim.h, this.DRAG_FRAME_THICKNESS, this.DRAG_FRAME_COLOR, 100);
		}
	}
};

_global.DialogBox.prototype.bottomRightHit = function(inX, inY) {
	if ((inX >= this.dialogWidth - this.BOTTOM_RIGHT_HIT_AREA) &&
		(inX <= this.dialogWidth) &&
		(inY >= this.dialogHeight - this.BOTTOM_RIGHT_HIT_AREA) &&
		(inY <= this.dialogHeight)) {
		return true;
	}
	return false;
};

_global.DialogBox.prototype.dumpMC = function(inMC) {
	trace('mc[' + inMC._name + ']: ' + inMC._x + ',' + inMC._y + ',' + inMC._width + ',' + inMC._height);
};

_global.DialogBox.prototype.startBlinking = function()
{
	if(this.blink_id == null)
	{ 
		clearInterval( this.blink_id );
		this.blink_id = setInterval(this, 'blink', 50, this);
	}	
};

_global.DialogBox.prototype.blink = function( trg )
{
	var step = trg.blink_idx ? 10 : -10;
	trg.setTitleAlpha( trg.dbTopLeft._alpha + step);
	
	if(trg.dbTopLeft._alpha <= 20) trg.blink_idx = true; 
	else if(trg.dbTopLeft._alpha >= 100) trg.blink_idx = false;
};

_global.DialogBox.prototype.stopBlinking = function()
{
	clearInterval( this.blink_id );
	this.blink_id = null;
	this.setTitleAlpha( 100 );
};

_global.DialogBox.prototype.setTitleAlpha = function ( inAlpha )
{
	this.dbTopLeft._alpha = inAlpha;
	this.dbTop._alpha = inAlpha;
	this.dbTopRight.bkg._alpha = inAlpha;
	this.dbMinTopRight.bkg._alpha = inAlpha;
}

//Object.registerClass('DialogBox', _global.DialogBox);

#endinitclip
