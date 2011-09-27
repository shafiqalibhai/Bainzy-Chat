#initclip 10

_global.Image = function() {
	this.imageUrl            = null;
	this.loaded              = false;
	this.handlerFunctionName = null;
	this.handlerObj          = null;
	
	this.width  = null;
	this.height = null;
};

_global.Image.prototype = new MovieClip();

//PUBLIC METHODS.

_global.Image.prototype.setHandler = function(inHandlerFunctionName, inHandlerObj) {
	this.handlerFunctionName = inHandlerFunctionName;
	this.handlerObj = inHandlerObj;
};

_global.Image.prototype.loadImage = function(inImageUrl, inUseDefault, inForce) {
	if ((this.imageUrl == inImageUrl) && this.image_mc._visible && (inForce == null)) 
	{
		return;
	}
	
	this._visible = false;//(this.handlerObj != null);
	this.loaded   = false;
	this.imageUrl = inImageUrl;
	
	this.image_mc.loadMovie(this.imageUrl);
		
	this.useDefault = inUseDefault;
	this.cnt = 0;
	this.onEnterFrame = function()
	{    
	
		if(
			this.image_mc.getBytesLoaded() == this.image_mc.getBytesTotal() && 
			this.image_mc._height > 0 && 
			this.image_mc._width > 0 &&
			this.cnt++ > 1
		  )
		{
			this.width  = this.image_mc._width;
			this.height = this.image_mc._height;
			
			this._visible = true;
			this.image_mc._visible = true;
			this.loaded = true;
			
			if(this.useDefault == undefined)
			{
				_global.FlashChatNS.preff_image_width  = this.image_mc._width;
				_global.FlashChatNS.preff_image_height = this.image_mc._height;
				
				if(this.image_mc._width  < Stage.width)  this.image_mc._width = Stage.width;
				if(this.image_mc._height < Stage.height) this.image_mc._height = Stage.height;
			}	
			
			this.imageMCLoaded(this.image_mc);
			
			delete this.onEnterFrame;
		}
	}
};

_global.Image.prototype.clear = function() {
	this.image_mc._visible = false;
	this.loaded            = false;
};

//PRIVATE METHODS.
_global.Image.prototype.imageMCLoaded = function(inMC) {
	this.handlerObj[this.handlerFunctionName](this);
};

Object.registerClass('Image', _global.Image);

#endinitclip
