function socketServer( host, port, parent )
{
	this.traceMsg( "[Instantiate]" );
	this.traceMsg( "host........: " + host );
	this.traceMsg( "port........: " + port );
	
	// main properties
	this.host			= host;
	this.port			= (port > 1024)? port : 9090;
	this.parent			= parent;
	
	this.connectionActive = false;
	
	this.incommings = new Array();
	this.structure  = null;
	
	this.intervalId = null;
	
	// data handling methods
	this.manageIncoming		= this.socketServ_manageIncoming;
	this.manageOutgoing		= this.socketServ_manageOutgoing;
	this.decodeResponse		= this.socketServ_decodeResponse;
	this.handleError		= this.socketServ_handleError;
	this.handleResponse		= this.socketServ_handleResponse;
	this.sendRequest		= this.socketServ_sendRequest;

	// connection methods and properties
	this.doConnect			= this.socketServ_doConnect;
	this.onConnect			= this.socketServ_onConnect;
	this.onDisconnect		= this.socketServ_onDisconnect;
	this.closeConnection	= this.socketServ_closeConnection;
	
	//socket
	this.socket 			= new XMLSocket();
	this.socket.chat		= this;
	this.socket.onConnect	= this.onConnect;
	this.socket.onClose		= this.onDisconnect;
	this.socket.onXML		= this.manageIncoming;
	this.socket.clientId	= 0;
};

socketServer.prototype.socketServ_closeConnection = function()
{
	//send to server message about close connection
	//this.sendRequest( structure, this.socket );
};

socketServer.prototype.socketServ_doConnect = function()
{
	this.traceMsg( "doConnect:" );
	this.traceMsg( "host.....: " + this.host );
	this.traceMsg( "port.....: " + this.port );

	if( !this.socket.connect( this.host , this.port ) )
	{
		this.connectionActive	= false;
		//connection failed
		this.traceMsg("Connection failed.");
	}
	else this.traceMsg( "Connecting for client." );
};

socketServer.prototype.socketServ_onConnect = function( success ) 
{
	this.chat.traceMsg( "onConnect:" );

	if( success ) 
	{
		this.chat.traceMsg( "Connection successful for client #" + this.clientId );
		this.chat.connectionActive	= true;
		
		clearInterval(this.chat.intervalId);
		this.chat.intervalId = setInterval(this.chat, "sendFirst", 500);
	}
	else 
	{
		this.chat.traceMsg( "Connection failed for client #" + this.clientId );
		this.chat.connectionActive	= false;
		this.structure  = null;
		
		//handle error
		this.chat.parent.ui.loggedout('Socket server connection failed.');
	}
};

socketServer.prototype.sendFirst = function()
{
	clearInterval(this.intervalId);
	
	if(_level0.login != undefined)
	{
		this.parent.login(_level0.login, _level0.password, _level0.lang, _level0.room);
	}	
	else if(this.structure != null)
	{
		this.sendRequest( this.structure );
		this.structure = null;
	}
	else 
	{ 
		this.parent.sendTimeZone();
	}
}

socketServer.prototype.socketServ_sendRequest = function( structure, socket )
{
	this.traceMsg( this.connectionActive );
	if( !this.connectionActive ) 
	{
		this.structure = structure;
		this.doConnect();
		return;
	}
	
	this.traceMsg( "sendRequest" );

	var command = new XML();
	    command.ignoreWhite = true;
	var request = command.createElement("request");

	var elements  = new Array();
	var textnodes = new Array();
	var i = 0;
	for( key in structure )
	{
		if( key == 't' )
		{ 
			elements[i]	=	command.createElement( key );
			textnodes[i]	=	command.createTextNode( structure[key] );
			request.appendChild( elements[i] );
			elements[i].appendChild( textnodes[i] );
			i++;
		}
		else
		{
			request.attributes[key] = structure[key];
		}
	}
	
	command.appendChild( request );
	this.traceMsg( command.toString() );
	
	if(socket == undefined) 
		this.socket.send( command );
	else 
		socket.send( command );
};

socketServer.prototype.socketServ_onDisconnect = function()
{
	this.chat.traceMsg("Disconnect client #" + this.clientId);
	this.chat.connectionActive = false;
};

socketServer.prototype.setManageIncomingHandler = function( target, handler)
{
	this.manageIncomingTarget  = target;
	this.manageIncomingHandler = handler;
};

socketServer.prototype.socketServ_manageIncoming = function( contents ) 
{
	this.chat.traceMsg( "manageIncoming: " );
	this.chat.traceMsg( "type..........: " + contents.childNodes[0].nodeName );
	
	//create queque
	//this.chat.incommings.push( contents );
		
	//if(this.chat.incommings.length == 1) 
	{ 
		this.chat.manageIncomingTarget[this.chat.manageIncomingHandler]( true, contents );
	}	
};

socketServer.prototype.socketServ_manageOutgoing = function()
{
	return true;
};

socketServer.prototype.socketServ_decodeResponse = function( xmlobj )
{
	this.traceMsg( "decodeResponse" );
	var currentNode	= xmlobj.firstChild;
	var decoded	= new Object;

	while( currentNode )
	{
		decoded[currentNode.nodeName] =	currentNode.firstChild.nodeValue;
		currentNode = currentNode.nextSibling;
	}
	
	return decoded;
};

socketServer.prototype.socketServ_handleResponse = function( response )
{
	response =	this.decodeResponse( response.firstChild );

	this.traceMsg( "Handling response... Type: " + response.type );

	switch( response.type )
	{
		case "message":
			this.traceMsg("from: " + response.fromClientId + " to: " + response.toClientId + " done ");
			break;
		default:
			this.traceMsg( "Type: unrecognized response type ->> " + response.type );
			break;
	}
};

socketServer.prototype.socketServ_handleError = function( error )
{
	return true;
};

socketServer.prototype.traceMsg = function( inText )
{
	trace(' >> SocketServer >> ' + inText);
};
