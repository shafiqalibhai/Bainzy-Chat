<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
	<head>
		<title>FlashChat Admin Panel - {$title}</title>
		<meta http-equiv=Content-Type content="text/html;  charset=UTF-8">
		<script language="javascript" src="funcs.js"></script>
	</head>

	{literal}
	<style type=text/css>
		<!--
		BODY {
			font-family: Verdana, Arial, Helvetica, sans-serif;
			font-size: 11px;
		}
		TD {
			font-family: Verdana, Arial, Helvetica, sans-serif;
			font-size: 11px;
		}
		TH {
			font-family: Verdana, Arial, Helvetica, sans-serif;
			font-size: 11px;
			font-weight: bold;
		}
		INPUT {
			font-family: Verdana, Arial, Helvetica, sans-serif;
			font-size: 11px;
		}
		SELECT {
			font-family: Verdana, Arial, Helvetica, sans-serif;
			font-size: 11px;
		}
		A {
			font-family: Verdana, Arial, Helvetica, sans-serif;
			color: #0000FF;
		}
		A:hover {
			font-family: Verdana, Arial, Helvetica, sans-serif;
			color: #FF0000;
		}
		-->
	</style>
	{/literal}
<body>
		<center>
			<a href="index.php?{$rand}">Home</a> |
			<a href="msglist.php?{$rand}">Messages</a> |
			<a href="chatlist.php?{$rand}">Chats</a> |
			<a href="usrlist.php?{$rand}">Users</a> | 
			<a href="roomlist.php?{$rand}">Rooms</a> |
			<a href="connlist.php?{$rand}">Connections</a> |
			<a href="banlist.php?{$rand}">Bans</a> |
			<a href="ignorelist.php?{$rand}">Ignores</a> |
			<a href="botlist.php?{$rand}">Bots</a> |
			<a href="uninstall.php?{$rand}">Un-install</a> |
			<a href="logout.php?{$rand}">Logout</a>
		</center>
		<hr>
