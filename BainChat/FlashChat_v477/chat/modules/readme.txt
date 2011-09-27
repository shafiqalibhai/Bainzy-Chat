Greetings!

Beginning with FlashChat 4.3, you can use the FlashChat module pack, which is available for $5 from www.tufat.com/modules.php

After unzipping the module pack, copy the contents to this folder. Thus, after copying the modules, you will have something like:

www.yourdomain.com/chat/modules/admin/
www.yourdomain.com/chat/modules/banner/
www.yourdomain.com/chat/modules/mp3_player/
www.yourdomain.com/chat/modules/text_ads/
www.yourdomain.com/chat/modules/web_radio/

You will need to edit the module properties in /inc/config.php to enable the module of your choice. The 'path' property should contain the path, relative to the FlashChat root, of the .swf file for the module.

For example, to enable the MP3 Player module, you  would edit /inc/config.php to this:

'module' => array(
	'anchor'  => 0,
	'path'    => 'modules/mp3_player/mp3player.swf',
	'stretch' => true,
	'float_x' => 300, 
	'float_y' => 200,
	'float_w' => 100, 
	'float_h' => 100, 
),

Since 'stretch' is set to true, the module will fill all available space, and since 'anchor' is set to '0', the space that the module will occupy is immediately below the room list. In this example, the 'float' properties do not apply, since they only apply when the module occupies a floating window ('anchor' => -1).

Good luck!
Darren