#initclip 10

_global.SmiliesArea = function() 
{
	this.BG_COLOR     = _global.FlashChatNS.chatUI.settings.user.skin.publicLogBackground;
	this.BORDER_COLOR = darker(_global.FlashChatNS.chatUI.settings.user.skin.publicLogBackground);
	
	this.border_mc = this.createEmptyMovieClip('border_mc', 1);
	this.border_mc.onPress = function(){};
	this.border_mc.onMouseDown = function()
	{
		//trace('x ' + this._xmouse + ' y ' + this._ymouse + ' w ' + this._width + ' h ' + this._height);
		if( 
				this._xmouse <= 0 || this._xmouse >= (this._width-3) || 
				this._ymouse <= 0 || this._ymouse >= (this._height-3)
		  )
		  {
				this._parent.close();
		  }	
	};
		
	this.setMatrix(this.SMILIES_PER_ROW);
	this.alignSmilies();
};

_global.SmiliesArea.prototype = new MovieClip();

//Data
_global.SmiliesArea.prototype.SMILIES_PER_ROW = 11;
_global.SmiliesArea.prototype.CELL_HEIGHT     = 14;
_global.SmiliesArea.prototype.SPACER          = 8;
_global.SmiliesArea.prototype.BG_COLOR        = 0xffffff;
_global.SmiliesArea.prototype.BORDER_COLOR    = 0x000000;

//Methods
_global.SmiliesArea.prototype.setMatrix = function( smi_cnt )
{
	var prev_smi = '';
	var real_len = 0;
	var tmp_patternList = new Array();
	for(var i = 0; i < SmileTextConst.patternList.length; i++)
	{
		if(
				prev_smi == SmileTextConst.patternList[i][1] ||
				(
					_global.FlashChatNS.chatUI.selfUserRole != user.ROLE_ADMIN &&
					_global.FlashChatNS.chatUI.settings.avatars.mod_only.list.indexOf(SmileTextConst.patternList[i][1]) != -1
				)	
		  ) 
		    continue;
		
		tmp_patternList[real_len] = new Array();
		tmp_patternList[real_len][0] = SmileTextConst.patternList[i][0];
		tmp_patternList[real_len][1] = SmileTextConst.patternList[i][1];
		
		real_len++;
		prev_smi = SmileTextConst.patternList[i][1];
	}
		
	this._SMI_MATRIX = new Array(Math.ceil(tmp_patternList.length/smi_cnt));
	for(var i = 0; i < this._SMI_MATRIX.length; i++)
	{
		this._SMI_MATRIX[i] = new Array(smi_cnt);
		
		//apply
		for(var j = 0; j < this.SMILIES_PER_ROW; j++)
		{
			var idx = smi_cnt*i + j;
			if( idx >= tmp_patternList.length ) break;
			
			var smi = new Object();	
			smi["name"] = tmp_patternList[idx][0];
			smi["link"] = tmp_patternList[idx][1];
			
			//process width/height
			var w = _global.FlashChatNS.SMILIES[tmp_patternList[idx][1]].width;
			var h = _global.FlashChatNS.SMILIES[tmp_patternList[idx][1]].height;
			var w2h = w/h;
			
			smi["xscale"] = (this.CELL_HEIGHT*w2h)/w * 100;
			smi["yscale"] = this.CELL_HEIGHT/h * 100;
				
			var smile_width = 0;
			if(tmp_patternList[idx][2] != undefined && tmp_patternList[idx][3] == undefined)
				smile_width = (tmp_patternList[idx][2]*smi["xscale"])/100;
			else
				smile_width = (w*smi["xscale"])/100;
			//end process
			
			smi["width"]  = smile_width;
			smi["height"] = this.CELL_HEIGHT;
			
			this._SMI_MATRIX[i][j] = smi;
		}
	}
	
	this._SMI_WIDTH = new Array( this.SMILIES_PER_ROW );
	//set widths
	for(var j = 0; j < this.SMILIES_PER_ROW; j++)
	{
		var max_width = 0;
		for(var i = 0; i < this._SMI_MATRIX.length; i++)
		{
			if( max_width < this._SMI_MATRIX[i][j]["width"]) max_width = this._SMI_MATRIX[i][j]["width"];
		}
		this._SMI_WIDTH[j] = max_width;
	}
	
};

_global.SmiliesArea.prototype.alignSmilies = function()
{
	var depth = 2;
	var max_w = 0;
	for(var i = 0; i < this._SMI_MATRIX.length; i++)
	{
		var pw = -this.SPACER;
		for(var j = 0; j < this._SMI_MATRIX[i].length; j++)
		{
			if(this._SMI_MATRIX[i][j]["link"] == null) break;
			
			var mc_name  = '' + i + '_' + j;
			var smi_name = 'smile_' + mc_name;
			var bdr_name = 'border_' + mc_name;
			
			this.createEmptyMovieClip(bdr_name, depth++);
			this[smi_name] = this.attachMovie(this._SMI_MATRIX[i][j]["link"], smi_name, depth++);
			
			this[smi_name]._xscale = this._SMI_MATRIX[i][j]["xscale"];
			this[smi_name]._yscale = this._SMI_MATRIX[i][j]["yscale"]; 
			
			this[bdr_name]._x = pw + 2*this.SPACER - this.SPACER/2;
			this[bdr_name]._y = i * (this.CELL_HEIGHT + this.SPACER) + this.SPACER/2;
			this[bdr_name].i = i;
			this[bdr_name].j = j;
			
			this[bdr_name].drawRect2(0, 0, this._SMI_WIDTH[j] + this.SPACER-1, this.CELL_HEIGHT + this.SPACER-1, 1, this.BG_COLOR, 100, this.BG_COLOR, 100);
			this[bdr_name].onRollOver = function()
			{
				//trace('ROLL OVER');
				this.drawRect2(0, 0, this._parent._SMI_WIDTH[this.j] + this._parent.SPACER-1, this._parent.CELL_HEIGHT + this._parent.SPACER-1, 1, this._parent.BORDER_COLOR, 100, this._parent.BORDER_COLOR, 100);
			};
			
			this[bdr_name].onRollOut = function()
			{
				//trace('ROLL OUT');
				this.drawRect2(0, 0, this._parent._SMI_WIDTH[this.j] + this._parent.SPACER-1, this._parent.CELL_HEIGHT + this._parent.SPACER-1, 1, this._parent.BG_COLOR, 100, this._parent.BG_COLOR, 100);
			};
	
			this[bdr_name].onRelease = function()
			{
				//trace('MOUSE DOWN _x ' + this._xmouse + ' y ' + this._ymouse);
				this._parent.processSmile(this.i, this.j);
			}
			
			this[smi_name]._x = this[bdr_name]._x + (this._SMI_WIDTH[j] - this._SMI_MATRIX[i][j]["width"])/2 + this.SPACER/2;
			this[smi_name]._y = this[bdr_name]._y + this.SPACER/2;
			
			pw += this._SMI_WIDTH[j] + this.SPACER;
			
			if(max_w < pw) max_w = pw + 2*this.SPACER;
		}
	}
	
	//draw border
	this.border_mc.drawRect2(0, 0, max_w, this._SMI_MATRIX.length*(this.CELL_HEIGHT + this.SPACER) + this.SPACER, 1, this.BORDER_COLOR, 100, this.BG_COLOR, 100);
};

_global.SmiliesArea.prototype.processSmile = function(inI, inJ)
{
	this.handlerObject[this.handlerFunc](this._SMI_MATRIX[inI][inJ]["name"]);
	this.close();
};

_global.SmiliesArea.prototype.setPosition = function(inX, inY, inH, inRX, inRY)
{
	var nx = inRX + inX + this.border_mc._width;
	var ny = inRY  + inY + this.border_mc._height;
	
	if(nx > Stage.width) this._x = inX - this.border_mc._width;
	else this._x = inX;
	
	if(ny > Stage.height) this._y = inY - this.border_mc._height;
	else this._y = inY + inH;
};

_global.SmiliesArea.prototype.setHandler = function(inFunction, inObject)
{
	this.handlerObject = inObject;
	this.handlerFunc = inFunction;
};

_global.SmiliesArea.prototype.setCloseHandler = function(inFunction, inObject)
{
	this.handlerObjectClose = inObject;
	this.handlerFuncClose = inFunction;
};

_global.SmiliesArea.prototype.close = function()
{
	this.handlerObjectClose[this.handlerFuncClose]();
	this.removeMovieClip();
};

Object.registerClass('SmiliesArea', _global.SmiliesArea);

#endinitclip