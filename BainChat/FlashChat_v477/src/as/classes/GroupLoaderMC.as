#initclip 10

function GroupLoaderClass() {
	this.items = new Array();
	this.currItem = -1;
}

GroupLoaderClass.prototype = new MovieClip();
Object.registerClass('GroupLoaderSymbol', GroupLoaderClass);

GroupLoaderClass.prototype.onEnterFrame = function() {
	if(this.currItem < 0 || this.currItem >= this.items.length) return;

	var item = this.items[this.currItem];
	var bloaded = item.getBytesLoaded();
	var btotal = item.getBytesTotal();
	this['bar' + this.currItem].update(bloaded, btotal);

	if(btotal > 10 && bloaded >= btotal) this.loadNext();
}

GroupLoaderClass.prototype.loadNext = function() {
	if(this.currItem < (this.items.length - 1)) {
		var bar = this['bar' + this.currItem];
		this.currItem++;
		this.attachMovie('ProgressBarSymbol', 'bar' + this.currItem, this.currItem + 1);
		var newbar = this['bar' + this.currItem];
		
		this.items[this.currItem].font.maxLabelWidth = this.maxLabelWidth;
		newbar.setLabel(this.items[this.currItem].label, this.items[this.currItem].font);
		newbar._y = (this.currItem > 0)?bar._y + bar._height:0;
		this.items[this.currItem].loadTarget();
	} else {
		if(this.onLoad != undefined) this.onLoad();
		return;
	}
}

GroupLoaderClass.prototype.load = function(items) {
	this.items = this.items.concat(items);
	this.maxLabelWidth = this.getMaxLabelWidth();
	this.loadNext();
}

GroupLoaderClass.prototype.getMaxLabelWidth = function() {
	this.createTextField('test_txt', 0, 0, 0, 150, 100);	

	this.test_txt._visible = false;
	this.test_txt.autoSize = 'left';
	
	var max_w = 0;
	for(var i = 0; i < this.items.length; i++)
	{
		this.test_txt.text = this.items[i].label;
		setTextProperty('font', this.items[i].font.fontFamily, this.test_txt);
		setTextProperty('size', this.items[i].font.fontSize,   this.test_txt);
		
		if(max_w < this.test_txt._width) max_w = this.test_txt._width;
	}
	
	delete(this.test_txt);
	
	return (max_w);
}

function GroupLoaderItem(label, url, target, font) {
	this.label = label;
	this.url = url;
	this.target = target;
	this.font = font;
}

GroupLoaderItem.prototype.loadTarget = function() {
	if(this.target instanceof MovieClip) {
		this.target.loadMovie(this.url);
	} else if(typeof this.target == 'number') {
		loadMovieNum(this.url, this.target);
	} else {
		this.target.load(this.url);
	}
}

GroupLoaderItem.prototype.getBytesLoaded = function() {
	if(typeof this.target == 'number') {
		return eval('_level' + this.target).getBytesLoaded();
	} else {
		return this.target.getBytesLoaded();
	}
}

GroupLoaderItem.prototype.getBytesTotal = function() {
	if(typeof this.target == 'number') {
		return eval('_level' + this.target).getBytesTotal();
	} else {
		return this.target.getBytesTotal();
	}
}

function Delayer(delay) {
	this.delay = delay;
}

Delayer.prototype.load = function(url) {
	this.time = new Date().getTime();
}

Delayer.prototype.getBytesLoaded = function() {
	var spent = new Date().getTime() - this.time;
	return Math.min(spent, this.delay);
}

Delayer.prototype.getBytesTotal = function() {
	return this.delay;
}

#endinitclip
