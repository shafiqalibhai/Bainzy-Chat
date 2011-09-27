//convert string to boolean
function toBool( arg )
{
	return (arg == '1' || arg == true)? true : false;	
};

function setTextProperty(propName, val, obj, isNew)
{
	//trace('propName ' + propName + ' val ' + val + ' obj ' + obj + ' isNew ' + isNew + ' txt ' + obj.htmlText);
	
	var textFormat = obj.getTextFormat();
	
	if (textFormat[propName] != val && val != undefined) 
	{ 
		textFormat[propName] = val;
		
		obj.setTextFormat(textFormat);
		if(isNew != undefined) obj.setNewTextFormat(textFormat);
		if(obj._height < obj.textHeight) obj._height = obj.textHeight + 5;
		return (true);
	}
	
	return (false);
};

function testText(inObj, inText, inProp)
{
	if(_global.FlashChatNS.test_text == undefined)
	{ 
		inObj._parent.createTextField("tEsT_tXt_tEsT",  inObj._parent.getNextHighestDepth(), 0, 0, 0, 0);
		
		_global.FlashChatNS.test_text = inObj._parent.tEsT_tXt_tEsT;
		_global.FlashChatNS.test_text._visible = false;
		_global.FlashChatNS.test_text.autoSize = 'left';
	}

	if(inProp == undefined)
	{ 
		var textFormat = inObj.getTextFormat();
		_global.FlashChatNS.test_text.setNewTextFormat(textFormat);
	}else
	{ 
		_global.FlashChatNS.test_text.setNewTextFormat(inProp);
	}
	_global.FlashChatNS.test_text.text = (inText == '')? 'l' : inText;
	
	var dimention = new Object();
	dimention.width = _global.FlashChatNS.test_text._width;
	dimention.height = _global.FlashChatNS.test_text._height;
	
	_global.FlashChatNS.test_text.text = '';
	_global.FlashChatNS.test_text._width = _global.test_text._height = 0;
	
	return (dimention);
};

//debug function
_global.dbg =  function(obj, level)
{
	if(level == undefined) level = 0;
	if(level > 5) return;
	for(var v in obj) 
	{
		var o = ""
		for(i=0;i<level;i++)o+="\t";
		trace(o+"obj["+v+"]=>" + obj[v]);
		if( typeof(obj[v]) == "object" )
		{
			dbg(obj[v],level+1);
		}
	}	
} 

_global.replaceHTMLSpecChars = function(msg)
{
	msg = str_replace(msg,"\n","<br>");
	msg = str_replace(msg,"\r","<br>");
	
	msg = str_replace(msg,"&lt;","<");
	msg = str_replace(msg,"&gt;",">");
	msg = str_replace(msg,"&amp;","&");
	msg = str_replace(msg,"&apos;","'");
	msg = str_replace(msg,"&quot;",'"');
	msg = msg.split("a> ").join("a>&nbsp;");
	
	return (msg);
};

_global.areplaceHTMLSpecChars = function(msg)
{
	msg = str_replace(msg,"&","&amp;");
	msg = str_replace(msg,"<","&lt;");
	msg = str_replace(msg,">","&gt;");
	msg = str_replace(msg,"'","&apos;");
	msg = str_replace(msg,"&quot;",'"');
	
	return (msg);
};

_global.str_replace = function(str, _old, _new)
{
	if(_new.indexOf(_old) >= 0) return str;
	
	var str1,str2;
	var pos = str.indexOf(_old);
	while (pos >= 0 ){
		str1 = str.substring(0, pos);
		str2 = str.substring(pos+_old.length);
		str = str1 + _new + str2;
		pos = str.indexOf(_old);
	};
	
	return str;
};

MovieClip.prototype.drawRect2 = function(x1,y1,x2,y2,l_gauge,l_color,l_alpha,fill_color,fill_alpha)
{	
	//trace('This ' + this + ' x ' + x1 + ' y1 ' + y1 + ' x2 ' + x2 + ' y2 ' + y2 + ' lg ' + l_gauge + ' col ' + l_color + ' alpha ' + l_alpha);
	
	if (arguments.length < 4){	return; } 
	
	if (arguments.length < 7 && arguments.length > 4) this.lineStyle(l_gauge, l_color);
	else this.lineStyle(l_gauge, l_color, l_alpha);
	
	if(fill_color != undefined && fill_alpha != undefined)
	  this.beginFill(fill_color,fill_alpha);
	
	this.moveTo(x1,y1);
	this.lineTo(x2,y1);
	this.lineTo(x2,y2);
	this.lineTo(x1,y2);
	this.lineTo(x1,y1);
	
	if(fill_color != undefined && fill_alpha != undefined)
	  this.endFill();
};

function setSmiliesDimention()
{
	_global.FlashChatNS.SMILIES = new Object();
	
	for(var i=0; i < SmileTextConst.patternList.length; i++)
	{ 	
		this.attachMovie(SmileTextConst.patternList[i][1], "ico", this.getNextHighestDepth());
		if(this.ico == undefined) continue;

		this.ico.moveTo(0,0);
		this.ico.lineTo(0,5);
		
		var w = 0, h = 0;
		var smi_w = SmileTextConst.patternList[i][2];
		var smi_h = SmileTextConst.patternList[i][3];
		if(smi_w != undefined && smi_h != undefined)
		{ 	
			w = smi_w;
			h = smi_h;
		}
		else
		{ 
			for(var j=1; j<= this.ico._totalframes; j++ )
			{ 
				this.ico.gotoAndStop(j);
				w = Math.max(w, this.ico._width);	
				h = Math.max(h, this.ico._height);	
			}
		}
		
		var smile_name = SmileTextConst.patternList[i][1];		
		_global.FlashChatNS.SMILIES[smile_name] = new Object();
		
		_global.FlashChatNS.SMILIES[smile_name]["width"] = w;
		_global.FlashChatNS.SMILIES[smile_name]["height"] = h;
		
		this.ico.removeMovieClip();
	}
};

function filterImgUrl(imageURL)
{
	var arr = this._url.split('/'); 
	arr.splice(arr.length-1, 1);
	var chatURL = arr.join('/'); 
	
	var filterURL = 'inc/swfimageproxy/swfimgproxy.php?url=' + chatURL + '/' + imageURL;
	//_global.FlashChatNS.chatUI.mc.msgTxt.text = filterURL;
		
	return filterURL;
};