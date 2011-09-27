#initclip 2

function FPushButtonClass()
{
	this.init();
}

FPushButtonClass.prototype = new FUIComponentClass();
Object.registerClass("FPushButtonSymbol", FPushButtonClass);

FPushButtonClass.prototype.init = function()
{
	super.setSize(this._width,this._height);
	this.boundingBox_mc.unloadMovie();
	this.attachMovie("fpb_states","fpbState_mc",1);
	this.attachMovie("FLabelSymbol","fLabel_mc",2);
	this.attachMovie("fpb_hitArea","fpb_hitArea_mc",3);
	super.init();
	
	this.setClickHandler(this.clickHandler);
	this.setType(this.btnType);
	
	this.btnState = false;
	this.value = false;
	this.toggle = false;
	
	//handle when we need to redraw skin of component
	this.drawSkin = this.drawFrame;
	
	this.icon_scale = 0.5;
	this._xscale = 100;
	this._yscale = 100;
	
	this.setSize(this.width,this.height);
	if(this.label != undefined)this.setLabel(this.label);
	// ACCESSIBILITY DEFINED ::o:: _accImpl object defined in base class ::o::
		this.ROLE_SYSTEM_PUSHBUTTON  = 0x2b;
		this.STATE_SYSTEM_PRESSED  = 0x00000008;
		this.EVENT_OBJECT_STATECHANGE = 0x800a;
		this.EVENT_OBJECT_NAMECHANGE = 0x800c;
		this._accImpl.master = this;
		this._accImpl.stub = false;
		this._accImpl.get_accRole = this.get_accRole;
		this._accImpl.get_accName = this.get_accName;	
		this._accImpl.get_accState = this.get_accState;
		this._accImpl.get_accDefaultAction = this.get_accDefaultAction;
		this._accImpl.accDoDefaultAction = this.accDoDefaultAction;
}

FPushButtonClass.prototype.setHitArea = function(w,h)
{	
	var hit = this.fpb_hitArea_mc;
	this.hitArea = hit;
	hit._visible = false;
	hit._width = w;
	hit._height = (arguments.length > 1) ? h : hit._height;
}

FPushButtonClass.prototype.setSize = function(w,h)
{
	w = (w == undefined) ? 0 : w;
	h = (h == undefined) ? 0 : h;
	w = (w < 6) ? 6 : w;
	
	if (arguments.length >1){
		if (h < 6){
			h = 6;
		}
	}
	
	super.setSize(w,h);
	
	this.setLabel(this.getLabel());
	this.arrangeLabel();

	this.setHitArea(this.width,this.height);
	this.boundingBox_mc._width = this.width;
	this.boundingBox_mc._height = this.height;
	
	this.drawFrame();
	
	if(this.focused)super.myOnSetFocus();
	this.initContentPos("fLabel_mc");
}

FPushButtonClass.prototype.arrangeLabel = function()
{
	var label = this.fLabel_mc;
	var h = this.height;
	var w = this.width-2;
	var b = 1; // frame border width 
	this.fLabel_mc.setSize(w - (b * 4));
	label._x = (b * 3);//padding value;
	label._y = ( (h-label._height)/2);
}

FPushButtonClass.prototype.getLabel = function()
{
	return (this.fLabel_mc.labelField.text);
}

FPushButtonClass.prototype.setLabel = function(label)
{
	if(label.toUpperCase() == 'X' && this.btnType == this.BTN_TYPE_CLOSE || this.icon_mc != undefined) this.fLabel_mc._visible = false;
	else this.fLabel_mc._visible = true;
	
	this.fLabel_mc.setLabel(label);
	this.txtFormat();
	this.arrangeLabel()
	
	// ACCESSIBILITY EVENT
	if (Accessibility.isActive()){
		Accessibility.sendEvent( this, 0, this.EVENT_OBJECT_NAMECHANGE );
	}
}

FPushButtonClass.prototype.getEnabled = function()
{
	return(this.enabled);
}
	
FPushButtonClass.prototype.setEnabled = function(enable)
{
	if ( enable || enable == undefined ) {
		this.gotoFrame(1);
		this.drawFrame();
		this.fLabel_mc.setEnabled(true);
		super.setEnabled(true);
		this.enabled = true;
	} else {
		this.gotoFrame(4);
		this.drawFrame();
		this.fLabel_mc.setEnabled(false);
		super.setEnabled(false);
		this.enabled = false;
	}
}

FPushButtonClass.prototype.txtFormat = function()
{
	var txtS = this.textStyle;
	var sTbl = this.styleTable;
	
	txtS.align = (sTbl.textAlign.value == undefined) ? txtS.align = "center" : undefined;
	txtS.leftMargin = (sTbl.textLeftMargin.value == undefined) ? txtS.leftMargin = 1 : undefined;
	txtS.rightMargin = (sTbl.textRightMargin.value == undefined) ? txtS.rightMargin = 1 : undefined
	
	var dim = testText(this.fLabel_mc.labelField, this.fLabel_mc.labelField.text);
	if(this.preset_width == undefined) this.preset_width = this.width;
	var w = (this.width > (dim.width + 8))? Math.max(this.preset_width, dim.width + 8) : dim.width + 8;
	
	if(this.btnType == this.BTN_TYPE_HFREEZE)
	{ 
		this.superSetSize(w, this.height);
	}
	else	if(this.btnType == this.BTN_TYPE_WFREEZE)
	{ 
		this.superSetSize(this.width, this.fLabel_mc._height + 2);
	}
	else if(this.fLabel_mc._height > (this.height / 2) && 
		    (this.btnType == this.BTN_TYPE_NORMAL ||
		     (this.fLabel_mc.labelField.text.toUpperCase() != 'X' && 
		     this.fLabel_mc.labelField.text.toUpperCase() != ''  && 
		     this.btnType == this.BTN_TYPE_CLOSE)
		    )
		  )
	{
		this.superSetSize(w, this.fLabel_mc._height + 2);
	}
	else	this.superSetSize(this.width, this.height);
	
	this.fLabel_mc.labelField.setTextFormat(this.textStyle);
	this.setEnabled(this.enable);
}

FPushButtonClass.prototype.superSetSize = function(w, h)
{
	if((w-h) < 0) super.setSize(h, h);
	else super.setSize(w, h);
}

FPushButtonClass.prototype.setType = function(inType)
{
	this.type = this.btnType = inType;
	switch(this.btnType)
	{ 
		case this.BTN_TYPE_HIDE : 
			this._face        = "faceMin";
			this._face_press  = "faceMin_press";
			this._highlight   = "highlightMin";
			this._highlight3D = "highlight3DMin";
			this._shadow      = "shadowMin";
			this._darkshadow  = "darkshadowMin";
			
			//aqua
			this._base = "faceMin";
			this._base2 = "highlightMin";
		break;
		case this.BTN_TYPE_CLOSE : 
			this._face        = "faceClose";
			this._face_press  = "faceClose_press";
			this._highlight   = "highlightClose";
			this._highlight3D = "highlight3DClose";
			this._shadow      = "shadowClose";
			this._darkshadow  = "darkshadowClose";
			
			//aqua
			this._base = "faceClose";
			this._base2 = "highlightClose";
		break;
		default :
			this.initSkinVars();
		break;
	}
	
	this.drawFrame();
}

FPushButtonClass.prototype.setIcon = function(inLink)
{
	this.icon_mc = this.attachMovie(inLink, 'icon_mc', this.getNextHighestDepth());
	this.setLabel('B');
	this.fLabel_mc._visible = false;
}

FPushButtonClass.prototype.getIcon = function()
{
	return (this.icon_mc);
}

FPushButtonClass.prototype.setToggle = function(val)
{
	this.toggle = val;
}

FPushButtonClass.prototype.setValue = function(val)
{
	this.value = val;
	this.setBtnState(val);
}

FPushButtonClass.prototype.getValue = function()
{
	return (this.value);
}

FPushButtonClass.prototype.drawFrame = function ()
{	
	var mc_array = ["up_mc","over_mc","down_mc","disabled_mc"];
	var frame = mc_array[(this.fpbState_mc._currentframe) - 1];
	
	this.fpbState_mc[frame].gotoAndStop(this.getSkinFrame());
	this.fpbState_mc[frame].clear();
	
	if(this.btnType != this.BTN_TYPE_CLOSE || this.btnType != this.BTN_TYPE_HIDE) 
	{ 
		this.fpbState_mc[frame]['close_mc']._visible = false;
		this.fpbState_mc[frame]['close_mc']._x = this.fpbState_mc[frame]['close_mc']._y = 0;
		this.fpbState_mc[frame]['close_mc']._width = this.fpbState_mc[frame]['close_mc']._height = 0;
	}
	
	var t = '';
	switch(frame)
	{ 
		case 'up_mc'       : t = this.STATE_OUT; break;
		case 'over_mc'     : t = this.STATE_OVER; break;
		case 'down_mc'     : t = this.STATE_PRESS; break;
		case 'disabled_mc' : t = this.STATE_DISABLED; break;
	}
	
	var data = {type : this.btnType, mode : t, pLink : this};
	
	this.fpbState_mc[frame].mc.clear();
	this.fpbState_mc[frame].mask.removeMovieClip();
	
	switch (this.getSkinFrame())
	{
		case 1  : this.drawDeafaultFrame(this.fpbState_mc[frame]); break;
		case 2  : this.drawXPFrame(this.fpbState_mc[frame], data); break;
		case 3  : this.drawGradientFrame(this.fpbState_mc[frame]); break;
		case 4  : this.drawAquaFrame(this.fpbState_mc[frame], data); break;
		default : this.drawDefaultFrame(this.fpbState_mc[frame]); break;
	};
}

FPushButtonClass.prototype.setIconSizeNPos = function(inObj, inObj2)
{
	if(this.icon_mc != undefined)
	{
		var hObj = (inObj2 == undefined)? inObj : inObj2;
		
		this.icon_mc._height = hObj._height * this.icon_scale;
		this.icon_mc._width  = inObj._width * this.icon_scale;
		
		this.icon_mc._x = inObj._x + (inObj._width - this.icon_mc._width)/2;
		this.icon_mc._y = hObj._y + (hObj._height - this.icon_mc._height)/2;
		
		this.initIconPos('icon_mc');
		this.setBtnState();	
	}
	
}

FPushButtonClass.prototype.setCloseMinSizeNPos = function(inObj, inPerc, inObj2)
{
	if(this.btnType == this.BTN_TYPE_CLOSE || this.btnType == this.BTN_TYPE_HIDE)  
	{ 
		inObj._parent['close_mc']._visible = true;
		if(this.btnType == this.BTN_TYPE_CLOSE) 
		{ 
			inObj._parent['close_mc']['min_icon']._visible = false;
			inObj._parent['close_mc']['close_icon']._visible = (this.getLabel().toUpperCase() == 'X' || this.getLabel() == '')? true : false;
		}
		else 
		{ 
			inObj._parent['close_mc']['close_icon']._visible = false;
			inObj._parent['close_mc']['min_icon']._visible = true;
		}
		
		var hObj = (inObj2 == undefined)? inObj : inObj2;
		
		inObj._parent['close_mc']._width  = inObj._width * inPerc;
		inObj._parent['close_mc']._height = hObj._height * inPerc;
		inObj._parent['close_mc']._x = inObj._x + (inObj._width - inObj._parent['close_mc']._width)/2;
		inObj._parent['close_mc']._y = hObj._y + (hObj._height - inObj._parent['close_mc']._height)/2;
	}	
}

FPushButtonClass.prototype.drawDeafaultFrame = function(btnObj)
{
	var b = 1; // border width of frame;
	var x1 = 0;
	var y1 = 0;
	var x2 = this.width;
	var y2 = this.height;
	
	var mc = "frame";
	
	for (var i =0;i<6; i++){
	 	x1 += ((i)%2)*b;
	 	y1 += ((i)%2)*b;
	 	x2 -= ((i+1)%2)*b;
	 	y2 -= ((i+1)%2)*b;
	 	var w = Math.abs (x1 - x2)+2*b;
		var h = Math.abs (y1 - y2)+2*b;
		btnObj[mc+i]._width = w;
		btnObj[mc+i]._height = h;
		btnObj[mc+i]._x = x1-b;
		btnObj[mc+i]._y = y1-b;
	}
	
	this.setCloseMinSizeNPos(btnObj[mc+5], 0.75);
	this.setIconSizeNPos(btnObj[mc+5]);
}

FPushButtonClass.prototype.drawXPFrame = function(btnObj, data)
{ 
	_global.xpLook.draw(btnObj, this.width - 0.5, this.height - 0.5, data);
	
	var obj = {_x : 0, _y : 0, _width : this.width, _height : this.height};
	this.setIconSizeNPos(obj);
	
	if(this.getLabel().toUpperCase() != 'X' && this.getLabel() != '') btnObj.mc.clear();
	
	return;
}

FPushButtonClass.prototype.drawGradientFrame = function(btnObj)
{ 
	var r1 = 5, r2 = 3; 
	
	//------------------------------------------------------------------------------------------------------//
	btnObj['aq_tl_round_mc']._width  = btnObj['aq_tr_round_mc']._width  = r1;
	btnObj['aq_bl_round_mc']._width  = btnObj['aq_br_round_mc']._width  = r1;
	btnObj['aq_tl_round_mc']._height = btnObj['aq_tr_round_mc']._height = r1;
	btnObj['aq_bl_round_mc']._height = btnObj['aq_br_round_mc']._height = r1;
	
	btnObj['aq_tl_round_mc']._x = 0;               btnObj['aq_tl_round_mc']._y = 0;
	btnObj['aq_tr_round_mc']._x = this.width - r1; btnObj['aq_tr_round_mc']._y = 0;
	btnObj['aq_bl_round_mc']._x = 0;               btnObj['aq_bl_round_mc']._y = this.height - r1;
	btnObj['aq_br_round_mc']._x = this.width - r1; btnObj['aq_br_round_mc']._y = this.height - r1;
	//------------------------------------------------------------------------------------------------------//
	btnObj['l_border_mc']._width  = btnObj['r_border_mc']._width = (r1 - r2);
	btnObj['l_border_mc']._height = btnObj['r_border_mc']._height = this.height - 2*r1;
	
	btnObj['l_border_mc']._x = 0; 
	btnObj['l_border_mc']._y = r1;
	btnObj['r_border_mc']._x = this.width - (r1 - r2); 
	btnObj['r_border_mc']._y = r1;
	//------------------------------------------------------------------------------------------------------//
	btnObj['t_border_mc']._width  = btnObj['b_border_mc']._width = this.width - 2*r1;
	btnObj['t_border_mc']._height = btnObj['b_border_mc']._height = (r1 - r2);
	
	btnObj['t_border_mc']._x = r1; 
	btnObj['t_border_mc']._y = 0;
	btnObj['b_border_mc']._x = r1; 
	btnObj['b_border_mc']._y = this.height - (r1 - r2);
	//------------------------------------------------------------------------------------------------------//
	btnObj['grad_middle_mc']._width  = this.width - 2*(r1 - r2);
	btnObj['grad_middle_mc']._height = this.height - 2*(r1 - r2);
	
	btnObj['grad_middle_mc']._x = (r1 - r2); 
	btnObj['grad_middle_mc']._y = (r1 - r2);
	//------------------------------------------------------------------------------------------------------//
	
	this.setCloseMinSizeNPos(btnObj['grad_middle_mc'], 0.6);
	this.setIconSizeNPos(btnObj['grad_middle_mc']);
}

FPushButtonClass.prototype.drawAquaFrame = function(btnObj, data)
{ 
	_global.aquaLook.draw(btnObj, this.width, this.height, data);
	
	var obj = {_x : 0, _y : 0, _width : this.width, _height : this.height};
	this.setIconSizeNPos(obj);
	
	if(this.getLabel().toUpperCase() != 'X' && this.getLabel() != '') btnObj.mc.clear();
}


FPushButtonClass.prototype.setClickHandler = function(chng,obj)
{
	this.handlerObj = (arguments.length<2) ? this._parent : obj;
	this.clickHandler = chng;
}

FPushButtonClass.prototype.executeCallBack = function()
{
	this.handlerObj[this.clickHandler](this);
}

FPushButtonClass.prototype.initContentPos = function (mc) 
{
	this.incrVal = 1; // DISTANCE TEXT SHIFTS DOWN AND RIGHT ::mr::
	this.initx = this[mc]._x - (this.getBtnState())*this.incrVal;
	this.inity = this[mc]._y - (this.getBtnState())*this.incrVal;
	this.togx = this.initx + this.incrVal;
	this.togy = this.inity + this.incrVal;
}

FPushButtonClass.prototype.initIconPos = function(mc)
{
	this.incrVal = 1; // DISTANCE TEXT SHIFTS DOWN AND RIGHT ::mr::
	this.icon_initx = this[mc]._x;
	this.icon_inity = this[mc]._y;
	this.icon_togx = this.icon_initx + this.incrVal;
	this.icon_togy = this.icon_inity + this.incrVal;
}

FPushButtonClass.prototype.setBtnState = function (state) 
{
	if(state != undefined) this.btnState = state;
	if (this.btnState) {
		this.fLabel_mc._x = this.togx;
		this.fLabel_mc._y = this.togy;
		
		if(this.icon_mc != undefined)
		{ 
			this.icon_mc._x = this.icon_togx;
			this.icon_mc._y = this.icon_togy;
		}
	}else{
		this.fLabel_mc._x = this.initx;
		this.fLabel_mc._y = this.inity;
		
		if(this.icon_mc != undefined)
		{ 
			this.icon_mc._x = this.icon_initx;
			this.icon_mc._y = this.icon_inity;
		}
	}
	
	if(state != undefined) 
	{
		this.fpbState_mc.gotoAndStop(1);
		this.drawFrame();
		//this.onRollOver();
	}	
}

FPushButtonClass.prototype.getBtnState = function () 
{
	return this.btnState;
}

FPushButtonClass.prototype.myOnSetFocus = function()
{
	this.focused = true;
	super.myOnSetFocus()
}

FPushButtonClass.prototype.onPress = function ()
{
	this.value = !this.value;
	
	this.pressFocus();
	this.fpbState_mc.gotoAndStop(3);
	this.drawFrame();
	this.setBtnState(true);
	
	// ACCESSIBILITY EVENT
	if (Accessibility.isActive()){
		Accessibility.sendEvent( this, 0, this.EVENT_OBJECT_STATECHANGE,true );
	}
}

FPushButtonClass.prototype.onRelease = function ()
{
	var toDo = this.value && this.toggle;
	this.fpbState_mc.gotoAndStop((toDo)? 3 : 2);
	this.drawFrame();
	this.executeCallBack();
	this.setBtnState(toDo);
	
	// ACCESSIBILITY EVENT
	if (Accessibility.isActive()){
		Accessibility.sendEvent( this, 0, this.EVENT_OBJECT_STATECHANGE,true );
	}
}

FPushButtonClass.prototype.onRollOver = function ()
{
	this.fpbState_mc.gotoAndStop((this.value && this.toggle)? 3 : 2);
	this.drawFrame();
}

FPushButtonClass.prototype.onRollOut = function ()
{
	this.fpbState_mc.gotoAndStop((this.value && this.toggle)? 3 : 1);
	this.drawFrame();	
}

FPushButtonClass.prototype.onReleaseOutside = function ()
{	
	this.setBtnState(this.value && this.toggle);
	this.fpbState_mc.gotoAndStop((this.value && this.toggle)? 3 : 1);
	this.drawFrame();	
}

FPushButtonClass.prototype.onDragOut = function ()
{	
	this.setBtnState(this.value && this.toggle);
	this.fpbState_mc.gotoAndStop((this.value && this.toggle)? 3 : 1);
	this.drawFrame();	
}

FPushButtonClass.prototype.onDragOver = function ()
{	
	this.setBtnState(true);
	this.fpbState_mc.gotoAndStop(3);
	this.drawFrame();	
}

FPushButtonClass.prototype.myOnKeyDown = function( )
{
	if (Key.getCode() == Key.SPACE && this.pressOnce == undefined ) {
		this.onPress();
		this.pressOnce = 1;
	}
}

FPushButtonClass.prototype.myOnKeyUp = function( )
{
	if (Key.getCode() == Key.SPACE) {
		this.onRelease();
		this.pressOnce = undefined;
	}
}



// START ACCESSIBILITY METHODS
FPushButtonClass.prototype.get_accRole = function(childId)
{
	return this.master.ROLE_SYSTEM_PUSHBUTTON;
}

FPushButtonClass.prototype.get_accName = function(childId)
{
	return this.master.getLabel();
}

FPushButtonClass.prototype.get_accState = function(childId)
{
	if(this.pressOnce){
		return this.master.STATE_SYSTEM_PRESSED;
	}else{
		return this.master.STATE_SYSTEM_DEFAULT;
	}
}

FPushButtonClass.prototype.get_accDefaultAction = function(childId)
{
	return "Press";
}

FPushButtonClass.prototype.accDoDefaultAction = function(childId)
{
	this.master.onPress();
	this.master.onRelease();
}
// END ACCESSIBILITY METHODS

#endinitclip 


boundingBox_mc._visible = false;
deadPreview._visible = false;
