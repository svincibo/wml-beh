% WML_train.m

% Written by Sophia Vinci-Booher
% September 2020

% Dependencies: drawInk2.m

% System Requirements:  UPDD Microchip AR1100 USB (licensed by Microchip, not Touch-base)
%                       Psychtoolbox, version 3.0.12
%                       GStreamer (For Apple OSX: Runtime v1.8.0, found at:
%                       <http://gstreamer.freedesktop.org/data/pkg/osx/1.8.0/gstreamer-1.0-1.8.0-x86_64.pkg>)

sca; clear all; clc;
rootDir = '~/Desktop/WML/';

% Add location of support files to path.
addpath(genpath(fullfile(rootDir, 'supportFiles')));

% Set preferences for the experiment.
PsychJavaTrouble;
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebugLevel', 0);
prefs.fontSize = 90;

%% Setup: general.

commandwindow;

% User input.
prefs.subID = str2num(deblank(input('\nPlease enter the subID number (e.g., 101): ', 's')));%'101';

% Load in the mapping between the subID and training group.
load(fullfile(rootDir, 'supportFiles/WML_subID_mappings.mat'));

% Set group training variables.
prefs.group = training_group(find(subID == prefs.subID));
prefs.group_label = training_group_labels{prefs.group};

disp(['You have indicated that this is participant ' num2str(prefs.subID) '. This is a ' prefs.group_label ' participant.']);
ch = input('Is this information correct [y, n]? ', 's');
if strcmp(ch, 'no') || strcmp(ch, 'NO') || strcmp(ch, 'n') || strcmp(ch, 'N')
    error('Please start over and be sure to enter the correct participant ID.');
end
clear ch

% Look to see if there are any days for this subject already, if no, set
% this as day 1. If yes, count how many and set day appropriately.
if exist(fullfile(rootDir, 'data', ['train_sub' num2str(prefs.subID) '_day4.mat']), 'file') == 2
    disp('Records suggest that this participant has already completed 4 days of training! This is not possible.');
    ch = input('Are you sure that you have entered the participant ID correctly [y, n]? ', 's');
    if strcmp(ch, 'yes') || strcmp(ch, 'YES') || strcmp(ch, 'y') || strcmp(ch, 'Y')
        disp('If you are sure that you have entered the participant ID correctly,');
        prefs.day = str2num(input('then enter the correct day here [1, 2, 3, 4]: ', 's'));
        flag = 1;
    elseif strcmp(ch, 'no') || strcmp(ch, 'NO') || strcmp(ch, 'n') || strcmp(ch, 'N')
        error('Please start over and be sure to enter the correct participant ID.');
    end
    clear ch ch2
elseif exist(fullfile(rootDir, 'data', ['train_sub' num2str(prefs.subID) '_day3.mat']), 'file') == 2
    prefs.day = 4; flag = 0;
elseif exist(fullfile(rootDir, 'data', ['train_sub' num2str(prefs.subID) '_day2.mat']), 'file') == 2
    prefs.day = 3; flag = 0;
elseif exist(fullfile(rootDir, 'data', ['train_sub' num2str(prefs.subID) '_day1.mat']), 'file') == 2
    prefs.day = 2; flag = 0;
else
    prefs.day = 1; flag = 0;
end

if flag == 0
    
    disp(['Records indicate that this is Day ' num2str(prefs.day) ' of training for this participant']);
    ch = input('Is this correct [y, n]? ', 's');
    if strcmp(ch, 'no') || strcmp(ch, 'NO') || strcmp(ch, 'n') || strcmp(ch, 'N')
        ch2 = input('Have you entered the participant ID correctly [y, n]? ', 's');
        if strcmp(ch2, 'yes') || strcmp(ch2, 'YES') || strcmp(ch2, 'y') || strcmp(ch2, 'Y')
            disp('If you are sure that you have entered the participant ID correctly,');
            prefs.day = str2num(input('then enter the correct day here [1, 2, 3, 4]: ', 's'));
        elseif strcmp(ch2, 'no') || strcmp(ch2, 'NO') || strcmp(ch2, 'n') || strcmp(ch2, 'N')
            error('Please start over and be sure to enter the correct participant ID.');
        end
    else
        disp('..............starting.............');
    end
    clear ch ch2
    
end
clear flag

% Import yoked stimuli if this is a Watch Dynamic participant. The second
% column of yoke is the WD participant while the first column of yoke is
% the DI participant.
if prefs.group == 3
    
    % Get yoked subID.
    prefs.subID_DI = yoke(find(yoke(:, 2) == prefs.subID), 1);
    
    % Import yoked subject's drawing trajectories.
    load(fullfile(rootDir, 'data', ['train_sub' num2str(prefs.subID_DI) '_day' num2str(prefs.day) '.mat']));
    
end

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
    prefs.rectForStim = [2250 50 2550 350];
    %[prefs.w0Size(3)+prefs.xcenter-prefs.scale prefs.w1Size(4)-600 prefs.w0Size(3)+prefs.xcenter+prefs.scale prefs.w1Size(4)-300];
    [prefs.w2, prefs.w2Size] = PsychImaging('OpenWindow', prefs.s1, prefs.backColor, prefs.rectForStim);
    prefs.w2Width = prefs.w2Size(3);
    prefs.w2Height = prefs.w2Size(4);
    % Dimensions of drawing area.
    prefs.rectForDrawing = [2250 580 2550 880];
    %[prefs.w0Size(3)+prefs.xcenter-prefs.scale prefs.w1Size(4)-2500 prefs.w0Size(3)+prefs.xcenter+prefs.scale prefs.w1Size(4)-2200];
    [prefs.w3, prefs.w3Size] = PsychImaging('OpenWindow', prefs.s1, prefs.backColor, prefs.rectForDrawing);
    prefs.w3Width = prefs.w3Size(3);
    prefs.w3Height = prefs.w3Size(4);
    
end

% Set the text size.
Screen('TextSize', prefs.w1, 80);

% Hide cursor and orient to the Matlab command window for user input.
% HideCursor([], prefs.w1);
commandwindow;

%% Record.

% Screen
Screen('FillRect', prefs.w1, prefs.backColor);
Screen('FillRect', prefs.w2, prefs.backColor);
Screen('FillRect', prefs.w3, prefs.backColor);
Screen('Flip', prefs.w3, [], [], [], 0); %0 to flip all onscreen windows

% Read in target symbols.
tsymbol_dir = dir(fullfile(rootDir, 'stimuli', 'typed_symbols_targets'));

% Remove the '.' and '..' files.
tsymbol_dir = tsymbol_dir(arrayfun(@(x) x.name(1), tsymbol_dir) ~= '.');

% % Get randomization vector;
% idx = randperm(length(tsymbol_dir));
%
% % Randomize the target symbols so that they are presented in random order.
% tsymbol_dir = tsymbol_dir(idx);
count = 1;
for block = 1:10
  
    % Set up symbol randomization for this block
    s = randperm(40);
        
    for trial = 1:40
        
        disp(['Block ' num2str(block) ', trial ' num2str(trial)])

        %% Symbol Stimuli
        
        % Select the symbol for this trial.
        prefs.symbol = fullfile(tsymbol_dir(s(trial)).folder, tsymbol_dir(s(trial)).name);
        
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
        
        if prefs.group == 1
            
            % Get and display drawing input.
            [prefs] = drawInk2(prefs);
            
        elseif prefs.group == 2
            
            [prefs] = drawNoInk(prefs);
            
        elseif prefs.group == 3
            
            % Find the appropriate symbol. Loop because sample is struct.
            for k = 1:size(sample, 2)
                
                % Make sure that this instance comes from the same prefs.block as
                % it was drawn by the DI participant.
                if strcmp(sample(k).symbol, prefs.symbol) && sample(k).block == block
                    
                    idx = k;
                    
                end
                
            end
            
            % Display.
            [prefs] = watchDynamic(prefs, sample(idx).dynamicStim);
            
        else
            
            error('Training group must be 1, 2, or 3.');
            
        end
        
        % Append the sample from this round to the
        % end of the sample struct.
        sample(count).subID = prefs.subID;
        sample(count).group = prefs.group;
        sample(count).day = prefs.day;
        sample(count).symbol = prefs.symbol;
        sample(count).symbolname = prefs.symbol_name;
        sample(count).block = block;
        sample(count).trial = trial;
        
        if prefs.group == 1
            
            % Save dynamic stim for yoked participant.
            sample(count).dynamicStim = prefs.dynamicStim;
            
            % Save static stim.
            sample(count).staticStim = prefs.image;
            
            % Write out the static image.
            imwrite(prefs.image, fullfile(rootDir, 'visualStim', ['sub' num2str(prefs.subID) '_trial' num2str(trial) '_' prefs.symbol_name]));
            
            if max(prefs.time)-min(prefs.time) > 0.01
                
                sample(count).drawduration = max(prefs.time)-min(prefs.time);
                
            else
                sample(count).drawduration = NaN;
                
            end
            
        else
            
            sample(count).drawduration = NaN;
            
        end
        
        Screen('FillRect', prefs.w1, prefs.backColor);
        Screen('FillRect', prefs.w2, prefs.backColor);
        Screen('FillRect', prefs.w3, prefs.backColor);
        flip_off = Screen('Flip', prefs.w3,[], [], [], 0); %0 to flip all onscreen windows
        
        % Get trial duration.
        sample(count).trialduration = flip_off - flip_on;
        clear flip_on flip_off
        
        % Update counter.
        count = count + 1;
        
    end
    
    % Add in the mandatory 3 minute break at half-way point (after block 5).
        if block == 5
            
            Screen('FillRect', prefs.w2, prefs.backColor);
            Screen('Flip', prefs.w2, [], [], [], 0); %0 to flip all onscreen windows
            
            Screen('FillRect', prefs.w1, prefs.backColor);
            Screen('Flip', prefs.w1, [], [], [], 0); %0 to flip all onscreen windows
            
            Screen('FillRect', prefs.w1, prefs.backColor);
            PresentCenteredText(prefs.w1, '3 minute rest', prefs.fontSize, prefs.foreColor, prefs.w1Size);
            Screen('Flip', prefs.w1);
            
            WaitSecs(60*3);
            
            Screen('FillRect', prefs.w1, prefs.backColor);
            PresentCenteredText(prefs.w1, 'Break is over! Ready?', prefs.fontSize, prefs.foreColor, prefs.w1Size+[0 0 0 -200]);
            PresentCenteredText(prefs.w1, 'Press y to proceed.', prefs.fontSize, prefs.foreColor, prefs.w1Size+[0 0 0 -20]);
            Screen('Flip', prefs.w1);
            
            waitForTrigger2('y');
            Screen('FillRect', prefs.w1, prefs.backColor);
            Screen('Flip', prefs.w1);
            
            WaitSecs(3);
            
        end
        
        if block == 10
            
            Screen('FillRect', prefs.w2, prefs.backColor);
            Screen('Flip', prefs.w2, [], [], [], 0); %0 to flip all onscreen windows
            
            Screen('FillRect', prefs.w1, prefs.backColor);
            Screen('Flip', prefs.w1, [], [], [], 0); %0 to flip all onscreen windows
            
            Screen('FillRect', prefs.w1, prefs.backColor);
            PresentCenteredText(prefs.w1, 'All done!', prefs.fontSize, prefs.foreColor, prefs.w1Size);
            Screen('Flip', prefs.w1);
            
            waitForTrigger2('y');
            Screen('FillRect', prefs.w1, prefs.backColor);
            Screen('Flip', prefs.w1);
            
        end
        
end

% Save static and dynamic stimuli as a mat file.
save(fullfile(rootDir, 'data', ['train_sub' num2str(prefs.subID) '_day' num2str(prefs.day) '.mat']), 'sample');

%% Close all.
clear PsychImaging;
sca;
% ShowCursor;
