//#initclip 10

_global.XPLook = function() {
	super();
};

_global.XPLook.prototype = new Object();

// data {className - component name, type - type of component, mode - press, over,..., pLink - link to an object, clr - color}
_global.XPLook.prototype.draw = function(movie:MovieClip, nW:Number, nH:Number, data:Object):Void
{
	if(movie == undefined) return;
	
	var clr = 0;
	switch(data.mode)
	{
		case data.pLink.STATE_OUT      : clr = globalStyleFormat[data.pLink._face]; break;
		case data.pLink.STATE_OVER     : clr = this.ex_brighter(globalStyleFormat[data.pLink._face], 0.77); break;
		case data.pLink.STATE_PRESS    : clr = globalStyleFormat[data.pLink._face]; break;
		case data.pLink.STATE_DISABLED : clr = this.brighter(this.brighter(globalStyleFormat[data.pLink._face])); break;
		default: clr = globalStyleFormat[data.pLink._face]; break;
	}
	data.clr = clr;
	
	switch(data.type)
	{
		case data.pLink.BG_TYPE_COMBO:
			data.clr = globalStyleFormat[data.pLink._background];
			this.drawComboBox(movie, nW, nH, data);
			break;
		case data.pLink.BG_TYPE_SCROLL:
			data.clr = globalStyleFormat[data.pLink._scroll_track];
			this.drawScrollBack(movie, nW, nH, data);
			break;
		case data.pLink.BTN_TYPE_COMBO:
			data.clr = clr;
			this.drawComboBoxBtn(movie, nW, nH, data);
			break;
		case data.pLink.BTN_TYPE_SCROLL:
			movie.clear();
			this.drawScroll(movie, nW, nH, clr, globalStyleFormat[data.pLink._highlight], data);
			//trace('w ' + movie._width + ' w2 ' + nW);
			break;
		case data.pLink.BTN_TYPE_SCROLL_LOW:
		case data.pLink.BTN_TYPE_SCROLL_HI:
			data.clr = clr;
			this.drawScrollLayer(movie, nW, nH, data);
			break;
		case data.pLink.BTN_TYPE_HIDE:
		case data.pLink.BTN_TYPE_MINIMIZE:
		case data.pLink.BTN_TYPE_CLOSE:
			this.drawTitleButton(movie, nW, nH, data);
			break;
		case "resizeHandle":
			drawResizeHandleBtn(movie, nW, nH, 0x8f8f8f);
			break;
		case "comboBox":
			drawLayer(movie, nW, nH, 0xffffff, 0x303030, data.border);
			break;
		default:
			movie.clear();
			this.drawRoundBtn(movie, 0, 0, nW, nH, data.clr, globalStyleFormat[data.pLink._highlight], data);
			break;
	}
}

_global.XPLook.prototype.drawScrollLayer = function(movie:MovieClip, nW:Number, nH:Number, data:Object):Void
{
	this.drawSquareBtn(movie, 0, 0, nW, nH, data.clr, globalStyleFormat[data.pLink._highlight], data);
	var dir:String = "";
	switch(data.dir)
	{
		case "vert":
			switch(data.type)
			{
				case data.pLink.BTN_TYPE_SCROLL_LOW: dir="up"; break;
				case data.pLink.BTN_TYPE_SCROLL_HI: dir="down"; break;
			}
			break;
		case "horz":
			switch(data.type)
			{
				case data.pLink.BTN_TYPE_SCROLL_LOW: dir="left"; break;
				case data.pLink.BTN_TYPE_SCROLL_HI: dir="right"; break;
			}
			break;
	}
	if(dir) this.drawSingleArrow(movie, 3, 3, nW - 6, nH - 6, dir, globalStyleFormat[data.pLink._arrow_xp]);
}

_global.XPLook.prototype.drawSingleArrow = function(movie:MovieClip, nX:Number, nY:Number, nW:Number, nH:Number, dir:String, clr:Number, alpha:Number):Void
{
	if(!alpha) alpha = 100;
	var bVert:Boolean = dir == "up" || dir == "down";
	var size:Number = bVert 
		? (nW / 2 > nH ? nH * 2 : nW)
		: (nH / 2 > nW ? nW * 2 : nH);
	size -= size % 2;
	var halfSize:Number = size / 2;
	var x:Number = nX + Math.round((nW - (bVert ? size : halfSize)) / 2);
	var y:Number = nY + Math.round((nH - (bVert ? halfSize : size)) / 2);
	switch(dir)
	{
		case "up":
			this.drawRect(movie, x, y + halfSize - 2, 1, 2, clr, alpha);
			this.drawRect(movie, x + size - 1, y + halfSize - 2, 1, 2, clr, alpha);
			for(var i:Number = 1; i < halfSize; i++)
			{
				this.drawRect(movie, x + i, y + halfSize - i - 2, 1, 3, clr, alpha);
				this.drawRect(movie, x + size - i - 1, y + halfSize - i - 2, 1, 3, clr, alpha);
			}
			break;
		case "down":
			this.drawRect(movie, x, y, 1, 2, clr, alpha);
			this.drawRect(movie, x + size - 1, y, 1, 2, clr, alpha);
			for(var i:Number = 1; i < halfSize; i++)
			{
				this.drawRect(movie, x + i, y + i - 1, 1, 3, clr, alpha);
				this.drawRect(movie, x + size - i - 1, y + i - 1, 1, 3, clr, alpha);
			}
			break;
		case "left":
			this.drawRect(movie, x + halfSize - 2, y, 2, 1, clr, alpha);
			this.drawRect(movie, x + halfSize - 2, y + size - 1, 2, 1, clr, alpha);
			for(var i:Number = 1; i < halfSize; i++)
			{
				this.drawRect(movie, x + halfSize - i - 2, y + i, 3, 1, clr, alpha);
				this.drawRect(movie, x + halfSize - i - 2, y + size - i - 1, 3, 1, clr, alpha);
			}
			break;
		case "right":
			this.drawRect(movie, x, y, 2, 1, clr, alpha);
			this.drawRect(movie, x, y + size - 1, 2, 1, clr, alpha);
			for(var i:Number = 1; i < halfSize; i++)
			{
				this.drawRect(movie, x + i - 1, y + i, 3, 1, clr, alpha);
				this.drawRect(movie, x + i - 1, y + size - i - 1, 3, 1, clr, alpha);
			}
			break;
	}
}

_global.XPLook.prototype.drawScroll = function(movie:MovieClip, nW:Number, nH:Number, col:Number, colBg:Number, data:Object):Void
{
	this.drawRoundBtn(movie, 0.5, 0, nW, nH, col, colBg, data);
	if(data.dir == "vert")
	{
		if(nH > 15)
		{
			var x:Number = 3;
			var y:Number = Math.round((nH - 8) / 2);
			var w:Number = nW - 6;
			for(var i:Number = 0; i < 8; i++)
				this.drawRect(movie, x + (i % 2 ? 1 : 0), y + i, w, 1, i % 2 ? this.ex_darker(col, 0.8) : this.ex_brighter(col, 0.7), 100);
		}
	}
	else
	{
		if(nW > 15)
		{
			var x:Number = Math.round((nW - 8) / 2);
			var y:Number = 3;
			var h:Number = nH - 6;
			for(var i:Number = 0; i < 8; i++)
				this.drawRect(movie, x + i, y + (i % 2 ? 1 : 0), h, i % 2 ? this.ex_darker(col, 0.8) : this.ex_brighter(col, 0.7), 1);
		}
	}
}

_global.XPLook.prototype.drawScrollBack = function(movie:MovieClip, nW:Number, nH:Number, data:Object):Void
{
	movie.clear();
	var bVert:Boolean = data.dir == "vert";
	var colors:Array = new Array(data.clr, 0xfcfcfe);
	var alphas:Array = new Array(100, 100);
	var ratios:Array = new Array(0, 188);
	var matrix:Object = {matrixType:"box", x:0, y:0, w:nW, h:nH, r:bVert ? 0 : Math.PI / 2};
	movie.lineStyle(1, data.clr);
	movie.beginGradientFill("linear", colors, alphas, ratios, matrix);
	this.drawFillRect(movie, 0, 0, nW, nH);
	movie.endFill();
	movie.lineStyle(undefined);
	delete colors;
	delete alphas;
	delete ratios;
	delete matrix;
}

_global.XPLook.prototype.drawFillRect = function(movie:MovieClip, x:Number, y:Number, w:Number, h:Number):Void
{
	movie.moveTo(x, y);
	movie.lineTo(x + w, y);
	movie.lineTo(x + w, y + h);
	movie.lineTo(x, y + h);
	movie.lineTo(x, y);
}

_global.XPLook.prototype.drawRoundBtn = function(movie:MovieClip, x:Number, y:Number, w:Number, h:Number, col:Number, colBorder:Number, data:Object):Void
{
	movie.clear();
	var r:Number = Math.min(data.type == data.pLink.BTN_TYPE_SCROLL ? 2 : 4, Math.min(w, h) / 2);
	var d:Number = data.type == data.pLink.BTN_TYPE_SCROLL ? 0.5 : 0;
	var bVert:Boolean = w < h;
	this.fillRoundRect(movie, x, y, w, h, r, col, 100, colBorder, 100);
	var colors:Array = new Array(0xffffff, 0xffffff, 0xffffff, 0xffffff);
	var alphas:Array = new Array(50, 65, 45, 0);
	var ratios:Array = new Array(0, 60, 120, 255);
	var flare:Number = (bVert ? w : h) * 2 / 3;
	var matrix:Object = bVert
		? {matrixType:"box", x:1+d, y:1, w:flare, h:h - 2, r:0}
		: {matrixType:"box", x:1+d, y:1, w:w - 2, h:flare, r:Math.PI / 2};
	movie.beginGradientFill("linear", colors, alphas, ratios, matrix);
	this.drawRoundRect(movie, 1+d, 1, bVert ? flare + 1 : w - 1, bVert ? h - 1 : flare + 1, Math.max(0, r - 0.5));
	movie.endFill();
	switch(data.mode)
	{
		case data.pLink.STATE_PRESS: this.fillRoundRect(movie, x, y, w, h, r, 0, 10); break;
		case data.pLink.STATE_OVER : this.fillRoundRect(movie, x, y, w, h, r, this.darker(0xffffff), 20); break;
	}
}

_global.XPLook.prototype.drawTitleButton = function(movie:MovieClip, nW:Number, nH:Number, data:Object):Void
{
	movie.clear();
	movie._alpha = 100; // xxx this line fixes alpha value, changed in other themes
	var bFaded:Boolean = data.faded && data.mode == data.pLink.STATE_OUT;
	switch(data.type)
	{
		case data.pLink.BTN_TYPE_HIDE:
			this.drawSquareBtn(movie, 0, 0, nW, nH, bFaded ? 0x78c5fe : data.clr, globalStyleFormat[data.pLink._highlight], data);
			var nOffX:Number = Math.round((0.6*nW) / 2);
			var nOffY:Number = Math.round((0.5*nH) / 2);
			this.drawRect(movie, nOffX - 1/16*nW, nOffY + 0.4*nW, 0.4*nW, 0.18*nH, globalStyleFormat[data.pLink._arrow]);
			break;
		case data.pLink.BTN_TYPE_MINIMIZE:
			this.drawSquareBtn(movie, 0, 0, nW, nH, bFaded ? 0x78c5fe : data.clr, globalStyleFormat[data.pLink._highlight], data);
			var nOffX:Number = Math.round((nW - 9) / 2);
			var nOffY:Number = Math.round((nH - 9) / 2);
			var clr:Number = globalStyleFormat[data.pLink._arrow];
			if(data.state == "sunken")
			{
				this.drawRect(movie, nOffX + 2, nOffY, 7, 2, clr);
				this.drawRect(movie, nOffX + 8, nOffY + 2, 1, 4, clr);
				this.drawRect(movie, nOffX, nOffY + 3, 7, 2, clr);
				this.drawRect(movie, nOffX, nOffY + 5, 1, 4, clr);
				this.drawRect(movie, nOffX + 1, nOffY + 8, 6, 1, clr);
				this.drawRect(movie, nOffX + 6, nOffY + 5, 1, 4, clr);
			}
			else
			{
				this.drawRect(movie, nOffX, nOffY, 9, 2, clr);
				this.drawRect(movie, nOffX, nOffY + 2, 1, 7, clr);
				this.drawRect(movie, nOffX + 1, nOffY + 8, 8, 1, clr);
				this.drawRect(movie, nOffX + 8, nOffY + 2, 1, 7, clr);
			}
			break;
		case data.pLink.BTN_TYPE_CLOSE:
			if(nW > nH)
				this.drawRoundBtn(movie, 0, 0, nW, nH, data.clr, globalStyleFormat[data.pLink._highlight], data);
			else
				this.drawSquareBtn(movie, 0, 0, nW, nH, bFaded ? 0xf9aa7b : data.clr, globalStyleFormat[data.pLink._highlight], data);
				
			this.drawCross(movie, 0, 0, nW, nH, globalStyleFormat[data.pLink._arrow]);
			break;
	}
}

_global.XPLook.prototype.drawSquareBtn = function(movie:MovieClip, x:Number, y:Number, w:Number, h:Number, col:Number, colBorder:Number, data:Object):Void
{
	movie.clear();
	var r:Number = Math.min(data.type == data.pLink.BTN_TYPE_SCROLL_LOW || data.type == data.pLink.BTN_TYPE_SCROLL_HI ? 1 : 3, Math.min(w, h) / 2);
	this.fillRoundRect(movie, x + 0.5, y + 0.5, w - 0.5, h - 0.5, r, col, 100, colBorder, 100);
	var colors:Array = new Array(0xffffff, 0xffffff);
	var alphas:Array = new Array(60, 0);
	var ratios:Array = new Array(40, 255);
	var flareH:Number = h * 2 / 3;
	var matrix:Object = {a:w - 2, b:0, c:0, d:0, e:flareH, f:0, g:w / 4, h:h / 4, i:1};
	movie.beginGradientFill("radial", colors, alphas, ratios, matrix);
	this.drawRoundRect(movie, 1, 1, w - 1, flareH + 1, Math.max(0, r - 0.5));
	movie.endFill();
	switch(data.mode)
	{
		case data.pLink.STATE_PRESS: this.fillRoundRect(movie, x, y, w, h, r, 0, 10); break;
		case data.pLink.STATE_OVER : this.fillRoundRect(movie, x, y, w, h, r, 0xffffff, 20); break;
	}
}

_global.XPLook.prototype.drawCross = function(movie:MovieClip, nX:Number, nY:Number, nW:Number, nH:Number, clr:Number, alpha:Number):Void
{
	var size:Number = 0.5*16;
	var size2:Number = Math.round(size / 2);
	var bx:Number = nX + Math.round((nW - 0.5*nW) / 2);
	var by:Number = nY + Math.round((nH - 0.5*nH) / 2);
	var dX:Number = 1;
	var dY:Number = 1;
	
	var mc:MovieClip = movie.createEmptyMovieClip('mc', 100);
	mc._x = bx;
	mc._y = by;
	
	var x:Number = 0;
	var y:Number = 0;
	
	this.drawLine(mc, x, y, x + size - dX, y + size - dY, clr, alpha);
	this.drawLine(mc, x + dX, y, x + size - dX, y + size - 2*dY, clr, alpha);
	this.drawLine(mc, x, y + dY, x + size - 2*dX, y + size - dY, clr, alpha);

	this.drawLine(mc, x, y + size - dY, x + size2 - 2*dX, y + size2 + dY, clr, alpha);
	this.drawLine(mc, x + dX, y + size - dY, x + size2 - dX, y + size2 + dY, clr, alpha);
	this.drawLine(mc, x, y + size - 2*dY, x + size2 - 2*dX, y + size2, clr, alpha);

	this.drawLine(mc, x + size2 + dX, y + size2 - 2*dY, x + size - dX, y, clr, alpha);
	this.drawLine(mc, x + size2 + dX, y + size2 - dY, x + size - dX, y + dY, clr, alpha);
	this.drawLine(mc, x + size2, y + size2 - 2*dY, x + size - 2*dX, y, clr, alpha);
	
	mc._width  = 0.5*nW; 
	mc._height = 0.5*nH;
}

_global.XPLook.prototype.drawComboBoxBtn = function(movie:MovieClip, nW:Number, nH:Number, data:Object):Void
{
	this.drawScrollLayer(movie, nW, nH, {mode:data.mode, dir:"vert", type:data.pLink.BTN_TYPE_SCROLL_HI, pLink : data.pLink, clr : data.clr});
}

_global.XPLook.prototype.drawComboBox = function(movie:MovieClip, nW:Number, nH:Number, data:Object):Void
{
	movie.clear();
		switch(data.mode)
		{
			default:
				movie.lineStyle(1, globalStyleFormat[data.pLink._backgroundBorder], 100);
				movie.beginFill(data.clr, 100);
				this.drawFillRect(movie, 0.5, 0.5, nW - 1, nH - 1);
				movie.endFill();
				movie.lineStyle(undefined);
				break;
		}
}

_global.XPLook.prototype.drawRect = function(movie:MovieClip, nX:Number, nY:Number, nW:Number, nH:Number, nColor:Number, nAlpha:Number):Void
{
	if(!nColor) nColor = 0;
	if(nAlpha == undefined || nAlpha == null) nAlpha = 100;
	with(movie)
	{
		beginFill(nColor, nAlpha);
		moveTo(nX, nY);
		lineTo(nX + nW, nY);
		lineTo(nX + nW, nY + nH);
		lineTo(nX, nY + nH);
		lineTo(nX, nY);
		endFill();
	}
}

_global.XPLook.prototype.drawLine = function(movie:MovieClip, x1:Number, y1:Number, x2:Number, y2:Number, clr:Number, alpha:Number):Void
{
	var dx:Number = Math.abs(x2 - x1);
	var dy:Number = Math.abs(y2 - y1);
	var sx:Number = x2 >= x1 ? 1 : -1;
	var sy:Number = y2 >= y1 ? 1 : -1;
	this.drawRect(movie, x1, y1, 1, 1, clr, alpha);
	if(dy <= dx)
	{
		var d1:Number = dy << 1;
		var d:Number  = d1 - dx;
		var d2:Number = ( dy - dx ) << 1;
		var x:Number = x1 + sx;
		var y:Number = y1;
		for(var i:Number = 1; i <= dx; i++)
		{
			if (d > 0)
			{
				d += d2;
				y += sy;
			}
			else d += d1;
			this.drawRect(movie, x, y, 1, 1, clr, alpha);
			x += sx;
		}
	}
	else
	{
		var d1:Number = dx << 1;
		var d:Number  = d1 - dy;
		var d2:Number = (dx - dy) << 1;
		var x:Number = x1;
		var y:Number = y1 + sy;
		for (var i:Number = 1; i <= dy; i++)
		{
			if( d > 0)
			{
				d += d2;
				x += sx;
			}
			else d += d1;
			this.drawRect(movie, x, y, 1, 1, clr, alpha);
			y += sy;
		}
	}
}

	
_global.XPLook.prototype.fillRoundRect = function(movie:MovieClip, x:Number, y:Number, w:Number, h:Number, r:Number,
	bgCol:Number, bgAlpha:Number, lineCol:Number, lineAlpha:Number):Void
{
	if(!bgAlpha) bgAlpha = 100;
	movie.beginFill(bgCol, bgAlpha)
	this.drawRoundRect(movie, x, y, w, h, r, lineCol, lineAlpha);
	movie.endFill();
}
	
_global.XPLook.prototype.drawRoundRect = function(movie:MovieClip, nX1:Number, nY1:Number, nX2:Number,
	nY2:Number, cornerRadius:Number, color:Number, alpha:Number, nSize:Number):Void
{
	if(nSize == undefined || nSize == null) nSize = 1;
	if(alpha == undefined) alpha = 100;
	if(color == null || color == undefined) movie.lineStyle(undefined);
	else movie.lineStyle(nSize, color, alpha);
	var x:Number = Math.min(nX1, nX2);
	var y:Number = Math.min(nY1, nY2);
	var w:Number = Math.abs(nX2 - nX1);
	var h:Number = Math.abs(nY2 - nY1);
	// ==============
	// mc.drawRect() - by Ric Ewing (ric@formequalsfunction.com) - version 1.1 - 4.7.2002
	// 
	// x, y = top left corner of rect
	// w = width of rect
	// h = height of rect
	// cornerRadius = [optional] radius of rounding for corners (defaults to 0)
	// ==============
	if (arguments.length < 4) return;
	// if the user has defined cornerRadius our task is a bit more complex. :)
	if (cornerRadius > 0)
	{
		// init vars
		var theta, angle, cx, cy, px, py;
		// make sure that w + h are larger than 2*cornerRadius
		var cr:Number = Math.min(w, h) / 2;
		if (cornerRadius > cr)
			cornerRadius = cr;
		// theta = 45 degrees in radians
		theta = Math.PI / 4;
		// draw top line
		movie.moveTo(x + cornerRadius, y);
		movie.lineTo(x + w - cornerRadius, y);
		//angle is currently 90 degrees
		angle = -Math.PI / 2;
		// draw tr corner in two parts
		cx = x + w - cornerRadius + (Math.cos(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
		cy = y + cornerRadius + (Math.sin(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
		px = x + w - cornerRadius + (Math.cos(angle + theta) * cornerRadius);
		py = y + cornerRadius + (Math.sin(angle + theta) * cornerRadius);
		movie.curveTo(cx, cy, px, py);
		angle += theta;
		cx = x + w - cornerRadius + (Math.cos(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
		cy = y + cornerRadius + (Math.sin(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
		px = x + w - cornerRadius + (Math.cos(angle + theta) * cornerRadius);
		py = y + cornerRadius + (Math.sin(angle + theta) * cornerRadius);
		movie.curveTo(cx, cy, px, py);
		// draw right line
		movie.lineTo(x + w, y + h - cornerRadius);
		// draw br corner
		angle += theta;
		cx = x + w - cornerRadius + (Math.cos(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
		cy = y + h - cornerRadius + (Math.sin(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
		px = x + w - cornerRadius + (Math.cos(angle + theta) * cornerRadius);
		py = y + h - cornerRadius + (Math.sin(angle + theta) * cornerRadius);
		movie.curveTo(cx, cy, px, py);
		angle += theta;
		cx = x + w - cornerRadius + (Math.cos(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
		cy = y + h - cornerRadius + (Math.sin(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
		px = x + w - cornerRadius + (Math.cos(angle + theta) * cornerRadius);
		py = y + h - cornerRadius + (Math.sin(angle + theta) * cornerRadius);
		movie.curveTo(cx, cy, px, py);
		// draw bottom line
		movie.lineTo(x+cornerRadius, y+h);
		// draw bl corner
		angle += theta;
		cx = x + cornerRadius + (Math.cos(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
		cy = y + h - cornerRadius + (Math.sin(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
		px = x + cornerRadius + (Math.cos(angle + theta) * cornerRadius);
		py = y + h - cornerRadius + (Math.sin(angle + theta) * cornerRadius);
		movie.curveTo(cx, cy, px, py);
		angle += theta;
		cx = x + cornerRadius + (Math.cos(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
		cy = y + h - cornerRadius + (Math.sin(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
		px = x + cornerRadius + (Math.cos(angle + theta) * cornerRadius);
		py = y + h - cornerRadius + (Math.sin(angle + theta) * cornerRadius);
		movie.curveTo(cx, cy, px, py);
		// draw left line
		movie.lineTo(x, y + cornerRadius);
		// draw tl corner
		angle += theta;
		cx = x + cornerRadius + (Math.cos(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
		cy = y + cornerRadius + (Math.sin(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
		px = x + cornerRadius + (Math.cos(angle+  theta) * cornerRadius);
		py = y + cornerRadius + (Math.sin(angle + theta) * cornerRadius);
		movie.curveTo(cx, cy, px, py);
		angle += theta;
		cx = x + cornerRadius + (Math.cos(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
		cy = y + cornerRadius + (Math.sin(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
		px = x + cornerRadius + (Math.cos(angle + theta) * cornerRadius);
		py = y + cornerRadius + (Math.sin(angle + theta) * cornerRadius);
		movie.curveTo(cx, cy, px, py);
	}
	else
	{
		// cornerRadius was not defined or = 0. This makes it easy.
		movie.moveTo(x, y);
		movie.lineTo(x + w, y);
		movie.lineTo(x + w, y + h);
		movie.lineTo(x, y + h);
		movie.lineTo(x, y);
	}
}
	
	
//
// drops drawing routine
//
_global.XPLook.prototype.rgb2hsb = function(colRGB:Number):Object
{
	var red:Number = (colRGB & 0xff0000) >> 16;
	var gre:Number = (colRGB & 0x00ff00) >> 8;
	var blu:Number = colRGB & 0x0000ff;
	var max:Number = Math.max(red, Math.max(gre, blu));
	var min:Number = Math.min(red, Math.min(gre, blu));
	var hsb:Object = new Object({h:0, s:0, b:Math.round(max * 100 / 255)});
	if(max != min)
	{ 
		hsb.s = Math.round(100 * (max - min) / max);
		var tmpR:Number = (max - red) / (max - min);
		var tmpG:Number = (max - gre) / (max - min);
		var tmpB:Number = (max - blu) / (max - min);
		switch(max)
		{
			case red: hsb.h = tmpB - tmpG; break;
			case gre: hsb.h = 2 + tmpR - tmpB; break;
			case blu: hsb.h = 4 + tmpG - tmpR; break;
		}
		hsb.h = (Math.round(hsb.h * 60) + 360) % 360;
	}
	return hsb;
}

_global.XPLook.prototype.hsb2rgb = function(hsb:Object):Number
{
	var red:Number = hsb.b;
	var gre:Number = hsb.b;
	var blu:Number = hsb.b;
	if(hsb.s)
	{ // if not grey
		var hue:Number = (hsb.h + 360) % 360;
		var dif:Number = (hue % 60) / 60;
		var mid1:Number = hsb.b * (100 - hsb.s * dif) / 100;
		var mid2:Number = hsb.b * (100 - hsb.s * (1 - dif)) / 100;
		var min:Number = hsb.b * (100 - hsb.s) / 100;
		switch(Math.floor(hue / 60))
		{
			case 0: red = hsb.b; gre = mid2; blu = min; break;
			case 1: red = mid1; gre = hsb.b; blu = min; break;
			case 2: red = min; gre = hsb.b; blu = mid2; break;
			case 3: red = min; gre = mid1; blu = hsb.b; break;
			case 4: red = mid2; gre = min; blu = hsb.b; break;
			default: red = hsb.b; gre = min; blu = mid1; break;
		}
	}
	return Math.round(red * 2.55) * 65536 +
		Math.round(gre * 2.55) * 256 +
		Math.round(blu * 2.55);
}

_global.XPLook.prototype.ex_brighter = function(rgb, fact) {
	var FACTOR = fact;
	var c = this.RGB2Obj(Number(rgb));

	var i = Math.ceil(5.0 / (1.0 - FACTOR));

	if(c.r == 0 && c.g == 0 && c.b == 0) return this.Obj2RGB({r:i, g:i, b:i});

	if ( c.r > 0 && c.r < i ) c.r = i;
	if ( c.g > 0 && c.g < i ) c.g = i;
	if ( c.b > 0 && c.b < i ) c.b = i;

	var ret = {r:Math.min(Math.ceil(c.r/FACTOR), 255), g:Math.min(Math.ceil(c.g/FACTOR), 255), b:Math.min(Math.ceil(c.b/FACTOR), 255)};

	return this.Obj2RGB(ret);
}

_global.XPLook.prototype.ex_darker = function(rgb, fact) {
	var FACTOR = fact;
	var c = this.RGB2Obj(rgb);
	var ret = {r:Math.max(Math.ceil(c.r*FACTOR), 0), g:Math.max(Math.ceil(c.g*FACTOR), 0), b:Math.max(Math.ceil(c.b*FACTOR), 0)};

	return this.Obj2RGB(ret);
}

_global.XPLook.prototype.brighter = function(rgb) {
	return this.ex_brighter(rgb, 0.7);
}

_global.XPLook.prototype.darker = function(rgb) {
	return this.ex_darker(rgb, 0.7);
}

_global.XPLook.prototype.RGB2Obj = function(rgb) {
	var r = (rgb & 0x00ff0000) >>> 16;
	var g = (rgb & 0x0000ff00) >>> 8;
	var b = (rgb & 0x000000ff);

	return { r:r, g:g, b:b };
}

_global.XPLook.prototype.Obj2RGB = function(obj) {
	var rgb = (obj.r << 16) | (obj.g << 8) | obj.b;
	return rgb;
}
	
Object.registerClass('XPLook', _global.XPLook);

//#endinitclip