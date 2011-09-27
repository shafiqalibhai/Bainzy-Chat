<?php

	if ( !defined( 'INC_DIR' ) ) {
		die( 'hacking attempt' );
	}

/************************************************************************/
//!!! IMPORTANT NOTE
//!!! FlashChat 4.4.0 and higher support a new user role: ROLE_MODERATOR
//!!! Please edit the getUser and getRoles function if you need use of
//!!! the new moderator role. This change has not yet been applied.
/************************************************************************/

//error_reporting(E_ALL);
// variation of AEDating integration class which only permits access to Gold members

$aed_root_path = realpath(dirname(__FILE__) . '/../../../') . '/';

include($aed_root_path . 'inc/header.inc.php');
require_once( "$dir[inc]db.inc.php" );
require_once( "$dir[inc]admin.inc.php" );

// access control for site members
// Set $access_gold to 1 to restrict access only for Gold subscribers
// Set $access_gold to 0 to allow access to every member
$access_gold = 1;


class AEDatingCMS {

    var $userid;
    var $loginStmt;
    var $getUserStmt;
    var $getUsersStmt;

    function AEDatingCMS() {

      $this->userid = NULL;

      $this->getUserStmt = new Statement("SELECT ID AS id, NickName AS login, ExtraAddons FROM Profiles WHERE ID = ? LIMIT 1");
      $this->getAdminsStmt = new Statement("SELECT Name AS login FROM Admins");

      $this->getUsersStmt = new Statement("SELECT ID AS id, NickName AS login FROM Profiles");

      // in addition to NOT having a numeric ID, admin passwords are stored unencrypted...
      $this->adminLoginStmt = new Statement("SELECT * FROM Admins WHERE Name = ? AND Password = ? LIMIT 1");


    }

    function isLoggedIn() {
      global $access_gold;

      if (isset($_COOKIE['memberID']) && isset($_COOKIE['memberPassword'])) {
        $this->userid = $_COOKIE['memberID'];
        if ($access_gold == 1) {
             $user = $this->getUser($_COOKIE['memberID']);
		 $this->userid = (!strlen($user['ExtraAddons']) ? NULL : $user['id']);
	  }

      }
      elseif (isset($_COOKIE['adminID']) && isset($_COOKIE['adminPassword'])) {
        // admin cookie.
        $this->userid = $this->genAdminID($_COOKIE['adminID']);
        $this->adminUser = true;
      }

      return $this->userid;

    }

    function getRoles() {

      $rv = NULL;

      if ($GLOBALS['fc_config']['liveSupportMode'])
        $rv = ROLE_CUSTOMER;
      elseif ($this->adminUser)
        $rv = ROLE_ADMIN;
      else
        $rv = ROLE_USER;

      return $rv;

    }

    function getUserProfile($userid) {

      if ($userid == SPY_USERID) $rv = NULL;

      elseif ($user = $this->getUser($userid))
	  {

        //if ($user['roles'] == ROLE_ADMIN) return NULL; // admins don't have a profile

        $boardURL = $GLOBALS['site']['url'];

        $rv = ($userid == $this->isLoggedIn()) ? $boardURL . "profile_edit.php?ID=" . $userid : $boardURL . "profile.php?ID=" . $userid;

        return $rv;
      }
    }


    function getUser($userid) {
      $rv = NULL;
      if(($rs = $this->getUserStmt->process($userid)) && ($rec = $rs->next())) {
        $rec['roles'] = ROLE_USER;
        $rv = $rec;
      }
      elseif (($rs = $this->getAdminsStmt->process()) && $rs->hasNext()) {
        while ($rs->hasNext()) {
          $rec = $rs->next();
          if ($userid == $this->genAdminID($rec['login'])) {
        break;
          }

        }
        $rec['roles'] = ROLE_ADMIN;
        $rec['id'] = $this->genAdminID($rec['login']);
        $rv = $rec;
      }

      return $rv;
    }

    function login($login, $password) {

      global $access_gold;

      $id = NULL;

      $passwd = crypt( $password, 'secret_string' );

      if ($id = getID($login)) {
      	if ($access_gold == 1) {
            	$user = $this->getUser($id);
           		if (!strlen($user['ExtraAddons'])) {
                      return NULL; // not enough privileges
                  }
	      }
      	if (check_login($id, $password, 'Profiles', false)) {
			setcookie("memberID", $id, 0, '/');
			setcookie("memberPassword", $passwd, 0, '/');
      	}

      }
      else {
        if (($rs = $this->adminLoginStmt->process($login, $password)) && $rs->hasNext()) {
          setcookie("adminID", $login, 0, '/');
          setcookie("adminPassword", $passwd, 0, '/');
          $id = $this->genAdminID($login);
        }

      }
      return $id;

    }

    function genAdminID($adminName) {

      // really simple hashing function
      // AEDating admins have no numeric ID in the table

      $r = 0;

      for ($i = 0; $i < strlen($adminName); $i++) {
        $r = 131 * $r + ord($adminName[$i]);
      }

      return $r;

    }

	function userInRole($userid, $role) {
		if($user = $this->getUser($userid)) {
			return ($user['roles'] == $role);
		}
		return false;
	}

    function logout() {

    }

    function getUsers() {

      $rv = $this->getUsersStmt->process();
      return $rv;

    }

	function getGender($userid) {
        // 'M' for Male, 'F' for Female, NULL for undefined
        return NULL;
    }
}

$GLOBALS['fc_config']['db'] = array(
    'host' => $GLOBALS['db']['host'],
    'user' => $GLOBALS['db']['user'],
    'pass' => $GLOBALS['db']['passwd'],
    'base' => $GLOBALS['db']['db'],
    'pref' => "fc_",
    );

$GLOBALS['fc_config']['cms'] = new AEDatingCMS();


foreach($GLOBALS['fc_config']['languages'] as $k => $v) {
    $GLOBALS['fc_config']['languages'][$k]['dialog']['login']['moderator'] = '';
}
?>