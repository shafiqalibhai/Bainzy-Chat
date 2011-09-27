<?php
	if($numb)
	{
		if (($GLOBALS['fc_config']['backtimeMax'] != 0) && ($numb > $GLOBALS['fc_config']['backtimeMax']))
		$numb = $GLOBALS['fc_config']['backtimeMax'];
		$lastid = $this->sendBack(new Message('backt', null, $numb));

		$stmt = new Statement("SELECT id FROM {$GLOBALS['fc_config']['db']['pref']}messages WHERE command='msg' AND toroomid=? AND created > DATE_SUB(NOW(),INTERVAL $numb MINUTE) ORDER BY id LIMIT 1");
		if(($rs = $stmt->process($this->roomid)) && ($rec = $rs->next()))
		{
			$firstid = $rec['id'];
			$stmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}messages WHERE command='msg' AND id>=? AND id<=? AND toroomid=? ORDER BY id");
			if($rs = $stmt->process($firstid, $lastid, $this->roomid))
			{
				while($rec = $rs->next())
				{
					$msg = new Message('msgb');
					$msg->created = $rec['created'];
					$msg->userid = $rec['userid'];
					$msg->roomid = $rec['roomid'];
					$msg->txt = $rec['txt'];
					$this->sendBack($msg);
				}
			}
		}
	}
?>