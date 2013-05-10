close all;

try
    closeAll();
catch
end

%fclose(serialHandler)
clear;
clc;
%% Init Variables

global network;

%% Init Serial Port
% creates a serial port object
serialHandler = serial('COM4','BaudRate',115200);


% Set serial port buffer 
set(serialHandler,'InputBufferSize', 299);

% opens the serial Port
fopen(serialHandler);

%% Setup a timer
% The timer has a callback that reads the serial port and updates the
% stripchart
t = timer('TimerFcn', @(x,y)timerFunction(serialHandler), 'Period', 0.01);
set(t,'ExecutionMode','fixedRate');

global newinfo;
newinfo = 0;
% Starts the Cortex to send data
% fwrite(serialHandler,'s');

% Starts the timer to read data
for i=1:5000
    global elapsedTime;
    elapsedTime = tic;
    timerFunction(serialHandler);
    toc(elapsedTime)
end
    %timerFunction(serialHandler)
    
%start(t);