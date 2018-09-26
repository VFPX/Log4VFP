lparameters toUpdateObject
local lcAppName, ;
	lcAppID, ;
	lcRepositoryURL, ;
	lcDownloadsURL, ;
	lcVersionFileURL, ;
	lcZIPFileURL

* Set the project settings; edit these for your specific project.

lcAppName       = 'Log4VFP'
	&& the name of the project
lcAppID         = 'Log4VFP'
	&& similar to lcAppName but must be URL-friendly (no spaces or other
	&& illegal URL characters)
lcRepositoryURL = 'https://github.com/vfpx/Log4VFP'
	&& the URL for the project's repository

* If the version file and zip file are in the ThorUpdater folder of the
* master branch of a GitHub repository, these don't need to be edited.
* Otherwise, set lcVersionFileURL and lcZIPFileURL to the correct URLs.

lcDownloadsURL   = strtran(lcRepositoryURL, 'github.com', ;
	'raw.githubusercontent.com') + '/master/ThorUpdater/'
lcVersionFileURL = lcDownloadsURL + lcAppID + 'Version.txt'
	&& the URL for the file containing code to get the available version number
lcZIPFileURL     = lcDownloadsURL + lcAppID + '.zip'
	&& the URL for the zip file containing the project

* This is code to execute after the project has been installed by Thor for the
* first time. Edit this if you want do something different (such as running
* the installed code) or display a different message. You can use code like
* this if you want to execute the installed code; Thor replaces
* ##InstallFolder## with the installation path for the project:
*
* 'do "##InstallFolder##MyProject.prg"'

* Set the properties of the passed updater object. You likely won't need to edit this code.

with toUpdateObject
	.ApplicationName      = lcAppName
	.Component            = 'No'
	.VersionLocalFilename = lcAppID + 'VersionFile.txt'
	.VersionFileURL       = lcVersionFileURL
	.SourceFileUrl        = lcZIPFileURL
	.Link                 = lcRepositoryURL
	.LinkPrompt           = lcAppName + ' Home Page'
	.Notes                = GetNotes()
endwith
return toUpdateObject

* Get the notes for the project. Edit this code as necessary.

procedure GetNotes
local lcNotes
text to lcNotes noshow
Log4VFP

Project Manager: Doug Hennig

Log4VFP provides a VFP wrapper for the Log4NET diagnostic logging library.
endtext
return lcNotes
