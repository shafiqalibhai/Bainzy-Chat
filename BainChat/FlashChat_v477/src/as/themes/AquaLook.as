//#initclip 10

_global.AquaLook = function() {
	super();
};

_global.AquaLook.prototype = new Object();

// data {className - component name, type - type of component, mode - press, over,..., pLink - link to an object, clr - color}
_global.AquaLook.prototype.draw = function(movie:MovieClip, nW:Number, nH:Number, data:Object):Void
{
	if(movie == undefined) return;
	
	var clr = 0;
	switch(data.mode)
	{
		case data.pLink.STATE_OUT      : clr = globalStyleFormat[data.pLink._face]; break;
		case data.pLink.STATE_OVER     : clr = this.ex_brighter(globalStyleFormat[data.pLink._face], 0.77); break;
		case data.pLink.STATE_PRESS    : clr = globalStyleFormat[data.pLink._face]; break;
		case data.pLink.STATE_DISABLED : clr = this.brighter(this.brighter(globalStyleFormat[data.pLink._face])); break;
	}
	data.clr = clr;
	
	//trace('W ' + nW + ' H ' + nH + ' this ' + movie);
	
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
			//data.clr = globalStyleFormat[data.pLink._face];
			data.clr = globalStyleFormat[data.pLink._scroll_track];
			this.drawComboBoxBtn(movie, nW, nH, data);
			break;
		case data.pLink.BTN_TYPE_SCROLL:
			movie.clear();
			//data.clr = globalStyleFormat[data.pLink._scroll_face];
			this.drawRoundDrop(movie, 0, 0, nW, nH, data.clr, data);
			break;
		case data.pLink.BTN_TYPE_SCROLL_LOW:
		case data.pLink.BTN_TYPE_SCROLL_HI:
			data.clr = globalStyleFormat[data.pLink._scroll_arrow];
			this.drawScrollLayer(movie, nW, nH, data);
			break;
		case data.pLink.BTN_TYPE_HIDE:
		case data.pLink.BTN_TYPE_MINIMIZE:
		case data.pLink.BTN_TYPE_CLOSE:
			this.drawTitleButton(movie, nW, nH, data);
			break;
		case "resizeHandle":
			drawResizeHandleBtn(movie, nW, nH, data.clr); //!
			break;
		case data.pLink.BTN_TYPE_RECT:
			drawLayer(movie, nW, nH, 0xffffff, data.clr, data.border);//!
			break;
		default:
			movie.clear();
			this.drawRoundDrop(movie, 0, 0, nW, nH, data.clr, data);
			break;
	}
}

_global.AquaLook.prototype.drawScrollLayer = function(movie:MovieClip, nW:Number, nH:Number, data:Object):Void
{
	movie.clear();
	var colors:Array = new Array(0xffffff, 0xffffff, 0xffffff);
	var alphas:Array = new Array(50, 100, 50);
	var ratios:Array = new Array(0, 180, 255);
	var bLow:Boolean = data.type == data.pLink.BTN_TYPE_SCROLL_LOW;
	
	if(data.dir == "vert")
	{
		var w:Number = nW * 4 / 11;
		var h:Number = nH / 3;
		var off:Number = bLow ? 1 : 0;
		var matrix:Object = {matrixType:"box", x:1, y:off, w:w, h:nH - (1 - off), r:0};
		movie.beginGradientFill("linear", colors, alphas, ratios, matrix);
		movie.moveTo(1, off);
		var obj:Object = this.drawArc(movie, 1, off, w, -90, 90, h);
		var curX:Number = w + 1;
		var curY:Number = nH - h - (1 - off);
		movie.lineTo(curX, curY);
		obj = this.drawArc(movie, curX, curY, w, -90, 0, h);
		movie.lineTo(1, off);
		movie.endGradientFill();
		//1) color of arrow 2) alpha
		movie.beginFill(0, 80);
		w = nH / 3;
		h = nH / 5;
		movie.moveTo(nW / 2, bLow ? nH / 2 - h : nH / 2 + h);
		movie.lineTo(nW / 2 - w / 2, bLow ? nH / 2 + h : nH / 2 - h);
		movie.lineTo(nW / 2 + w / 2, bLow ? nH / 2 + h : nH / 2 - h);
		movie.lineTo(nW / 2, bLow ? nH / 2 - h : nH / 2 + h);
		movie.endFill();
	}
	else
	{
		var w:Number = nW / 3;
		var h:Number = nH * 4 / 11;
		var off:Number = data.type == data.pLink.BTN_TYPE_SCROLL_LOW ? 1 : 0;
		var matrix:Object = {matrixType:"box", x:off, y:1, w:w - (1 - off), h:nH, r:Math.PI / 2};
		movie.beginGradientFill("linear", colors, alphas, ratios, matrix);
		movie.moveTo(off, 1);
		var obj:Object = this.drawArc(movie, off, 1, w, 90, 180, h);
		var curX:Number = nW - w - (1 - off);
		var curY:Number = h + 1;
		movie.lineTo(curX, curY);
		obj = this.drawArc(movie, curX, curY, w, 90, 270, h);
		movie.lineTo(off, 1);
		movie.endFill();
		movie.beginFill(0, 80);
		w = nW / 5;
		h = nW / 3;
		movie.moveTo(bLow ? nW / 2 - w : nW / 2 + w, nH / 2);
		movie.lineTo(bLow ? nW / 2 + w : nW / 2 - w, nH / 2 - h / 2);
		movie.lineTo(bLow ? nW / 2 + w : nW / 2 - w, nH / 2 + h / 2);
		movie.lineTo(bLow ? nW / 2 - w : nW / 2 + w, nH / 2);
		movie.endFill();
	}
	
	delete colors;
	delete alphas;
	delete ratios;
	delete matrix;
	movie.drawRect(0, 0, nW, nH, 0, 0);
}

_global.AquaLook.prototype.drawArc = function(movie:MovieClip, x:Number, y:Number, radius:Number,
	arc:Number, startAngle:Number, yRadius:Number, color:Number):Object
{
	if(color != null && color != undefined) movie.lineStyle(1, color, 100);
	// if yRadius is undefined, yRadius = radius
	if (yRadius == undefined) yRadius = radius;
	// Init vars
	var segAngle, theta, angle, angleMid, segs, ax, ay, bx, by, cx, cy:Number;
	// no sense in drawing more than is needed :)
	if (Math.abs(arc) > 360) arc = 360;
	segs = Math.ceil(Math.abs(arc) / 45);
	// Now calculate the sweep of each segment
	segAngle = arc / segs;
	// The math requires radians rather than degrees. To convert from degrees
	// use the formula (degrees/180)*Math.PI to get radians. 
	theta = -(segAngle / 180) * Math.PI;
	// convert angle startAngle to radians
	angle = -(startAngle / 180) * Math.PI;
	// find our starting points (ax,ay) relative to the specified x,y
	ax = x - Math.cos(angle) * radius;
	ay = y - Math.sin(angle) * yRadius;
	// if our arc is larger than 45 degrees, draw as 45 degree segments
	// so that we match Flash's native circle routines.
	if (segs > 0)
	{
		// Loop for drawing arc segments
		for (var i = 0; i < segs; i++)
		{
			// increment our angle
			angle += theta;
			// find the angle halfway between the last angle and the new
			angleMid = angle-(theta / 2);
			// calculate our end point
			bx = ax + Math.cos(angle) * radius;
			by = ay + Math.sin(angle) * yRadius;
			// calculate our control point
			cx = ax + Math.cos(angleMid) * (radius / Math.cos(theta / 2));
			cy = ay + Math.sin(angleMid) * (yRadius / Math.cos(theta / 2));
			// draw the arc segment
			movie.curveTo(cx, cy, bx, by);
		}
	}
	return {x:bx, y:by};
}

_global.AquaLook.prototype.drawScrollBack = function(movie:MovieClip, nW:Number, nH:Number, data:Object):Void
{
	movie.clear();
	var bVert:Boolean = data.dir == "vert";
	var colors:Array = new Array(data.clr, 0xffffff);
	var alphas:Array = new Array(100, 100);
	var ratios:Array = new Array(0, 188);
	var matrix:Object = {matrixType:"box", x:0, y:0, w:nW, h:nH, r:bVert ? 0 : Math.PI / 2};
	movie.beginGradientFill("linear", colors, alphas, ratios, matrix);
	this.drawFillRect(movie, 0, 0, nW, nH);
	movie.endFill();
	delete colors;
	delete alphas;
	delete ratios;
	delete matrix;
	var colors:Array = new Array(globalStyleFormat[data.pLink._scroll_track], 0xffffff);
	var alphas:Array = new Array(30, 0);
	var ratios:Array = new Array(0, 180);
	var size:Number = Math.min(nW, nH);
	var x:Number = bVert ? 0 : size;
	var y:Number = bVert ? size : 0;
	var matrix:Object = {matrixType:"box", x:x, y:y, w:size, h:size, r:bVert ? Math.PI / 2 : 0};
	movie.beginGradientFill("linear", colors, alphas, ratios, matrix);
	this.drawOvalRect(movie, x, y, size, size);
	movie.endFill();
	delete matrix;
	x = bVert ? 0 : nW - size * 2;
	y = bVert ? nH - size * 2: 0;
	var matrix:Object = {matrixType:"box", x:x, y:y, w:size, h:size, r:bVert ? Math.PI * 3 / 2 : Math.PI};
	movie.beginGradientFill("linear", colors, alphas, ratios, matrix);
	this.drawOvalRect(movie, x, y, size, size);
	movie.endFill();
	delete colors;
	delete alphas;
	delete ratios;
	delete matrix;
}

_global.AquaLook.prototype.drawFillRect = function(movie:MovieClip, x:Number, y:Number, w:Number, h:Number):Void
{
	movie.moveTo(x, y);
	movie.lineTo(x + w, y);
	movie.lineTo(x + w, y + h);
	movie.lineTo(x, y + h);
	movie.lineTo(x, y);
}

_global.AquaLook.prototype.drawTitleButton = function(movie:MovieClip, nW:Number, nH:Number, data:Object):Void
{
	movie.clear();
	movie._alpha = 100; // xxx this line fixes alpha value, changed in other themes
	if(!data.faded || data.mode != "out")
	{
		var clr:Number = data.mode == "press" ? 0xffffff : 0;
		var alpha:Number = data.mode == "press" ? 100 : 60;
		switch(data.type)
		{
			case data.pLink.BTN_TYPE_HIDE:
				this.drawDrop(movie, 0, 0, nW, nH, data.clr, data);
				if(data.mode == "press" || data.mode == "over")
					this.drawMinus(movie, 0, 0, nW, nH, clr, alpha);
				break;
			case data.pLink.BTN_TYPE_MINIMIZE:
				this.drawDrop(movie, 0, 0, nW, nH, data.clr, data);
				if(data.mode == "press" || data.mode == "over")
					this.drawPlus(movie, 0, 0, nW, nH, clr, alpha);
				break;
			case data.pLink.BTN_TYPE_CLOSE:
				if(nW > nH)
					this.drawRoundDrop(movie, 0, 0, nW, nH, data.clr, data);
				else
					this.drawDrop(movie, 0, 0, nW, nH, data.clr, data);
				if(data.mode == "press" || data.mode == "over")
					this.drawCross(movie, 0, 0, nW, nH, clr, alpha);
				break;
		}
	}
	else drawDrop(movie, 0, 0, nW, nH, 0xf0f0f0);
}

_global.AquaLook.prototype.drawMinus = function(movie:MovieClip, nX:Number, nY:Number, nW:Number, nH:Number, clr:Number, alpha:Number):Void
{
	var w:Number = 0.5*16;
	var h:Number = 0.15*16;
	var bx:Number = nX + Math.round((nW - 0.5*nW) / 2);
	var by:Number = nY + Math.round((nH - 0.15*nH) / 2);
	
	var mc:MovieClip = movie.createEmptyMovieClip('mc', 100);
	mc._x = bx;
	mc._y = by;
	
	var x:Number = 0;
	var y:Number = 0;
	
	this.drawRect(mc, x, y, w, h, clr, alpha);
	
	mc._width  = 0.5*nW; 
	mc._height = 0.15*nH;
}

_global.AquaLook.prototype.drawPlus = function(movie:MovieClip, nX:Number, nY:Number, nW:Number, nH:Number, clr:Number, alpha:Number):Void
{
	var size:Number = 0.5*nW;
	var thick:Number = 0.1*nH;
	var x:Number = nX + Math.round((nW - size) / 2);
	var y:Number = nY + Math.round((nH - size) / 2);
	var cx:Number = nX + Math.round((nW - thick) / 2);
	var cy:Number = nY + Math.round((nH - thick) / 2);
	var dh:Number = Math.round(size - thick) / 2;
	this.drawRect(movie, x, cy, size, thick, clr, alpha);
	this.drawRect(movie, cx, y, thick, dh, clr, alpha);
	this.drawRect(movie, cx, cy + thick, thick, dh, clr, alpha);
}

_global.AquaLook.prototype.drawCross = function(movie:MovieClip, nX:Number, nY:Number, nW:Number, nH:Number, clr:Number, alpha:Number):Void
{
	var prop:Number = 0.5; 
	var size:Number = prop*16;
	var size2:Number = Math.round(size / 2);
	var bx:Number = nX + Math.round((nW - prop*nW) / 2);
	var by:Number = nY + Math.round((nH - prop*nH) / 2);
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
	
	mc._width  = prop*nW; 
	mc._height = prop*nH;
}

_global.AquaLook.prototype.drawComboBoxBtn = function(movie:MovieClip, nW:Number, nH:Number, data:Object):Void
{
	movie.clear();
	
	var colors:Array = new Array(data.clr, 0xffffff);
	var alphas:Array = new Array(90, 90);
	var ratios:Array = new Array(0, 188);
	var matrix:Object = {matrixType:"box", x:0, y:0, w:nW, h:nH, r: 0};
	movie.beginGradientFill("linear", colors, alphas, ratios, matrix);
	this.drawRoundRect(movie, 1.5, 1.5, nW - 1.5, nH - 1.5, 2);
	movie.endFill();
	
	/*
	movie.createEmptyMovieClip('mc', 100);
	movie.mc._x = 0.1*nW;
	movie.mc._y = 0.1*nH;
	
	nW *= 0.8; 
	nH *= 0.8;
		
	var colors:Array = new Array(0xffffff, 0xffffff, 0xffffff);
	var alphas:Array = new Array(50, 100, 50);
	var ratios:Array = new Array(0, 180, 255);
	
	var w:Number = nW * 4 / 11;
	var h:Number = nH / 3;
	var off:Number = 0;
	var matrix:Object = {matrixType:"box", x:1, y:off, w:w, h:nH - (1 - off), r:0};
	movie.mc.beginGradientFill("linear", colors, alphas, ratios, matrix);
	movie.mc.moveTo(1, off);
	var obj:Object = this.drawArc(movie.mc, 1, off, w, -90, 90, h);
	var curX:Number = w + 1;
	var curY:Number = nH - h - (1 - off);
	movie.mc.lineTo(curX, curY);
	obj = this.drawArc(movie.mc, curX, curY, w, -90, 0, h);
	movie.mc.lineTo(1, off);
	movie.mc.endGradientFill();
	//1) color of arrow 2) alpha
	movie.mc.beginFill(0, 80);
	w = nH / 3;
	h = nH / 5;
	movie.mc.moveTo(nW / 2, nH / 2 + h);
	movie.mc.lineTo(nW / 2 - w / 2, nH / 2 - h);
	movie.mc.lineTo(nW / 2 + w / 2, nH / 2 - h);
	movie.mc.lineTo(nW / 2, nH / 2 + h);
	movie.mc.endFill();
	
	delete colors;
	delete alphas;
	delete ratios;
	delete matrix;
	*/
	
	/*
	movie.clear();
	movie.beginFill(data.clr, 55); //35
	this.drawRoundRect(movie, 1, 1, nW - 1, nH - 1, 2);
	movie.endFill();
	*/
	
	var size:Number = Math.min(nW, nH) / 4;
	var cw:Number = nW / 2;
	var ch:Number = nH * 3 / 4;
	var halfSize:Number = size / 2;
	movie.beginFill(0, 80);
	movie.moveTo();
	movie.moveTo(cw, ch + halfSize);
	movie.lineTo(cw - halfSize, ch - halfSize);
	movie.lineTo(cw + halfSize, ch - halfSize);
	movie.lineTo(cw, ch + halfSize);
	movie.endFill();
	var ch:Number = nH / 4;
	movie.beginFill(0, 80);
	movie.moveTo();
	movie.moveTo(cw, ch - halfSize);
	movie.lineTo(cw - halfSize, ch + halfSize);
	movie.lineTo(cw + halfSize, ch + halfSize);
	movie.lineTo(cw, ch - halfSize);
	movie.endFill();
}

_global.AquaLook.prototype.drawComboBox = function(movie:MovieClip, nW:Number, nH:Number, data:Object):Void
{
	movie.clear();
	switch(data.mode)
	{
		default:
			movie.beginFill(globalStyleFormat[data.pLink._backgroundBorder], 100);
			this.drawRoundRect(movie, 0, 0, nW, nH, 3);
			movie.endFill();
			var colors:Array = new Array(globalStyleFormat[data.pLink._backgroundBorder], data.clr);
			var alphas:Array = new Array(100, 100);
			var ratios:Array = new Array(0, 180);
			var matrix:Object = {matrixType:"box", x:1, y:1, w:nW - 2, h:nH - 2, r:Math.PI / 2};
			movie.beginGradientFill("linear", colors, alphas, ratios, matrix);
			this.drawRoundRect(movie, 1, 1, nW - 1, nH - 1, 2);
			movie.endFill();
			// highlight
			var colors:Array = new Array(data.clr, data.clr, data.clr);
			var alphas:Array = new Array(100, 50, 0);
			var ratios:Array = new Array(10, 110, 110);
			var matrix:Object = {matrixType:"box", x:1, y:1, w:nW - 2, h:nH - 2, r:Math.PI / 2};
			movie.beginGradientFill("linear", colors, alphas, ratios, matrix);
			this.drawRoundRect(movie, 1, 1, nW - 1, nH - 1, 2);
			movie.endFill();
			break;
	}
}

_global.AquaLook.prototype.drawRect = function(movie:MovieClip, nX:Number, nY:Number, nW:Number, nH:Number, nColor:Number, nAlpha:Number):Void
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

_global.AquaLook.prototype.drawLine = function(movie:MovieClip, x1:Number, y1:Number, x2:Number, y2:Number, clr:Number, alpha:Number):Void
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

_global.AquaLook.prototype.drawDrop = function(movie:MovieClip, x:Number, y:Number, w:Number, h:Number, col:Number, data:Object):Void
{
	movie.beginFill(0, 60);
	this.drawOvalRect(movie, x, y, w, h);
	movie.endFill();

	var hsb:Object = this.rgb2hsb(col);
	var colors:Array = new Array(
		this.hsb2rgb({h:hsb.h, s:Math.max(0, hsb.s - 60), b:Math.min(100, hsb.b + 30)}),
		this.hsb2rgb({h:hsb.h, s:Math.max(0, hsb.s - 55), b:Math.min(100, hsb.b + 25)}),
		this.hsb2rgb({h:hsb.h, s:Math.max(0, hsb.s), b:Math.min(100, hsb.b - 12)}),
		this.hsb2rgb({h:hsb.h, s:Math.max(0, hsb.s), b:3}));
		//this.hsb2rgb({h:hsb.h, s:Math.max(0, hsb.s), b:Math.min(100, hsb.b - 65)}));//0xdffeab, 0xbfff55, 0x136806, 0);
	
	var alphas:Array = new Array(100, 100, 100, 100);
	var ratios:Array = new Array(0, 60, 140, 255);
	var w1:Number = w - 2;
	var h1:Number = h - 2;
	var matrix:Object = {a:w1 * 1.55, b:0, c:0, d:0, e:h1 * 1.55, f:0, g:x + 1 + w1 / 2, h:y + 1 + h1 * 0.85, i:1};
	movie.beginGradientFill("radial", colors, alphas, ratios, matrix);
	this.drawOvalRect(movie, x + 1, y + 1, w1, h1);
	movie.endFill();
	colors.splice(0);
	alphas.splice(0);
	ratios.splice(0);
	colors.push(0xffffff, 0xffffff);
	alphas.push(80, 10);
	ratios.push(65, 255);
	matrix = {a:w1 * 0.9, b:0, c:0, d:0, e:h1 * 0.5, f:0, g:x + w / 2, h:y + 1 + h1 * 0.1, i:1};
	movie.beginGradientFill("radial", colors, alphas, ratios, matrix);
	this.drawOvalRect(movie, x + (w - w1 * 0.7) / 2, y + 1 + h1 * 0.02, w1 * 0.7, h1 * 0.35);
	movie.endFill();
	delete colors;
	delete alphas;
	delete ratios;
	if(data.mode == "press") this.fillOvalRect(movie, x, y, w, h, 0, 20);
	else if(data.mode == "over") this.fillOvalRect(movie, x, y, w, h, 0xffffff, 20);
}

_global.AquaLook.prototype.drawRoundDrop = function(movie:MovieClip, x:Number, y:Number, w:Number, h:Number, col:Number, data:Object):Void
{
	var r:Number = Math.min(w, h) / 2;
	var w1:Number = w - 2;
	var h1:Number = h - 2;
	var r1:Number = Math.min(w1, h1) / 2;
	movie.beginFill(col, 100);
	this.drawRoundRect(movie, x + 1, y + 1, w - 1, h - 1, r - 1);
	movie.endFill();

	if(w < h)
	{
		var colors:Array = new Array(0, 0);
		var alphas:Array = new Array(0, 50);
		var ratios:Array = new Array(160, 255);
		var matrix:Object = new Object({a:r1 * 3, b:0, c:0, d:0, e:r1 * 3, f:0, g:x + r, h:y + r * 1.4});
		movie.beginGradientFill("radial", colors, alphas, ratios, matrix);
		this.drawOvalRect(movie, x + 1, y + 1, r1 * 2, r1 * 2);
		movie.endFill();
		colors.splice(0);
		alphas.splice(0);
		ratios.splice(0);
		colors.push(0, 0);
		alphas.push(0, 50);
		ratios.push(160, 255);
		var matrix:Object = new Object({a:r1 * 3, b:0, c:0, d:0, e:r1 * 3, f:0, g:x + r, h:y + h - r * 1.4});
		movie.beginGradientFill("radial", colors, alphas, ratios, matrix);
		this.drawOvalRect(movie, x + 1, y + h - r1 * 2 - 1, r1 * 2, r1 * 2);
		movie.endFill();

		colors.splice(0);
		alphas.splice(0);
		ratios.splice(0);
		colors.push(0xffffff, 0xffffff, 0xffffff);
		alphas.push(65, 40, 35);
		ratios.push(10, 50, 100);
		var offX:Number = 1;
		var offY:Number = 1;
		matrix = {matrixType:"box", x:offX, y:offY, w:r1 * 2, h:h1, r:0};
		movie.beginGradientFill("linear", colors, alphas, ratios, matrix);
		this.drawRoundRect(movie, x + 1, y + 1 + r1 / 4, r1 - 0.5, h - 1 - r1 / 4, r);
		movie.endFill();
	
		colors.splice(0);
		alphas.splice(0);
		ratios.splice(0);
		colors.push(0xffffff, 0xffffff);
		alphas.push(0, 85);
		ratios.push(90, 235);
		var offX:Number = x + w - r1 * 2 - 1;
		var offY:Number = 1;
		matrix = {matrixType:"box", x:offX, y:offY, w:r1 * 2, h:h1, r:0};
		movie.beginGradientFill("linear", colors, alphas, ratios, matrix);
		this.drawRoundRect(movie, x + w - r1 * 2 - 1, y + 1, x + w - 1, h - 1, r);
		movie.endFill();
	}
	else
	{
		var colors:Array = new Array(0, 0);
		var alphas:Array = new Array(0, 50);
		var ratios:Array = new Array(160, 255);
		var matrix:Object = new Object({a:r1 * 3, b:0, c:0, d:0, e:r1 * 3, f:0, g:x + r * 1.4, h:y + r});
		movie.beginGradientFill("radial", colors, alphas, ratios, matrix);
		this.drawOvalRect(movie, x + 1, y + 1, r1 * 2, r1 * 2);
		movie.endFill();
		colors.splice(0);
		alphas.splice(0);
		ratios.splice(0);
		colors.push(0, 0);
		alphas.push(0, 50);
		ratios.push(160, 255);
		var matrix:Object = new Object({a:r1 * 3, b:0, c:0, d:0, e:r1 * 3, f:0, g:x + w - r * 1.4, h:y + r});
		movie.beginGradientFill("radial", colors, alphas, ratios, matrix);
		this.drawOvalRect(movie, x + w - r1 * 2 - 1, y + 1, r1 * 2, r1 * 2);
		movie.endFill();

		colors.splice(0);
		alphas.splice(0);
		ratios.splice(0);
		colors.push(0xffffff, 0xffffff, 0xffffff);
		//alphas.push(65, 40, 35);
		alphas.push(50, 25, 20);
		ratios.push(10, 50, 100);
		var offX:Number = 1;
		var offY:Number = 1;
		var dY:Number = 1;
		matrix = {matrixType:"box", x:offX, y:offY, w:w1, h:r1 * 2, r:Math.PI / 2};
		movie.beginGradientFill("linear", colors, alphas, ratios, matrix);
		this.drawRoundRect(movie, x + 1 + r1 / 4, y + dY, w - 1 - r1 / 4, r1 - 0.5, r);
		movie.endFill();
	
		colors.splice(0);
		alphas.splice(0);
		ratios.splice(0);
		colors.push(0xffffff, 0xffffff);
		alphas.push(0, 50); //85
		ratios.push(90, 235);
		var offX:Number = 1;
		var offY:Number = y + h - r1 * 2 - 1;
		matrix = {matrixType:"box", x:offX, y:offY, w:w1, h:r1 * 2, r:Math.PI / 2};
		movie.beginGradientFill("linear", colors, alphas, ratios, matrix);
		this.drawRoundRect(movie, x + 1, y + h - r1 * 2 - 1, w - 1, y + h - 1, r);
		movie.endFill();
	}

	this.drawRoundRect(movie, x + 0.5, y + 0.5, w - 0.5, h - 0.5, r - 0.5, globalStyleFormat[data.pLink._darkshadow], 100, 1);
	movie.lineStyle(undefined);
	if(data.mode == "press") this.fillRoundRect(movie, x, y, w, h, r, 0, 20);
	
	if(movie.mask == undefined || movie._width != movie.mask._width || movie._height != movie.mask._height)
	{ 
		var mask:MovieClip = movie.createEmptyMovieClip('mask', 200);
		this.fillRoundRect(mask, x, y, w, h, r, 0, 0);
		mask._visible = false;
		movie.setMask(mask);
	}
}
	
_global.AquaLook.prototype.fillRoundRect = function(movie:MovieClip, x:Number, y:Number, w:Number, h:Number, r:Number,
	bgCol:Number, bgAlpha:Number, lineCol:Number, lineAlpha:Number):Void
{
	if(!bgAlpha) bgAlpha = 100;
	movie.beginFill(bgCol, bgAlpha)
	this.drawRoundRect(movie, x, y, w, h, r, lineCol, lineAlpha);
	movie.endFill();
}
	
_global.AquaLook.prototype.drawRoundRect = function(movie:MovieClip, nX1:Number, nY1:Number, nX2:Number,
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

	
_global.AquaLook.prototype.drawOvalRect = function(movie:MovieClip, x:Number, y:Number,
	w:Number, h:Number, color:Number, nAlpha:Number, nSize:Number):Void
{
	var rx:Number = Math.abs(w / 2);
	var ry:Number = Math.abs(h / 2);
	this.drawOval(movie, x + rx, y + ry, rx, ry, color, nAlpha, nSize);
}

_global.AquaLook.prototype.fillOvalRect = function(movie:MovieClip, x:Number, y:Number, w:Number, h:Number,
	bgCol:Number, bgAlpha:Number, lineCol:Number, lineAlpha:Number):Void
{
	if(!bgAlpha) bgAlpha = 100;
	movie.beginFill(bgCol, bgAlpha)
	this.drawOvalRect(movie, x, y, w, h, lineCol, lineAlpha);
	movie.endFill();
}
	
_global.AquaLook.prototype.drawOval = function(movie:MovieClip, x:Number, y:Number,
	radius:Number, yRadius:Number, color:Number, nAlpha:Number, nSize:Number):Void
{
	if (arguments.length < 3) return;
	if(nSize == undefined || nSize == null) nSize = 1;
	if(nAlpha == undefined) nAlpha = 100;
	if(color != null && color != undefined) movie.lineStyle(nSize, color, nAlpha);
	else movie.lineStyle(null, null, null);
	// init variables
	var theta, xrCtrl, yrCtrl, angle, angleMid, px, py, cx, cy:Number;
	// if only yRadius is undefined, yRadius = radius
	if (yRadius == undefined) yRadius = radius;
	// convert 45 degrees to radians for our calculations
	theta = Math.PI / 4;
	// calculate the distance for the control point
	xrCtrl = radius / Math.cos(theta / 2);
	yrCtrl = yRadius / Math.cos(theta / 2);
	// start on the right side of the circle
	angle = 0;
	movie.moveTo(x + radius, y);
	// this loop draws the circle in 8 segments
	for (var i = 0; i < 8; i++)
	{
		// increment our angles
		angle += theta;
		angleMid = angle - (theta / 2);
		// calculate our control point
		cx = x + Math.cos(angleMid) * xrCtrl;
		cy = y + Math.sin(angleMid) * yrCtrl;
		// calculate our end point
		px = x + Math.cos(angle) * radius;
		py = y + Math.sin(angle) * yRadius;
		// draw the circle segment
		movie.curveTo(cx, cy, px, py);
	}
}
	
//
// drops drawing routine
//
_global.AquaLook.prototype.rgb2hsb = function(colRGB:Number):Object
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

_global.AquaLook.prototype.hsb2rgb = function(hsb:Object):Number
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

_global.AquaLook.prototype.ex_brighter = function(rgb, fact) {
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

_global.AquaLook.prototype.brighter = function(rgb) {
	return this.ex_brighter(rgb, 0.7);
}

_global.AquaLook.prototype.RGB2Obj = function(rgb) {
	var r = (rgb & 0x00ff0000) >>> 16;
	var g = (rgb & 0x0000ff00) >>> 8;
	var b = (rgb & 0x000000ff);

	return { r:r, g:g, b:b };
}

_global.AquaLook.prototype.Obj2RGB = function(obj) {
	var rgb = (obj.r << 16) | (obj.g << 8) | obj.b;
	return rgb;
}
	
Object.registerClass('AquaLook', _global.AquaLook);

//#endinitclip