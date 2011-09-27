<?php
	require_once('inc/common.php');

	header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
	header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
	header("Cache-Control: no-store, no-cache, must-revalidate");
	header("Cache-Control: post-check=0, pre-check=0", false);
	header("Pragma: no-cache");

	$req = array_merge($_GET, $_POST);
		
	$conn =& ChatServer::getConnection($req);
	$mqi = $conn->process($req);

	$users = array();
	$rooms = array();

	function getLocalMessage($messageid, $lang = null) {
		if(!isset($lang)) $lang = $GLOBALS['fc_config']['defaultLanguage'];
		$msg = $GLOBALS['fc_config']['languages'][$lang]['messages'][$messageid];
		if(!$msg) $msg = $GLOBALS['fc_config']['languages'][$GLOBALS['fc_config']['defaultLanguage']]['messages'][$messageid];
		if(!$msg) $msg = $GLOBALS['fc_config']['languages']['en']['messages'][$messageid];
		return $msg;
	}

	function parseMessage($msg, $userLabel, $roomLabel, $timestamp) {
		global $users, $rooms;

		$search = array(
			'USER_LABEL',
			'ROOM_LABEL',
			'TIMESTAMP'
		);

		$replace = array(
			$userLabel,
			$roomLabel,
			$timestamp
		);
		
		return str_replace($search, $replace, $msg);
	}

	function formatMessage($msg, $userLabel = '', $roomLabel = '', $timestamp = '') {
		$color = htmlColor($GLOBALS['fc_config']['themes'][$GLOBALS['fc_config']['defaultTheme']]['enterRoomNotify']);
		return "<font color=\"$color\">" . parseMessage($msg, $userLabel, $roomLabel, $timestamp) . '</font><br>';
	}
?>
<html>
	<head>
		<title>Chat log</title>
		<meta http-equiv=Content-Type content="text/html;  charset=UTF-8">
	</head>

	<style type="text/css">
		<!--
		BODY {
			font-family: <?php echo $req['font']?>, Verdana, Arial, Helvetica, sans-serif;
			font-size: <?php echo $req['size']?>px;
		}
		-->
	</style>


	<body bgcolor="<?php echo htmlColor($GLOBALS['fc_config']['themes'][$GLOBALS['fc_config']['defaultTheme']]['publicLogBackground'])?>" onLoad="window.focus()">
		<?php 
			while($mqi->hasNext()) {
				$m = $mqi->next();

				$m->created = format_Timestamp($m->created, $conn->tzoffset);

				switch($m->command) {
					case 'msgu':
					case 'msgb':
					case 'msg':
						if ($users[$m->userid] == null) break;
						$color = ($m->command != 'msg')?htmlColor($GLOBALS['fc_config']['themes'][$GLOBALS['fc_config']['defaultTheme']]['enterRoomNotify']):$users[$m->userid][2];
						$login = $users[$m->userid][0];
						if($m->touserid) $login .= "->{$users[$m->touserid][0]}";
						echo("<font color=\"$color\">");
						
						$msgLabel = $GLOBALS['fc_config']['labelFormat'];
						$replace_pairs = array( "AVATAR" => "",
												"USER" => $login,
												"TIMESTAMP" => $m->created,
											  );
						$msgLabel = strtr ( $msgLabel, $replace_pairs);
						echo($msgLabel);
														
						$replace_pairs = array( "&amp;apos;" => "'",
												"&lt;" => "<",
												"&gt;" => ">",
												"&amp;" => "&",
												"&nbsp;" => " "
											  );
						$str = strtr ( $m->txt, $replace_pairs);
						echo("{$str}</font><br>");
						
						break;
					case 'adu':
						$users[$m->userid] = array($m->txt, $m->roomid, htmlColor($GLOBALS['fc_config']['themes'][$GLOBALS['fc_config']['defaultTheme']]['recommendedUserColor']));
						if(isset($users[$conn->userid]) && $users[$conn->userid][1] == $m->roomid) {
							echo(formatMessage(getLocalMessage(($m->userid == $conn->userid)?'selfenterroom':'enterroom', $conn->lang), $users[$m->userid][0], $rooms[$m->roomid], $m->created)); 
						}
						break;
					case 'uclc': 
						$users[$m->userid][2] = htmlColor($m->txt);
						break;
					case 'mvu':
						if($m->userid == $conn->userid) {
							echo(formatMessage(getLocalMessage('selfenterroom', $conn->lang), $users[$m->userid][0], $rooms[$m->roomid], $m->created)); 
						} else {
							if($m->roomid == $users[$conn->userid][1]) {
								echo(formatMessage(getLocalMessage('enterroom', $conn->lang), $users[$m->userid][0], $rooms[$m->roomid], $m->created)); 
							} else {
								echo(formatMessage(getLocalMessage('leaveroom', $conn->lang), $users[$m->userid][0], $rooms[$users[$conn->userid][1]], $m->created)); 
							}
						}
					    $users[$m->userid][1] = $m->roomid;
						break;
					case 'rmu':
						echo(formatMessage(getLocalMessage('leaveroom', $conn->lang), $users[$m->userid][0], $rooms[$users[$conn->userid][1]], $m->created)); 
						break;
					case 'adr':
						$rooms[$m->roomid] = $m->txt;
						break;
					case 'error':
						echo(formatMessage(getLocalMessage($m->txt, $conn->lang), $users[$m->userid][0], $rooms[$users[$conn->userid][1]], $m->created)); 
						break;
					case 'back':
						echo(formatMessage("/back {$m->roomid}"));
						break;
					case 'backt':
						echo(formatMessage("/backtime {$m->roomid}"));
						break;
				}
			}
		?>
	</body>
</html>
