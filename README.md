# Log4VFP

Log4NET is a powerful diagnostic logging library for .NET applications. Log4VFP provides a VFP wrapper for Log4NET, allowing you to add advanced logging features to your VFP applications.

Documentation for Log4NET can be found at [https://logging.apache.org/log4net](https://logging.apache.org/log4net). I won't reproduce the documentation here but will just highlight some ways you can use Log4VFP.

Thanks to Rick Strahl for creating the VFP wrapper class.

## Installing Log4VFP

You can install Log4VFP one of two ways:

* Click the Clone or Download button and choose Download ZIP to download the source code for Log4VFP.

* Click the Clone or Download button, copy the URL displayed in the dialog, and use that to clone the repository using Git on your system.

**Important**: Log4VFP requires wwDotNetBridge by Rick Strahl, which isn't included in the repository or downloads. If you already have wwDotNetBridge, adjust the sample code included with this project to include the path to  wwDotNetBridge's files. If you do not have wwDotNetBridge, you can get it from its repository at [https://github.com/RickStrahl/wwDotnetBridge](https://github.com/RickStrahl/wwDotnetBridge).

If you want to modify the source code for the C# Log4VFP wrapper, you will also need to retrieve the Log4NET package. The easiest way to do that is to open the Log4VFP solution (Log4VFP.sln in the Log4VFPSource subdirectory) in Visual Studio and choose Rebuild Solution from the Build menu. 

## Log4VFP components

Log4VFP consists of three files:

* Log4VFP.dll, a C# wrapper DLL built from the C# solution in the Log4VFP folder

* Log4NET.dll, the Log4NET assembly

* Log4VFP.prg, which contains a VFP class that wraps the functionality of the C# classes

Include the PRG in your project so it's built into the EXE and deploy the two DLLs with your application; they do not require any registration on the user's system. 

In addition, as noted above, Log4VFP uses wwDotNetBridge, so you'll need to add wwDotNetBridge.prg to your project plus deploy ClrHost.dll and wwDotNetBridge.dll with your application; neither of these files need registration either.

Finally, you'll need a configuration file, named anything you wish, which contains XML that tells Log4NET how to perform diagnostic logging. Log4VFP includes three sample configuration files:

* compact.config: logs to a text file in a compact format

* verbose.config: logs to a text file in a verbose format

* database.config: logs to a SQL Server database

The VFP Log4VFP wrapper class creates a configuration file named log4net.config (similar to compact.config) automatically if you don't specify one and it doesn't already exist.

## Starting Log4VFP

Start by instantiating the Log4VFP class:

```Fox
loLogger = newobject('Log4VFP', 'Log4VFP.prg')
```

If you run Log4VFP first, you can use CREATEOBJECT instead of NEWOBJECT because the program uses SET PROCEDURE TO Log4VFP ADDITIVE:

```Fox
do Log4VFP
loLogger = createobject('Log4VFP')
```

Next call the Open method, specifying the name and path of the file to log to:

```Fox
lcLogFile = lower(fullpath('applog.txt'))
loLogger.Open(lcLogFile)
```

By default, Open uses log4net.config in the current folder as its configuration file and the name of the Windows user running the application as the user name. If you want to change those, set the cConfigurationFile and cUser properties as necessary before calling Open:

```Fox
lcConfigFile = fullpath('verbose.config')
lcUser       = 'DHENNIG'
loLogger = newobject('Log4VFP', 'Log4VFP.prg')
loLogger.cConfigurationFile = lcConfigFile
loLogger.cUser = lcUser
loLogger.Open(lcLogFile)
```

## Using Log4VFP

Now that you have a logger object, you can write to the log file using these methods:

* LogInfo: writes an INFO message to the log

* LogDebug: writes a DEBUG message to the log

* LogWarn: writes a WARN message to the log

* LogError: writes an ERROR message to the log

* LogFatal: writes a FATAL message to the log

INFO, DEBUG, WARN, ERROR, and FATAL are different levels of logging. You can filter Log4NET to only write certain levels to the log, allowing you to determine how verbose the log is for a particular run of the application (recording all messages or only errors, for example). You decide which things are INFO, which are DEBUG, and so on by calling the appropriate method in your code.

Pass these methods a single parameter: the message to write to the log. You don't have to worry about the user name, the application name, or the date/time of the message; the logging pattern described in the configuration file (discussed later) determines what's written to the log. Here's an example:

```Fox
loLogger.LogInfo('=================> App started')
```

Depending on what the logging pattern is in the configuration file, the log file entry for this message may look like this:

```
2018-10-03 09:30:17,971 =================> App started  
0.0659599 seconds since previous milestone  
Total time to run: 0.0679591 seconds
```

or like this:

```
2018-09-24 12:17:38,497 (0.0069945 seconds since app started, 0.0069945 seconds since last milestone) DHENNIG INFO - =================> App started
```

or something else.

You can also pass these methods a message string with placeholders ({0} for the first parameter, {1} for the second, and so on) followed by up to 10 parameters that are inserted into the placeholders. For example:

```Fox
loLogger.LogInfo('Using {0} build {1} {2}', os(1), os(5), os(7))
```

displays this message on my system:

```
Using Windows 6.02 build 9200 
```

## Configuring Log4VFP

Log4NET uses a configuration file to determine how, where, and when to log. I won't go into detail on this because it's discussed at great length in the Log4NET documentation. We'll just look at some common use cases.

Here's the content of compact.config that comes with Log4VFP (this is also the content of log4net.config used by the wrapper class if it creates that file):

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
<conversionPattern value="%date %message%newline%property{Milestone} seconds since previous milestone%newlineTotal time to run: %property{AppStart} seconds%newline%newline" />
```

In this case, they appear as the date/time of the entry, the message, a carriage return, the number of seconds since the previous milestone, a carriage return, and the number of seconds since the application started. Here's an example:

```
2018-10-03 09:30:17,981 Error 12 occurred: Variable 'Y' is not found.
0.0669598 seconds since previous milestone
Total time to run: 0.0841964 seconds
```

database.config specifies logging to a table named Log in a SQL Server database named ErrorLog on my server:

```
<configuration>
  <configSections>
    <section name="log4net" type="log4net.Config.Log4NetConfigurationSectionHandler, log4net"/>
  </configSections>
  <log4net>
    <appender name="AdoNetAppender" type="log4net.Appender.AdoNetAppender">
      <bufferSize value="1" />
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

Set the "connectionString" element to the desired connection string. Adjust the "commandText" and "parameter" elements as necessary, depending on the name and structure of your log table. Here's the structure of the Log table expected by this sample config file:

```SQL
CREATE TABLE [dbo].[Log] (
    [Id] [int] IDENTITY (1, 1) NOT NULL,
    [Date] [datetime] NOT NULL,
    [Thread] [varchar] (255) NOT NULL,
    [Level] [varchar] (50) NOT NULL,
    [Logger] [varchar] (255) NOT NULL,
    [Message] [varchar] (4000) NOT NULL,
    [Exception] [varchar] (2000) NULL
)
```

## Custom properties

You can add and set the values of custom properties to Log4VFP using the SetProperty method. Here's an example:

```
loLogger.SetProperty('MyCustomProperty', 'SomeValue')
```

If the specified property name doesn't exist, SetProperty creates it. Note that values are automatically converted to strings if necessary.

To log a custom property, specify it as "%property{*PropertyName*}" in a log pattern. For example:

```
<conversionPattern value="%date %message%newline%My custom property = %property{MyCustomProperty}" />
```

## Milestones

You can record the start and end of certain processes in your application by starting "milestones". To start a milestone, call the StartMilestone method of the logger object, optionally passing it a message to log. For example:

```Fox
loLogger.StartMilestone('=================> Started process')
* some code here that takes a while to run
loLogger.LogInfo('Process done')
```

The following is logged (using compact.config):

```
2018-09-24 12:44:43,922 (2.3954147 seconds since app started, 0.0009998 seconds since last milestone) DHENNIG INFO - =================> Started process
2018-09-24 12:44:48,922 (7.3955336 seconds since app started, 5.0011187 seconds since last milestone) DHENNIG INFO - Process done
```

## Helping with this project

See [How to contribute to Log4VFP](.github/CONTRIBUTING.md) for details on how to help with this project.

## Releases

### 2021-06-16

* Added SetProperty method which allows creating custom properties.

### 2021-01-30

* Updated to Log4Net 2.0.12.