#initclip 0
/*=============
  FUIComponentClass
  
   The base class for all FUI controls in flash6.
   
==============*/


function FUIComponentClass()
{
	this.init();
}

FUIComponentClass.prototype = new MovieClip();

FUIComponentClass.prototype.DEFAULT_SKIN = _global.FlashChatNS.DefaultSkin;

FUIComponentClass.prototype.BTN_TYPE_NORMAL   = 0;
FUIComponentClass.prototype.BTN_TYPE_CLOSE    = 1;
FUIComponentClass.prototype.BTN_TYPE_MINIMIZE = 2;
FUIComponentClass.prototype.BTN_TYPE_HIDE     = 3;
FUIComponentClass.prototype.BTN_TYPE_WFREEZE  = 4;
FUIComponentClass.prototype.BTN_TYPE_HFREEZE  = 5;
FUIComponentClass.prototype.BTN_TYPE_COMBO    = 6;
FUIComponentClass.prototype.BTN_TYPE_SCROLL   = 7;
FUIComponentClass.prototype.BTN_TYPE_SCROLL_LOW = 8;
FUIComponentClass.prototype.BTN_TYPE_SCROLL_HI  = 9;

FUIComponentClass.prototype.BG_TYPE_COMBO     = 10;
FUIComponentClass.prototype.BG_TYPE_SCROLL    = 11;
FUIComponentClass.prototype.BG_TYPE_RECT      = 12;

FUIComponentClass.prototype.STATE_OUT      = 'out';
FUIComponentClass.prototype.STATE_OVER     = 'over';
FUIComponentClass.prototype.STATE_PRESS    = 'press';
FUIComponentClass.prototype.STATE_DISABLED = 'disabled';

//skin table
FUIComponentClass.prototype.SKIN_TABLE = { 
	default_skin  : 1,
	xp_skin       : 2,
	gradient_skin : 3,
	aqua_skin     : 4
}; 

FUIComponentClass.prototype.init = function()
{
	//set default skin
	if(_global.FlashChatNS.SKIN_NAME == undefined)
		_global.FlashChatNS.SKIN_NAME = this.DEFAULT_SKIN;
	//register object in global array
	if (_global.FlashChatNS.components_arr == undefined) 
	{ 
		_global.FlashChatNS.components_arr = new Array();
		_global.FlashChatNS.skin_table = this.SKIN_TABLE;
	}
	_global.FlashChatNS.components_arr.push(this);
	
	this.initSkinVars();
	
	this.type = '';
	this.enable = true;
	this.focused = false;
	this.useHandCursor = false;
	//accessibility :: hide non accessible components from screen reader
	this._accImpl = new Object();
	this._accImpl.stub = true;
	this.styleTable = new Array();
	if (_global.globalStyleFormat==undefined) {
		_global.globalStyleFormat = new FStyleFormat();
		globalStyleFormat.isGlobal = true;
		_global._focusControl = new Object();
		_global._focusControl.onSetFocus = function(oldFocus, newFocus)
		{
			oldFocus.myOnKillFocus();
			newFocus.myOnSetFocus();
		}
		Selection.addListener(_global._focusControl);
	}
	if (this._name!=undefined) {
		this._focusrect = false;
		this.tabEnabled = true;
		this.focusEnabled = true;
		this.tabChildren = false;
		this.tabFocused = true;
		if (this.hostStyle==undefined) {
			globalStyleFormat.addListener(this);
		} else { 
			this.styleTable = this.hostStyle;
		}
		
		this.deadPreview._visible = false;
		this.deadPreview._width = this.deadPreview._height = 1;
		this.methodTable = new Object();
		
		this.keyListener = new Object();
		this.keyListener.controller = this;
		this.keyListener.onKeyDown = function()
		{
			this.controller.myOnKeyDown();
		}
		this.keyListener.onKeyUp = function()
		{
			this.controller.myOnKeyUp();
		}
		for (var i in this.styleFormat_prm) {
			this.setStyleProperty(i, this.styleFormat_prm[i]);
		}
	}
}

// ::: PUBLIC METHODS
FUIComponentClass.prototype.initSkinVars = function()
{
	this._face        = "face";
	this._face_press  = "face_press";
	this._highlight   = "highlight";
	this._highlight3D = "highlight3D";
	this._shadow      = "shadow";
	this._darkshadow  = "darkshadow";
	//color of "X" end "_" symbols
	this._arrow       = "arrowClose";
	this._arrow_xp    = "arrowClose";
	this._arrow_gradient  = "arrowClose";
	//gradient
	this._scroll_arrow  = "arrow";
	this._scroll_face   = "scrollFace";
	this._scroll_border = "scrollBorder";
	this._scroll_face_press = "scrollFacePress";
	this._scroll_track = "scrollTrack";
	
	this._foregroundDisabled = "arrow";
	this._background = "background";
	this._backgroundBorder = "backgroundBorder";
	this._check = "check";
	
	//aqua
	this._base = "face";     //button
	this._base2 = "highlight";  //button
	this._face_aqua = "face";  //combo
	this._face2 = "highlight";  //combo
	this._seperator  = "face"; //tabview
}

FUIComponentClass.prototype.getSkinFrame = function()
{
	
	return this.SKIN_TABLE[_global.FlashChatNS.SKIN_NAME];
}

FUIComponentClass.prototype.getSkinName = function()
{
	return (_global.FlashChatNS.SKIN_NAME);
}

FUIComponentClass.prototype.setSkin = function(inSkin)
{
	_global.FlashChatNS.SKIN_NAME = (inSkin == undefined)? this.DEFAULT_SKIN : inSkin;
	_global.FlashChatNS.SKIN_ID   = this.getSkinFrame();

	this.drawSkin();
}

FUIComponentClass.prototype.setSkinId = function(inSkin)
{
	_global.FlashChatNS.SKIN_ID = this.SKIN_TABLE[inSkin];
}

FUIComponentClass.prototype.drawSkin = function()
{
	return;
}

FUIComponentClass.prototype.setEnabled = function(enabledFlag)
{
	this.enable = (arguments.length>0) ? enabledFlag : true;
	this.tabEnabled = this.focusEnabled = enabledFlag;
	if (!this.enable && this.focused) {
		Selection.setFocus(undefined);
	}
}

FUIComponentClass.prototype.getEnabled = function()
{
	return this.enable;
}

FUIComponentClass.prototype.setSize = function(w, h)
{
	this.width = w;
	this.height = h;
	this.focusRect.removeMovieClip();
}

FUIComponentClass.prototype.setChangeHandler = function(chng,obj)
{
	this.handlerObj = (obj==undefined) ? this._parent : obj;
	this.changeHandler = chng;
}

// ::: PRIVATE METHODS

FUIComponentClass.prototype.invalidate = function(methodName)
{
	this.methodTable[methodName] = true;
	this.onEnterFrame = this.cleanUI;
}

FUIComponentClass.prototype.cleanUI = function()
{
	
	// rules of invalidation : setSize beats everyone else
	if (this.methodTable.setSize) {
		this.setSize(this.width, this.height);
	} else {
		this.cleanUINotSize();
	}
	this.methodTable = new Object();
	delete this.onEnterFrame;
}

// EXTEND this method to add new invalidation rules.
FUIComponentClass.prototype.cleanUINotSize = function()
{
	for (var funct in this.methodTable) {
		this[funct]();
	}
}

FUIComponentClass.prototype.drawRect = function(x, y, w, h)
{
	var inner = this.styleTable.focusRectInner.value;
	var outer = this.styleTable.focusRectOuter.value;
	if (inner==undefined) {
		inner = 0xffffff;
	}
	if (outer==undefined) {
		outer = 0x000000;
	}
	
	this.createEmptyMovieClip( "focusRect", 1000 );
//	this.focusRect._alpha = 50; // uncomment out this line if you want focus rect with alpha
	this.focusRect.controller = this;
	this.focusRect.lineStyle(1, outer);
	this.focusRect.moveTo(x, y);
	this.focusRect.lineTo(x+w, y);
	this.focusRect.lineTo(x+w, y+h);
	this.focusRect.lineTo(x, y+h);
	this.focusRect.lineTo(x, y);
	this.focusRect.lineStyle(1, inner);
	this.focusRect.moveTo(x+1, y+1);
	this.focusRect.lineTo(x+w-1, y+1);
	this.focusRect.lineTo(x+w-1, y+h-1);
	this.focusRect.lineTo(x+1, y+h-1);
	this.focusRect.lineTo(x+1, y+1);
}

FUIComponentClass.prototype.pressFocus = function()
{
	this.tabFocused = false;
	this.focusRect.removeMovieClip();
	Selection.setFocus(this);
}

// OVERWRITE THIS METHOD FOR YOUR OWN RECTANGLES
FUIComponentClass.prototype.drawFocusRect = function()
{
	this.drawRect(-2, -2, this.width+4, this.height+4);	
}

FUIComponentClass.prototype.myOnSetFocus = function()
{
	this.focused =true;
	Key.addListener(this.keyListener);

	if (this.tabFocused) {
		this.drawFocusRect();
	}
}

FUIComponentClass.prototype.myOnKillFocus = function()
{
	this.tabFocused = true;
	this.focused =false;
	this.focusRect.removeMovieClip();
	Key.removeListener(this.keyListener);
}

FUIComponentClass.prototype.executeCallBack = function()
{
	this.handlerObj[this.changeHandler](this);
}

// An FUIComponentClass Helper for the styleFormat : 
// puts a styleFormat value into the component's styleTable,
// updates the component (the coloredMCs that make up a skin)
FUIComponentClass.prototype.updateStyleProperty = function(styleFormat, propName)
{
	this.update();
	this.setStyleProperty(propName, styleFormat[propName], styleFormat.isGlobal);
}

FUIComponentClass.prototype.update = function()
{ 
};

FUIComponentClass.prototype.setStyleProperty = function(propName, value, isGlobal)
{
	if (value=="") return;
	var tmpValue = parseInt(value);
	if (!isNaN(tmpValue)) {
		value = tmpValue;
	}
	var global = (arguments.length>2) ? isGlobal : false;
		
	if (this.styleTable[propName]==undefined) {
		this.styleTable[propName] = new Object();
		this.styleTable[propName].useGlobal=true;
	}
	if (this.styleTable[propName].useGlobal || !global) {

		this.styleTable[propName].value = value;

		if (this.setCustomStyleProperty(propName, value)) {
			// a hook for extending further styleProperty reactions.
		} else if (propName == "embedFonts") {
			this.invalidate("setSize");
		} 
		else if (propName.substring(0,4)=="text") {
			if (this.textStyle==undefined) {
				this.textStyle = new TextFormat();
			}
			//fix for styles
			var textProp = propName.substring(4, propName.length);			
			var firstChar = textProp.substring(0,1);
			firstChar = firstChar.toLowerCase();
			textProp = firstChar+(textProp.substring(1,textProp.length));
			this.textStyle[textProp] = value;
			this.invalidate("setSize");
		} else {
			for (var j in this.styleTable[propName].coloredMCs) {
				var myColor = new Color(this.styleTable[propName].coloredMCs[j].link);
				if (this.styleTable[propName].value==undefined) {
					var myTObj = { ra: '100', rb: '0', ga: '100', gb: '0', ba: '100', bb: '0', aa: '100', ab: '0'};
					myColor.setTransform(myTObj);
				} else {
					this.chooseFillType(this.styleTable[propName].coloredMCs[j].link, value, this.styleTable[propName].coloredMCs[j].fillType);
				}
			}
		}
		this.styleTable[propName].useGlobal = global;	
	}
}


/* Another styleFormat helper --
/  A skin mc calls up to this to register its existence and the
/  styleTable property it wants to listen to */
FUIComponentClass.prototype.registerSkinElement = function(skinMCRef, propName, fillType)
{
	if(skinMCRef == undefined) return;
	
	if (this.styleTable[propName]==undefined) {
		this.styleTable[propName] = new Object();
		this.styleTable[propName].useGlobal = true;
	}
	if (this.styleTable[propName].coloredMCs==undefined) {
		this.styleTable[propName].coloredMCs = new Object();
	}
	if(this.styleTable[propName].coloredMCs[skinMCRef] == undefined){ 
		this.styleTable[propName].coloredMCs[skinMCRef] = new Object();
	}
		
	this.styleTable[propName].coloredMCs[skinMCRef].link = skinMCRef;
	this.styleTable[propName].coloredMCs[skinMCRef].fillType = (fillType == undefined)? 'default' : fillType;
	
	if (this.styleTable[propName].value != undefined) {
		this.chooseFillType(skinMCRef, this.styleTable[propName].value, this.styleTable[propName].coloredMCs[skinMCRef].fillType);
	}
}

FUIComponentClass.prototype.getPref = function(inMc)
{
	var pref = inMc._parent._currentframe;
	if(inMc._parent._totalframes == 1) return (this.getPref(inMc._parent));
	else return (pref == undefined)? '' : pref;
}

FUIComponentClass.prototype.chooseFillType = function(skinMCRef, val, fillType)
{
	if(skinMCRef == undefined || skinMCRef._name == '') return;
	
	//trace('Choose feel type |' + skinMCRef + '|');
	//trace(' Ref ' + skinMCRef + ' || val ' + val + ' || fillType ' + fillType);
	
	// inSets descriprion : [fillType] = {linear, radial}, [figure] = {rect, circle, top_circle, bottom_circle},
	//                      [orientType] = {v, vb, h, hl, vt, hr} (only for 'linear' fill type)
	//                      v - vertical, vb - vertical bottom, vt - vertical top
	//                      h - horizontal, hl - horizontal left, hr - horizontal right
	var inSets = new Object();
	
	switch(fillType)
	{
		case 'default':
			var myColor = new Color(skinMCRef);
			myColor.setRGB(val);
		break;
		case 'HLinear': case 'HLLinear': case 'HRLinear': 
			inSets.fillType = 'linear';
			if(fillType == 'HLinear')  inSets.orientType = 'h'; 
			if(fillType == 'HLLinear') inSets.orientType = 'hl'; 
			if(fillType == 'HRLinear') inSets.orientType = 'hr'; 
			
			inSets.figure = 'rect';
			fillGradient(skinMCRef, val, inSets);
		break;
		case 'VLinear': case 'VTLinear': case 'VBLinear':
			inSets.fillType = 'linear';
			if(fillType == 'VLinear')  inSets.orientType = 'v'; 
			if(fillType == 'VTLinear') inSets.orientType = 'vt'; 
			if(fillType == 'VBLinear') inSets.orientType = 'vb';
			
			inSets.figure = 'rect';
			fillGradient(skinMCRef, val, inSets);
		break;
		case 'VBLinearBrighter':
			inSets.fillType = 'linear';
			inSets.orientType = 'vb';
			
			inSets.figure = 'rect';
			fillGradient(skinMCRef, ex_brighter(val, 0.6), inSets);
		break;
		case 'TopCircleLinear': case 'BottomCircleLinear': 
			inSets.fillType = 'linear';
			inSets.orientType = 'h';
			if(fillType == 'TopCircleLinear')    inSets.figure = 'top_circle';
			if(fillType == 'BottomCircleLinear') inSets.figure = 'bottom_circle';
			fillGradient(skinMCRef, val, inSets);
		break;
		case 'AquaButton':
			inSets.fillType = 'linear';
			inSets.orientType = 'vt';
			inSets.figure = 'aqua_button';
			fillGradient(skinMCRef, val, inSets);
		break;
		case 'Brighter':
			var myColor = new Color(skinMCRef);
			myColor.setRGB(ex_brighter(val, 0.40));	
		break;
		default : 
			var myColor = new Color(skinMCRef);
			myColor.setRGB(val);
		break;	
	}
}

// ============  styleFormat Class =========== //


_global.FStyleFormat = function()
{
	this.nonStyles = {listeners:true, isGlobal:true, isAStyle:true, addListener:true,
					removeListener:true, nonStyles:true, applyChanges:true};
	this.listeners = new Object();
	this.isGlobal = false;
	if (arguments.length>0) {
		for (var i in arguments[0]) {
			this[i] = arguments[0][i];
		}
	}
}

_global.FStyleFormat.prototype = new Object();


// ::: PUBLIC FStyleFormat Methods
FStyleFormat.prototype.addListener = function()
{
	for (var arg=0; arg<arguments.length; arg++) {
		var mcRef = arguments[arg];
		this.listeners[arguments[arg]] = mcRef;
		for (var i in this) {
			if (this.isAStyle(i)) {
				mcRef.updateStyleProperty(this, i.toString());
			}
		}
	}
}

FStyleFormat.prototype.removeListener = function(component)
{
	this.listeners[component] =undefined;	
	for (var prop in this) {
		if (this.isAStyle(prop)) {
			if (component.styleTable[prop].useGlobal==this.isGlobal) {
				component.styleTable[prop].useGlobal = true;
				var value = (this.isGlobal) ? undefined : globalStyleFormat[prop];
				component.setStyleProperty(prop, value, true);
			}
		}
	}
}

FStyleFormat.prototype.applyChanges = function()
{
	var count=0;
	for (var i in this.listeners) {
		var component = this.listeners[i];
		if (arguments.length>0) {
			for (var j=0; j<arguments.length; j++) {
				if (this.isAStyle(arguments[j])) {
					component.updateStyleProperty(this, arguments[j]);
				}
			}
		} else {
			for (var j in this) {
				if (this.isAStyle(j)) {
					component.updateStyleProperty(this, j.toString());
				}
			}
		}
	}
	
	if(this.intervalID == null) this.intervalID = setInterval(this.applyChangesHandler, 900, this); 
}

FStyleFormat.prototype.applyChangesHandler = function(inTarget)
{
	clearInterval(inTarget.intervalID);
	
	inTarget.handlerObj[inTarget.handlerFunc]();
	inTarget.intervalID = null;
	inTarget.handlerObj = null;
	inTarget.handlerFunc = null;
}

FStyleFormat.prototype.setApplyChangesHandler = function(inObj, inFunc)
{
	this.handlerObj = inObj;
	this.handlerFunc = inFunc;
}



// ::: PRIVATE FStyleFormat Methods

FStyleFormat.prototype.isAStyle = function(name)
{
	return (this.nonStyles[name]) ? false : true;
}



#endinitclip