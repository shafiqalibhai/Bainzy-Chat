#initclip 10

function ProgressBarClass() {
	this.createEmptyMovieClip('bar', 1);
}

ProgressBarClass.prototype = new MovieClip();
Object.registerClass('ProgressBarSymbol', ProgressBarClass);

ProgressBarClass.prototype.drawBox = function(x, y, w, h, col, alpha) {
	var values = new Array(0,0,1,1, col, alpha);
	var params = (arguments.length == 1)?arguments[0]:arguments;

	for(var i = 0; i < params.length; i++) {
		values[i] = params[i];
	}

	this.beginFill(values[4], values[5]);
	this.moveTo(values[0], values[1]);
	this.lineTo(values[0] + values[2], values[1]);
	this.lineTo(values[0] + values[2], values[1] + values[3]);
	this.lineTo(values[0], values[1] + values[3]);
	this.endFill();
}

ProgressBarClass.prototype.update = function(bloaded, btotal) {
	if(btotal > 10 && bloaded >= btotal) {
		this.percent.text = this.okText;
		if(this.onLoad != undefined) this.onLoad();
		this.clear();
	} else {
		var done = (btotal > 10)?Math.ceil(bloaded * 100 / btotal):0;
		this.percent.text = done + '%';
		this.drawBox(3, Math.ceil(this.label._height), (this.percent._x + this.percent._width) * done / 100, 2, this.barColor, 100);
	}
	
	this.percent._height = this.percent.textHeight;
}

ProgressBarClass.prototype.setLabel = function(txt, inFont) {
	this.barColor = inFont.barColor;
	this.okText   = inFont.okText;
	
	this.label.text = txt;
	
	this.label.autoSize = 'left';
	this.percent.autoSize = 'left';
	
	this.percent._x = this.label._x + inFont.maxLabelWidth + 2;
	
	setTextProperty('font', inFont.fontFamily, this.label);
	setTextProperty('size', inFont.fontSize,   this.label);
	setTextProperty('font', inFont.fontFamily, this.percent, true);
	setTextProperty('size', inFont.fontSize,   this.percent, true);
	
	this.label.textColor = this.percent.textColor = inFont.fontColor;
}

#endinitclip
