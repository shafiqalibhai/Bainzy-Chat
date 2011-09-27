_global.CSmileTextConst = function() 
{
	//this.patternList.sort(this.sortPatern);
};

_global.CSmileTextConst.prototype.sortPatern = function (a, b) 
{   
   if (a[0].length < b[0].length) { return -1;} 
   else if (a[0].length > b[0].length) {return 1;} 
   else {return 0;}
}

// [0] = patternStr, [1] = patternIcon, [2] = icon prefered width, [3] = icon prefered height
// by default patternList is list of all available smilies in the FlashChat (see smiles.fla)
_global.CSmileTextConst.prototype.patternList = [
	//['::', 'smi_'],
	
	[':?', 'smi_ask'],
	[':awe:', 'smi_awe'],
	[':baby:', 'smi_baby', 14.0, 14.0],
	['8)', 'smi_cool'],
	[':evil:', 'smi_evil'],
	[':finger:', 'smi_finger'],
	[':grin:', 'smi_grin'],
	[':heart:', 'smi_heart'],
	[':kiss:', 'smi_kiss'],
	[':D', 'smi_laugh'],
	[':break:', 'smi_newline'],
	[':ninja:', 'smi_ninja', 24.3, 18.7],
	[':red:', 'smi_red'],
	[':roll:', 'smi_roll', 37],
	[':rolleyes:', 'smi_roll_eyes'],
	[':(', 'smi_sad'],
	[':!', 'smi_slash'],
	[':zzz:', 'smi_sleep', 21.9, 17.1],
	[':)', 'smi_smile'],
	[':p', 'smi_tongue'],
	[':weird:', 'smi_weird'],
	[':whistle:', 'smi_whistle'],
	[';)', 'smi_wink'],
	['8s', 'smi_wonder', 16, 16],
	
	//addon 1
	[':call:', 'smi_call'],
	[':cash:', 'smi_cash', 16, 16],
	[':check:', 'smi_check', 19, 25],
	[':shock:', 'smi_shock', 16, 16],
	
	//addon 2
	[':ball:', 'smi_ball'],
	[':clap:', 'smi_clap', 130, 80],
	[':cry:', 'smi_cry'],
	[':luck:', 'smi_luck'],
	[':nono:', 'smi_nono', 112.2, 85],
	[':Punch:', 'smi_punch', 25, 15.9],
	[':skull:', 'smi_skull', 14, 14],
	[':yeah:', 'smi_yeah', 140, 89.6],
	[':69:', 'smi_yinyang', 28.3, 29.0],
	
	//addon 3
	[':earth:', 'smi_earth'],
	[':huh:', 'smi_huh', 25, 16],
	[':hypno:', 'smi_hypno', 38, 38],
	[':java:', 'smi_java', 25, 25],
	[':no:', 'smi_no'],
	[':rain:', 'smi_rain'],
	[':rose:', 'smi_rose'],
	[':usa:', 'smi_usa'],
	
	//addon 4
	[':biggrin:', 'smi_big_grin'],
	[':faint:', 'smi_faint'],
	[':mean:', 'smi_ill_content'],
	[':cat:', 'smi_meow', 18.5, 16],
	[':down:', 'smi_thumbs_down'],
	[':up:', 'smi_thumbs_up'],
	[':dog:', 'smi_woof', 25, 16],
	
	[':au:', 'smi_AustraliaFlag'],
	[':br:', 'smi_Brazil'],
	[':ca:', 'smi_CanadaFlag'],
	[':cn:', 'smi_China'],
	[':eu:', 'smi_European_Union'],
	[':fr:', 'smi_France'],
	[':de:', 'smi_Germany'],
	[':gr:', 'smi_Greece'],
	[':in:', 'smi_IndianFlag'],
	[':it:', 'smi_Italy'],
	[':jp:', 'smi_Japan'],
	[':mx:', 'smi_MexicoFlag'],
	[':pl:', 'smi_PolandFlag'],
	[':pt:', 'smi_PortugalFlag'],
	[':ru:', 'smi_Russia'],
	[':se:', 'smi_Sweeden'],
	[':es:', 'smi_Spain'],
	[':uk:', 'smi_UK'],
	[':ua:', 'smi_UkraineFlag'],
	[':us:', 'smi_US_Map'],
	
	[':beer:', 'smi_beer', 18.5, 17],
	[':music:', 'smi_music', 27, 16],
	[':read:', 'smi_reading', 27, 16],
	
	[':admin:', 'smi_admin'],
	[':female:', 'smi_female'],
	[':ms:', 'smi_female2'],
	[':male:', 'smi_male'],
	[':mr:', 'smi_male2'],
	[':mod:', 'smi_moderator'],
	[':speak:', 'smi_word_bubble'],
	
	[':bball:', 'smi_basketball'],
	[':bowl:', 'smi_bowling'],
	[':cricket:', 'smi_cricket'],
	[':fball:', 'smi_football'],
	[':golf:', 'smi_golf'],
	[':hockey:', 'smi_hockey'],
	[':sail:', 'smi_sailing'],
	[':soccer:', 'smi_soccer'],
	[':tennis:', 'smi_tennis']
	
];

_global.CSmileTextConst.prototype.setNewPattern = function(inSmilies)
{
	var ArrayObj = new Object();
	
	for(var i = 0; i < this.patternList.length; i++)
	{
		var smi = inSmilies[this.patternList[i][1]];
		if(smi == '') continue;
		
		var ptrn = smi.split(' ');
		
		ArrayObj[this.patternList[i][1]] = new Array();
		ArrayObj[this.patternList[i][1]].push(this.patternList[i]);
		
		if(this.patternList[i][0] != ptrn[0] || ptrn.length > 1)
		{
			this.patternList[i][0] = ptrn[0];
			
			if(ptrn.length > 1)
			{ 
				for(var j = 1; j < ptrn.length; j++)
				{ 
					var cpy = new Array();
					for(var t = 0; t < this.patternList[i].length; t++) cpy[t] = this.patternList[i][t];
					
					this.patternList.splice(i+j, 0, cpy);
					this.patternList[i+j][0] = ptrn[j];
					ArrayObj[this.patternList[i][1]].push(this.patternList[i+j]);
				}
				
				i+=(j-1);
			}
		}
	}
	
	this.patternList.splice(0, this.patternList.length);
	for(var itm in inSmilies)
	{
		if(ArrayObj[itm] == undefined) continue;
		
		for(var i = ArrayObj[itm].length-1; i >= 0; i--)
			this.patternList.push(ArrayObj[itm][i]);
	}
	this.patternList.reverse();
};

_global.CSmileTextConst.prototype.setExtendedPattern = function(inSmilies)
{
	for(var itm in inSmilies)
	{
		var tmp = new Array(inSmilies[itm].keycode, itm, null, null, inSmilies[itm].image);
		this.patternList.push(tmp);
	}
};

_global.SmileTextConst = new CSmileTextConst();
