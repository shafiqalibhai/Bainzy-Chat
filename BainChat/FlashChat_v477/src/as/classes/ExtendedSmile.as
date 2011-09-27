#initclip 10

_global.ExtendedSmile = function()
{
	this.loadMovie(this.imageURL);
	
	this._parent.onEnterFrame = function()
	{
		if(this.getBytesLoaded() == this.getBytesTotal() && 
		   this.smile._height > 0 && this.smile._width > 0)
		{
			delete this.onEnterFrame;
			this.smile._visible = true;
			
			var w = this.smile._width;
			var h = this.smile._height;
			var sm_parent = this.smile._parent;
			
			var w2h = w/h, txt_h = sm_parent.fLabel_mc.labelField.textHeight - 4;
			this.smile._xscale = (txt_h*w2h)/w * 100;
			this.smile._yscale = txt_h/h * 100;
			var smile_width = (w*this.smile._xscale)/100;
			
			sm_parent.fLabel_mc.setSize(this.width - 2 - this.smile._x - smile_width);
			
			this.smile._x = 3;
			this.smile._y = (sm_parent.fLabel_mc._height - (h*this.smile._yscale)/100) / 2;
			
			sm_parent.fLabel_mc._x = this.smile._x + smile_width + sm_parent.fLabel_mc._height/12;
			sm_parent.fLabel_mc._y = sm_parent.fLabel_mc._height/12;
		}
	}
};

_global.ExtendedSmile.prototype = new MovieClip();

Object.registerClass('ExtendedSmile', _global.ExtendedSmile);

#endinitclip