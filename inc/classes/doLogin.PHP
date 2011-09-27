<?php
			//fixes for aumlavta
			
			ChatServer::loadCMSclass();
			$cms = $GLOBALS['fc_config']['cms'];
			$cmsclass = strtolower(get_class($cms));
			if( $cmsclass != 'statelesscms' && $GLOBALS['fc_config']['loginUTF8decode'] ) 
			{
				$login    = utf8_decode( $login );
				$password = utf8_decode( $password );
			}
			//---	
			
			if($this->userid = ChatServer::login($login, $password, array('ip' => $bot_id))) {
				if($lang) $this->lang = $lang;
				if($tzoffset) $this->tzoffset = $tzoffset;
				$ar = $this->getAvailableRoom($GLOBALS['fc_config']['defaultRoom']);
				$this->roomid = $roomid? $roomid : $ar['id'];
				$this->room_is_permanent = $ar['ispermanent'] != '';
				$this->start = $this->sendLoginInfo();
				
				
			} else {
				$this->start = $this->sendBack(new Message('lout', null, null, 'wrongPass'));
			}
			
			$this->save();
?>