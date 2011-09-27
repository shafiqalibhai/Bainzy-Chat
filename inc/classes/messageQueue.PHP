<?php
	class MessageQueueIterator {
		var $rs = null;
		var $dropTheRest = false;
		
		function MessageQueueIterator($rs) {
			$this->rs = $rs;
		}

		function hasNext() {
			return !$this->dropTheRest && $this->rs->hasNext();
		}

		function next() {
			if($rec = $this->rs->next()) {
				$msg = new Message($rec['command']);
				$msg->id = $rec['id'];

				$msg->userid = $rec['userid'];
				$msg->roomid = $rec['roomid'];
				$msg->txt = $rec['txt'];

				$msg->toconnid = $rec['toconnid'];
				$msg->touserid = $rec['touserid'];
				$msg->toroomid = $rec['toroomid'];
				$msg->created  = $rec['created'];

				$this->dropTheRest = ($msg->command == 'lout');

				return $msg;
			} else {
				return null;
			}
		}
	}

	class MessageQueue {
		var $addStmt = null;

		function MessageQueue() {
			$this->addStmt = new Statement("INSERT INTO {$GLOBALS['fc_config']['db']['pref']}messages (created, toconnid, touserid, toroomid, command, userid, roomid, txt) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
		}

		function addMessage($message) {
			return $this->addStmt->process($message->created, $message->toconnid, $message->touserid, $message->toroomid, $message->command, $message->userid, $message->roomid, $message->txt);
		}

		function getMessages($connid, $userid, $roomid, $start = 0) {
			if($userid) 
			{
				//$getStmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}messages WHERE (toconnid=? OR touserid=? OR toroomid=? OR (toconnid IS NULL AND touserid IS NULL AND toroomid IS NULL)) AND id>=? ORDER BY id");
				//---fixes for ignor
				$p = $GLOBALS['fc_config']['db']['pref'];
				$getStmt = new Statement("SELECT {$p}messages.* FROM {$p}messages LEFT JOIN {$p}ignors ON ({$p}ignors.userid=$userid AND {$p}ignors.ignoreduserid={$p}messages.userid AND ({$p}messages.command = 'msg' OR {$p}messages.command = 'msgu')) WHERE (toconnid=? OR touserid=? OR toroomid=? OR (toconnid IS NULL AND touserid IS NULL AND toroomid IS NULL)) AND id>=? AND {$p}ignors.created IS NULL ORDER BY id");
				//---
				return new MessageQueueIterator($getStmt->process($connid, $userid, $roomid, $start));
			} else {
				$getStmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}messages WHERE toconnid=? AND id>=? ORDER BY id");
				return new MessageQueueIterator($getStmt->process($connid, $start));
			}
		}
	}
?>
