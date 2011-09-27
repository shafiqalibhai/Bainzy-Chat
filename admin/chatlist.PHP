<?php

// cfg
$msg_to_show = 3;
// cfg
require_once('init.php');
if(!inSession()) {
	include('login.php');
	exit;
}
else if(!inPermission('chats'))
{
	$tabName = 'Chats';
	include('nopermit.php');
	exit;
}

ChatServer::loadCMSclass();

$cms = $GLOBALS['fc_config']['cms'];
$cmsclass = strtolower(get_class($cms));
$manageUsers = ($cmsclass == 'defaultcms') || ($cmsclass == 'statelesscms'  && (! isset($cms->constArr)));
if(!$manageUsers)
{
	$smarty->assign('manageUsers',true);
	$smarty->display('chatlist.tpl');
	exit;
}

if(!isset($_REQUEST['roomid']) || isset($_REQUEST['clear'])) $_REQUEST['roomid'] = 0;
if(!isset($_REQUEST['initiatorid']) || isset($_REQUEST['clear'])) $_REQUEST['initiatorid'] = 0;
if(!isset($_REQUEST['moderatorid']) || isset($_REQUEST['clear'])) $_REQUEST['moderatorid'] = 0;
if(!isset($_REQUEST['from']) || isset($_REQUEST['clear'])) $_REQUEST['from'] = '';
if(!isset($_REQUEST['to']) || isset($_REQUEST['clear'])) $_REQUEST['to'] = '';
if(!isset($_REQUEST['days']) || isset($_REQUEST['clear'])) $_REQUEST['days'] = '';
if(!isset($_REQUEST['sort']) || isset($_REQUEST['clear'])) $_REQUEST['sort'] = 'none';


//=============================================================================================
// FUNCTIONS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//=============================================================================================

function str2timestamp($str)
{
	//YYYY-MM-DD hh:mm:ss
	return $parts = str_replace(array(' ',':','-'),'',$str);
}
// functions for this only !!!
function start_chat()
{
	global 	$openchats,$rec;
	$openchats[$rec['roomid']]['start'] = $rec['created'];
	$openchats[$rec['roomid']]['usercount'] = 1;
	$openchats[$rec['roomid']]['initiatorid'] =  $rec['userid'];
	$openchats[$rec['roomid']]['initiatorlogin'] = $rec['login'];
	$openchats[$rec['roomid']]['roomid'] = $rec['roomid'];
	$openchats[$rec['roomid']]['roomname'] = $rec['name'];
}
function first_admin()
{
	global 	$openchats,$rec;
	if ( ($rec['roles'] == ROLE_ADMIN) && (!isset($openchats[$rec['roomid']]['firstadminid'])) ) {
		$openchats[$rec['roomid']]['moderatorid'] = $rec['userid'];
		$openchats[$rec['roomid']]['moderatorlogin'] = $rec['login'];
	}
}
function user_enter_room()
{
	global $user_room,$openchats,$rec;
	if ( isset($openchats[$rec['roomid']]['start']) ) {
		// chat session already started
		// check if user is loged in allready
		$user_in_room = ((isset($user_room[$rec['userid']])) && ($user_room[$rec['userid']]));
		if ( ($user_in_room  && ($user_room[$rec['userid']] != $rec['roomid'])) || !$user_in_room ) {
		//if ( (isset($user_room[$rec['userid']])) && $user_room[$rec['userid']] && ($user_room[$rec['userid']] != $rec['roomid'])  ) {
				$openchats[$rec['roomid']]['usercount']++;
		}
	} else {
		// this user is starting chat session
		start_chat();
	}
	first_admin();
	$user_room[$rec['userid']] = $rec['roomid'];
}

function end_chat()
{
	global $openchats, $user_room, $chats, $rec;
	if ( $openchats[$user_room[$rec['userid']]]['usercount'] < 1 ) {
		//this is chat end
		$openchats[$user_room[$rec['userid']]]['end'] = $rec['created'];
		if (display_chat($openchats[$user_room[$rec['userid']]])) {
			$chats[] = $openchats[$user_room[$rec['userid']]];
		}
		// chat session closed clear info.
		$openchats[$user_room[$rec['userid']]] = null;
		//$user_room[$user_room[$rec['userid']]] = null;
	}
}
function user_leave_room()
{
	global $openchats, $user_room, $chats, $rec;
	if ( isset($user_room[$rec['userid']]) && $user_room[$rec['userid']] && (isset($openchats[$user_room[$rec['userid']]]['start'])) ) {
		$openchats[$user_room[$rec['userid']]]['usercount']--;
		end_chat();
	}
}

function time_array($time_stamp)
{
	if ( (strlen($time_stamp) == 14) && is_numeric($time_stamp) ){
		$result['YYYY'] = substr($time_stamp,0 ,4);
		$result['MM'] =   substr($time_stamp,4 ,2);
		$result['DD'] =   substr($time_stamp,6 ,2);
		$result['hh'] =   substr($time_stamp,8 ,2);
		$result['mm'] =   substr($time_stamp,10 ,2);
		$result['ss'] =   substr($time_stamp,12 ,2);
		return $result;
	}
	return false;
}

function time_display($time_array)
{
	if ($time_array) {
		return "{$time_array['YYYY']}-{$time_array['MM']}-{$time_array['DD']} {$time_array['hh']}:{$time_array['mm']}:{$time_array['ss']}";
	}
	return "unknown";
}
function time_min ($timestampmin , $timestampmax)
{
	if (strcasecmp($timestampmin , $timestampmax) < 0) { return true;}
	return false;
}
function time_between($timestamp1,$timestamp2, $bet)
{
	if ( (time_min($bet,$timestamp1) && time_min($timestamp2, $bet)) ||
		(time_min($bet, $timestamp2) && time_min($timestamp1, $bet)) ) {
		return true;
	} else {
		return false;
	}
}

function time_for_msgs($time_array)
{
	// MM/DD/YY
	$YY = substr($time_array['YYYY'],2,2);
	if ($time_array) {
		return "{$time_array['MM']}/{$time_array['DD']}/$YY";
	}
	return "unknown";
}

function display_chat($request) //filter function
{
	if ( ($request['roomid'] != $_REQUEST['roomid']) && ($_REQUEST['roomid'] != 0) ) {
		return false;
	}
	if ( ($request['initiatorid'] != $_REQUEST['initiatorid']) && ($_REQUEST['initiatorid'] != 0) ) {
		return false;
	}
	if ( (isset($request['moderatorid'])) && ($request['moderatorid'] != $_REQUEST['moderatorid']) && ($_REQUEST['moderatorid'] != 0) ) {
		return false;
	}
	if ( (!isset($request['moderatorid'])) && ($_REQUEST['moderatorid'] != 0) ) {
		return false;
	}
	return true;
}

//=============================================================================================
// FUNCTIONS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
//=============================================================================================

$p = $GLOBALS['fc_config']['db']['pref'];
$m = $p.'messages';
$u = $p.'users';
$r = $p.'rooms';

//get users
$urs = ChatServer::getUsers();

$user_array = array();

if ( is_array( $urs ) ) {
	while( $rec = next( $urs ) ) {
		$user_array[] = $rec;
	}
}
else {
	while($rec = $urs->next()) {
		$user_array[] = $rec;
	}
}

if($GLOBALS['fc_config']['enableBots'])
{
	$GLOBALS['fc_config']['bot']->getUsersIntoArray($user_array);
}

$stmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}rooms");
$rrs = $stmt->process();

$where = array('1=1');
if($_REQUEST['days']) $where[] = "$m.created >= DATE_SUB(NOW(),INTERVAL {$_REQUEST['days']} DAY)";
if($_REQUEST['from']) $where[] = "$m.created >= '" . str2timestamp($_REQUEST['from']) . "'";
if($_REQUEST['to'])   $where[] = "$m.created <= '" . str2timestamp($_REQUEST['to']) . "'";



$query = "SELECT $m.created, $m.command, $m.userid, $m.roomid, $u.login, $u.roles, $r.name".
" FROM $m LEFT JOIN $u ON ($m.userid = $u.id) LEFT JOIN $r ON ($m.roomid = $r.id) WHERE".
" ($m.userid IS NOT NULL) AND ($m.command in('adu','mvu','rmu')) AND ".join(' AND ', $where)." ORDER BY $m.created";

$sttest = new Statement($query);
$result = $sttest->process();

// getting chats
$chats = array();
$openchats = array(); //temp array;
$user_room = array(); //temp array;

while( $rec = next( $urs ) ) {
	$user_array[] = $rec;
}

if ( $result ) {

	while($rec = $result->next()){

		if ($rec['command'] == 'adu') {
			// user is logging in
			user_enter_room();
		} elseif ( $rec['command'] == 'rmu' ) {
			// user is logging out
			user_leave_room();
			$user_room[$rec['userid']] = null;

		} elseif ($rec['command'] == 'mvu') {
			// user moving to another room
			// user leaving room
			user_leave_room();
			// user entering room
			user_enter_room();
		} else {
			echo "error";
		}
	}
}

// sort chats by col
if ($_REQUEST['sort'] != 'none') {
	sort_table($_REQUEST['sort'], $chats);
}

//=============================================================================================
// QUERY CONSTRUCTOR >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//=============================================================================================


//Set variables for display in the query
$rooms = array();
while($rec = $rrs->next()) {
	$rooms[$rec['id']] = $rec['name'];
}


$initiators = array();
foreach ($user_array as $rec) {
	$initiators[$rec['id']] = $rec['login'];
}

$moderators = array();
foreach ($user_array as $rec) {
	$moderators[$rec['id']] = $rec['login'];
}


//=============================================================================================
// QUERY CONSTRUCTOR <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
//=============================================================================================

//=============================================================================================
// CHATS TABLE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//=============================================================================================

if(count($chats) > 0) {

$dispchats = array();
foreach ($chats as $key=>$chat) {
	$temp_chat = $chat;
	$temp_chat['start'] = $chat['start'];//time_display(time_array($chat['start'])); 
	$temp_chat['end'] = $chat['end'];//time_display(time_array($chat['end']));

	$query = "SELECT userid,login,txt FROM $m LEFT JOIN $u ON ($m.userid = $u.id) ".
			"WHERE ($m.command = 'msg') AND ($m.roomid = '{$chat['roomid']}')".
			" AND ($m.created >= {$chat['start']}) AND ($m.created <= {$chat['end']})";
	$sttest = new Statement($query);
	$result = $sttest->process();
	$msg_nr = 0;

	$temp_chat['messages'] = array();
	if($result != null)
	{
		while(($res = $result->next()) and ($msg_nr < $msg_to_show))
		{
			$temp_message 		= array();
			if($res['login'] == '')
			{
				$user = $GLOBALS['fc_config']['bot']->getUser( $res['userid'] );
				$temp_message['name'] = $user['login'];
			}
			else
				$temp_message['name'] 	= $res['login'];
			$temp_message['txt'] 	= $res['txt'];

			array_push($temp_chat['messages'], $temp_message);

			$msg_nr++;
		}
	}
	
	array_push($dispchats, $temp_chat);
}
}

//=============================================================================================
// CHATS TABLE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
//=============================================================================================

//Assign Smarty variables and load the admin template
$smarty->assign('rooms',$rooms);
$smarty->assign('moderators',$moderators);
$smarty->assign('initiators',$initiators);
$smarty->assign('chats',$dispchats);
$smarty->display('chatlist.tpl');

?>