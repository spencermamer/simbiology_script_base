%% Pre-setup Cleanup
clc; % Clear text in console
clear all; % Clear all variables in workbench
close all; % Close any open Figure windows

%% MODEL LOADING AND CONFIGURATION
% The SBProj file is loaded. We then load that model's default
% simulation ConfigSet into cs. We set the SolverType and StopTime (24
% hours in seconds)

% Present's standard window dialogue for "Open file..." for .sbproj type files, saving the selected file's name, and the path to that file.
[projFileName, projPathName] = uigetfile('*.sbproj', 'Select SimBiology project file');
% Check to make sure a file was selected. If the FileName is not defined, or has an invalid value, an error will be thrown.
if isequal(projFileName, 0)
    error('Must select a valid SBProj file!')
end

% Load the SimBiology project from the full file path and name, storing into the 'file' variable
file = sbioloadproject(fullfile(projPathName, projFileName));
% Load model of interest from file to local variable m
model = file.m1;

%% Define and modify ConfigSet for simulations
% Load default simulation ConfigSet from model. The ConfigSet contains settings that pertain to simulating our model, such as the simulation solving algorithm (SSA, ODE15, Sundials, etc.) and the simulation end time. 
% Define configSet to point to model's default simulation ConfigSet
configSet = getconfigset(model, 'default');
% Sets the configSet to use the "sundials" simulation solver engine
set(configSet, 'SolverType', 'sundials'); 
% The StopTime defines for how many time data points should the simulation solve. By default, values are assumed to be in seconds, though this can be changed
set(configSet, 'StopTime', 86400); % Set the StopTime to 86400 seconds (24 hours)


% Occasional outputs such as below provide progress updates
disp('[Notice] Model Initialized successfully')

%% Model Configuration
% Configure model details, such as parameter values or initial specie values, in here....

        
%% Performing Simulation
disp('[Status] Initialization and Configuration Complete.\n [Status] Begining simulations.')
% Next we actually run a simulation on our model by calling sbiosimulate(...) on our model object with a simulation configSet. 

% Simulations often fail, sometimes for certain parameter configurations, or with the wrong SolverType choice. When they fail, an exception is thrown that, unhandled, will stop the script. This is a particular pain when we are running simulations within a loop, such as during a parameter variation study. 

% To avoid this, we enclose the command inside a try/catch block. If sbiosimulate throws an exception, we catch it, print the exception description, and then move on in the script.
try
    % Execute the model simulation and assign the simulation output object to new variable, simulationOutput
	simulationOutput = sbiosimulate(model, configSet, [], []);
catch exception
    exception % Display the exception description
    continue % Continue the script despite the error. Useful when looping through parameter values
end


% Assign new variable 'time' which contains the time points for the following data points. Each row represents a different time point found. Spacing in time points will vary with models and simulation solver choices. 
time = simulationOutput.Time; 
% Data is returned as a matrix of n columns (n == number of output variables) and t rows (t being the number of steps used in solving, or how many time points were found. This will be the same length as the number of time rows.  
data = simulationOutput.Data; 

disp('[Status] Complete!')
