local lcConfigFile, ;
	lcLogFile, ;
	lcUser, ;
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
lcLogFile    = lower(fullpath('applog.txt'))
	&& the name of the log file to write to
lcUser       = 'DHENNIG'
	&& the name of the current user

* Initialize the logger.

loLogger = newobject('Log4VFP', 'Log4VFP.prg')
loLogger.cConfigurationFile = lcConfigFile
	&& optional: uses a basic log4vfp.config (created if necessary) if not
	&& specified
loLogger.cUser = lcUser
	&& optional: uses Windows user name if not specified
loLogger.Open(lcLogFile)

* Log the application start.

loLogger.LogInfo('=================> App started at {0}', datetime())
loLogger.LogInfo('Application object created: version {0}', '1.0.1234')
loLogger.LogInfo('Using {0} build {1} {2}', os(1), os(5), os(7))

* Log that an error occurred.

try
	x = y
catch to loException
	loLogger.LogError('Error {0} occurred: {1}', loException.ErrorNo, ;
		loException.Message)
endtry

* Log a process.

wait window timeout 2 'Inserting a 2 second delay between logs (1)...'
loLogger.StartMilestone('=================> Started process')
wait window timeout 2 'Inserting a 2 second delay between logs (2)...'
loLogger.LogInfo('Process done')

* Shut down the logger and display the log.

release loLogger
modify file (lcLogFile) nowait
