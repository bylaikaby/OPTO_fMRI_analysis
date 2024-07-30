CREATING OF MATLAB TIMER CALLBACKS
-----------------------------------

SUMMARY:
TIMER.DLL MEX-file is intended to create MATLAB callbacks caused by W95 timer
events for asynchronous work, e.g. for real-time data acquisition using MATLAB.
It allows MATLAB program to connect Windows timer with arbitrary MATLAB
evaluation string (similar to conventional MATLAB callbacks). As defined these
callbacks will be executed asynchronously every time when appropriate timer
event occurs.

TMCLOCK.M M-function presents the simplest example for using timer.dll namely
real-time digital clock. 

PLATFORM         : Windows 95/NT (tested under W95 only).
MATLAB VERSION   : 5.1.
COPYRIGHT        : School of Physics and Chemistry, Lancaster University, UK
AUTHOR           : Dr Igor Kaufman
E-MAIL ADDRESS   : I.KAUFMAN@LANCASTER.AC.UK

MEX-FUNCTION CALL SYNTAX:
    Result=timer ( Command, Param, cbString )

Command  : action code. May be both string and numeric. 
Param    : numeric parameter.
cbString : MATLAB callback string.

There are three Commands available:
1. 'SetTimer'     - defines timer using WINAPI SetTimer function. 
                    Current version allows to create up to 16 timers.  
    Param         - elapse time in milliseconds.    
    cbString      - callback string for eval(), any valid MATLAB expression.
    Result        - new Windows timer ID if successful (should be kept),
                    otherwise zero.
2.  'SetCallBack' - sets new callback for valid timer.
    Param         - valid timer ID.
    cnString      - new callback string.
    Result        - timer ID if successful otherwise zero.

3.  'KillTimer'   - cancels timer using WINAPI KillTimer function.
    Param         - timer ID to kill (kills all timers if zero or not present) 
    Result        - one if successful otherwise zero 

RUNNING INSTRUCTIONS:
1. Put all files into the same folder that should be on MATLAB path.
2. Type "tmclock" from MATLAB command prompt.
3. Type <ENTER> 

FILE LIST:
readme.txt  - this file.
timer.dll   - main MEX-file.
timer.m     - MATLAB help for TIMER
tmclock.m   - example M-function.
