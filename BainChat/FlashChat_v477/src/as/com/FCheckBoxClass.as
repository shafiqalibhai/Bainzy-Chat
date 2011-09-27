#initclip 1

function FCheckBoxClass()
{
	this.init();
}

FCheckBoxClass.prototype = new FUIComponentClass();
Object.registerClass("FCheckBoxSymbol", FCheckBoxClass);
	
FCheckBoxClass.prototype.init = function()
{
	super.setSize(this._width,this._height);
	this.boundingBox_mc.unloadMovie();
	this.attachMovie("fcb_hitArea","fcb_hitArea_mc",1);
	this.attachMovie("fcb_skins", "fcb_skins_mc",2);
	/*this.attachMovie("FLabelSymbol","fLabel_mc",3);*/
	super.init();
	
	//handle when we need to redraw skin of component
	this.drawSkin = this.drawFrame;
	
	this.real_height = this.fcb_skins_mc.fcb_states_mc._height;
	
	this.setChangeHandler(this.changeHandler);
	this._xscale = 100;
	this._yscale = 100;
	this.setSize(this.width,this.height);
	if ( this.initialValue == undefined ) {
		this.setCheckState(false);
	}  else {
		this.setCheckState(this.initialValue);
	}
	if(this.label != undefined){
		this.setLabel(this.label);
	}
	// ACCESSIBILITY DEFINED :: _accImpl object defined in base class
		this.ROLE_SYSTEM_CHECKBUTTON = 0x2c;
		this.STATE_SYSTEM_CHECKED = 0x10;
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
/*
FCheckBoxClass.prototype.setLabelPlacement = function( pos )
{
	this.setLabel(this.getLabel());
	this.txtFormat( pos );
	var halfLabelH = this.fLabel_mc._height/2;
	var halfFrameH = (this.real_height-1)/2;
	var vertCenter = (halfFrameH - halfLabelH );
	var checkWidth = this.fcb_skins_mc.fcb_states_mc._width;
	var frame = this.fcb_skins_mc.fcb_states_mc
	var label = this.fLabel_mc;
	var w = 0;
	
	if (frame._width > this.width){
		w  = 0;
	} else {
		w  = this.width - frame._width;
	}
	this.fLabel_mc.setSize(w);

	if (pos == "right" || pos == undefined){
		this.labelPlacement = "right";
		this.fcb_skins_mc.fcb_states_mc._x  = 0;
		this.fLabel_mc._x = checkWidth;
		this.txtFormat("left");
	} else if (pos == "left"){
		this.labelPlacement = "left";
		this.fLabel_mc._x = 0;
		this.fcb_skins_mc.fcb_states_mc._x = this.width - checkWidth;
		this.txtFormat("right");
	}

	this.fLabel_mc._y = vertCenter;
	this.fcb_hitArea_mc._y = vertCenter;
}

FCheckBoxClass.prototype.txtFormat = function( pos )
{
	var txtS = this.textStyle;
	var sTbl = this.styleTable;
	txtS.align = (sTbl.textAlign.value == undefined) ? txtS.align = pos : undefined;
	txtS.leftMargin = (sTbl.textLeftMargin.value == undefined) ? txtS.leftMargin = 0 : undefined;
	txtS.rightMargin = (sTbl.textRightMargin.value == undefined) ? txtS.rightMargin = 0 : undefined
	if(this.fLabel_mc._height > this.height){
		super.setSize(this.width,this.fLabel_mc._height);
	}else{
		super.setSize(this.width,this.height);
	}
	this.fLabel_mc.labelField.setTextFormat(this.textStyle);
	this.setEnabled(this.enable)
}*/

FCheckBoxClass.prototype.setHitArea = function(w,h)
{
	var hit = this.fcb_hitArea_mc;
	this.hitArea = hit;
	if ( this.fcb_skins_mc.fcb_states_mc._width > w ){
		hit._width = this.fcb_skins_mc.fcb_states_mc._width;
	}else{ 
		hit._width = w;
	}	
	hit._visible = false;
	if(arguments.length > 1){
		hit._height = h;
	}
}

FCheckBoxClass.prototype.setSize = function(w)
{
	this.drawFrame();
	
	this.setLabel(this.getLabel());
	this.setLabelPlacement(this.labelPlacement);
	/*
	if(this.fcb_skins_mc.fcb_states_mc._height < this.fLabel_mc.labelField._height){
		super.setSize(w,this.fLabel_mc.labelField._height);
	}*/
	this.setHitArea(this.width,this.height);
	this.setLabelPlacement(this.labelPlacement);
	
}

FCheckBoxClass.prototype.drawFocusRect = function()
{
	this.drawRect(-2, -2, this._width+6, this._height-1);
}

FCheckBoxClass.prototype.drawFrame = function()
{
	if(this.getSkinFrame() == 4)
		this.fcb_skins_mc.gotoAndStop(3);
	else	
		this.fcb_skins_mc.gotoAndStop(this.getSkinFrame());
		
	this.setValue(this.checked);
	
}

FCheckBoxClass.prototype.onPress = function()
{
	this.pressFocus();
	_root.focusRect.removeMovieClip();
	var states = this.fcb_skins_mc.fcb_states_mc;
	if (this.getValue()) {
		states.gotoAndStop( "checkedPress" );
	} else {
		states.gotoAndStop( "press" );
	}
}

FCheckBoxClass.prototype.onRelease = function()
{
	this.fcb_skins_mc.fcb_states_mc.gotoAndStop( "up" );
	this.setValue(!( this.checked ));
}

FCheckBoxClass.prototype.onReleaseOutside = function()
{
	var states = this.fcb_skins_mc.fcb_states_mc;
	if (this.getValue()) {
		states.gotoAndStop( "checkedEnabled" );
	} else {
		states.gotoAndStop("up");
	}
}

FCheckBoxClass.prototype.onDragOut = function()
{
	var states = this.fcb_skins_mc.fcb_states_mc;
	if (this.getValue()) {
		states.gotoAndStop( "checkedEnabled" );
	} else {
		states.gotoAndStop("up");
	}
}

FCheckBoxClass.prototype.onDragOver = function()
{
	var states = this.fcb_skins_mc.fcb_states_mc;
	if (this.getValue()) {
		states.gotoAndStop( "checkedPress" );
	} else {
		states.gotoAndStop("press");
	}
}


FCheckBoxClass.prototype.setValue = function( checkedValue )
{
	if ( checkedValue || checkedValue == undefined) {
		this.setCheckState( checkedValue );
	} else if (checkedValue == false){
		this.setCheckState( checkedValue );
	}
	this.executeCallBack();
	
	if(Accessibility.isActive()){
			Accessibility.sendEvent(this, 0, this.EVENT_OBJECT_STATECHANGE, true);
		}
	
}

FCheckBoxClass.prototype.setCheckState = function( checkedValue )
{
	var states = this.fcb_skins_mc.fcb_states_mc;
	if ( this.enable ) {
		this.fLabel_mc.setEnabled(true);
		if ( checkedValue || checkedValue == undefined) {
			states.gotoAndStop( "checkedEnabled" );
			this.enabled = true;
			this.checked = true;
		} 
		else
		{
			states.gotoAndStop("up");
			this.enabled = true;
			this.checked = false;
		}
	} 
	else 
	{
		this.fLabel_mc.setEnabled(false);
		if ( checkedValue || checkedValue == undefined) {
			states.gotoAndStop( "checkedDisabled" );
			this.enabled = false;
			this.checked = true;
		} 
		else 
		{
			states.gotoAndStop( "uncheckedDisabled" );										   
			this.enabled = false;
			this.checked = false;
			this.focusRect.removeMovieClip()
		}
	}
}

FCheckBoxClass.prototype.getValue = function()
{
	return (this.checked);
}

FCheckBoxClass.prototype.setEnabled = function( enable )
{
	if(enable == true || enable == undefined){
		 this.enable = true;
		 super.setEnabled(true);
	} else {
		this.enable = false;
		super.setEnabled(false);
	}
	this.setCheckState(this.checked);
}

FCheckBoxClass.prototype.getEnabled = function()
{
	return(this.enable);
}
/*
FCheckBoxClass.prototype.setLabel = function( label )
{
	this.fLabel_mc.setLabel(label);
	this.txtFormat();
	// ACCESSIBILITY
	if(Accessibility.isActive()){
		Accessibility.sendEvent( this, 0, this.EVENT_OBJECT_NAMECHANGE );
	}
}*/
/*
FCheckBoxClass.prototype.getLabel = function()
{
	return (this.fLabel_mc.labelField.text);
}

FCheckBoxClass.prototype.setTextColor = function( color )
{
	this.fLabel_mc.labelField.textColor = color;
}*/

FCheckBoxClass.prototype.myOnKeyDown = function( )
{
	if (Key.getCode() == Key.SPACE && this.pressOnce == undefined && this.enabled == true) {
		this.setValue(!this.getValue());
		this.pressOnce = true;
	}
}

FCheckBoxClass.prototype.myOnKeyUp = function( )
{
	if (Key.getCode() == Key.SPACE) {
		this.pressOnce = undefined;
	}
}

// START ACCESSIBILITY METHODS

FCheckBoxClass.prototype.get_accRole = function(childId)
{
	return this.master.ROLE_SYSTEM_CHECKBUTTON;
}

FCheckBoxClass.prototype.get_accName = function(childId)
{
	return this.master.getLabel();
}

FCheckBoxClass.prototype.get_accState = function(childId)
{
	if (this.master.getValue())	{
		return this.master.STATE_SYSTEM_CHECKED;
	}else{
		return 0;
	}
}

FCheckBoxClass.prototype.get_accDefaultAction = function(childId)
{
	if ( this.master.getValue() ){
		return "UnCheck";
	}else{
		return "Check";
	}
}

FCheckBoxClass.prototype.accDoDefaultAction = function(childId)
{
	this.master.setValue( !this.master.getValue() );
}
	
// END ACCESSIBILITY METHODS ::mr::


#endinitclip 

boundingBox_mc._visible = false;
deadPreview._visible = false;





