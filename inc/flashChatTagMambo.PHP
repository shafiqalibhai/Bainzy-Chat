<?php
	function flashTag($id, $movie, $width = '100%', $height = '100%', $params = array(), $base) {
		$flashVars = array();

		foreach($params as $name => $value) {
			if($value) $flashVars[] = "$name=" . urlencode($value);
		}

		$fv = join('&', $flashVars);
		
		$tag .= "<script type=\"text/javascript\">\n";
		$tag .= "FL_RunContent( \n";
		$tag .= "'codebase','http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,0,0',\n";
		$tag .= "'pluginspage','http://www.macromedia.com/go/getflashplayer',\n";
		$tag .= "'name','".$id."',\n";
		$tag .= "'id','".$id."',\n";
		$tag .= "'width','".$height."',\n";
		$tag .= "'height','".$height."',\n";
		$tag .= "'BASE','".$base."',\n";
		$tag .= "'align','',\n";
		$tag .= "'salign','LT',\n";
		$tag .= "'src','".$movie."',\n";
		$tag .= "'movie','".$movie."',\n";
		$tag .= "'flashvars','".$fv."',\n";
		$tag .= "'menu','true',\n";
		$tag .= "'scale','noscale',\n";
		$tag .= "'quality','high'\n";
		$tag .= "); //end ActivsteFlash\n";
		$tag .= "</script>\n";
		
		$tag .= "<noscript>\n";

		$tag  = "<object classid=\"clsid:d27cdb6e-ae6d-11cf-96b8-444553540000\" codebase=\"http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,0,0\" WIDTH=\"$width\" HEIGHT=\"$height\"  id=\"$id\" ALIGN=\"\">";
		$tag .= "<PARAM NAME=\"FlashVars\" VALUE=\"$fv\">";
		$tag .= "<PARAM NAME=\"movie\" VALUE=\"$movie\">";
		$tag .= "<PARAM NAME=\"quality\" VALUE=\"high\">";
		$tag .= "<PARAM NAME=\"menu\" VALUE=\"false\">";
		$tag .= "<PARAM NAME=\"scale\" VALUE=\"noscale\">";
		$tag .= "<PARAM NAME=\"salign\" VALUE=\"LT\">";
		$tag .= "<PARAM NAME=\"BASE\" VALUE=\"$base\">";
		$tag .= "<EMBED src=\"$movie\" FlashVars=\"$fv\" menu=\"false\" quality=\"high\" scale=\"noscale\" salign=\"LT\" WIDTH=\"$width\" HEIGHT=\"$height\" NAME=\"$id\" ALIGN=\"\" TYPE=\"application/x-shockwave-flash\" PLUGINSPAGE=\"http://www.macromedia.com/go/getflashplayer\" BASE=\"$base\"></EMBED>";
		$tag .= "</OBJECT>";
		
		$tag .= "</noscript>\n";

		return $tag;
	}

	function flashChatTag($width, $height, $params = array(), $base = '') {
		$tag  = flashTag('flashchat', $base . 'preloader.swf', $width, $height, $params, $base);
		$tag .= '<script type="text/javascript" src="' . $base . 'js.php"></script>';

		return $tag;
	}
?>
