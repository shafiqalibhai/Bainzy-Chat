<?php

	header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
	header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
	header("Cache-Control: no-store, no-cache, must-revalidate");
	header("Cache-Control: post-check=0, pre-check=0", false);
	header("Pragma: no-cache");


/**
If this file is not in the FlashChat root folder, then change this
path to the location of the inc/common.php file.
*/
require_once('inc/common.php');

ChatServer::purgeExpired();

/**
Retrieves the number of users who are chatting in any room.
Leave the $room parameter empty to return the number of users in all room.
*/
function numusers( $room = "" )
{
	if($room) {
		$stmt = new Statement("SELECT COUNT(*) AS numb FROM {$GLOBALS['fc_config']['db']['pref']}connections WHERE userid IS NOT NULL AND userid <> ? AND roomid=?");
		$rs = $stmt->process(SPY_USERID, $room);
	} else {
		$stmt = new Statement("SELECT COUNT(*) AS numb FROM {$GLOBALS['fc_config']['db']['pref']}connections,{$GLOBALS['fc_config']['db']['pref']}rooms
							  WHERE userid IS NOT NULL AND userid <> ? AND ispublic IS NOT NULL
							  AND {$GLOBALS['fc_config']['db']['pref']}connections.roomid = {$GLOBALS['fc_config']['db']['pref']}rooms.id");
		$rs = $stmt->process(SPY_USERID);
	}

	$rec = $rs->next();

	return $rec?$rec['numb']:0;
}

/**
Retrieves a list of the users (by login ID) who are in $room.
Leave the $room parameter empty to return a list of all users in all rooms.
*/
function usersinroom( $room = "" )
{
	$list = array();

	if($room) {
		$stmt = new Statement("SELECT userid, state, color, lang, roomid FROM {$GLOBALS['fc_config']['db']['pref']}connections WHERE userid IS NOT NULL AND userid <> ? AND roomid=?");
		$rs = $stmt->process(SPY_USERID, $room);
	} else {
		$stmt = new Statement("SELECT userid, state, color, lang, roomid FROM {$GLOBALS['fc_config']['db']['pref']}connections WHERE userid IS NOT NULL AND userid <> ?");
		$rs = $stmt->process(SPY_USERID);
	}

	while($rec = $rs->next())
	{
		$usr = ChatServer::getUser($rec['userid']);
		if($usr == null && $GLOBALS['fc_config']['enableBots']) $usr = $GLOBALS['fc_config']['bot']->getUser($rec['userid']);
		$list[] = array_merge($usr, $rec);
	}

	return $list;
}

/**
Retrieves a list of all available rooms, as an array.
*/
function roomlist()
{
	$list = array();

	// populate $list with the names of all available rooms
	$stmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}rooms WHERE ispublic IS NOT NULL order by ispermanent");
	$rs = $stmt->process();

	while($rec = $rs->next()) $list[] = $rec;

	//result will be an array of arrays like ('id' => <room id>, 'updated' = <timestamp>, 'created' => <timestamp>, 'name' => <room name>, 'ispublic' => <public flag>, 'ispermanent' => <autoclose flag>)
	return $list;
}


$rooms = roomlist();
$roomnumb = sizeof($rooms);
$usernumb = numusers();
?><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Who's in the chat?</title>
<meta http-equiv=Content-Type content="text/html;  charset=UTF-8">
<style type="text/css">
<!--
.normal {
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 12px;
	font-weight: normal;
}
A {
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 12px;
	color: #0000FF;
}
A:hover {
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 12px;
	color: #FF0000;
}
-->
</style>
</head>
	<body>
		<center>
		<p class=normal>There are <?php echo numusers()?> users in <?php echo $roomnumb?> rooms.</p>
		<?php if($roomnumb) { ?>
			<table border="1" cellpadding="1" class="normal">
				<tr>
					<th>ID</th>
					<th>Name</th>
					<th>Count</th>
					<th>Users</th>
				</tr>
				<?php foreach($rooms as $room) { ?>
					<tr>
						<td><?php echo $room['id']?></td>
						<td><?php echo $room['name']?></td>
						<td><?php echo numusers($room['id'])?></td>
						<td><?php

						$users = usersinroom($room['id']);

						foreach( $users as $user ) {
							echo $user['login'] . "<br>";
						}

						?> </td>
					</tr>
				<?php } ?>
			</table>
		<?php } ?>

		<p><a href="javascript:window.close()">Close</a></p>
		</center>
	</body>
</html>
