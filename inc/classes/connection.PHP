<?php
	class Connection {
		var $clientId	= null;
		var $id			= null;
		var $userid 	= null;
		var $roomid 	= null;
		var $color 		= null;
		var $state 		= 1;
		var $start 		= 0;
		var $lang 		= 'en';
		var $ip 		= '';
		var $tzoffset 	= 0;
		var $room_is_permanent = false;

		var $messageQueue;

		function Connection($id = null, $args = array()) {
			$this->messageQueue = new MessageQueue();
			
			//clientId is id of client in socket Server
			$this->clientId = $args['clientId'];
			if( $id )
			{
				if( isset($GLOBALS['socket_server']) && ($args['ip'] != $GLOBALS['fc_config']['bot_ip']))
				{
					$this->setData($args);
					$this->updateSelfRoom();	//Touch room
					return;
				}
				
				$rec = $_SESSION['fc_connections'][$id];
				if($rec == null)
				{
					$stmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}connections WHERE id=? LIMIT 1");
					$rs = $stmt->process($id);
					$rec = $rs->next();
				}
				
				if($rec != null)
				{
					$this->setData($rec);
					
					//Touch connection
					$stmt = new Statement("UPDATE {$GLOBALS['fc_config']['db']['pref']}connections SET updated=NOW() WHERE id=?");
					$stmt->process($this->id);
					
					$this->updateSelfRoom();	//Touch room
					return;
				}	
			}
			
			//create cache session
			if(!isset($_SESSION['fc_users_cache'])) 
				$_SESSION['fc_users_cache']  = array();
			if(!isset($_SESSION['fc_gender_cache'])) 
				$_SESSION['fc_gender_cache'] = array();
			if(!isset($_SESSION['fc_roles_cache'])) 
				$_SESSION['fc_roles_cache']  = array();
			if(!isset($_SESSION['fc_connections'])) 
				$_SESSION['fc_connections'] = array(); 
			//

			$this->id     = md5(uniqid(rand(), true));
			$this->userid = ChatServer::isLoggedIn( $args );
			$ar = $this->getAvailableRoom($GLOBALS['fc_config']['defaultRoom']);
			$this->roomid = $ar['id'];
			$this->room_is_permanent = $ar['ispermanent'] != '';
			
			if(!isset($GLOBALS['fc_config']['themes'][$GLOBALS['fc_config']['defaultTheme']]))
			{
				require_once(INC_DIR . 'themes/' . $GLOBALS['fc_config']['defaultTheme'] . '.php');
			}
			$this->color  = $GLOBALS['fc_config']['themes'][$GLOBALS['fc_config']['defaultTheme']]['recommendedUserColor'];
			$this->state  = 1;
			$this->lang   = $GLOBALS['fc_config']['defaultLanguage'];
			
			// # Paul M - Real ip detection # //
			$realip = ''; $proxyip = ''; 
			$ignoreprivate = true; // Set to false to allow private 'real' ip's //	
			if($_SERVER['HTTP_FROM'] != '') $proxyip = $_SERVER['HTTP_FROM']; 
			if($_SERVER['HTTP_FORWARDED'] != '') $proxyip = $_SERVER['HTTP_FORWARDED']; 
			if($_SERVER['HTTP_CLIENT_IP'] != '') $proxyip = $_SERVER['HTTP_CLIENT_IP']; 
			if($_SERVER['HTTP_X_FORWARDED_FOR'] != '') $proxyip = $_SERVER['HTTP_X_FORWARDED_FOR']; 
			if(preg_match("#\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}#", $proxyip, $iplist))
			{
				$proxyip = $iplist[0]; 
				if($ignoreprivate and preg_match("#^(127|10|172\.(1[6-9]|2[0-9]|3[0-1])|192\.168|169\.254)\.#", $proxyip)) $proxyip = ''; 
			}
			else
			{ 
				$proxyip = '';
			}	
			if ($proxyip == '') 
				$realip = $_SERVER['REMOTE_ADDR']; 
			else 
				$realip = $proxyip; 
			
			$this->ip = ($args['ip'] == null)? $realip : $args['ip'];
						
			//socketServer implementation save 'tzoffset'
			if( isset($GLOBALS['socket_server']) && ($this->userid == null || !($this->userid < -1)))
			{
				if(isset($args['tz'])) $this->tzoffset = $args['tz'];
				$GLOBALS['socket_server']->saveClientConnection( $this->clientId, $this->getData() );
			}	
						
			if($this->userid >= -1 && $this->userid != null)
			{
				$this->start = $this->sendLoginInfo();
			}
			else if($args['c'] != 'lin')
			{
				$this->start = $this->sendBack(new Message('lout', null, null, 'login'));
			}
			
			//socketServer implementation save 'start'
			if( isset($GLOBALS['socket_server']) && ($this->userid == null || !($this->userid < -1)))
			{
				$GLOBALS['socket_server']->saveClientConnection( $this->clientId, $this->getData() );
			}	

			$stmt = new Statement("INSERT INTO {$GLOBALS['fc_config']['db']['pref']}connections (id, updated, created, userid, roomid, color, state, start, lang, ip) VALUES (?, NOW(), NOW(), ?, ?, ?, ?, ?, ?, ?)");
			$ret = $stmt->process($this->id, $this->userid, $this->roomid, $this->color, $this->state, $this->start, $this->lang, $this->ip);
			
			$this->saveConnection2Session();
		}
		
		function saveConnection2Session()
		{
			$_SESSION['fc_connections'][$this->id] = $this->getData();				
		}
		
		function updateSelfRoom()
		{
			// next line fix for default room touch
			if(	$this->roomid == $GLOBALS['fc_config']['defaultRoom'] || $this->room_is_permanent ) 
				return;
			
			$stmt = new Statement("UPDATE {$GLOBALS['fc_config']['db']['pref']}rooms SET updated=NOW() WHERE id=?");
			$stmt->process($this->roomid);
		}
		
		function getAvailableRoom($roomId)
		{
			$stmt = new Statement("SELECT id, ispermanent FROM {$GLOBALS['fc_config']['db']['pref']}rooms");
			$rs = $stmt->process();

			$retval = array();
			while($rec = $rs->next())
			{
				if(count($retval) == 0) $retval = $rec;
				if($rec['id'] == $roomId)
				{
					$retval = $rec;
					break;
				}
			}

			return ($retval);
		}
		
		function setData($inArray)
		{
			$this->id       = $inArray['id'];
			$this->userid   = $inArray['userid'];
			$this->roomid   = $inArray['roomid'];
			$this->color    = $inArray['color'];
			$this->state    = $inArray['state'];
			$this->start    = $inArray['start'];
			$this->lang     = $inArray['lang'];
			$this->ip       = $inArray['ip'];
			$this->tzoffset = $inArray['tzoffset'];
			$this->room_is_permanent = $inArray['room_is_permanent'];
		}
		
		function getData()
		{
			$data = array(
						'clientId'  => $this->clientId,
						'id'		=> $this->id,
						'userid'	=> $this->userid,
						'roomid'	=> $this->roomid,
						'color'		=> $this->color,
						'state'		=> $this->state,
						'start'		=> $this->start,
						'lang'		=> $this->lang,
						'ip' 		=> $this->ip,
						'tzoffset'	=> $this->tzoffset,
						'room_is_permanent' => $this->room_is_permanent
			);
			
			return $data;
		}
		
		function save() {
			//socketServer implementation
			if( isset($GLOBALS['socket_server']) && !($this->userid < 0) )
			{
				$GLOBALS['socket_server']->saveClientConnection( $this->clientId, $this->getData() );
			}	
			
			$stmt = new Statement("UPDATE {$GLOBALS['fc_config']['db']['pref']}connections SET updated=NOW(), userid=?, roomid=?, color=?, state=?, start=?, lang=?, ip=?, tzoffset=? WHERE id=?");
			$stmt->process($this->userid, $this->roomid, $this->color, $this->state, $this->start, $this->lang, $this->ip, $this->tzoffset, $this->id);
			$this->saveConnection2Session();
		}

		function send($message) {
			//Spy can send messages back to him self only
			if(ChatServer::userInRole($this->userid, ROLE_SPY)) {
				$message->toconnid = $this->id;
				$message->touserid = null;
				$message->toroomid = null;
			}
			
			//socketServer implementation
			if( isset($GLOBALS['socket_server']) )
			{
				$GLOBALS['socket_server']->sendMessage( $message );
				//if socket server then write only 'msg' messages
				//if(!in_array($message->command, array('msg', 'adu', 'mvu', 'rmu', 'lout', 'glng', 'lng'))) return;
			}
			
			return $this->messageQueue->addMessage( $message );
		}

		function sendBack($message) {
			$message->toconnid = $this->id;
			return $this->send($message);
		}

		function sendToUser($userid, $message) {
			$stmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}ignors WHERE userid=? AND ignoreduserid=?");
			if(
				($rs = $stmt->process($userid, $this->userid)) && $rs->hasNext() &&
				 $message->command != 'ignu' && $message->command != 'nignu'
			)
			{
				$this->sendBack(new Message('error', $userid, 0, 'ignored'));
			} else {
				switch($message->command) {
					case 'nignu':
					case 'ignu':
					case 'msg':
						$message->toconnid = $this->id;
						break;
				}

				/*
				$stmt = new Statement("SELECT id FROM {$GLOBALS['fc_config']['db']['pref']}users WHERE roles=?");
				if(($rs = $stmt->process(ROLE_ADMIN)))
				{
					while($rs->hasNext())
					{
						$i = $rs->next();
						$message->touserid = $i['id'];
						if($message->touserid != $this->userid && $message->touserid != $userid ) $this->send($message);
					}
				}
				*/

				$message->touserid = $userid;
				return $this->send($message);
			}
		}

		function sendToAll($message) {
			$message->toconnid = null;
			$message->touserid = null;
			$message->toroomid = null;
			return $this->send($message);
		}

		function sendToRoom($roomid, $message) {
			$message->toroomid = $roomid;
			return $this->send($message);
		}

		function process($req) {
			
//			toLog("req",$req);
			
			//Set default values for missed request params
			if(!isset($req['c'])) $req['c']   = 'msgl'; 	//command
			if(!isset($req['u'])) $req['u']   = null;   	//userId or UserName
			if(!isset($req['r'])) $req['r']   = null;   	//roomId
			if(!isset($req['b'])) $req['b']   = 0;      	//backtime
			if(!isset($req['t'])) $req['t']   = '';     	//text
			if(!isset($req['l'])) $req['l']   = null;   	//language
			if(!isset($req['p'])) $req['p']   = 0;      	//is public room
			if(!isset($req['lg'])) $req['lg'] = '';     	//login
			if(!isset($req['ps'])) $req['ps'] = '';     	//password
			if(!isset($req['n'])) $req['n']   = 0;      	//???
			if(!isset($req['a'])) $req['a']   = '';     	// additional arguments
			if(!isset($req['s'])) $req['s']   = 0;      	//???
			if(!isset($req['tz'])) $req['tz'] = 0;      	//timezone

			if(get_magic_quotes_gpc())
			{
				foreach($req as $k => $v) $req[$k] = stripslashes($v);
			}

			if($req['c'] == 'lin')
			{
				//Try to login
				$this->doLogin($req['lg'], $req['ps'], $req['l'], $req['tz'], $req['r'], $req['bot_ip']);
			}
			else if($req['c'] == 'tzset')
			{
				$this->doTimeZoneSet($req['tz']);
			}
			else if($this->userid)
			{
				//Process request
				switch($req['c']) {
					case 'msgl'  : $this->doLoadMessages(); break;
					case 'lout'  : $this->doLogout(); break;
					case 'msg'   : $this->doSendMessageTo($req['u'], $req['r'], $req['t'], $req['a'], $req['s']); break;
					case 'mvu'   : $this->doMoveTo($req['r'], null, $req['ps']); break;
					case 'imvu'  : $this->doMoveTo($req['r'], null, $req['ps'], true); break;
					case 'adr'   : $this->doCreateRoom($req['l'], $req['p'], $req['ps']); break;
					case 'invu'  : $this->doInviteUserTo($req['u'], $req['r'], $req['t']); break;
					case 'inva'  : $this->doAcceptInvitationTo($req['u'], $req['r'], $req['t']); break;
					case 'invd'  : $this->doDeclineInvitationTo($req['u'], $req['r'], $req['t']); break;
					case 'ignu'  : $this->doIgnoreUser($req['u'], $req['t']); break;
					case 'nignu' : $this->doUnignoreUser($req['u'], $req['t']); break;
					case 'sst'   : $this->doSetState($req['t']); break;
					case 'scl'   : $this->doSetColor($req['t']); break;
					case 'usrp'  : $this->doRequestUserProfileText($req['u']); break;
					case 'help'  : $this->doRequestHelpText(); break;
					case 'ring'  : $this->doRing(); break;
					case 'back'  : $this->doBack($req['n']); break;
					case 'backt' : $this->doBacktime($req['n']); break;
					case 'glan'  : $this->doGetLanguage($req['l'], true, $req['s']); break;
					case 'cfrm'  : $this->doConfirm($req['u'], $req['t'], $req['a']); break;
					case 'mavt'  :
					case 'ravt'  : $this->doSendAvatar($req['c'], $req['a'], $req['u']); break;
					case 'spht'  : $this->sendToAll(new Message($req['c'], $this->userid, null, $req['a'])); break;
					case 'gpht'  : $this->doGetPhoto($req['u']); break;
					case 'sgen'  : $this->doSetGender($req['u'], $req['t']); break;
					case 'flshr' : $this->doFileShare($req['u'], $req['a'], $req['r']); break;
					default: addError("Unhandled request: {$req['c']}"); break;
				}
				
				//admin commands
				if( 
					ChatServer::userInRole($this->userid, ROLE_ADMIN) || 
					ChatServer::userInRole($this->userid, ROLE_MODERATOR) ||
					($req['s'] == 7)
				  )
				{
					switch($req['c']) {
						case 'alrt'  : $this->doAlert($req['u'], $req['t']); break;
						case 'ralrt' : $this->doRoomAlert($req['r'], $req['t']); break;
						case 'calrt' : $this->doChatAlert($req['t']); break;
						case 'banu'  : $this->doBanUser($req['u'], $req['b'], $req['r'], $req['t']); break;
						case 'nbanu' : $this->doUnbanUser($req['u'], $req['t']); break;
						case 'gag'   : $this->doGag($req['u'], $req['t']); break;
						case 'ngag'  : $this->doUnGag($req['u'], $req['t']); break;
						default: addError("Unhandled admin request: {$req['c']}"); break;
					}
					
					//if bots are enabled
					if( $GLOBALS['fc_config']['enableBots'] )
					{
						switch($req['c']) {
							case 'srtbt' : $this->doStartBot($req['lg'], $req['r']); break;
							case 'klbt'  : $this->doKillBot($req['lg']); break;
							case 'adbt'  : $this->doAddBot($req['lg'], $req['a']); break;
							case 'rmbt'  : $this->doRemoveBot($req['lg']); break;
							case 'tchbt' : $this->doTeachBot($req['lg'], $req['a']); break;
							case 'utbt'  : $this->doUnTeachBot($req['lg'], $req['a']); break;
							case 'swbt'  : $this->doShowBots(); break;
							default: addError("Unhandled admin bot request: {$req['c']}"); break;
						}	
					}
					else if(strpos('srtbt klbt adbt rmbt tchbt utbt swbt', $req['c']) !== false) 
					{
						$this->sendBack(new Message('error', null, null, 'botfeat'));
					}	
				}
			}

			if( isset($GLOBALS['socket_server']) ) return;

			//Send back actual messages
			$start = max($this->start, $req['b']);
			return $this->messageQueue->getMessages($this->id, $this->userid, $this->roomid, $start);
		}

		function doTimeZoneSet($tzoffset) {
			$this->tzoffset = $tzoffset;
			$this->save();
		}

		function doLoadMessages() {
		}

		function doLogin($login, $password, $lang, $tzoffset, $roomid = null, $bot_id = null) {
			include(INC_DIR . 'classes/doLogin.php');
		}

		function doGetLanguage($lang, $save=false, $save_only=0) {
			return (include(INC_DIR . 'classes/doGetLanguage.php'));
		}

		function sendLoginInfo() {
			return (include(INC_DIR . 'classes/sendLoginInfo.php'));
		}

		function doLogout($msg = null) {
			include(INC_DIR . 'classes/doLogout.php');
		}

		function doSendMessageTo($touserid, $toroomid, $txt, $args, $sup=0) 
		{
			$type = ($args == 'isUrgent')?'msgu':'msg';
			$txt = trim($txt, ' ');
// start query, msg, whois, whowas, who, unignore, showignores, showbans, rooms, reban and names fix
			
			$irctxt = strip_tags($txt);
            if(strpos($irctxt, ' ')) $irc_len = strpos($irctxt, ' '); else $irc_len = strlen($irctxt);
            $irc_cmd = strtolower(substr($irctxt, 0, $irc_len));

			
			$r_admin = ChatServer::userInRole($this->userid, ROLE_ADMIN);
			$r_mod   = ChatServer::userInRole($this->userid, ROLE_MODERATOR);
 			$role_admin = $r_admin || $r_mod || ($sup == 7);

			$comm = $GLOBALS['fc_config']['disabledIRC'];
			if($r_mod) $comm = $GLOBALS['fc_config']['mods'];
			if(substr($irc_cmd, 0, 1) == '/' && !strstr($comm, substr($irc_cmd, 1)))
			{
				$txt = $irctxt;
				if((include(INC_DIR . 'classes/commands.php')) == 'ok') return;
			}

// end query, msg, whois, whowas, who, unignore, showignores and names fix

			if($touserid) {
				//$this->sendToUser($touserid, new Message($type, $this->userid, $GLOBALS['fc_config']['liveSupportMode']?$this->roomid:null, $txt, $this->color));
				$this->sendToUser($touserid, new Message($type, $this->userid, null, $txt, $this->color));
			} else {
				if(!$role_admin) $toroomid = $this->roomid;

				$this->sendToRoom($toroomid?$toroomid:null, new Message($type, $this->userid, $toroomid, $txt, $this->color));
				
				//blink if nothing
				if($GLOBALS['fc_config']['liveSupportMode'] && ChatServer::userInRole($this->userid, ROLE_CUSTOMER))
				{
					$stmt = new Statement("SELECT COUNT(*) AS CNT FROM {$GLOBALS['fc_config']['db']['pref']}connections WHERE roomid=? AND userid IS NOT NULL");
					$rs = $stmt->process($this->roomid);
					if( $rec = $rs->next() )
						if( $rec['CNT'] == 1)
						{
							$this->sendToAll(new Message('notf', $this->userid, null, null));		
						}
				}
			}
		}

		function doMoveTo($toroomid, $msg = null, $pass = '', $is_invite = false) {
			include(INC_DIR . 'classes/doMoveTo.php');
		}

		function doCreateRoom($label, $isPublic, $pass = '') {
			return (include(INC_DIR . 'classes/doCreateRoom.php'));
		}

		function doInviteUserTo($invitedUserID, $toRoomID, $txt) {
			include(INC_DIR . 'classes/doInviteUserTo.php');
		}

		function doAcceptInvitationTo($invitedByUserID, $toRoomID, $txt) {
			$this->sendToUser($invitedByUserID, new Message('inva', $this->userid, $toRoomID, $txt));
		}

		function doDeclineInvitationTo($invitedByUserID, $toRoomID, $txt) {
			include(INC_DIR . 'classes/doDeclineInvitationTo.php');
		}

		function doIgnoreUser($ignoredUserID, $txt) {
			include(INC_DIR . 'classes/doIgnoreUser.php');
		}

		function doUnignoreUser($ignoredUserID, $txt) {
			include(INC_DIR . 'classes/doUnignoreUser.php');
		}

		function doBanUser($bannedUserID, $banType, $fromRoomID, $txt) {
			include(INC_DIR . 'classes/doBanUser.php');
		}

		function doUnbanUser($bannedUserID, $txt) {
			include(INC_DIR . 'classes/doUnbanUser.php');
		}

		function doAlert($userID, $txt) {
			include(INC_DIR . 'classes/doAlert.php');
		}

		function doRoomAlert($roomID, $txt) {
			include(INC_DIR . 'classes/doRoomAlert.php');
		}

		function doChatAlert($txt) {
			include(INC_DIR . 'classes/doChatAlert.php');
		}

		function doGag($userID, $min) {
			include(INC_DIR . 'classes/doGag.php');
		}

		function doUnGag($userID, $txt){
			include(INC_DIR . 'classes/doUnGag.php');
		}

		function doConfirm($userID, $data, $args){
			include(INC_DIR . 'classes/doConfirm.php');
		}

		function doSendAvatar($type, $args, $userID){
			if($userID == 0)
				$this->sendToAll(new Message($type, $this->userid, null, $args));
			else
				$this->sendToUser($userID, new Message($type, $this->userid, null, $args));
		}

		function doSetState($state) {
			$this->state = $state;
			$this->sendToAll(new Message('ustc', $this->userid, null, $this->state));

			$this->save();
		}

		function doSetColor($color) {
			$this->color = $color;
			$this->sendToAll(new Message('uclc', $this->userid, null, $this->color));

			$this->save();
		}

		function doRequestUserProfileText($userid) {
			$prof = ChatServer::getUserProfile($userid);
			if($prof != null) $this->sendBack(new Message('usrp', $userid, null, $prof));
		}

		function doRequestHelpText() {
			$this->sendBack(new Message('help', null, null, "<b>help</b> text"));
		}

		function doRing() {
			include(INC_DIR . 'classes/doRing.php');
		}

		function doBack($numb) {
			include(INC_DIR . 'classes/doBack.php');
		}

		function doBacktime($numb) {
			include(INC_DIR . 'classes/doBacktime.php');
		}

		function doStartBot($login, $roomId) {
			include(INC_DIR . 'classes/doStartBot.php');
		}

		function doKillBot($userName){
			include(INC_DIR . 'classes/doKillBot.php');
		}

		function doAddBot($login, $bot){
			include(INC_DIR . 'classes/doAddBot.php');
		}

		function doRemoveBot($userName){
			include(INC_DIR . 'classes/doRemoveBot.php');
		}

		function doTeachBot($userName, $args){
			include(INC_DIR . 'classes/doTeachBot.php');
		}

		function doUnTeachBot($userName, $args){
			include(INC_DIR . 'classes/doUnTeachBot.php');
		}

		function doShowBots(){
			include(INC_DIR . 'classes/doShowBots.php');
		}

		function doSetGender($userID, $gender){
			$this->sendToUser($userID, new Message('sgen', $this->userid, null, $gender));
		}
		
		function doFileShare($userID, $toUserID, $toRoomID){
			$this->sendToUser($toUserID, new Message('fileshare', $userID, $toRoomID));
		}
		
		function doGetPhoto($userID){
			$url = chatServer::getPhoto($userID);
			$this->sendToUser($this->userid, new Message('spht', $userID, null, $url));
		}
		
		function addRoom($rec, &$rooms, &$room_pass){
			$this->sendBack(new Message('adr', null, $rec['id'], $rec['name']));
			if( $rec['password'] != '' )
			{
				$this->sendBack(new Message('srl', null, $rec['id'], 'true'));
			}
				
			$rooms[$rec['id']] = 0;
			$room_pass[$rec['id']] = ($rec['password'] != '');
		}
	}
?>
