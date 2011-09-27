#initclip 20

function FTabItemClass(){
	this.skinFrame = this.controller.getSkinFrame();
}

FTabItemClass.prototype = new MovieClip();

FTabItemClass.prototype.setSize = function(width){
	this.removeAssets();
	this.attachAssets(0);
	
	this.middle._x = this.left._width;
	this.middle._width = width - this.left._width - this.right._width;
	this.right._x = this.middle._width + this.left._width;
	
	this.fLabel_mc.setSize(width-this.left._width-this.right._width);
	this.fLabel_mc._x = this.left._width;
	this.fLabel_mc.labelField.selectable = false;
	this.fLabel_mc.setEnabled(this.enabled);
}

FTabItemClass.prototype.setHeight = function(){
	var h = this.fLabel_mc._height;
	
	if(this.skinFrame < 4)
	{ 
		this.left.darkshadow_mc._height = this.right.darkshadow_mc._height = h;
		this.left.highlight3d_mc._height = this.right.highlight3d_mc._height = h - this.left.seperator_mc._height;
		this.left.face_mc._height = this.right.face_mc._height = h - 2*this.left.seperator_mc._height;
		this.left.seperator_mc._y = this.right.seperator_mc._y = h - this.left.seperator_mc._height;
	
		this.middle.face_mc._height = h - 2*this.left.seperator_mc._height;
		this.middle.seperator_mc._y = h - this.left.seperator_mc._height;
	}
	else
	{
		var arr = ['left', 'middle', 'right'];
		
		for(var itm in arr)
		{ 
			this[arr[itm]].mask_mc._height = this[arr[itm]].face_mc._height = h;
			this[arr[itm]].face2_mc._height = h / 2;
			this[arr[itm]].face2_mc._y = this[arr[itm]].face2_mc._height - 1;
		}
	}
}

FTabItemClass.prototype.removeAssets = function(){
	this.left.removeMovieClip();
	this.middle.removeMovieClip();
	this.right.removeMovieClip();
	this.fLabel_mc.removeMovieClip();	
}

FTabItemClass.prototype.attachAssets = function(depth){
	this.attachMovie("ftv_left","left",depth++);
	this.attachMovie("ftv_middle","middle",depth++);
	this.attachMovie("ftv_right","right",depth++);	
	this.attachMovie("FLabelSymbol", "fLabel_mc", depth, {hostComponent:this.controller}); 
	
	this.left.gotoAndStop(this.skinFrame);
	this.middle.gotoAndStop(this.skinFrame);
	this.right.gotoAndStop(this.skinFrame);
}

FTabItemClass.prototype.setLabel = function(label){
	this.fLabel_mc.setLabel(label);
	this.setHeight();
}

FTabItemClass.prototype.setEnabled = function(enabled){
	this.enabled = enabled;
	this.fLabel_mc.setEnabled(enabled);
	
	if(this.enabled){
		this.onRelease = this._onRelease;
		this.useHandCursor = false;
	}else{
		delete this.onRelease;	
	}

}

FTabItemClass.prototype._onRelease = function(){
	if(this.controller.focused == false) this.controller.pressFocus();
	this.controller.setSelectedIndex(this.tabNum);
}


Object.registerClass("ftv_tab",FTabItemClass);

#endinitclip