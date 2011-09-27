function RGB2Obj(rgb) {
	var r = (rgb & 0x00ff0000) >>> 16;
	var g = (rgb & 0x0000ff00) >>> 8;
	var b = (rgb & 0x000000ff);

	return { r:r, g:g, b:b };
}

function Obj2RGB(obj) {
	var rgb = (obj.r << 16) | (obj.g << 8) | obj.b;
	return rgb;
}

function RGB2String(rgb) {
	var obj = RGB2Obj(rgb);
	return 'r=' + obj.r + ', g=' + obj.g + ', b=' + obj.b;
}

function brighter(rgb) {
	return ex_brighter(rgb, 0.7);
}

function darker(rgb) {
	var FACTOR = 0.7;
	var c = RGB2Obj(rgb);
	var ret = {r:Math.max(Math.ceil(c.r*FACTOR), 0), g:Math.max(Math.ceil(c.g*FACTOR), 0), b:Math.max(Math.ceil(c.b*FACTOR), 0)};

	return Obj2RGB(ret);
}

//----------------------------------------------------------------------------------------------------------------//
// ADDON
//----------------------------------------------------------------------------------------------------------------//
function softdarker(rgb) {
	var FACTOR = 0.92;
	var c = RGB2Obj(rgb);
	var ret = {r:Math.max(Math.ceil(c.r*FACTOR), 0), g:Math.max(Math.ceil(c.g*FACTOR), 0), b:Math.max(Math.ceil(c.b*FACTOR), 0)};

	return Obj2RGB(ret);
}

function ex_brighter(rgb, fact) {
	var FACTOR = fact;
	var c = RGB2Obj(Number(rgb));

	var i = Math.ceil(5.0 / (1.0 - FACTOR));

	if(c.r == 0 && c.g == 0 && c.b == 0) return Obj2RGB({r:i, g:i, b:i});

	if ( c.r > 0 && c.r < i ) c.r = i;
	if ( c.g > 0 && c.g < i ) c.g = i;
	if ( c.b > 0 && c.b < i ) c.b = i;

	var ret = {r:Math.min(Math.ceil(c.r/FACTOR), 255), g:Math.min(Math.ceil(c.g/FACTOR), 255), b:Math.min(Math.ceil(c.b/FACTOR), 255)};

	return Obj2RGB(ret);
}

function ex_darker(rgb, fact) {
	var FACTOR = fact;
	var c = RGB2Obj(rgb);
	var ret = {r:Math.max(Math.ceil(c.r*FACTOR), 0), g:Math.max(Math.ceil(c.g*FACTOR), 0), b:Math.max(Math.ceil(c.b*FACTOR), 0)};

	return Obj2RGB(ret);
}

function fillHGradient(inMc, inColor)
{
	//trace('MC ' + inMc + ' colour ' + inColor);
	//trace('_x ' + inMc._x + ' _y ' + inMc._y + ' w ' + inMc.myWidth + ' h ' + inMc.myHeight);
	
	var x1 = inMc._x, y1 = inMc._y;
	var x2 = (inMc.myWidth)? inMc.myWidth : inMc._width, y2 = (inMc.myHeight)? inMc.myHeight : inMc._height; 

	// PI/2 - brighter on top, 3*PI/2 - brighter on bottom
	var matrix : Object = { matrixType : "box", x:0, y:0, w:x2, h:y2, r:3*Math.PI/2 }; 
	var colors : Array = [inColor, brighter(inColor)];
	var ratios : Array = [0, 255];   //if you want darker set 160 up to 255
	var alphas : Array = [100, 100];
	
	inMc.clear();
	inMc.beginGradientFill("linear", colors, alphas, ratios, matrix);
	inMc.moveTo(x1,y1);
	inMc.lineTo(x2,y1);
	inMc.lineTo(x2,y2);
	inMc.lineTo(x1,y2);
	inMc.lineTo(x1,y1);
	inMc.endFill();
}

function fillGradient(inMc, inColor, inSets)
{
	//trace('MC ' + inMc + ' colour ' + inColor);
	//trace('_x ' + inMc._x + ' _y ' + inMc._y + ' w ' + inMc._width + ' h ' + inMc._height);
	
	// inSets descriprion : [fillType] = {linear, radial}, [figure] = {rect, circle, top_circle, bottom_circle},
	//                      [orientType] = {v, vb, h, hl, vt, hr} (only for 'linear' fill type)
	//                      v - vertical, vb - vertical bottom, vt - vertical top
	//                      h - horizontal, hl - horizontal left, hr - horizontal right
	
	//--------------------old variant----------------------------------------------------------------------// 
	//var w = (inMc._width / inMc._xscale) * 100;
	//var h = (inMc._height / inMc._yscale) * 100;
	//var mc = inMc._parent.createEmptyMovieClip(inMc._name, inMc.getNextHighestDepth());
	//--------------------old variant----------------------------------------------------------------------//
	
	if(inMc._x == undefined) return;
	
	var fillObj = new Object();
	var dimObj  = new Object();
	
	var x = inMc._x,     y = inMc._y;
	var w = inMc._width, h = inMc._height;
	
	var mc = inMc._parent.createEmptyMovieClip(inMc._name, inMc.getDepth());
		
	//prepare fill object
	if(inSets.fillType == 'linear')
	{ 
		var angle = 0;
		switch(inSets.orientType)
		{	 
			case 'v' : case 'vb' :
				angle = 3*Math.PI/2;
			break;
			case 'h' : case 'hl' :
				angle = 2*Math.PI;
			break;
			case 'vt':
				angle = Math.PI/2;
			break;
			case 'hr':
				angle = Math.PI;
			break;
		}
	
		fillObj.fillType = 'linear';
		fillObj.matrix = { matrixType : "box", x:0, y:0, w:w, h:h, r: angle}; 
		fillObj.colors = [inColor, brighter(ex_brighter(inColor, 0.55))];
		fillObj.ratios = [0, 255];   //if you want darker set 160 up to 255
		fillObj.alphas = [100, 100];
	}
	else if(inSets.fillType == 'radial')
	{
		fillObj.fillType = 'radial';
		
		fillObj.matrix = {	a:2*w,	b:0,		c:0, 
						d:0,		e:2*h,	f:0,
						g:w/2,	h:h/2,	i:1};
						
		fillObj.colors = [inColor, brighter(brighter(inColor))];
		fillObj.ratios = [0, 255];   
		fillObj.alphas = [100, 100];
	
	}
	
	switch(inSets.figure)
	{ 
		case 'rect':
			dimObj.x1 = 0;
			dimObj.y1 = 0;
			dimObj.x2 = w;
			dimObj.y2 = h; 
			
			drawRectangle(mc, fillObj, dimObj);
		break;	
		case 'circle':
			dimObj.fromAngle = 0;
			dimObj.toAngle   = 2*Math.PI;
			dimObj.bx = w; 
			dimObj.by = h/2;
			dimObj.ox = w/2;
			dimObj.oy = h/2;
			dimObj.rx = w/2;
			dimObj.ry = h/2; 
			
			drawCircle(mc, fillObj, dimObj);
		break;
		case 'icon_circle':
			dimObj.fromAngle = 0;
			dimObj.toAngle   = 2*Math.PI;
			dimObj.bx = w; 
			dimObj.by = h/2;
			dimObj.ox = w/2;
			dimObj.oy = h/2;
			dimObj.rx = w/2;
			dimObj.ry = h/2;
			
			fillObj.matrix = {	
							a:2*w,	b:0,		c:0, 
							d:0,		e:2*h,	f:0,
							g:w/2 - w/8, h:h/1.5,	i:1
						 };
			
			fillObj.colors = [ex_brighter(inColor, 0.4), darker(inColor)];
			fillObj.ratios = [0, 175];   
			fillObj.alphas = [100, 100];
			
			drawCircle(mc, fillObj, dimObj);
		break;
		case 'icon_plus_default':
			dimObj.x1 = 0;
			dimObj.y1 = 0;
			dimObj.x2 = w;
			dimObj.y2 = h;
			dimObj.d = 1.0;
			
			fillObj.alpha = 50;
			fillObj.bgcolor = 0x999999;
			fillObj.lcolor = 0x000000;
			
			drawPlus(mc, fillObj, dimObj);
		break;
		case 'icon_roundrect_gradient':
		case 'icon_roundrect_xp':
		case 'icon_roundrect_default':
			dimObj.x1 = 0;
			dimObj.y1 = 0;
			dimObj.x2 = w;
			dimObj.y2 = h; 
			dimObj.r  = h/5;
			//corners : [0] = top left corner (if true then rounded), [1] = top right, [2] = bottom right, [3] = bottom left
			dimObj.corners = inSets.corners;
			
			if(inSets.figure == 'icon_roundrect_gradient')
			{ 
				fillObj.matrix = {	
								a:2*w,	b:0,		c:0, 
								d:0,		e:2*h,	f:0,
								g:w/4, 	h:h/4,	i:1
							 };
			}
			else if(inSets.figure == 'icon_roundrect_xp')
			{
				fillObj.matrix = {	
								a:3*w,	b:0,		c:0, 
								d:0,		e:3*h,	f:0,
								g:w,	 	h:0,		i:1
							 };
			}
			else if(inSets.figure == 'icon_roundrect_default')
			{
				fillObj.matrix = {	
								a:2*w,	b:0,		c:0, 
								d:0,		e:2*h,	f:0,
								g:w/2, 	h:h/2,	i:1
							 };
			}
			
			fillObj.colors = [ex_brighter(inColor, 0.4), darker(inColor)];
			fillObj.ratios = [0, 175];   
			fillObj.alphas = [100, 100];
			
			drawRoundRectangle(mc, fillObj, dimObj);
		break;
		case 'top_circle':
			dimObj.fromAngle = 0;
			dimObj.toAngle   = Math.PI;
			dimObj.bx = w;
			dimObj.by = h;
			dimObj.ox = w/2;
			dimObj.oy = h;
			dimObj.rx = w/2;
			dimObj.ry = h;
			
			if(inSets.fillType == 'radial')
			{ 
				fillObj.matrix = {	
								a:2*w,	b:0,		c:0, 
								d:0,		e:4*h,	f:0,
								g:w/2,	h:h,		i:1
							 };
			}
			
			drawCircle(mc, fillObj, dimObj);
		break;
		case 'bottom_circle':
			dimObj.fromAngle = Math.PI;
			dimObj.toAngle   = 2*Math.PI;
			dimObj.bx = 0;
			dimObj.by = 0;
			dimObj.ox = w/2;
			dimObj.oy = 0;
			dimObj.rx = w/2;
			dimObj.ry = h;
			
			if(inSets.fillType == 'radial')
			{ 
				fillObj.matrix = {	a:2*w,	b:0,		c:0, 
								d:0,		e:4*h,	f:0,
								g:w/2,	h:0,		i:1
							 };
			}
			
			drawCircle(mc, fillObj, dimObj);
		break;
		case 'aqua_button':
			dimObj.x1 = 0;
			dimObj.y1 = 0;
			dimObj.x2 = w;
			dimObj.y2 = h; 
			
			drawAquaRectangle(mc, fillObj, dimObj);
		break;
	}
	
	mc._x = x;
	mc._y = y;
}

function drawAquaRectangle(mc, fillObj, dimObj)
{
	var d = 30;
	
	//filling
	mc.clear();
	mc.beginGradientFill(fillObj.fillType, fillObj.colors, fillObj.alphas, fillObj.ratios, fillObj.matrix);
	
	//paint top part
	mc.moveTo(dimObj.x1, dimObj.y1);
	mc.lineTo(dimObj.x2, dimObj.y1);
	mc.lineTo(dimObj.x2 - dimObj.x2/d, dimObj.y2 / 2);
	mc.lineTo(dimObj.x2/d, dimObj.y2 / 2);
	mc.lineTo(dimObj.x1, dimObj.y2);
	mc.lineTo(dimObj.x1, dimObj.y1);
	
	mc.endFill();
	
	fillObj.colors[0] = darker(fillObj.colors[0]);
	mc.beginGradientFill(fillObj.fillType, fillObj.colors, fillObj.alphas, fillObj.ratios, fillObj.matrix);
	
	//paint bottom part
	mc.lineTo(dimObj.x2, dimObj.y1);
	mc.lineTo(dimObj.x2 - dimObj.x2/d, dimObj.y2 / 2);
	mc.lineTo(dimObj.x2/d, dimObj.y2 / 2);
	mc.lineTo(dimObj.x1, dimObj.y2);
	mc.lineTo(dimObj.x2, dimObj.y2);
	mc.lineTo(dimObj.x2, dimObj.y1);
	
	mc.endFill();
}

function drawRectangle(mc, fillObj, dimObj)
{
	//filling
	mc.clear();
	mc.beginGradientFill(fillObj.fillType, fillObj.colors, fillObj.alphas, fillObj.ratios, fillObj.matrix);
	mc.moveTo(dimObj.x1, dimObj.y1);
	mc.lineTo(dimObj.x2, dimObj.y1);
	mc.lineTo(dimObj.x2, dimObj.y2);
	mc.lineTo(dimObj.x1, dimObj.y2);
	mc.lineTo(dimObj.x1, dimObj.y1);
	mc.endFill();
}

function drawRoundRectangle(mc, fillObj, dimObj)
{
	//filling
	mc.clear();
	mc.beginGradientFill(fillObj.fillType, fillObj.colors, fillObj.alphas, fillObj.ratios, fillObj.matrix);
	
	if(dimObj.corners[0] == true)
	{ 
		mc.moveTo(dimObj.x1, dimObj.y1 + dimObj.r);
		paintCircle(mc, Math.PI, Math.PI/2, dimObj.x1 + dimObj.r, dimObj.y1 + dimObj.r, dimObj.r, dimObj.r, -1);
	}
	else mc.moveTo(dimObj.x1, dimObj.y1);
	
	if(dimObj.corners[1] == true)
	{ 
		mc.lineTo(dimObj.x2 - dimObj.r, dimObj.y1);
		paintCircle(mc, Math.PI/2, 0, dimObj.x2 - dimObj.r, dimObj.y1 + dimObj.r, dimObj.r, dimObj.r, -1);
	}
	else mc.lineTo(dimObj.x2, dimObj.y1);
	
	if(dimObj.corners[2] == true)
	{ 
		mc.lineTo(dimObj.x2, dimObj.y2 - dimObj.r);
		paintCircle(mc, 0, -Math.PI/2, dimObj.x2 - dimObj.r, dimObj.y2 - dimObj.r, dimObj.r, dimObj.r, -1);
	}
	else mc.lineTo(dimObj.x2, dimObj.y2);
	
	if(dimObj.corners[3] == true)
	{ 
		mc.lineTo(dimObj.x1 + dimObj.r, dimObj.y2);
		paintCircle(mc, -Math.PI/2, -Math.PI, dimObj.x1 + dimObj.r, dimObj.y2 - dimObj.r, dimObj.r, dimObj.r, -1);
	}
	else mc.lineTo(dimObj.x1, dimObj.y2);
	
	if(dimObj.corners[0] == true)
		mc.lineTo(dimObj.x1, dimObj.y1 + dimObj.r);
	else 	mc.lineTo(dimObj.x1, dimObj.y1);
	
	mc.endFill();
}

function paintCircle(mc, from, to, ox, oy, rx, ry, speed)
{
	for(var i = from; (speed > 0)? (i <= to) : (i >= to); i += speed*0.01)
	{
		var nx = ox + rx * Math.cos(i);
		var ny = oy - ry * Math.sin(i);
		mc.lineTo(nx, ny);
	}
	
}

function drawPlus(mc, fillObj, dimObj)
{
	mc.clear();
	//draw rect and feel it
	
	mc.beginFill(fillObj.bgcolor, fillObj.alpha);
	mc.lineStyle(dimObj.d, fillObj.lcolor);
	
	mc.moveTo(dimObj.x1, dimObj.y1);
	mc.lineTo(dimObj.x2, dimObj.y1);
	mc.lineTo(dimObj.x2, dimObj.y2);
	mc.lineTo(dimObj.x1, dimObj.y2);
	mc.lineTo(dimObj.x1, dimObj.y1);
	mc.endFill();
	
	//draw plus icon
	var dx = dimObj.x2/4, dy = dimObj.y2/4;
	var nx1 = dimObj.x1 + dx, ny1 = dimObj.y1 + dy;
	var nx2 = dimObj.x2 - dx + dimObj.d/2, ny2 = dimObj.y2 - dy + dimObj.d/2;
		
	mc.moveTo(nx1, dimObj.y2/2);
	mc.lineTo(nx2, dimObj.y2/2);
	
	mc.moveTo(dimObj.x2/2, ny1);
	mc.lineTo(dimObj.x2/2, ny2);
}

function drawCircle(mc, fillObj, dimObj)
{
	//filling
	mc.clear();
	mc.beginGradientFill(fillObj.fillType, fillObj.colors, fillObj.alphas, fillObj.ratios, fillObj.matrix);
		mc.moveTo(dimObj.bx, dimObj.by);
		paintCircle(mc, dimObj.fromAngle, dimObj.toAngle, dimObj.ox, dimObj.oy, dimObj.rx, dimObj.ry, 1);
		mc.lineTo(dimObj.bx, dimObj.by);
	mc.endFill();
}
