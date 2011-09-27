<?php
		$stmt = new Statement("INSERT INTO {$GLOBALS['fc_config']['db']['pref']}rooms (created, name, password, ispublic) VALUES (NOW(), ?,?,?)");

		$id       = $stmt->process($label, $pass, (($isPublic)?'y':null));
		$msg      = new Message('adr', null, $id, $label);
		$msg_lock = new Message('srl', null, $id, 'true');
		if($isPublic)
		{
			$this->sendToAll($msg);
			if($pass != '') $this->sendToAll($msg_lock);
			
			// start fix for message to all when new public room is created
            $txt = 'I created room "' . $label . '"';
            $stmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}rooms");
            $rs = $stmt->process();
            while($rec = $rs->next())
			{
				if($rec['ispublic']) $this->sendToRoom($rec['id'], new Message('msg', $this->userid, $rec['id'], $txt, $this->color));
			}                  
			// end fix			
		} 
		else 
		{
			$this->sendBack($msg);
			if($pass != '') $this->sendBack($msg_lock);
		}

		return $id;
?>