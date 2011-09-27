<?php
			//Prevent login if this username/password used by another user
			$stmt = new Statement("SELECT id, ip FROM {$GLOBALS['fc_config']['db']['pref']}connections WHERE userid=? AND id<>?");
			if(($rs = $stmt->process($this->userid, $this->id)) && ($rec = $rs->next())) {
				if($rec['ip'] == $this->ip)
				{
					$conn = new Connection($rec['id']);
					$conn->doLogout('login');
				}
				else
				{
					//!!!do not delete this line
					$this->userid = null;
					//!!!do not delete this line
					return $this->sendBack(new Message('lout', null, null, 'anotherlogin'));
				}
			}

			$stmt = new Statement("SELECT COUNT(*) as cnt FROM {$GLOBALS['fc_config']['db']['pref']}connections WHERE ip=? AND userid IS NOT NULL");
			if(($rs = $stmt->process($this->ip)) && ($rec = $rs->next()) && $this->ip != $GLOBALS['fc_config']['bot_ip'])
			{
				if($rec['cnt'] >= $GLOBALS['fc_config']['loginsPerIP'])
				{
					$this->userid = null;
					return $this->sendBack(new Message('lout', null, null, 'iplimit'));
				}
			}

			// # Paul M - Prevent non authorised members joining # //
			// start fix for banned and non-banned user denial access
			if(
				(ChatServer::userInRole($this->userid, ROLE_NOBODY) || ChatServer::userInRole($this->userid, ROLE_ANY)) && 
				 $this->ip != $GLOBALS['fc_config']['bot_ip']
			  )
			{
			    $txt = ChatServer::userInRole($this->userid, ROLE_NOBODY)? 'banned' : 'wrongPass';
			    $this->userid = null;
			    return $this->sendBack(new Message('lout', null, null, $txt));
		    }
			// end fix

			//Prevent login from banned users/IPs
			$stmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}bans WHERE (banneduserid=? OR ip=?) AND roomid IS NULL");
			if(($rs = $stmt->process($this->userid, $this->ip)) && $rs->hasNext())
			{
				$this->userid = null;
				return $this->sendBack(new Message('lout', null, null, 'banned'));
			}
			//autounban user if he was banned from room
			$stmt = new Statement("DELETE FROM {$GLOBALS['fc_config']['db']['pref']}bans WHERE banneduserid=? AND roomid IS NOT NULL");
			$stmt->process($this->userid);

			$user = ChatServer::getUser($this->userid);

			$ret = $this->doGetLanguage($this->lang);

			$this->sendBack(new Message('lin', $this->userid, $user['roles'], $this->lang));

			//Send room list to user
			$rooms = array();
			$room_pass = array();
			if(ChatServer::userInRole($this->userid, ROLE_CUSTOMER)) {
				$stmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}rooms WHERE name=?");
				if(($rs = $stmt->process("Support Room for {$user['login']}")) && ($rec = $rs->next())) {
					$this->roomid = $rec['id'];
					$this->addRoom($rec, $rooms, $room_pass);
				}
				else
				{
					$this->roomid = $this->doCreateRoom("Support Room for {$user['login']}", true);
					$stmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}rooms WHERE id=?");
					if(($rs = $stmt->process($this->roomid)) && ($rec = $rs->next())) {
						$this->addRoom($rec, $rooms, $room_pass);
					}
				}
				$this->room_is_permanent = false;
			} else {
				$stmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}rooms WHERE ispublic IS NOT NULL AND ispermanent IS NOT NULL ORDER BY ispermanent");
				if($rs = $stmt->process()) {
					while($rec = $rs->next()) {
						$this->addRoom($rec, $rooms, $room_pass);
					}
				}

				// # Paul M - Load permanant, private (Staff) rooms when Chat Admin # //
				if(ChatServer::userInRole($this->userid, ROLE_ADMIN) || ChatServer::userInRole($this->userid, ROLE_MODERATOR))
				{
					$stmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}rooms WHERE ispublic IS NULL AND ispermanent IS NOT NULL ORDER BY created");
					if($rs = $stmt->process())
					{
						while($rec = $rs->next())
						{
							$this->addRoom($rec, $rooms, $room_pass);
						}
					}
				}

				$stmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}rooms WHERE ispublic IS NOT NULL AND ispermanent IS NULL ORDER BY created");
				if($rs = $stmt->process()) {
					while($rec = $rs->next()) {
						$this->addRoom($rec, $rooms, $room_pass);
					}
				}
			}

			//Send user list to user
			$stmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}connections WHERE id<>? AND userid IS NOT NULL");
			if($rs = $stmt->process($this->id)) {
				if($GLOBALS['fc_config']['enableBots'])
				{
					$bots = $GLOBALS['fc_config']['bot']->getBots();
				}

				while($rec = $rs->next()) {
					$user = ChatServer::getUser($rec['userid']);
					$spy = ChatServer::userInRole($rec['userid'], ROLE_SPY);
					if($user && !$spy) {
						if(!$GLOBALS['fc_config']['liveSupportMode'] || !ChatServer::userInRole($this->userid, ROLE_CUSTOMER) || ChatServer::userInRole($rec['userid'], ROLE_ADMIN)) {

							if(!isset($rooms[$rec['roomid']])) $rooms[$rec['roomid']] = 0;
							$rooms[$rec['roomid']] += 1;

							$this->sendBack(new Message('adu2', $rec['userid'], $rec['roomid'], $user['login']));
							$this->sendBack(new Message('uclc', $rec['userid'], null, $rec['color']));
							$this->sendBack(new Message('ustc', $rec['userid'], null, $rec['state']));

							//send bot avatar
							if($rec['userid'] < 0)
							{
								$in_rec = array();
								$in_rec['id'] = $rec['id'];
								$conn =& ChatServer::getConnection($in_rec);
								$conn->doSendAvatar('mavt', $bots[$rec['userid']]['chat_avatar'], 0);
								$conn->doSendAvatar('ravt', $bots[$rec['userid']]['room_avatar'], 0);
							}
						}
					}
				}
			}

			$user = ChatServer::getUser($this->userid);
			if($rooms[$this->roomid] >= $GLOBALS['fc_config']['maxUsersPerRoom'])
			{
				foreach(array_keys($rooms) as $room)
				{
					if($rooms[$room] < $GLOBALS['fc_config']['maxUsersPerRoom'])
					{
						$this->roomid = $room;
						break;
					}
				}

				if($this->roomid <> $room)
					return $this->sendBack(new Message('lout', null, null, 'chatfull'));
			}

			//warn all users about new user
			$this->sendToAll(new Message('adu', $this->userid, $this->roomid, $user['login']));
			$this->sendToAll(new Message('uclc', $this->userid, null, $this->color));
			$this->sendToAll(new Message('ustc', $this->userid, null, $this->state));

			//Update ingonre state
			$stmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}ignors WHERE userid=?");
			if($rs = $stmt->process($this->userid)) {
				while($rec = $rs->next()) {
					$this->sendBack(new Message('ignu', $rec['ignoreduserid']));
				}
			}

			if($GLOBALS['fc_config']['backtimeOnLogin']) $this->doBacktime($GLOBALS['fc_config']['backtimeOnLogin']);
// fix for /welcome message

			if ($GLOBALS['fc_config']['auto_motd']) {
             require_once(INC_DIR . 'classes/doMotd.php');
			 }
            $destination = null;
  			if ($GLOBALS['fc_config']['auto_topic']) {
				require_once(INC_DIR . 'classes/doRoomEntryInfo.php');
			}

// end fix
			return $ret;
?>
