<?php
/**
 ** Constants used for installation file.
 **/

define('INC_DIR', dirname(__FILE__) . '/./../inc/');//for config.php

define('NAVY_FILE_SIZE', 1992);//necessary for check uploaded in binary mode

define('CHAT_ROOMS', 'The Lounge, Hollywood, Tech Talk, Current Events');//default rooms

define('CONFIG_FILE', INC_DIR . 'config.php');

define('INST_DIR', './install_files/');


$cmss = array(

			'aedatingCMS' => 'aeDating 2.0/3.0 (FlashChat is built in to aeDating 3.x)',
			'aedatingCMS2'=> 'aeDating 2.0/3.0 (which only permits access to Gold members)',
			'aedating4CMS'=> 'aeDating 4.0',
			'azdgCMS'     => 'AZDG Dating Lite 2.1.2',
			'cpgNukeCMS'  => 'CPGNuke',
			'datingProCMS'=> 'Dating Pro',
			'e107CMS'     => 'e107 0.617',
			'eMeetingCMS' => 'eMeeting',
			'fusionCMS'   => 'PHP Fusion 4.0.0',
			'fusionCMS2'  => 'PHP Fusion 5.0.1',
			'fusion6CMS'  => 'PHP Fusion 6',
			'geeklogCMS'  => 'GeekLog 1.3.9',
			'joomlaCMS'	  => 'Joomla 1.1',
			'ipbCMS'      => 'Invision Power Board (IPB) 2.0.0',
			'ipbCMS2'     => 'Invision Power Board (IPB) 2.0.3',
			'ipbCMS2'     => 'Invision Power Board (IPB) 2.1.0',
			'lunabyteCMS' => 'LunaByte / Enigma 1.3',
			'mamboCMS'    => 'Mambo 4.5.0',
			'mamboCMS2'   => 'Mambo 4.5.2',
			'mdproCMS'    => 'MD-Pro 1.0.7',
			'moodleCMS'   => 'Moodle',
			'moodle16CMS' => 'Moodle 1.6',
			'moodle17CMS' => 'Moodle 1.7',
			'osdateCMS'   => 'osDate Dating System',
			'phpBB2CMS'	  => 'phpBB 2.0.10 and above',
			'phpBB3CMS'	  => 'phpBB 3.0.B2 and above',
			//'phpNukeModCMS'	=> 'PHP-Nuke 7.3(module version)',
			'phpNukeCMS73'	=> 'PHP-Nuke 7.3',
			'phpNukeCMS78'	=> 'PHP-Nuke 7.8',
			//'postNukeModCMS'	=> 'PostNuke 0.726-3(module version)',
			'postNukeCMS'	=> 'PostNuke 0.726-3',
			'postNukeCMS0762'	=> 'PostNuke 0.762',
			'smfCMS'	=> 'Simple Machines 1.0',
			'smfCMS2'	=> 'Simple Machines 1.1',
			'ubbCMS'	=> 'UBB.Threads 6.5',
			'vbulletin30CMS'=> 'vBulletin 3.0',
			'vbulletin35CMS'=> 'vBulletin 3.5',
			'vbulletin36CMS'=> 'vBulletin 3.6',
			'webDateCMS'    => 'Web Date',
			'wotCMS2'	=> 'WoltLab Burning Board 2.3.4',
			'wowCMS'	=> 'WowBB 1.6.1',
			'wowCMS2'	=> 'WowBB 1.6.2',
			'wowCMS165'	=> 'WowBB 1.6.5',
			'wowCMS170'	=> 'WowBB 1.7',
			'xmbCMS'	=> 'XMB 1.9.1',
			'xoopsCMS'	=> 'Xoops 2.0.7',
			'phpkitCMS' => 'phpkit 1.6.1',
			'MyBBCMS'	=> 'MyBB 1.0',
			'easysiteCMS' => 'EasySite 3.2.5',
			'SBDatingCMS' => 'Softbiz Dating',
			'phpFox108' => 'phpFox 1.0.8',
			'phpFox11' => 'phpFox 1.1',
			'inspirations31CMS'   => 'Inspirations 3.1',
			'drupalCMS' => 'Drupal',
			);

//Create DB tables
$db_tables = array
(
	"bans"        => "CREATE TABLE {dbpref}bans (created timestamp(14) NOT NULL, userid int(11) default NULL, banneduserid int(11) default NULL, roomid int(11) default NULL, ip varchar(16) default NULL, INDEX(userid), INDEX(created))",
	"connections" => "CREATE TABLE {dbpref}connections (id varchar(32) NOT NULL default '', updated timestamp(14) NOT NULL, created timestamp(14) NOT NULL, userid int(11) default NULL, roomid int(11) default NULL, state tinyint(4) NOT NULL default '1', color int(11) default NULL, start int(11) default NULL, lang char(2) default NULL, ip varchar(16) default NULL, tzoffset int(11) default 0, chatid int(11) NOT NULL default '1', INDEX(userid), INDEX(roomid), INDEX(updated), PRIMARY KEY (id))",
	"ignors"      => "CREATE TABLE {dbpref}ignors (created timestamp(14) NOT NULL, userid int(11) default NULL, ignoreduserid int(11) default NULL, INDEX(userid), INDEX(ignoreduserid), INDEX(created))",
	"messages"    => "CREATE TABLE {dbpref}messages (id int(11) NOT NULL auto_increment, created timestamp(14) NOT NULL, toconnid varchar(32) default NULL, touserid int(11) default NULL, toroomid int(11) default NULL, command varchar(255) NOT NULL default '', userid int(11) default NULL, roomid int(11) default NULL, txt text, chatid int(11) NOT NULL default '1', INDEX(touserid), INDEX(toroomid), INDEX(toconnid), INDEX(created), PRIMARY KEY (id))",
	"rooms"       => "CREATE TABLE {dbpref}rooms (id int(11) NOT NULL auto_increment, updated timestamp(14) NOT NULL, created timestamp(14) NOT NULL, name varchar(64) NOT NULL default '', password varchar(32) NOT NULL default '', ispublic char(1) default NULL, ispermanent int(11) default NULL, INDEX(name), INDEX(ispublic), INDEX(ispermanent), INDEX(updated), PRIMARY KEY (id))",
	"users"       => "CREATE TABLE {dbpref}users (id int(11) NOT NULL auto_increment, login varchar(200) NOT NULL default '', password varchar(32) NOT NULL default '', roles int(11) NOT NULL default '0', profile TEXT default NULL, INDEX(login), PRIMARY KEY  (id))",

	"config"	  => "CREATE TABLE {dbpref}config
							(id int(10) unsigned NOT NULL auto_increment,
  							level_0 varchar(255) NOT NULL default '',
  							level_1 varchar(255) default NULL,
			    			level_2 varchar(255) default NULL,
  							level_3 varchar(255) default NULL,
  							level_4 varchar(255) default NULL,
  							type varchar(10) default NULL,
  							title varchar(255) NOT NULL default '',
  							comment varchar(255) NOT NULL default '',
							info varchar(255) NOT NULL default '',
  							parent_page varchar(255) NOT NULL default '',
  							_order int(10) unsigned NOT NULL default '0',
  							PRIMARY KEY  (id),
  							KEY id (id))",

	"config_values" => "CREATE TABLE {dbpref}config_values
							(id int(3) unsigned NOT NULL auto_increment,
  							instance_id int(10) unsigned NOT NULL default '0',
  							config_id int(10) unsigned NOT NULL default '0',
  							value text NOT NULL,
  							disabled int(1) unsigned NOT NULL default '0',
  							PRIMARY KEY  (id),
  							KEY id (id))",

	"config_instances" => "CREATE TABLE {dbpref}config_instances
							(id int(10) unsigned NOT NULL auto_increment,
							is_active tinyint(1) unsigned NOT NULL default '1',
							is_default tinyint(1) unsigned NOT NULL default '0',
							name varchar(100) NOT NULL default '',
							created_date datetime NOT NULL default '0000-00-00 00:00:00',
							PRIMARY KEY  (id),
							KEY id (id) )",
	"config_chats"  => 		"CREATE TABLE {dbpref}config_chats (
  							id int(10) unsigned NOT NULL auto_increment,
  							name char(100) NOT NULL default '',
  							instances char(255) NOT NULL default '1',
							is_default tinyint(1) NOT NULL default '0',
  							PRIMARY KEY  (id),
  							KEY id (id))",

);

?>