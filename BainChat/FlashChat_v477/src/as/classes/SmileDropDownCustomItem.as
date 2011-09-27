#initclip 3

function SmileDropDownCustomItem() {
	this.init();
	
	this.onRollOver = function()
	{
		for (var i = 0; i < this.controller.numDisplayed; i++)
		{
			this.controller.container_mc["fListItem" + i + "_mc"].setHighlighted(false);
		}
		
		this.setHighlighted(true);
	}
	
	this.onPress = function()
	{
		this.controller.clickHandler(this.itemNum);
	}
	
	if(this.isTop == true)
	{
		this.highlight_mc.onRollOver = function()
		{
			this.controller.controller.selectionHandler(this.controller.itemNum);
		}
	}
}

SmileDropDownCustomItem.prototype = new FSelectableItemClass();

Object.registerClass('SmileDropDownCustomItem', SmileDropDownCustomItem);

SmileDropDownCustomItem.prototype.layoutContent = function(width) {
	this.attachMovie('FLabelSymbol', 'fLabel_mc', 2, {hostComponent : this.controller}); 
	this.fLabel_mc.labelField.selectable = false;
	var textFmt = this.fLabel_mc.labelField.getTextFormat();
	textFmt.leading = 5;
	this.fLabel_mc.labelField.setTextFormat(textFmt);
	this.fLabel_mc.labelField.setNewTextFormat(textFmt);
}

SmileDropDownCustomItem.prototype.displayContent = function(itmObj, selected) {
	super.displayContent(itmObj, selected);
	if (itmObj.data.patternIcon == null) {
		if (this.smile != null) {
			this.smile.removeMovieClip();
		}
		this.fLabel_mc._x = 2;
	} else {
		if(itmObj.data.image == undefined)
		{ 
			this.attachMovie(itmObj.data.patternIcon, 'smile', 3); 
		}
		else 	
		{ 
			this.attachMovie('ExtendedSmile', 'smile', 3, {imageURL : itmObj.data.image}); 
		} 
		
		var w = _global.FlashChatNS.SMILIES[itmObj.data.patternIcon].width;
		var h = _global.FlashChatNS.SMILIES[itmObj.data.patternIcon].height;
		
		var is_labeled = true;
		if(this.fLabel_mc.labelField.text == '')
		{
			this.fLabel_mc.setLabel('TeStTeXt');
			is_labeled = false;
		}
		
		if(itmObj.data.image == undefined)
		{ 
			var w2h = w/h, txt_h = this.fLabel_mc.labelField.textHeight - 4;
			this.smile._xscale = (txt_h*w2h)/w * 100;
			this.smile._yscale = txt_h/h * 100;
		}
		
		var smile_width = 0;
		if(itmObj.data.iconWidth != undefined && itmObj.data.iconHeight == undefined)
			smile_width = (itmObj.data.iconWidth*this.smile._xscale)/100;
		else
			smile_width = (w*this.smile._xscale)/100;
		
		this.fLabel_mc.setSize(this.width - 2 - this.smile._x - smile_width);
		
		this.smile._x = (is_labeled)? 3 : (this.controller.downArrow._x - smile_width) / 2;
		this.smile._y = (this.fLabel_mc._height - (h*this.smile._yscale)/100) / 2;
		
		this.fLabel_mc._x = this.smile._x + smile_width + this.fLabel_mc._height/12;
		this.fLabel_mc._y = this.fLabel_mc._height/12;
		
		if(!is_labeled) this.fLabel_mc.setLabel('');
	}
}

#endinitclip
