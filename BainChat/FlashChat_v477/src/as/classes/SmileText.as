#initclip 10

_global.SmileText = function() 
{
	//first init all variables
	//*************************************************
	//maximum number of messages in smile text.
	this.maxMessageCount = 100;
	//current number of messages in smile text.
	this.messageCount = 0;
	
	//do realignment of smiles or do not do
	this.isRefresh = false;
	
	this.isColored = true;
	this.selfColor = -1;
	
	//text format initials options
	this.tf_font = _level0.ini.text.itemToChange.mainChat.fontFamily;
	this.tf_size = _level0.ini.text.itemToChange.mainChat.fontSize;
	
	this.showSmilies = _level0.ini.layout.toolbar.smilies != 0;
	
	this.textFormat = new TextFormat(this.tf_font , this.tf_size);
		
	//objects depth
	this.curDepth = 10;
	
	//setInterval ID
	_global.FlashChatNS['SmileInitId_' + this._name] = null;
		
	this.width  = undefined;
	this.height = undefined;
	this.min_width = 60;
	//*************************************************
	
	//create objects	
	this.createTextField("smile_txt", this.curDepth++, 0, 0,   100, 100);
	this.createTextField("test_txt",  this.curDepth++, 0, 250, 100, 100);	
	
	this.setTextFieldProp(this.smile_txt,{ background:false, wordWrap:!this.showSmilies, multiline:true, border:false, html:true});
	this.setTextFieldProp(this.test_txt,{_visible:false, background:false, wordWrap:!this.showSmilies, multiline:true, border:true, html:true});
	
	//this function is called when mouse wheel is. 
	//this.smile_txt.mouseWheelEnabled = false;
	
	//this function is called each time 'scroll' property of smile_txt changes.
	//depending on whether mouse is down and whether some text is selected 
	//it shows or hides icons.	
	this.smile_txt.onScroller = this.onScrollerSmile;
		
	//number of text lines visible in text field.		
	this.addProperty('_width',  this.getPropWidth,  this.setPropWidth);
	this.addProperty('_height', this.getPropHeight, this.setPropHeight); 
	//---	
	//create border
	this.createEmptyMovieClip(this._name + '_border', this.curDepth++);
	this.border = this[this._name + '_border'];

	//create container that keeps all icons.
	this.createEmptyMovieClip(this._name  + '_iconContainer', this.curDepth++);
	this.iconContainer = this[this._name  + '_iconContainer'];
	
	//create vertical scroll bar
	this.attachMovie("FScrollBarSymbol", "scrollBar", this.curDepth++);
	this.scrollBar.setScrollTarget(this.smile_txt);
	this.scrollBar.autoHide = true;
	
	//create mask.
	this.createEmptyMovieClip(this._name  + '_mask', this.curDepth++, {_x : -1, _y : -1});
	this.mask = this[this._name  + '_mask'];
	this.mask.drawRect2(0, 0, 1, 1, 0.1, 0x000000, 100, 0x000000, 100);
	this.mask._visible = false;
	this.setMask(this.mask);
		
	//align in first time all objects
	this._xscale = 100;
	this._yscale = 100;
	this.setSize(100, 100);
		
	//--------------------------------------------------------------------------------
	
	if( this.showSmilies )
	{ 
		//main smile property hash table
		this._SMI = new Object();
		
		for(var i=0; i < SmileTextConst.patternList.length; i++)
		{ 	
			var smile_name = SmileTextConst.patternList[i][0];		
			this._SMI[smile_name] = new Object();
			this._SMI[smile_name]["id"] = i;
			this._SMI[smile_name]["link"] = SmileTextConst.patternList[i][1];
			
			this._SMI[smile_name]["width"]  = _global.FlashChatNS.SMILIES[SmileTextConst.patternList[i][1]].width;
			this._SMI[smile_name]["height"] = _global.FlashChatNS.SMILIES[SmileTextConst.patternList[i][1]].height;
			
			this._SMI[smile_name]["space_width"] = this._SMI[smile_name]["width"];
		}
	}
	
	this.smile_txt.htmlText = "";	
	
	this.setupTextFormat();
	
	//messages array
	this.messages = new Array();
	
	this.smile_counter = 0;
	
};

_global.SmileText.prototype = new MovieClip();

//CONSTANTS.
_global.SmileText.prototype.backgroundColor = 0xffffff;
_global.SmileText.prototype.borderColor     = 0x000000;
//-------------------------------------------------------------//
_global.SmileText.prototype.BREAK     = 1; //'br';
_global.SmileText.prototype.TMP_BREAK = 2; //'tb';
_global.SmileText.prototype.WORD      = 3; //'w';
_global.SmileText.prototype.SMILE     = 4; //'s';
_global.SmileText.prototype.TAG       = 5; //'t';
//-------------------------------------------------------------//
_global.SmileText.prototype.SP        = ' ';
_global.SmileText.prototype.BR        = '<br>';
//-------------------------------------------------------------//

//private metod
_global.SmileText.prototype.setTextFieldProp = function(_txt, _prop)
{ 
	for(var p in _prop)
	{ 
		_txt[p] = _prop[p];		
	}
	
}
//---
_global.SmileText.prototype.setFont = function(inFontProp, propName)
{
	if(propName      == 'font') this.setupTextFormat(inFontProp, this.tf_size);
	else if(propName == 'size') this.setupTextFormat(this.tf_font, inFontProp);
	
	this.setupTextFormat(this.tf_font, this.tf_size);
	
	this.isRefresh = true;
	
	//this.AlignSmilies();
	//this.refreshText();
	
	clearInterval(_global.FlashChatNS['SmileInitId_' + this._name]);
	_global.FlashChatNS['SmileInitId_' + this._name] = setInterval(this, 'setFontAlignSmilies', 1);
}

_global.SmileText.prototype.setFontAlignSmilies = function()
{
	clearInterval(_global.FlashChatNS['SmileInitId_' + this._name]);
	
	this.AlignSmilies();
		
	_global.FlashChatNS['SmileInitId_' + this._name] = setInterval(this, 'setFontRefreshText', 1);
}

_global.SmileText.prototype.setFontRefreshText = function()
{
	clearInterval(_global.FlashChatNS['SmileInitId_' + this._name]);
  
	this.refreshText();
	
	this.setMaxScroll();
	
	this.onEnterFrame = this.updateScroll;
}

_global.SmileText.prototype.setColored = function(inColor, inVal, isPrivate)
{
	this.selfColor = (inColor != undefined)? inColor : this.selfColor;
	if(this.isColored == inVal) return;
	
	this.isColored = (inVal != undefined)? inVal : this.isColored;
	
	//refresh text
	if(isPrivate != true)
	{
		this.smile_txt.htmlText = "";
		for(var i = 0; i < this.messages.length; i++)
		{ 
			var msg_obj = this.messages[i];
			var msg = (this.showSmilies)? msg_obj.sequence.data.join('') : msg_obj.msg;
			msg_obj.color = (this.isColored)? msg_obj.realcolor : this.selfColor;
			this.appendMessage(this.smile_txt, msg, msg_obj.color, false);
		}
		
		this.onEnterFrame = this.updateScroll;
	}
}

_global.SmileText.prototype.smile2font = function(inIco, x_y, dY, ico_name)
{ 
	this.smileSetSize(inIco, ico_name);
	
	inIco._x = x_y.x + (this._SMI[ico_name]["spaces_width"] - inIco.width)/2;
	
	inIco.y = x_y.y + dY;
	dY -= (this.smile_txt.scroll-1) * this.textFieldHeight;
	inIco._y = x_y.y + dY;
	
	return (inIco);
}

_global.SmileText.prototype.smileSetSize = function(inIco, ico_name)
{
	if(this.tf_size != inIco.width)
	{ 
		var w2h  = this._SMI[ico_name]['width'] / this._SMI[ico_name]['height'];
		
		if(inIco.width == undefined)
		{ 
			inIco._yscale = (this.tf_size / this._SMI[ico_name]['height']) * inIco._yscale;
			inIco._xscale = ((this.tf_size * w2h) / this._SMI[ico_name]['width']) * inIco._xscale;
		}
		else
		{ 
			inIco._yscale = (this.tf_size / inIco.height) * inIco._yscale;
			inIco._xscale = ((this.tf_size * w2h) / inIco.width) * inIco._xscale;
		}
		
		inIco.width  = this._SMI[ico_name]['width']*inIco._xscale/100;
		inIco.height = this._SMI[ico_name]['height']*inIco._yscale/100;
		this._SMI[ico_name]["space_width"] = inIco.width;
	}
}

_global.SmileText.prototype.onScrollerSmile = function(text_field)
{	
	
	var p = this._parent;
	var dY = -(text_field.scroll - 1) * p.textFieldHeight;
	
	for(var i=1; i<=p.smile_counter; i++)
	{
		var ico = p.iconContainer["ico"+i];
		ico._y = ico.y + dY;
		p.showSmile(ico);
		
		var nY = ico.y + dY;
		
		//trace('nY ' + nY + ' < 0 ? : > ' + (p.height - p.textFieldHeight) + ' ? : dummi ' + ico.dummi);
		/*
		var not_on_scr = nY < 0 || nY > (p.height - p.textFieldHeight);
		
		if( not_on_scr ) //remove unvisible smile
		{
			if( !ico.dummi )
			{ 
				var dummi = new Object({
									link     : ico.link,
									msgId	   : ico.msgId,
									icoId    : ico.icoId,
									depth    : ico.getDepth(),
									y        : ico.y,
									dummi    : true, 
									_name    : ico._name,
									_visible : ico._visible,
									_x       : ico._x,
									_y       : ico._y,
									_xscale  : ico._xscale,
									_yscale  : ico._yscale,
									width    : ico.width,
									height   : ico.height
								 });
				ico.removeMovieClip();
				p.iconContainer["ico"+i] = dummi;
				
				//trace('DELETE SMILE');
				//dbg(dummi);
				
				var msg = p.messages[dummi.msgId];
				msg.smiles[dummi.icoId]["ico"] = p.iconContainer["ico"+i];
			}	
		}
		else if( ico.dummi ) //attach smile again
		{
			ico.dummi = false;
			p.iconContainer["ico"+i] = p.iconContainer.attachMovie( ico.link, ico._name, ico.depth, ico );
			
			//trace('CREATE SMILE');
			//dbg(ico);
			
			var msg = p.messages[ico.msgId];
			msg.smiles[ico.icoId]["ico"] = p.iconContainer["ico"+i];
		}
		*/
		//checking system
		
	}
}

//PUBLIC METHODS.
_global.SmileText.prototype.setShowSmilies = function(inVal) 
{
	this.showSmilies = inVal;
	this.smile_txt.wordWrap = !inVal;
	this.test_txt.wordWrap = !inVal;
}

_global.SmileText.prototype.addText = function(lbl, msg, inColor, inUserId) 
{
	if(msg == undefined || msg == "") return;
	
	this.scrollPosition = (this.smile_txt.scroll == this.smile_txt.maxscroll)? true : false;
	
	//remove top messages if need
	if( this.messages.length >= this.maxMessageCount)
	{
		//remove smilies
		for(var i = 0; i < (this.maxMessageCount / 3) - 1; i++)
		{
			var msg_obj = this.messages[i];
			for(var j = 0; j < msg_obj.smiles.length; j++) 
			{ 
				msg_obj.smiles[j]["ico"].removeMovieClip();
				delete(msg_obj.smiles[j]["ico"]);
			}	
		}
		
		this.messages.splice(0, this.maxMessageCount / 3);
		
		this.refreshText();
	}
		
	var msg_obj = new Object();
	var lbl_msg = '';	
	if(inUserId != null)
	{ 
		//apply label format
		var parent = _global.FlashChatNS.chatUI;
		var sender = parent.getUser(inUserId);
		if(sender != null)
			lbl_msg = this.str_replace(lbl, "AVATAR", sender.getAvatar('mainchat'));
		else	
			lbl_msg = this.str_replace(lbl, "AVATAR", '');	
	}
		
	msg_obj.label= lbl; 
	msg_obj.text = msg; 
	
	msg_obj.msg = lbl_msg + replaceHTMLSpecChars( msg );
	msg_obj.realcolor = inColor;
	msg_obj.color = (this.isColored || this.selfColor == -1)? inColor : this.selfColor;
	msg_obj.userId = inUserId;

	if(!this.showSmilies)
	{
		this.messages.push(msg_obj);
		this.appendMessage(this.smile_txt, msg_obj.msg, msg_obj.color, false);
		this.setMaxScroll();
		this.onEnterFrame = this.updateScroll;
		return;
	}
	
	msg_obj.sequence = new Object();
	msg_obj.sequence.label = new Array();
	msg_obj.sequence.data  = new Array();
	msg_obj.sequence.br_index = new Array();
	
	//parse message
	msg_obj.smiles = this.getSmilesInText( msg_obj.msg, sender.getAvatar('mainchat'));
	
	this.messages.push(msg_obj);
	
	this.addMessageToField();
	this.setMaxScroll();
};
//---
_global.SmileText.prototype.setMaxScroll = function()
{
	if(this.scrollPosition) this.smile_txt.scroll = 10000;
}
//---
_global.SmileText.prototype.breakMessage = function(inArrObj)
{
	inArrObj.label.push(this.TMP_BREAK);
	inArrObj.data.push(this.BR);
	inArrObj.br_index.push(inArrObj.label.length-1);
		
	//trace('LENGTH ' + inArrObj.label.length);
	
	var msg = '', otag = '', ctag = '';
	for(var i = 0; i < inArrObj.label.length; i++)
	{
		var stype = inArrObj.label[i];
		var sdata = inArrObj.data[i];
		if(stype == this.TAG) 
		{ 
			if(sdata.length < 5) 
			{ 
				var upper = sdata.toUpperCase();
				if(upper == '<B>' || upper == '<I>')
				{ 
					otag += sdata;
					ctag += sdata.charAt(0) + '/' + sdata.substr(1);
				}
				else if(upper == '</B>' || upper == '</I>')
				{
					otag = ctag = '';
				}
				msg += sdata;
			}
			continue;
		}
		if(stype == this.BREAK) 
		{
			msg = otag;
			continue;
		}
		
		msg += sdata;
		this.appendMessage(this.test_txt, msg + ctag, 0, true);
		if(this.test_txt.textWidth > (this.test_txt._width - 5))
		{
			inArrObj.label.splice(i, 0, this.TMP_BREAK);
			inArrObj.data.splice(i, 0, this.BR);
			inArrObj.br_index.push(i);
			
			msg = otag;
		}
		
	}
	
	//trace('<BRAKE MESSAGE>');
	//trace('label: ' + inArrObj.label);
	//trace('data : ' + inArrObj.data);
	
	return (inArrObj.data.join(''));
}
//---
_global.SmileText.prototype.searchTags = function(inTxt)
{
	var retObj = new Object();
	retObj.label = new Array();
	retObj.data = new Array();
	
	var b = inTxt.split('<');
	for(var i = 0; i < b.length; i++)
	{
		if(i == 0)
		{
			retObj.label.push(this.WORD);
			retObj.data.push(b[i]);
			continue;
		}
		
		var tag = '<' + b[i].substr(0, b[i].indexOf('>') + 1);
		var txt = b[i].substr(b[i].indexOf('>') + 1);
		
		if(tag.length > 2) 
		{
			var n = (tag == this.BR)? this.BREAK : this.TAG;
			retObj.label.push(n);
			retObj.data.push(tag);
			
		}
		
		if(txt.length != 0)
		{
			retObj.label.push(this.WORD);
			retObj.data.push(txt);
		}
	}
	
	//trace('<SEARCH TAGS>');
	//trace('ret l ' + retObj.label);
	//trace('ret d ' + retObj.data);
	
	return (retObj);
}

_global.SmileText.prototype.getWords = function(msg_obj, inTxt)
{ 
	if(inTxt.length != 0)
	{ 
		//break tags
		var ret = this.searchTags(inTxt);
		for(var itm = 0; itm < ret.label.length; itm++)
		{ 
			var stype = ret.label[itm];
			var sdata = ret.data[itm];
			
			if(stype == this.BREAK || stype == this.TAG)
			{ 
				msg_obj.sequence.label.push(stype);
				msg_obj.sequence.data.push(sdata);
			}
			else if(stype == this.WORD)
			{ 
				var word = sdata.substr(0, sdata.indexOf(this.SP));
				for(var i = word.length; i < sdata.length; i++)
				{
					var next_char = sdata.charAt(i);
					if(next_char != this.SP && (i != sdata.length-1)) word += next_char;
					else
					{ 
						if(i == sdata.length-1) word += next_char;
						else
						{ 
							for(var j = 1; next_char == this.SP && (i+j) < sdata.length; j++)
							{ 
								word += next_char;
								next_char = sdata.charAt(i+j);
							}
							i += (j-2);
						}
							
						//break big word if needed
						var tmp_str = '';
						while( true )
						{	
							this.appendMessage(this.test_txt, tmp_str, 0, true);
							if(this.test_txt.textWidth > (this.min_width - 40) || tmp_str == word)
							{ 
								msg_obj.sequence.label.push(this.WORD);
								msg_obj.sequence.data.push(tmp_str);
								
								if(tmp_str != word)
								{
									word = word.substr(tmp_str.length);
									tmp_str = '';
								}	
								else break;
							}
							tmp_str = word.substr(0, tmp_str.length + 1);
						}
						
						word = '';
					}	
				}
			}
		}
	}
}
//---
_global.SmileText.prototype.addMessageToField = function()
{
	var msg_obj = this.messages[this.messages.length-1];
	if(msg_obj == undefined) return;
	
	var s_index = 0;	
	
	var add_txt = '';
	for(var i = 0; i < msg_obj.smiles.length; i++)
	{
		add_txt = msg_obj.msg.substring( s_index, msg_obj.smiles[i].ind );
		
		this.getWords(msg_obj, add_txt);
		
		var smi = msg_obj.smiles[i]["smi"];
		add_txt = this._SMI[smi]["spaces"];
		
		msg_obj.sequence.label.push(this.SMILE);
		msg_obj.sequence.data.push(add_txt);
		
		s_index = msg_obj.smiles[i].ind + smi.length;
		
		this.iconContainer.attachMovie( this._SMI[smi]["link"], "ico"+this.smile_counter, this.smile_counter++, {_visible : false} );
		
		msg_obj.smiles[i]["ico"]          = this.iconContainer["ico"+(this.smile_counter)];
		msg_obj.smiles[i]["ico"]["link"]  = this._SMI[smi]["link"];
		msg_obj.smiles[i]["ico"]["msgId"] = this.messages.length-1;
		msg_obj.smiles[i]["ico"]["icoId"] = i;
	}
	
	add_txt = msg_obj.msg.substr( s_index );
	this.getWords(msg_obj, add_txt);
	
	var msg = this.breakMessage(msg_obj.sequence);
	this.appendMessage(this.smile_txt, msg, msg_obj.color, false);
	this.AlignSmilies(); 
}

_global.SmileText.prototype.AlignSmilies = function()
{
	if(!this.showSmilies) return;
	
	this.onEnterFrame = function(){ updateAfterEvent(); }
	
	var len = this.messages.length;	
	var dY =  0;
	
	for(var i = 0; i < len; i++)
	{
		var msg_obj  = this.messages[i];		

		var curr_smi = 0, lines = 0;
		
		var msg = '', otag = '', ctag = '';
		
		for(var j = 0; j < msg_obj.sequence.label.length; j++)
		{
			var stype = msg_obj.sequence.label[j];
			var sdata = msg_obj.sequence.data[j];
			
			if(stype == this.WORD)
			{
				msg += sdata;
			}
			else if(stype == this.TAG)
			{
				if(sdata.length < 5) 
				{ 
					if(sdata.toUpperCase() == '<B>' || sdata.toUpperCase() == '<I>')
					{ 
						otag += sdata;
						ctag += sdata.charAt(0) + '/' + sdata.substr(1);
					}
					else if(sdata.toUpperCase() == '</B>' || sdata.toUpperCase() == '</I>')
					{
						otag = ctag = '';
					}
					msg += sdata;
				}
			}
			else if(stype == this.BREAK || stype == this.TMP_BREAK)
			{
				lines++;
				msg = otag;
			}
			else if(stype == this.SMILE && (this.isRefresh == true || i == (len - 1)))
			{
				this.appendMessage(this.test_txt, msg + ctag, 0, true, true);
				var l_width = this.test_txt.textWidth;
				
				var x_y = new Object();
				x_y.x = l_width + 2;
				x_y.y = lines * this.textFieldHeight + 3;
				
				var smi = msg_obj.smiles[curr_smi++];
				var ico = this.smile2font(smi["ico"], x_y, dY, smi["smi"]);
				
				//this.showSmile(ico);
				
				msg_obj.sequence.data[j] = this._SMI[smi["smi"]]["spaces"];
				msg += msg_obj.sequence.data[j];
			}
			
			updateAfterEvent();
		}
		
		dY += lines * this.textFieldHeight;
	}	
	
	this.setMaxScroll();
	this.smile_txt.onScroller(this.smile_txt);
	this.onEnterFrame = this.updateScroll;
	
	this.isRefresh = false;
}

_global.SmileText.prototype.showSmile = function(inIco)
{
	var lines = this.smile_txt.bottomScroll - this.smile_txt.scroll;
	inIco._visible = (
					(Math.floor(inIco._y/this.textFieldHeight) <= lines && 
					inIco._y > 0 && 
					(inIco._x + inIco.width) < this.width) || 
					lines < 2
				 );
}

_global.SmileText.prototype.getLinesCount = function(_txt)
{ 	
	this.updateAfterEvent();
	return (_txt.bottomScroll - _txt.scroll + _txt.maxscroll);	
}

//---
_global.SmileText.prototype.replaceHTMLSpecChars = function(msg)
{
	msg = this.str_replace(msg,"\n","<br>");
	msg = this.str_replace(msg,"\r","<br>");
	
	msg = this.str_replace(msg,"&lt;","<");
	msg = this.str_replace(msg,"&gt;",">");
	msg = this.str_replace(msg,"&amp;","&");
	msg = this.str_replace(msg,"&apos;","'");
	msg = msg.split("a> ").join("a>&nbsp;");

	return (msg);
}

_global.SmileText.prototype.appendMessage = function(_txt, msg, _color, _clear, _nbsp)
{
	if(msg == undefined) return;
	
	if(_nbsp == true) msg = this.str_replace(msg," ","&nbsp;");
	
	var _str = '<FONT FACE="' + this.tf_font + '" SIZE="' + this.tf_size + '" COLOR="#';
	_str += Number(_color).toString(16) + '">';
	_str += msg + '</FONT>';
	
	if(_clear == true) _txt.htmlText = "";	
	_txt.htmlText += _str;
	
}
//---

//if smile found return array else undefined
_global.SmileText.prototype.getSmilesInText = function( inTxt, inAvatar )
{
	var ret_arr = new Array();
	var txt = inTxt;
	var avatar = inAvatar;
	
	if(inAvatar != null && inAvatar != '')
	{ 
		var startIndex = 0;
		var ind = 0;
		while( (ind = txt.indexOf(inAvatar,startIndex)) >= 0)
		{
			startIndex = ind + inAvatar.length;
			var smi_obj = new Object();
			smi_obj.ind = ind;
			smi_obj.smi = inAvatar;
			ret_arr.push(smi_obj);
		}
		
		//replace smile text
		if(startIndex != 0)
		{ 
			var repl = '';
			for(var i = 0; i < inAvatar.length; i++) repl+= '#';
			
			txt = this.str_replace(txt, inAvatar, repl);
		}
	}	
	
	for(var smi in this._SMI)
	{ 
		if(smi == undefined) continue;
	
		var startIndex = 0;
		var ind = 0;
		
		while( (ind = txt.indexOf(smi,startIndex)) >= 0)
		{
			startIndex = ind + smi.length;
			//fix bug with 'mailto:p'
			if(txt.substr(ind-6, 7) == 'mailto:') continue;
			
			var smi_obj = new Object();
			smi_obj.ind = ind;
			smi_obj.smi = smi;
			ret_arr.push(smi_obj);
		}
		
		//replace smile text
		if(startIndex != 0)
		{ 
			var repl = '';
			for(var i = 0; i < smi.length; i++) repl+= '#';
			
			txt = this.str_replace(txt, smi, repl);
		}
	}
	
	ret_arr.sort( this.sortSmilesInMessage );
	
	return ret_arr;
}

_global.SmileText.prototype.setMinWidth = function(w) {
	this.min_width = (w == undefined && w < 40)? this.min_width : w;
}

_global.SmileText.prototype.showSmiliesOnOff = function( flag ) {
	//for(var i = 0; i < this.messages.length; i++) this.iconContainer["ico"+i]._visible = false;
	
	for(var i = 0; i < this.messages.length; i++)
	{ 
		var msg_obj = this.messages[i];
		for(var j = 0; j < msg_obj.smiles.length; j++) msg_obj.smiles[j]["ico"]._visible = flag;
	}
};

_global.SmileText.prototype.setSize = function(w, h) {
	if ((this.width == w) && (this.height == h) || w==undefined || h==undefined) 
	{
		return;
	}
	
	var fl = (this.width > w) || (this.height > h);
	if( fl ) this.showSmiliesOnOff(!fl);
	
	this.width = w;
	this.height = h;	
	
	this.smile_txt._width = w - (this.scrollBar._visible ? this.scrollBar._width : 0);
	this.test_txt._width = this.smile_txt._width;
	this.smile_txt._height = h;	
	this.scrollBar._x = this.smile_txt._width;
	this.scrollBar.setSize(h);
	this.smiletext_background._width  = w;
	this.smiletext_background._height = h;
	
	this.mask._width  = w + 2;
	this.mask._height = h + 2;
	
	this.drawBorder();
	
	this.refreshText();
	
	if( fl ) this.showSmiliesOnOff(fl);
};

_global.SmileText.prototype.refreshText = function()
{
	if(!this.showSmilies) 
	{ 
		this.onEnterFrame = this.updateScroll;
		return;
	}
	
	//refresh text
	this.smile_txt.htmlText = "";
	for(var i = 0; i < this.messages.length; i++)
	{ 
		var msg_obj = this.messages[i];
		//remove tmp_break
		var len = msg_obj.sequence.br_index.length;
		for(var j = 0; j < len; j++)
		{
			var ind = msg_obj.sequence.br_index.pop();
			msg_obj.sequence.label.splice(ind, 1);
			msg_obj.sequence.data.splice(ind, 1);
		}
		
		var msg = this.breakMessage(msg_obj.sequence);
		this.appendMessage(this.smile_txt, msg, msg_obj.color, false);
	}
	
	this.isRefresh = true;
	this.onEnterFrame = this.AlignSmilies;
}

_global.SmileText.prototype.updateScroll = function()
{ 
	delete this.onEnterFrame;
	this.scrollBar.setScrollTarget(this.smile_txt);
}


_global.SmileText.prototype.clear = function() 
{
	this.smile_txt.htmlText = "";
	
	this.resetTextLines();
	this.messages = new Array();
	
	for(var i = 1; i <= this.smile_counter; i++)
	{
		var ico = this.iconContainer["ico"+i];
		if(ico.dummi) delete(this.iconContainer["ico"+i]);
		else ico.removeMovieClip();
	}
	
	this.createEmptyMovieClip(this.iconContainer._name, this.iconContainer.getDepth());
};

//sets maximum number of messages in smile text.
_global.SmileText.prototype.setMaxMessageCount = function(inMaxMessageCount) 
{
	this.maxMessageCount = inMaxMessageCount;
};

_global.SmileText.prototype.setEnabled = function(inEnabled) 
{
	this.smile_txt.selectable = inEnabled;
	this.scrollBar.setEnabled(inEnabled);
};

_global.SmileText.prototype.setBackgroundColor = function(inBackgroundColor, inAlpha) 
{
	this.backgroundColor = inBackgroundColor;
	var c = new Color(this.smiletext_background);
	c.setRGB(this.backgroundColor);
	
	this.smiletext_background._alpha = inAlpha;
};

_global.SmileText.prototype.setBorderColor = function(inBorderColor, inAlpha) 
{
	this.borderColor = inBorderColor;
	this.drawBorder();
};

//PRIVATE METHODS.
_global.SmileText.prototype.setupTextFormat = function(font_name, font_size)
{
	if(font_name == this.tf_font && font_size == this.tf_size) return;
	
	if(font_name == undefined)font_name = this.tf_font;
	if(font_size == undefined)font_size = this.tf_size;
	
	this.tf_font = font_name;
	this.tf_size = font_size;
	
	this.test_txt.multiline = true;
	this.appendMessage(this.test_txt, "&nbsp;<br>&nbsp;<br>&nbsp;", 0, true);
	this.textFieldHeight = this.test_txt.textHeight / 3 ;
	this.spaceWidth	= this.test_txt.textWidth;	
	this.test_txt.multiline = false;
	
	for(var i=0; i<SmileTextConst.patternList.length; i++)
	{
		var smile_name = SmileTextConst.patternList[i][0];
		
		var dummyObj = {_xscale:100, _yscale:100};
		
		this.smileSetSize(dummyObj, smile_name);
		var need_spaces = Math.ceil( this._SMI[smile_name]["space_width"] / this.spaceWidth );
		
		var spaces = "";
		for(var j=0; j<need_spaces; j++) spaces += "&nbsp;";
		
		this._SMI[smile_name]["spaces"] = spaces;
		this.appendMessage(this.test_txt, this.str_replace(spaces, " ", "&nbsp;"), 0, true);
		this._SMI[smile_name]["spaces_width"] = this.test_txt.textWidth;
	}
	
};

_global.SmileText.prototype.getLinesCount = function(_txt){ 	
	this.updateAfterEvent();
	return (_txt.bottomScroll - _txt.scroll + _txt.maxscroll);	
};

_global.SmileText.prototype.getPropWidth = function() {
	return this.width;
};

_global.SmileText.prototype.setPropWidth = function(inWidth) {
	return this.setSize(inWidth, this.height);
};

_global.SmileText.prototype.getPropHeight = function() {
	return this.height;
};

_global.SmileText.prototype.setPropHeight = function(inHeight) {
	return this.setSize(inHeight, this.height);
};

_global.SmileText.prototype.resetTextLines = function() {
	this.currentY = 0;
	this.messageCount = 0;
	this.smile_txt.text = '';
	this.smile_txt.scroll = 1;
};

_global.SmileText.prototype.drawBorder = function() {
	this.border.clear();
	this.border.lineStyle(1, this.borderColor, 100);
	this.border.moveTo(0, 0);
	this.border.lineTo(this.width, 0);
	this.border.lineTo(this.width, this.height);
	this.border.lineTo(0, this.height);
	this.border.lineTo(0, 0);
};


_global.SmileText.prototype.str_replace = function(str, _old, _new)
{
	if(_new.indexOf(_old) >= 0) return str;
	
	var str1,str2;
	var pos = str.indexOf(_old);
	while (pos >= 0 ){
		str1 = str.substring(0, pos);
		str2 = str.substring(pos+_old.length);
		str  = str1 + _new + str2;
		pos  = str.indexOf(_old);
	};
	
	return str;
};
 
_global.SmileText.prototype.sortSmilesInMessage = function (a, b) 
{   
   if (a.ind < b.ind) { return -1;} 
   else if (a.ind > b.ind) {return 1;} 
   else {return 0;}
};

_global.SmileText.prototype.changeAvatar = function (inUserId)
{
	/*
	var msgs = new Array();

	for(var i = 0; i < this.messages.length; i++)
	{
		var msg_obj = this.messages[i];
		msgs[i] = new Object();
		msgs[i].label  = msg_obj.label;
		msgs[i].msg    = msg_obj.msg;
		msgs[i].text   = msg_obj.text;
		msgs[i].userId = msg_obj.userId;
		msgs[i].color  = msg_obj.color;
	}
	
	this.clear();
	for(i = 0; i < msgs.length; i++)
	{
		this.addText(msgs[i].label, msgs[i].text, msgs[i].color, msgs[i].userId); 
	}
	*/
}; 

Object.registerClass('SmileText', _global.SmileText);

#endinitclip
