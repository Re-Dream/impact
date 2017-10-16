--- debug functions, Re-Dream
-- Variables
local clrAccent = Color( 0, 148, 255 )
local clrInfo	= Color( 244, 244, 244 )
local clrError	= Color( 244, 88, 88 )

-- Functions
function impact.Print( message )
	MsgC( clrAccent, "I " )
	MsgC( clrInfo, message )
	MsgC( "\n" )
end

function impact.Error( message )
	MsgC( clrAccent, "I " )
	MsgC( clrError, message )
	MsgC( clrInfo, "!" )
	MsgC( "\n" )
end