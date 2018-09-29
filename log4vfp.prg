*** wwDotnetBridge dependency
DO wwDotnetBridge
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
oLog = null
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

loLogger = THIS.oLogManager.GetLogger(lcName)	
RETURN loLogger
ENDFUNC
*   Open


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
FUNCTION StartMileStone()

IF VARTYPE(this.oLogManager) = "O"
	this.oLogManager.StartMileStone()
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


ENDFUNC
*   Shutdown

ENDDEFINE
*EOC Log4Vfp 