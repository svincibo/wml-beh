% WML_training.m

% Written by Sophia Vinci-Booher
% September 2020

% Dependencies: drawInk2.m

% System Requirements:  UPDD Microchip AR1100 USB (licensed by Microchip, not Touch-base)
%                       Psychtoolbox, version 3.0.12
%                       GStreamer (For Apple OSX: Runtime v1.8.0, found at:
%                       <http://gstreamer.freedesktop.org/data/pkg/osx/1.8.0/gstreamer-1.0-1.8.0-x86_64.pkg>)

sca; clear all; clc;
rootDir = '~/Desktop/WML_training/';

% Set preferences for the experiment.
PsychJavaTrouble;
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebugLevel', 0);

%% Setup: general.

commandwindow;

% User input.
prefs.subID = '100';%strtrim(deblank(input('\nPlease enter the subID number (e.g., 101): ', 's')));%'101';

% % Import previous samples from subject if they exist. This is for the case
% % where there is a glitch or a power-outage. This will allow the training
% % to pick back up where it left off.
% if exist(fullfile([pwd '/visualStim/'], [prefs.subID '.mat']), 'file') == 2
%     load(['visualStim/' prefs.subID '.mat'])
% else
% sample.subID = prefs.subID;
% end

%%%%%%%%%%%%%%%%%%%%% Parameters: DO NOT CHANGE. %%%%%%%%%%%%%%%%%%%%%%%%
prefs.lengthEvents = 4; % This is the number of seconds you'll have for each stimulus.
% prefs.scale = 300; % You can increase the size of the box by increasing this number.
prefs.penWidth = 6; % You can increase the thickness of the pen-tip by increasing this number, but there's a limit to the thickness... around 10 maybe.
prefs.backColor = [255 255 255];   % (0 0 0) is black, (255 255 255) is white
prefs.foreColor = [0 0 0];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read in target symbols.
tsymbol_dir = dir(fullfile(rootDir, 'stimuli', 'typed_symbols_targets'));

% Remove the '.' and '..' files.
tsymbol_dir = tsymbol_dir(arrayfun(@(x) x.name(1), tsymbol_dir) ~= '.');

% Get randomization vector;
idx = randperm(length(tsymbol_dir));

% Randomize the target symbols so that they are presented in random order.
tsymbol_dir = tsymbol_dir(idx);

% Screen.
prefs.s1 = max(Screen('Screens')); % Choose the screen that is most likely not the controller screen.
prefs.s0 = min(Screen('Screens')); % Find primary screen.

%% Select window according to number of screens present. (Assumes that the desired device for display will have the highest screen number.)

% Choose dimension of window according to available screens. If only one
% screen available, them set the window to be a short portion of it b/c
% testing. If two screens are available, then set the window to be the
% second screen b/c experiment.
if isequal(prefs.s1, prefs.s0)
    % Dimensions of primary screen
    prefs.w0Size = [0 0 0 0];
    prefs.w0Width = 0;
    prefs.w0Height = 0;
    % Dimensions of auxiliary screen
    [prefs.w1, prefs.w1Size] = PsychImaging('OpenWindow', prefs.s1, prefs.backColor, [0 0 640 480]);
    prefs.w1Width = prefs.w1Size(3);
    prefs.w1Height = prefs.w1Size(4);
    % Dimensions of stimulus presentation area.
    [prefs.w2, prefs.w2Size] = PsychImaging('OpenWindow', prefs.s1, prefs.backColor, [250 5 390 145]);
    prefs.w2Width = prefs.w2Size(3);
    prefs.w2Height = prefs.w2Size(4);
    % Dimensions of drawing area.
    [prefs.w3, prefs.w3Size] = PsychImaging('OpenWindow', prefs.s1, prefs.backColor, [250 310 390 450]);
    prefs.w3Width = prefs.w3Size(3);
    prefs.w3Height = prefs.w3Size(4);
    prefs.scale = 100;
    
else
    prefs.scale = 300;
    % Dimensions of primary screen
    prefs.w0Size = get(prefs.s0, 'ScreenSize');
    prefs.w0Width = prefs.w0Size(3); prefs.w0Height = prefs.w0Size(4);
    % Dimensions of auxiliary screen.
    [prefs.w1, prefs.w1Size] = PsychImaging('OpenWindow', prefs.s1, prefs.backColor);
    prefs.w1Width = prefs.w1Size(3); prefs.w1Height = prefs.w1Size(4);
    % Dimensions of stimulus presentation area.
    prefs.xcenter = prefs.w1Width/2;
    prefs.ycenter = prefs.w1Height/2;
    rectForStim_temp = [2250 50 2550 350];
    %[prefs.w0Size(3)+prefs.xcenter-prefs.scale prefs.w1Size(4)-600 prefs.w0Size(3)+prefs.xcenter+prefs.scale prefs.w1Size(4)-300];
    [prefs.w2, prefs.w2Size] = PsychImaging('OpenWindow', prefs.s1, prefs.backColor, rectForStim_temp);
    prefs.w2Width = prefs.w2Size(3);
    prefs.w2Height = prefs.w2Size(4);
    % Dimensions of drawing area.
    rectForDrawing_temp = [2200 580 2600 880];
    %[prefs.w0Size(3)+prefs.xcenter-prefs.scale prefs.w1Size(4)-2500 prefs.w0Size(3)+prefs.xcenter+prefs.scale prefs.w1Size(4)-2200];
    [prefs.w3, prefs.w3Size] = PsychImaging('OpenWindow', prefs.s1, prefs.backColor, rectForDrawing_temp);
    prefs.w3Width = prefs.w3Size(3);
    prefs.w3Height = prefs.w3Size(4);
    clear rectForDrawing_temp;
    
end

% Set the text size.
Screen('TextSize', prefs.w1, 80);

% Set an onscreen place for the item count.
prefs.rectrunNum = [50 50];

% Hide cursor and orient to the Matlab command window for user input.
% HideCursor([], prefs.w1);
commandwindow;

%% Record.

% Screen
Screen('FillRect', prefs.w1, prefs.backColor);
Screen('FillRect', prefs.w2, prefs.backColor);
Screen('FillRect', prefs.w3, prefs.backColor);
Screen('Flip', prefs.w3, [], [], [], 0); %0 to flip all onscreen windows

prefs.trial = 1;
while prefs.trial < 30
    
    %% Symbol Stimuli
    
    % Select the symbol for this trial.
    prefs.symbol = fullfile(tsymbol_dir(prefs.trial).folder, tsymbol_dir(prefs.trial).name);
    
    % Load it ahead of time.
    prefs.symbol_array = imread(prefs.symbol);
    
    % Get symbol name for file outputs. Only looks for targets.
    prefs.symbol_name = prefs.symbol(strfind(prefs.symbol, 'S'):end);
    
    % Set image in buffer.
    t1 = Screen('MakeTexture', prefs.w2, prefs.symbol_array);
    Screen('DrawTexture', prefs.w2, t1, [], prefs.w2Size); clear t1;
    flip_on = Screen('Flip', prefs.w2);
    
    % Move mouse to projector
    SetMouse((ceil(prefs.w1Width / 2) + prefs.w0Width), ceil(prefs.w1Height / 2))
    
    % Get and display drawing input.
    [prefs] = drawInk2(prefs);
    
    % As long as this is not the first round,
    if prefs.trial ~= 1
        
        % check to see if this symbol has already been done.
        for k = 1:prefs.trial
            
            if strcmp(sample(k).symbol, prefs.symbol)
                
                % If so, insert the sample from this round into the
                % prior location.
                sample(k).symbol = prefs.symbol;
                sample(k).dynamicStim = prefs.dynamicStim;
                sample(k).dynamicStimMockTablet = prefs.dynamicStimMockTablet;
                sample(k).staticStim = prefs.image;
                
                break;
                
            else
                
                % If not, append the sample from this round to the
                % end of the sample struct.
                sample(prefs.trial).symbol = prefs.symbol;
                sample(prefs.trial).dynamicStim = prefs.dynamicStim;
                sample(prefs.trial).dynamicStimMockTablet = prefs.dynamicStimMockTablet;
                sample(prefs.trial).staticStim = prefs.image;
                
                % Update counter.
                prefs.trial = prefs.trial + 1;
                
                break;
                
            end
            
        end
        
    else
        
        % If it's the first round, start the sample struct.
        sample(prefs.trial).symbol = prefs.symbol;
        sample(prefs.trial).dynamicStim = prefs.dynamicStim;
        sample(prefs.trial).dynamicStimMockTablet = prefs.dynamicStimMockTablet;
        sample(prefs.trial).staticStim = prefs.image;
        
        % Update counter.
        prefs.trial = prefs.trial + 1;
        
    end
    
    % Write out the static image.
    imwrite(prefs.image, fullfile(rootDir, 'visualStim', ['sub' prefs.subID '_trial' prefs.trial prefs.symbol_name]));
    
    Screen('FillRect', prefs.w1, prefs.backColor);
    Screen('FillRect', prefs.w2, prefs.backColor);
    Screen('FillRect', prefs.w3, prefs.backColor);
    flip_off = Screen('Flip', prefs.w3,[], [], [], 0); %0 to flip all onscreen windows
    
    % Get trial duration.
    sample(prefs.trial).trialduration = flip_off - flip_on;
    clear flip_on flip_off
    
    % Get subID for output.
    sample(prefs.trial).subID = prefs.subID;
    
end

% Save static and dynamic stimuli as a mat file.
save(['visualStim/' prefs.subID], 'sample');

%% Close all.
clear PsychImaging;
sca;
% ShowCursor;










