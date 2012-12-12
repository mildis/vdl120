vdl120
======

Manage Voltcraft's DL-120TH datalogger. OS X port of vdl120.
-- 

This is an OS X rewrite of the Voltcraft DL-120TH datalogger by milahu at gmail dot com.
Original code can be found in [1] under public domain licence (as of 12-dec-2012).

* Mon Dec 12 2012 0.0.1-1
- Initial rewrite to use IOKit's IOUSBLib
- Known bug : no more than 4096 points can be retrieved
- Known bug : need to unplug the logger after each execution
- TODO : use a dynamic field to hold Pipe index instead of hardcoding 1/2
- TODO : do smarter error checks on function returns
- TODO : use CoreData to persist retrieved datas
- TODO : rewrite to Objective-C


[1] http://vdl120.sourceforge.net
