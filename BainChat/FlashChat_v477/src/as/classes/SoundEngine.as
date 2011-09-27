_global.SoundEngine = function( initObj, initSndOpt, parent ) 
{
	this.sounds_obj = new Object();
	this.initObj    = initObj;
	this.parent     = parent;
	this.initSndOpt = initSndOpt;
	
	this.Volume = this.initSndOpt['volume'];
	this.Pan    = this.initSndOpt['pan'];
};

_global.SoundEngine.prototype = new Object(); 

_global.SoundEngine.prototype.setVolume = function(vol)
{ 
	this.Volume = vol;
}
_global.SoundEngine.prototype.setPan = function(pan)
{ 
	this.Pan = pan;
}

_global.SoundEngine.prototype.attachSound = function( sound_id , play_anyway)
{ 	
	//trace('attachSound ' + sound_id + ' (' + this.initObj[sound_id] + ') = ' + this.parent.settings.user.sound['mute' + sound_id]);
	//trace('volume ' + this.Volume);
	//trace('DBG ' + this.parent.settings);
	//dbg(this.parent.settings);
	
	if (
	     play_anyway != true && 
	     ( 
	       toBool(this.parent.settings.user.sound.muteAll)            ||
	       toBool(this.parent.settings.user.sound["mute" + sound_id]) ||
	       this.initObj[sound_id] == undefined
	     )
	   ) 
	     return;
		
	if(this.sounds_obj[sound_id] == undefined)
	{
		this.sounds_obj[sound_id] = new Sound();
		
		this.sounds_obj[sound_id].setPan(this.Pan);
		this.sounds_obj[sound_id].setVolume(this.Volume);
		this.sounds_obj[sound_id].loadSound(this.initObj[sound_id], true);
		return;
	}
	
	this.sounds_obj[sound_id].setPan(this.Pan);
	this.sounds_obj[sound_id].setVolume(this.Volume);
	this.sounds_obj[sound_id].start();	
}

_global.SoundEngine.prototype.start = function()
{ 
}