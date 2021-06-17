SET PROCEDURE TO Log4Vfp ADDITIVE
RETURN

*************************************************************
DEFINE CLASS Log4Vfp AS Custom
*************************************************************
*: Author: Rick Strahl
*:         (c) West Wind Technologies, 2018
*:Contact: http://www.west-wind.com
*:Created: 09/29/18
*************************************************************
#IF .F.
*:Help Documentation
*:Topic:
Class Log4Vfp

*:Description:

*:Example:

*:Remarks:

*:SeeAlso:


*:ENDHELP
#ENDIF

oBridge = null
oLogger = null
oLogManager = null

cConfigurationFile = LOWER(FULLPATH("Log4Net.config"))
cUser = SUBSTR(SYS(0),AT("#",SYS(0)) + 2)


************************************************************************
*  Init
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Init()

*** wwDotnetBridge dependency
DO wwDotnetBridge

this.oBridge = GetwwDotnetBridge()
IF VARTYPE(this.oBridge) # "O" 
   ERROR "Failed to load wwDotnetBridge."
ENDIF

IF(!THIS.oBridge.LoadAssembly('Log4VFP.dll'))
   ERROR "Failed to load Log4VFP assembly."
ENDIF

THIS.cUser = SUBSTR(SYS(0),AT("#",SYS(0)) + 2)

ENDFUNC
*   Init

************************************************************************
*  Open
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Open(lcLogFile, lcName)
LOCAL loLogManager, loLogger

IF(!FILE(this.cConfigurationFile))
  THIS.CreateConfigurationFile()
ENDIF

IF EMPTY(lcLogFile)
	lcLogFile = ''
ENDIF

IF EMPTY(lcName)
   lcName = SYS(2015)
ENDIF

this.oLogManager = THIS.oBridge.CreateInstance('Log4VFP.LogManager', ;
    THIS.cConfigurationFile, ;
	lcLogFile,;
	this.cUser)
IF VARTYPE(THIS.oLogManager) # "O"
	ERROR "Unable to create Log Manager: " + this.oBridge.cErrorMsg
ENDIF

This.oLogger = THIS.oLogManager.GetLogger(lcName)	
RETURN This.oLogger
ENDFUNC
*   Open

************************************************************************
*  SetProperty
****************************************
***  Function: Sets the value of a named property to the specified value (if the property doesn't exists, it's created).
***    Assume:
***      Pass: tcName - the name of the property, tuValue - the value of the property
***    Return:
************************************************************************
function SetProperty(tcName, tuValue)
This.oLogManager.SetProperty(tcName, transform(tuValue))
endfunc

************************************************************************
*  CreateLogConfiguration
****************************************
***  Function: Creates a new configuration file as a template
***    Assume:
***      Pass: lcFilename - 
***    Return:
************************************************************************
FUNCTION CreateConfigurationFile(lcFileName)
LOCAL lcConfig

IF(EMPTY(lcFilename))
   lcFilename = this.cConfigurationFile
ENDIF

TEXT TO lcConfig NOSHOW
<configuration>
  <configSections>
    <section name="log4net" type="log4net.Config.Log4NetConfigurationSectionHandler, log4net"/>
  </configSections>
  <log4net>
    <appender name="RollingFileAppender" type="log4net.Appender.RollingFileAppender">
      <file type="log4net.Util.PatternString" value="%property{LogFileName}" />
      <appendToFile value="true" />
      <rollingStyle value="Size" />
      <maxSizeRollBackups value="5" />
      <maximumFileSize value="10MB" />
      <staticLogFileName value="true" />
      <layout type="log4net.Layout.PatternLayout">
        <conversionPattern value="%date (%property{AppStart} seconds since app started, %property{Milestone} seconds since last milestone) %property{CurrentUser} %level - %message%newline" />
      </layout>
    </appender>
	<root>
      <level value="INFO"/>
      <appender-ref ref="RollingFileAppender"/>
	</root>
  </log4net>
</configuration>
ENDTEXT

TRY
	STRTOFILE(STRCONV(lcConfig,9),lcFilename, 4)
CATCH
ENDTRY

RETURN FILE(lcFilename)
ENDFUNC
*   CreateLogConfiguration


************************************************************************
*  StartMileStone
****************************************
***  Function: 
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION StartMileStone(tcMessage)

IF VARTYPE(this.oLogManager) = "O"
	this.oLogManager.StartMileStone()
	if vartype(tcMessage) = 'C' and not empty(tcMessage)
		This.LogInfo(tcMessage)
	endif
	RETURN .T.
ENDIF

RETURN .F.	
ENDFUNC
*   StartMileStone

************************************************************************
*  Shutdown
****************************************
***  Function: Shuts down the log Session
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Shutdown()

IF VARTYPE(this.oLogManager) = "O"
   this.oLogManager.Shutdown()
   THIS.oLogManager = null
ENDIF
This.oLogger = .NULL.


ENDFUNC
*   Shutdown

************************************************************************
*  Destroy
****************************************
***  Function: Shuts down the log Session
***    Assume:
***      Pass:
***    Return:
************************************************************************

function Destroy
This.Shutdown()
endfunc

************************************************************************
* LogInfo
****************************************
***  Function: Logs an INFO message
***    Assume:
***      Pass: The message to log and up to 10 parameters to be inserted
***				into placeholders in the message
***    Return:
************************************************************************
function LogInfo(tcMessage, tuParam1, tuParam2, tuParam3, tuParam4, ;
	tuParam5, tuParam6, tuParam7, tuParam8, tuParam9, tuParam10)
local lnParams
lnParams = pcount()
do case
	case vartype(This.oLogger) <> 'O'
		return .F.
	case lnParams = 1
		This.oLogger.Info(tcMessage)
	case lnParams = 2
		This.oLogger.InfoFormat(tcMessage, tuParam1)
	case lnParams = 3
		This.oLogger.InfoFormat(tcMessage, tuParam1, tuParam2)
	case lnParams = 4
		This.oLogger.InfoFormat(tcMessage, tuParam1, tuParam2, tuParam3)
	case lnParams = 5
		This.oLogger.InfoFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4)
	case lnParams = 6
		This.oLogger.InfoFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5)
	case lnParams = 7
		This.oLogger.InfoFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6)
	case lnParams = 8
		This.oLogger.InfoFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6, tuParam7)
	case lnParams = 9
		This.oLogger.InfoFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6, tuParam7, tuParam8)
	case lnParams = 10
		This.oLogger.InfoFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6, tuParam7, tuParam8, tuParam9)
	case lnParams = 11
		This.oLogger.InfoFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6, tuParam7, tuParam8, tuParam9, ;
			tuParam10)
endcase
return .T.
endfunc

************************************************************************
* LogError
****************************************
***  Function: Logs an ERROR message
***    Assume:
***      Pass: The message to log and up to 10 parameters to be inserted
***				into placeholders in the message
***    Return:
************************************************************************
function LogError(tcMessage, tuParam1, tuParam2, tuParam3, tuParam4, ;
	tuParam5, tuParam6, tuParam7, tuParam8, tuParam9, tuParam10)
local lnParams
lnParams = pcount()
do case
	case vartype(This.oLogger) <> 'O'
		return .F.
	case lnParams = 1
		This.oLogger.Error(tcMessage)
	case lnParams = 2
		This.oLogger.ErrorFormat(tcMessage, tuParam1)
	case lnParams = 3
		This.oLogger.ErrorFormat(tcMessage, tuParam1, tuParam2)
	case lnParams = 4
		This.oLogger.ErrorFormat(tcMessage, tuParam1, tuParam2, tuParam3)
	case lnParams = 5
		This.oLogger.ErrorFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4)
	case lnParams = 6
		This.oLogger.ErrorFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5)
	case lnParams = 7
		This.oLogger.ErrorFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6)
	case lnParams = 8
		This.oLogger.ErrorFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6, tuParam7)
	case lnParams = 9
		This.oLogger.ErrorFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6, tuParam7, tuParam8)
	case lnParams = 10
		This.oLogger.ErrorFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6, tuParam7, tuParam8, tuParam9)
	case lnParams = 11
		This.oLogger.ErrorFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6, tuParam7, tuParam8, tuParam9, ;
			tuParam10)
endcase
return .T.
endfunc

************************************************************************
* LogWarn
****************************************
***  Function: Logs a WARN message
***    Assume:
***      Pass: The message to log and up to 10 parameters to be inserted
***				into placeholders in the message
***    Return:
************************************************************************
function LogWarn(tcMessage, tuParam1, tuParam2, tuParam3, tuParam4, ;
	tuParam5, tuParam6, tuParam7, tuParam8, tuParam9, tuParam10)
local lnParams
lnParams = pcount()
do case
	case vartype(This.oLogger) <> 'O'
		return .F.
	case lnParams = 1
		This.oLogger.Warn(tcMessage)
	case lnParams = 2
		This.oLogger.WarnFormat(tcMessage, tuParam1)
	case lnParams = 3
		This.oLogger.WarnFormat(tcMessage, tuParam1, tuParam2)
	case lnParams = 4
		This.oLogger.WarnFormat(tcMessage, tuParam1, tuParam2, tuParam3)
	case lnParams = 5
		This.oLogger.WarnFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4)
	case lnParams = 6
		This.oLogger.WarnFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5)
	case lnParams = 7
		This.oLogger.WarnFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6)
	case lnParams = 8
		This.oLogger.WarnFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6, tuParam7)
	case lnParams = 9
		This.oLogger.WarnFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6, tuParam7, tuParam8)
	case lnParams = 10
		This.oLogger.WarnFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6, tuParam7, tuParam8, tuParam9)
	case lnParams = 11
		This.oLogger.WarnFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6, tuParam7, tuParam8, tuParam9, ;
			tuParam10)
endcase
return .T.
endfunc

************************************************************************
* LogDebug
****************************************
***  Function: Logs a DEBUG message
***    Assume:
***      Pass: The message to log and up to 10 parameters to be inserted
***				into placeholders in the message
***    Return:
************************************************************************
function LogDebug(tcMessage, tuParam1, tuParam2, tuParam3, tuParam4, ;
	tuParam5, tuParam6, tuParam7, tuParam8, tuParam9, tuParam10)
local lnParams
lnParams = pcount()
do case
	case vartype(This.oLogger) <> 'O'
		return .F.
	case lnParams = 1
		This.oLogger.Debug(tcMessage)
	case lnParams = 2
		This.oLogger.DebugFormat(tcMessage, tuParam1)
	case lnParams = 3
		This.oLogger.DebugFormat(tcMessage, tuParam1, tuParam2)
	case lnParams = 4
		This.oLogger.DebugFormat(tcMessage, tuParam1, tuParam2, tuParam3)
	case lnParams = 5
		This.oLogger.DebugFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4)
	case lnParams = 6
		This.oLogger.DebugFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5)
	case lnParams = 7
		This.oLogger.DebugFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6)
	case lnParams = 8
		This.oLogger.DebugFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6, tuParam7)
	case lnParams = 9
		This.oLogger.DebugFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6, tuParam7, tuParam8)
	case lnParams = 10
		This.oLogger.DebugFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6, tuParam7, tuParam8, tuParam9)
	case lnParams = 11
		This.oLogger.DebugFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6, tuParam7, tuParam8, tuParam9, ;
			tuParam10)
endcase
return .T.
endfunc

************************************************************************
* LogFatal
****************************************
***  Function: Logs a FATAL message
***    Assume:
***      Pass: The message to log and up to 10 parameters to be inserted
***				into placeholders in the message
***    Return:
************************************************************************
function LogFatal(tcMessage, tuParam1, tuParam2, tuParam3, tuParam4, ;
	tuParam5, tuParam6, tuParam7, tuParam8, tuParam9, tuParam10)
local lnParams
lnParams = pcount()
do case
	case vartype(This.oLogger) <> 'O'
		return .F.
	case lnParams = 1
		This.oLogger.Fatal(tcMessage)
	case lnParams = 2
		This.oLogger.FatalFormat(tcMessage, tuParam1)
	case lnParams = 3
		This.oLogger.FatalFormat(tcMessage, tuParam1, tuParam2)
	case lnParams = 4
		This.oLogger.FatalFormat(tcMessage, tuParam1, tuParam2, tuParam3)
	case lnParams = 5
		This.oLogger.FatalFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4)
	case lnParams = 6
		This.oLogger.FatalFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5)
	case lnParams = 7
		This.oLogger.FatalFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6)
	case lnParams = 8
		This.oLogger.FatalFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6, tuParam7)
	case lnParams = 9
		This.oLogger.FatalFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6, tuParam7, tuParam8)
	case lnParams = 10
		This.oLogger.FatalFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6, tuParam7, tuParam8, tuParam9)
	case lnParams = 11
		This.oLogger.FatalFormat(tcMessage, tuParam1, tuParam2, tuParam3, ;
			tuParam4, tuParam5, tuParam6, tuParam7, tuParam8, tuParam9, ;
			tuParam10)
endcase
return .T.
endfunc

ENDDEFINE
*EOC Log4Vfp 