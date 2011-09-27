<?php

	if ( !defined( 'INC_DIR' ) ) {
		die( 'hacking attempt' );
	}

//------------------------------------------
// Joomla 1.0.x
//------------------------------------------

$joomla_root_path = realpath(dirname(__FILE__) . '/../../../') . '/';

$database = NULL;
define("_VALID_MOS", 1);
//require_once($joomla_root_path . "includes/sef.php" );
//require_once($joomla_root_path . "includes/frontend.php" );
require_once($joomla_root_path . "configuration.php");
require_once($joomla_root_path . "includes/database.php");
require_once($joomla_root_path . "includes/joomla.php");
if (!ini_get('register_globals')) {
	while (list( $key, $value ) = each( $_FILES )) $GLOBALS[$key] = $value;
	while (list( $key, $value ) = each( $_ENV )) $GLOBALS[$key] = $value;
	while (list( $key, $value ) = each( $_GET )) $GLOBALS[$key] = $value;
	while (list( $key, $value ) = each( $_POST )) $GLOBALS[$key] = $value;
	while (list( $key, $value ) = each( $_COOKIE )) $GLOBALS[$key] = $value;
	while (list( $key, $value ) = each( $_SERVER )) $GLOBALS[$key] = $value;

	if (isset($_SESSION)) {
		while (list( $key, $value ) = @each( $_SESSION )) $GLOBALS[$key] = $value;
	}

	foreach ($_FILES as $key => $value){
		$GLOBALS[$key] = $_FILES[$key]['tmp_name'];
		foreach ($value as $ext => $value2){
			$key2 = $key . '_' . $ext;
			$GLOBALS[$key2] = $value2;
		}
	}
}


$GLOBALS['database'] =& new database( $GLOBALS['mosConfig_host'], $GLOBALS['mosConfig_user'], $GLOBALS['mosConfig_password'], $GLOBALS['mosConfig_db'], $GLOBALS['mosConfig_dbprefix'] );
$GLOBALS['mainframe'] =& new mosMainFrame( $GLOBALS['database'], "", $GLOBALS['mambo_root_path']);


class MamboCMS {

  var $user = null;
  var $userid = null;

  var $mamboDBConn = null;

  function MamboCMS() {

    $this->mamboDBConn =  $GLOBALS['database'];
    $this->mainframe = $GLOBALS['mainframe'];

    $this->mainframe->initSession();

    if ($this->user =& $this->mainframe->getUser()) {
      $this->userid = $this->user->id;
    }

  }

  function isLoggedIn() {
    return $this->userid;

  }

  function login($login, $password) {

    $acl = new gacl_api($this->mamboDBConn);

    $username = trim($login);
    $passwd = md5(trim($password));


    $this->mamboDBConn->setQuery("SELECT id, gid, block, usertype"
			. "\nFROM #__users"
			. "\nWHERE username='$username' AND password='$passwd' AND block='0' LIMIT 1"
			);
    $row = null;
    if ($this->mamboDBConn->loadObject( $row )) {

      $grp = $acl->getAroGroup( $row->id );

      $row->gid = 1;
      if ($acl->is_group_child_of( $grp->name, 'Registered', 'ARO' ) || $acl->is_group_child_of( $grp->name, 'Administrator', 'ARO' )) {
	$row->gid = 2;
      }
      $row->usertype = $grp->name;

      $session =& $this->mainframe->_session;


      $session->guest = 0;
      $session->username = $username;
      $session->userid = intval( $row->id );
      $session->usertype = $row->usertype;
      $session->gid = intval( $row->gid );

      $session->update();

      return $session->userid;
    }
    else {
      return false;
    }

  } // ends function

  function logout(){
	    $this->user = null;
  }

  function getUser($userid) {

    if ($userid == SPY_USERID) return NULL;

    $user = new mosUser($this->mamboDBConn);
    $user->load($userid);


    $rec = array("login" => $user->username, "id" => $user->id, "roles" => $this->getRoles($user->gid));
    return $rec;

  }

  function getGender($userid)
  {
	        // 'M' for Male, 'F' for Female, NULL for undefined
			return NULL;
  }

  function getUsers() {
	$getUsersStmt = new Statement("SELECT * FROM {$GLOBALS['mosConfig_dbprefix']}users ORDER BY username");
	$users = $getUsersStmt->process();

	while($rec = $users->next()) {

		$users2[$rec['id']]['id'] = $rec['id'];
		$users2[$rec['id']]['password'] = $rec['password'];
		$users2[$rec['id']]['login'] = $rec['username'];
		$users2[$rec['id']]['roles'] = $this->getRoles($rec['gid']);
	}
	return $users2;
  }

  function getUserProfile($userid) {
    if ($userid == SPY_USERID) return NULL;

    return('../index.php?option=com_user&task=UserDetails&Itemid=' . $userid);
  }

  function getRoles($gid) {

    switch($gid) {
    case 17: $roles = ROLE_USER; break;
    case 18: $roles = ROLE_USER; break;
    case 19: $roles = ROLE_USER; break;
    case 20: $roles = ROLE_MODERATOR; break;
    case 21: $roles = ROLE_MODERATOR; break;
    case 23: $roles = ROLE_MODERATOR; break;
    case 24: $roles = ROLE_MODERATOR; break;
    case 25: $roles = ROLE_ADMIN; break;
    case 28: $roles = ROLE_USER; break;
    case 29: $roles = ROLE_USER; break;
    case 30: $roles = ROLE_USER; break;
    default: $roles = ROLE_USER; break;
    }

	if ($GLOBALS['fc_config']['liveSupportMode'] && $roles == ROLE_USER) {

		return ROLE_CUSTOMER;
	}
    return $roles;

  }

	function userInRole($userid, $role) {
		if($user = $this->getUser($userid)) {
			return ($user['roles'] == $role);
		}
		return false;
	}
}


$GLOBALS['fc_config']['db'] = array(
	'host' => $mosConfig_host,
	'user' => $mosConfig_user,
	'pass' => $mosConfig_password,
	'base' => $mosConfig_db,
	'pref' => $mosConfig_dbprefix."fc_",
	);


$GLOBALS['fc_config']['cms'] = new MamboCMS();

	foreach($GLOBALS['fc_config']['languages'] as $k => $v) {
		$GLOBALS['fc_config']['languages'][$k]['dialog']['login']['moderator'] = '';
	}
?>