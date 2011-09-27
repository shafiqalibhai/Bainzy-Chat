_global.CThread = function() {
	this.intervalId = null;
	this.threadCallList = new Array();
	this.doInterrupt = false;
};

_global.CThread.prototype.TICK_TIME = 8000;

//PUBLIC METHODS.

_global.CThread.prototype.addCall = function(inObj, inFunctionName, inArg1, inArg2, inArg3) {
	var threadCall = new CThreadCall(inObj, inFunctionName, inArg1, inArg2, inArg3);
	this.threadCallList.push(threadCall);
	if (this.intervalId == null) {
		this.intervalId = setInterval(this.tick, 10, this);
	}
};

_global.CThread.prototype.insertCall = function(inObj, inFunctionName, inArg1, inArg2, inArg3) {
	var threadCall = new CThreadCall(inObj, inFunctionName, inArg1, inArg2, inArg3);
	this.threadCallList.splice(0, 0, threadCall);
	if (this.intervalId == null) {
		this.intervalId = setInterval(this.tick, 10, this);
	}
};

//tells currently running thread to imediately interrupt and wait until next interval call.
_global.CThread.prototype.interrupt = function() {
	this.doInterrupt = true;
};

//PRIVATE METHODS.

_global.CThread.prototype.tick = function(inThread) {
	if (inThread.threadCallList.length == 0) {
		clearInterval(inThread.intervalId);
		inThread.intervalId = null;
		return;
	}
	var tickStartTime = getTimer();
	while ((inThread.threadCallList.length > 0) && (getTimer() - tickStartTime < inThread.TICK_TIME)) {
		if (inThread.doInterrupt) {
			break;
		}
		var threadCall = inThread.threadCallList[0];
		inThread.threadCallList.splice(0, 1);
		//trace('CThread: tick: [' + (getTimer() - tickStartTime) + ' ms]: calling \'' + threadCall.functionName + '\'.');
		//var callStartTime = getTimer();
		threadCall.obj[threadCall.functionName](threadCall.arg1, threadCall.arg2, threadCall.arg3);
		//var callTime = getTimer() - callStartTime;
		/*
		if (callTime > 1.5 * inThread.TICK_TIME) {
			trace('CThread: tick: [' + callTime + ' ms]: calling \'' + threadCall.functionName + '\'.');
		}
		*/
	}
	inThread.doInterrupt = false;
	//trace('CThread: tick: [' + (getTimer() - tickStartTime) + ' ms]: time out.');
};

_global.thread = new CThread();
