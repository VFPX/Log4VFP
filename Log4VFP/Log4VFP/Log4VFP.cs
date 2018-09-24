using log4net;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Log4VFP
{
    /// <summary>
    /// This class creates and manages log4net loggers.
    /// </summary>
    public class LogManager
    {
        /// <summary>
        /// Constructor.
        /// </summary>
        /// <param name="loggerSettingsFile">
        /// The path for the logger settings file.
        /// </param>
        /// <param name="loggerLogFile">
        /// The path for the log file.
        /// </param>
        /// <param name="userName">
        /// The name of the user to log.
        /// </param>
        public LogManager(string loggerSettingsFile, string loggerLogFile, string userName)
        {
            FileInfo loggerConfigFile = new FileInfo(loggerSettingsFile);
            GlobalContext.Properties["LogFileName"] = loggerLogFile;
            GlobalContext.Properties["CurrentUser"] = userName;
            GlobalContext.Properties["AppStart"] = new MilestoneHelper();
            GlobalContext.Properties["Milestone"] = new MilestoneHelper();
            log4net.Config.XmlConfigurator.Configure(loggerConfigFile);
        }

        /// <summary>
        /// Ensure log4net is shut down properly.
        /// </summary>
        public void Shutdown()
        {
            log4net.LogManager.Shutdown();
        }

        /// <summary>
        /// Start a milestone.
        /// </summary>
        public void StartMilestone()
        {
            ((MilestoneHelper)GlobalContext.Properties["Milestone"]).Start();
        }

        /// <summary>
        /// Get a logger object for the specified name.
        /// </summary>
        /// <param name="name">
        /// The name of the logger.
        /// </param>
        /// <returns>
        /// The desired logger object.
        /// </returns>
        public ILog GetLogger(string name)
        {
            return log4net.LogManager.GetLogger(name);
        }
    }

    /// <summary>
    /// This class provides a milestone.
    /// </summary>
    public class MilestoneHelper
    {
        /// <summary>
        /// The timestamp for the start of the milestone.
        /// </summary>
        private DateTime _start;

        /// <summary>
        /// The constructor.
        /// </summary>
        public MilestoneHelper()
        {
            Start();
        }

        /// <summary>
        /// Start the milestone.
        /// </summary>
        public void Start()
        {
            _start = DateTime.Now;
        }

        /// <summary>
        /// Get the number of seconds since the milestone started.
        /// </summary>
        /// <returns>
        /// The number of seconds since the milestone started.
        /// </returns>
        public override string ToString()
        {
            return (DateTime.Now - _start).TotalSeconds.ToString();
        }
    }
}
