<?php
// start fix nr 2 for no bans on ChatOwner
			if(in_array($bannedUserID, $GLOBALS['fc_config']['ChatOwner'])) return;
// end fix

			$this->sendToUser($bannedUserID, new Message('banu', $this->userid, $banType, $txt));

			$roomid = null;
			$ip = null;

			$stmt = new Statement("SELECT id FROM {$GLOBALS['fc_config']['db']['pref']}connections WHERE userid=?  LIMIT 1");
			if(($rs = $stmt->process($bannedUserID)) && ($rec = $rs->next())) {
				$clientId = null;
				if(isset($GLOBALS['socket_server'])) $clientId = $GLOBALS['socket_server']->clientInfo['userid'][$bannedUserID];
				$conn = ChatServer::getConnection($rec, $clientId);
// start fix nr 3 for message to room users about bans

				$br = ChatServer::getUser($this->userid);
				$bd = ChatServer::getUser($bannedUserID);
				if($banType == BAN_BYROOMID) {$bt = 'room';}
				if($banType == BAN_BYUSERID || $banType == BAN_BYIP) {$bt = 'chat';}

				if($this->userid == $bannedUserID) $br['login'] = 'MODULE';
				$this->sendToRoom($conn->roomid, new Message('ralrt', $this->userid, null, '<BR>' . $br['login'] . ' bans ' . $bd['login'] . ' from ' . $bt . ' with message:<BR><BR>' . $txt));
// end of fix

				switch($banType) {
					case BAN_BYUSERID:
						$conn->doLogout('banned');
						break;
					case BAN_BYROOMID: 
						/*
						$roomid = $fromRoomID;
						if($conn->roomid == $fromRoomID) {
							if($fromRoomID == $this->getAvailableRoom($GLOBALS['fc_config']['defaultRoom'])) {
								$conn->doLogout('banned');
							} else {
								$conn->doMoveTo($this->getAvailableRoom($GLOBALS['fc_config']['defaultRoom']), 'banned');
							}
						}
						*/
						
						$roomid = $fromRoomID;
						$stmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}bans WHERE banneduserid=? AND roomid=?");
						if(!(($rs = $stmt->process($bannedUserID, $roomid)) && $rs->hasNext()))
						{
							$qry = "INSERT INTO {$GLOBALS['fc_config']['db']['pref']}bans 
									(created, userid, banneduserid, roomid, ip) 
									VALUES (NOW(), ?, ?, ?, ?)";
							$stmt = new Statement($qry);
							$stmt->process($this->userid, $bannedUserID, $roomid, $ip);
						}
						
						if($conn->roomid == $fromRoomID)
						{
							$stmt = new Statement("SELECT id FROM {$GLOBALS['fc_config']['db']['pref']}rooms WHERE password=''");
							$rs = $stmt->process();
							while( $rs->hasNext())
							{
							 	$i = $rs->next();
								$rec_rooms[] = $i['id'];
							}
									
							$stmt = new Statement("SELECT roomid FROM {$GLOBALS['fc_config']['db']['pref']}bans WHERE banneduserid=?");
							$rs = $stmt->process($bannedUserID);
							while( $rs->hasNext())
							{
							 	$i = $rs->next();
								$rec_bans[] = $i['roomid'];
							}
							
							$stmt = new Statement("SELECT roomid
												   FROM {$GLOBALS['fc_config']['db']['pref']}connections 
												   WHERE id<>? AND userid IS NOT NULL
												   GROUP BY roomid
												   HAVING COUNT(*) < {$GLOBALS['fc_config']['maxUsersPerRoom']}");
							$rs = $stmt->process($bannedUserID);
							while( $rs->hasNext())
							{
							 	$i = $rs->next();
								$rec_full[] = $i['roomid'];
							}
													
							$free_rooms = (count($rec_bans) > 0)? array_diff($rec_rooms, $rec_bans) : $rec_rooms;
							$free_rooms = (count($rec_full) > 0)? array_diff($free_rooms, $rec_full) : $free_rooms;
							
							$id = array_pop(array_reverse($free_rooms));
							
							if( $id )
							{
								$conn->doMoveTo($id, 'banned');
							} 
							else
							{
								$conn->doLogout('banned');
							}
						}
						break;
					case BAN_BYIP: 
						$ip = $conn->ip;
						$conn->doLogout('banned!#@#!'.$this->userid.'!#@#!'.$txt);
						break;
				}
			}
			
			if($banType != BAN_BYROOMID)
			{
				$stmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}bans WHERE banneduserid=?");
				if(($rs = $stmt->process($bannedUserID)) && $rs->hasNext()) {
					$stmt = new Statement("UPDATE {$GLOBALS['fc_config']['db']['pref']}bans SET created=NOW(), userid=?, roomid=?, ip=? WHERE banneduserid=?");
					$stmt->process($this->userid, $roomid, $ip, $bannedUserID);
				} else {
					$stmt = new Statement("INSERT INTO {$GLOBALS['fc_config']['db']['pref']}bans (created, userid, banneduserid, roomid, ip) VALUES (NOW(), ?, ?, ?, ?)");
					
					if($banType == BAN_BYIP && ($GLOBALS['fc_config']['CMSsystem'] == ''  || $GLOBALS['fc_config']['CMSsystem'] == 'statelessCMS')) 					
					{
						$bid = null; 
					}					
					else $bid = $bannedUserID;
					
     				$stmt->process($this->userid, $bid, $roomid, $ip);										
				}
			}
?>