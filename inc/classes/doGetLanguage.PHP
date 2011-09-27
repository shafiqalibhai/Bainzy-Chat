<?php
			if($lang && $save == true) $this->lang = $lang;
			
			if($save_only != 1)
			{
				$v = $GLOBALS['fc_config']['languages'][$this->lang];
				
				$msg = ($save == true)? new Message('glng') : new Message('lng');
				
				$msg->txt  = "<language loaded=\"1\" id=\"{$this->lang}\" name=\"{$v['name']}\">";
				$msg->txt .= "<messages " . array2attrsHtml($v['messages']) . "/>";
				$msg->txt .= "<desktop " . array2attrs($v['desktop']) . "/>";
				
				if(is_array($v) && count($v) > 0)
				{
					foreach($v['dialog'] as $dk => $dv) { 
						$msg->txt .= "<dialog id=\"$dk\" " . array2attrsHtml($dv) . "/>";
					}
				}	
				$msg->txt .= "<status " . array2attrs($v['status']) . "/>";
				$msg->txt .= "<usermenu " . array2attrs($v['usermenu']) . "/>";
				$msg->txt .= "</language>";

				$ret = $this->sendBack($msg);
			}	
			
			if($save == true) $this->save();
			
			return ($ret);
?>