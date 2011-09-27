<?php
			if(ChatServer::userInRole($this->userid, ROLE_CUSTOMER)) return;

			$stmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}bans WHERE banneduserid=? AND roomid=?");
			if(($rs = $stmt->process($this->userid, $toroomid)) && ($rec = $rs->next())) {
				$this->sendToAll(new Message('mvu', $this->userid, $this->roomid, $msg));
				$this->sendBack(new Message('error', null, null, 'banned'));
			} else {
				$stmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}rooms WHERE id=?");
				if($rs = $stmt->process($toroomid)) $rec = $rs->next();
				$is_lock = ($pass != $rec['password']);
				if($is_lock && !$is_invite) {
					$this->sendBack(new Message('error', null, null, 'locked'));
				}
				else
				{
					$this->roomid = $toroomid;
					$this->room_is_permanent = $rec['ispermanent'] != '';
					$this->sendToAll(new Message('mvu', $this->userid, $this->roomid, $msg));

					if($GLOBALS['fc_config']['liveSupportMode'] && ChatServer::userInRole($this->userid, ROLE_ADMIN)) $this->doBack(1000);
									
					$this->save();
// fix for welcome message
					$destination = null;
					if ($GLOBALS['fc_config']['auto_topic']) {
						require_once(INC_DIR . 'classes/doRoomEntryInfo.php');
					}
// end fix
				}
			}	
?>