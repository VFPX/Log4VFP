local lcConfigFile, ;
	lcLogFile, ;
	lcUser, ;
	lcName, ;
	loLogManager, ;
	loLogger, ;
	loException as Exception

* Define some things.

lcConfigFile = fullpath('compact.config')
	&& the name of the configuration file to use; use this for a compact log
*lcConfigFile = fullpath('verbose.config')
	&& the name of the configuration file to use; use this for a verbose log
*lcConfigFile = fullpath('database.config')
	&& the name of the configuration file to use; use this to log to a SQL
	&& Server database
lcLogFile    = fullpath('applog.txt')
	&& the name of the log file to write to
lcUser       = 'DHENNIG'
	&& the name of the current user
lcName       = 'MyLogger'
	&& the name of the logger

* Set up wwDotNetBridge, instantiate a log manager, and create a logging
* object.

do wwDotNetBridge
oBridge = GetwwDotNetBridge()
oBridge.LoadAssembly('Log4VFP.dll')
loLogManager = oBridge.CreateInstance('Log4VFP.LogManager', lcConfigFile, ;
	lcLogFile, lcUser)
loLogger     = loLogManager.GetLogger(lcName)

* Log the application start.

loLogger.InfoFormat('=================> App started at {0}', datetime())
loLogger.InfoFormat('Application object created: version {0}', '1.0.1234')
loLogger.InfoFormat('Using {0} build {1} {2}', os(1), os(5), os(7))

* Log that an error occurred.

try
	x = y
catch to loException
	loLogger.ErrorFormat('Error {0} occurred: {1}', loException.ErrorNo, ;
		loException.Message)
endtry

* Log a process.

inkey(2, 'H')
loLogManager.StartMilestone()
loLogger.InfoFormat('=================> Started process at {0}', datetime())
inkey(5, 'H')
loLogger.Info('Process done')

* Shut down the log manager and display the log.

loLogManager.Shutdown()
release loLogger, loLogManager
modify file (lcLogFile) nowait
