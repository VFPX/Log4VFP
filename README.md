# Log4VFP

Log4NET is a powerful diagnostic logging library for .NET applications. Log4VFP provides a VFP wrapper for Log4NET, allowing you to add advanced logging features to your VFP applications.

Documentation for Log4NET can be found at [https://logging.apache.org/log4net](https://logging.apache.org/log4net). I won't reproduce the documentation here but will just highlight some ways you can use Log4VFP.

## Installing Log4VFP

You can install Log4VFP one of three ways:

* Click the Clone or Download button and choose Download ZIP to download the source code for Log4VFP.

* Click the Clone or Download button, copy the URL displayed in the dialog, and use that to clone the repository using Git on your system.

* If you use Thor, choose Check for Updates from the Thor menu, select Log4VFP in the dialog that appears, and click Install Updates.

**Important**: Log4VFP requires wwDotNetBridge by Rick Strahl, which isn't included in the repository or downloads. If you already have wwDotNetBridge, adjust the sample code included with this project to include the path to  wwDotNetBridge's files. If you do not have wwDotNetBridge, you can get it from its repository at [https://github.com/RickStrahl/wwDotnetBridge](https://github.com/RickStrahl/wwDotnetBridge).

If you want to modify the source code for the C# Log4VFP wrapper, you will also need to retrieve the Log4NET package. The easiest way to do that is to open the Log4VFP solution (Log4VFP.sln in the Log4VFP subdirectory) in Visual Studio and choose Rebuild Solution from the Build menu. 

## Log4VFP components

Log4VFP just consists of a single file: Log4VFP.dll, a C# wrapper DLL built from the C# solution in the Log4VFP folder. Deploy this file with your application; it does not require any registration on the user's system.

In addition, as noted above, Log4VFP uses wwDotNetBridge, so you'll need to add wwDotNetBridge.prg to your project so it's built into the EXE plus deploy ClrHost.dll and wwDotNetBridge.dll with your application; neither of these files need registration either.

Finally, you'll need a configuration file, which can be named anything you wish, which contains XML that tells Log4NET how to perform diagnostic logging. Log4VFP includes two sample configuration files, compact.config and verbose.config, that provide logging to a text file in a compact and verbose format, respectively.

See Sample.prg for an example of how to use Log4VFP.

## Using Log4VFP

To use Log4VFP in your application, start by instantiating wwDotNetBridge (your application may already do this if you're using wwDotNetBridge for other things) and load the Log4VFP assembly:

```Fox
do wwDotNetBridge
oBridge = GetwwDotNetBridge()
oBridge.LoadAssembly('Log4VFP.dll')
```

Next, create an instance of the LogManager class in Log4VFP.dll, passing it the name and path of the configuration file, the name and path of the file to log to, and the name of the current user (if your application doesn't have user names, you can just pass a blank string). Then ask the LogManager object to create a logger object, which is an instance of an object using the Log4NET ILog interface:

```Fox
lcConfigFile = fullpath('verbose.config')
	&& the name of the configuration file to use
lcLogFile    = fullpath('applog.txt')
	&& the name of the log file to write to
lcUser       = 'DHENNIG'
	&& the name of the current user
lcName       = 'MyLogger'
	&& the name of the logger

loLogManager = oBridge.CreateInstance('Log4VFP.LogManager', ;
    lcConfigFile, lcLogFile, lcUser)
loLogger     = loLogManager.GetLogger(lcName)
```

You can have multiple logging objects, each with a different logger name. The name is really only used for advanced purposes so you can pass anything you wish to the GetLogger method.

Now that you have a logger object, you can write to the log file using one of these methods:

* Info: writes an INFO message to the log

* InfoFormat: write a formatted INFO string with parameters to the log

* Debug: writes a DEBUG message to the log

* DebugFormat: write a formatted DEBUG string with parameters to the log

* Warn: writes a WARN message to the log

* WarnFormat: write a formatted WARN string with parameters to the log

* Error: writes an ERROR message to the log

* ErrorFormat: write a formatted ERROR string with parameters to the log

* Fatal: writes a FATAL message to the log

* FatalFormat: write a formatted FATAL string with parameters to the log

INFO, DEBUG, WARN, ERROR, and FATAL are different levels of logging. You can filter Log4NET to only write certain levels to the log, allowing you to determine how verbose the log is for a particular run of the application (recording all messages or only errors, for example). You decide which things are INFO, which are DEBUG, and so on by calling the appropriate method in your code.

The methods without "Format" in the name accept a single parameter: the message to write to the log. You don't have to worry about the user name, the application name, or the date/time of the message; the logging pattern described in the configuration file (discussed later) determines what's written to the log. Here's an example:

```Fox
loLogger.Info('=================> App started')
```

Depending on what the logging pattern is in the configuration file, the log file entry for this message may look like this:

```
=================> App started  
0.0659599 seconds since previous milestone  
Total time to run: 0.0679591 seconds
```

or like this:

```
2018-09-24 12:17:38,497 (0.0069945 seconds since app started, 0.0069945 seconds since last milestone) DHENNIG INFO - =================> App started
```

or something else.

The *Format methods accept multiple parameters: a message string with placeholders ({0} for the first parameter, {1} for the second, and so on) followed by parameters that are inserted into the placeholders. For example:

```Fox
loLogger.InfoFormat('Using {0} build {1} {2}', os(1), os(5), os(7))
```

displays this message on my system:

```
Using Windows 6.02 build 9200 
```

## Configuring Log4VFP

Log4NET uses a configuration file to determine how, where, and when to log. I won't go into detail on this because it's discussed at great length in the Log4NET documentation. We'll just look at some common use cases.

Here's the content of compact.config that comes with Log4VFP:

```
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
```

This specifies the following:

* Output goes to a text file (the "type" attribute in the "appender" element)

* The size of the text file is limited to 10 MB (the "maximumFileSize" element), after which up to five backups are created (the "maxSizeRollBackups" element).

* Log entries display the date/time of the entry, the number of seconds since the application started, the number of seconds since the last milestone (milestones are discussed later), the name of the current user, the level of the message (INFO, DEBUG, etc.), the message, and a carriage return. See [https://logging.apache.org/log4net/release/sdk/html/T_log4net_Layout_PatternLayout.htm](https://logging.apache.org/log4net/release/sdk/html/T_log4net_Layout_PatternLayout.htm) for documentation on layout patterns. Here's an example:

```
2018-09-24 12:17:38,502 (0.0089932 seconds since app started, 0.0089932 seconds since last milestone) DHENNIG ERROR - Error 12 occurred: Variable 'Y' is not found.
```

verbose.config also specifies a text file but formats the log entries differently:

```
<conversionPattern value="%message%newline%property{Milestone} seconds since previous milestone%newlineTotal time to run: %property{AppStart} seconds%newline%newline" />
```

In this case, they appear as the message, a carriage return, the number of seconds since the previous milestone, a carriage return, and the number of seconds since the application started.

database.config specifies logging to a table named Log in a SQL Server database named ErrorLog on my server:

```
<configuration>
  <configSections>
    <section name="log4net" type="log4net.Config.Log4NetConfigurationSectionHandler, log4net"/>
  </configSections>
  <log4net>
    <appender name="AdoNetAppender" type="log4net.Appender.AdoNetAppender">
      <bufferSize value="100" />
      <connectionType value="System.Data.SqlClient.SqlConnection, System.Data, Version=1.0.3300.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" />
      <connectionString value="data source=MyServer;initial catalog=errorlog;integrated security=true;persist security info=True;" />
      <commandText value="INSERT INTO Log ([Date],[Thread],[Level],[Logger],[Message],[Exception]) VALUES (@log_date, @thread, @log_level, @logger, @message, @exception)" />
      <parameter>
        <parameterName value="@log_date" />
        <dbType value="DateTime" />
        <layout type="log4net.Layout.RawTimeStampLayout" />
      </parameter>
      <parameter>
        <parameterName value="@thread" />
        <dbType value="String" />
        <size value="255" />
        <layout type="log4net.Layout.PatternLayout">
            <conversionPattern value="%thread" />
        </layout>
      </parameter>
      <parameter>
        <parameterName value="@log_level" />
        <dbType value="String" />
        <size value="50" />
        <layout type="log4net.Layout.PatternLayout">
            <conversionPattern value="%level" />
        </layout>
      </parameter>
      <parameter>
        <parameterName value="@logger" />
        <dbType value="String" />
        <size value="255" />
        <layout type="log4net.Layout.PatternLayout">
            <conversionPattern value="%logger" />
        </layout>
      </parameter>
      <parameter>
        <parameterName value="@message" />
        <dbType value="String" />
        <size value="4000" />
        <layout type="log4net.Layout.PatternLayout">
            <conversionPattern value="%message" />
        </layout>
      </parameter>
      <parameter>
        <parameterName value="@exception" />
        <dbType value="String" />
        <size value="2000" />
        <layout type="log4net.Layout.ExceptionLayout" />
      </parameter>
    </appender>
	<root>
      <level value="INFO"/>
      <appender-ref ref="AdoNetAppender"/>
	</root>
  </log4net>
</configuration>
```

Set the "connectionString" element to the desired connection string. Adjust the "commandText" and "parameter" elements as necessary, depending on the name and structure of your log table.

## Milestones

You can record the start and end of certain processes in your application by starting "milestones". To start a milestone, call the StartMilestone method of the LogManager (not logger) object. For example:

```Fox
loLogManager.StartMilestone()
loLogger.InfoFormat('=================> Started process at {0}', datetime())
inkey(5, 'H')
loLogger.Info('Process done')
```

results in this being logged (using compact.config):

```
2018-09-24 12:44:43,922 (2.3954147 seconds since app started, 0.0009998 seconds since last milestone) DHENNIG INFO - =================> Started process at 09/24/2018 12:44:43
2018-09-24 12:44:48,922 (7.3955336 seconds since app started, 5.0011187 seconds since last milestone) DHENNIG INFO - Process done
```
