local lcConfigFile, ;
	lcLogFile, ;
	lcUser, ;
	lcName, ;
	loLogManager, ;
	loLogger, ;
	loException as Exception

* Define some things.
lcLogFile    = fullpath('applog.txt')
	&& the name of the log file to write to
lcName       = 'MyLogger'
	&& the name of the logger


DO Log4Vfp
loLog = CREATEOBJECT("Log4Vfp")
loLogger = loLog.Open(lcLogFile)


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
WAIT WINDOW TIMEOUT 2 "Inserting a 2 second delay between logs (1)..."
loLog.StartMilestone()
loLogger.InfoFormat('=================> Started process at {0}', datetime())
WAIT WINDOW TIMEOUT 2 "Inserting a 2 second delay between logs (2)..."
loLogger.Info('Process done')

* Shut down the log manager and display the log.
loLog.Shutdown()
release loLogger, loLogManager

modify file (lcLogFile) nowait
