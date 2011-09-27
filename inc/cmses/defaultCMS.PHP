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

	//The DefaultCMS implementation behaves as usual content management system - i.e. checks provided login/password against system database and uses user roles predefined in it.

	class DefaultCMS {
		var $autocreateUsers = false; //change this to false to disabe nonexisting users auto creation

		var $userid = null;

		var $loginStmt;
		var $getUserStmt;
		var $addUserStmt;
		var $getUsersStmt;

		function DefaultCMS()
		{
			$this->loginStmt      = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}users WHERE login=? LIMIT 1");
			$this->getUserStmt    = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}users WHERE id=? LIMIT 1");
			$this->addUserStmt    = new Statement("INSERT   INTO {$GLOBALS['fc_config']['db']['pref']}users (login, password, roles) VALUES(?, ?, ?)");
			$this->getUsersStmt   = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}users ORDER BY login");
			$this->delUserStmt    = new Statement("DELETE FROM {$GLOBALS['fc_config']['db']['pref']}users WHERE login=?");
		}

		function isLoggedIn() {
			return $this->userid;
		}

		function login($login, $password) {
			$this->userid = null;

			$login = utf8_encode($login);// umlavta fix
			if(trim($login) == '' || trim($password) == '') return null;

			if($login && $password)
			{
				//Try to find user using provided login
				if(($rs = $this->loginStmt->process($login)) && ($rec = $rs->next()))
				{
					if($rec['password'] == $password || $rec['password'] == md5($password))
						$this->userid = $rec['id'];
				}
				else
				{
					//If not - autocreate user with such login and password
					if($this->autocreateUsers)
					{
						$roles = $GLOBALS['fc_config']['liveSupportMode']? ROLE_CUSTOMER : ROLE_USER;
						$this->userid = $this->addUser($login, $password, $roles);
					}
				}
			}

			return $this->userid;
		}

		function logout(){
			$this->userid = null;
		}

		function getUser($userid) {
			if($userid) {
				$rs = $this->getUserStmt->process($userid);
				return $rs->next();
			} else {
				return null;
			}
		}

		function getUsers() {
			return 	$this->getUsersStmt->process();
		}

		function getUserProfile($userid) {
			if($userid == SPY_USERID) return null;

			return "profile.php?userid=$userid";
		}

		function userInRole($userid, $role) {
			if($user = $this->getUser($userid)) {
				return ($user['roles'] == $role);
			}
			return false;
		}

		function getGender($userid) {
	        // 'M' for Male, 'F' for Female, NULL for undefined
			$pr      = $this->getUser($userid);
			$profile = unserialize($pr['profile']);
			$gender  = $profile['gender'];
			if(!isset($gender)) $gender = $profile['t43'];
			$ret     = strtoupper(substr($gender, 0, 1));

			return ($ret != 'M' && $ret != 'F')? NULL : $ret;
		}


		function getPhoto($userid)
		{
			$user = $this->getUser($userid);
			if($user == null)
				return '';

			$profile = unserialize($user['profile']);
			return $profile['t12'];
		}

		function addUser($login, $password, $roles){
			$user = $this->loginStmt->process($login);
			if(($rec = $user->next()) != null) return $rec['id'];

			if( $GLOBALS['fc_config']['encryptPass'] > 0 ) $password = md5($password);//encrypt password

			return $this->addUserStmt->process($login, $password, $roles);
		}

		function deleteUser($login){
			$this->delUserStmt->process($login);
		}

	}

	$GLOBALS['fc_config']['cms'] = new DefaultCMS();

	//clear 'if moderator' message
	foreach($GLOBALS['fc_config']['languages'] as $k => $v) {
		$GLOBALS['fc_config']['languages'][$k]['dialog']['login']['moderator'] = '';
	}
?>