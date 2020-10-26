

% WML_train.m

% Written by Sophia Vinci-Booher
% September 2020

% Dependencies: drawInk2.m

% System Requirements:  UPDD Microchip AR1100 USB (licensed by Microchip, not Touch-base)
%                       Psychtoolbox, version 3.0.12
%                       GStreamer (For Apple OSX: Runtime v1.8.0, found at:
%                       <http://gstreamer.freedesktop.org/data/pkg/osx/1.8.0/gstreamer-1.0-1.8.0-x86_64.pkg>)

sca; clear all; clc; tic
localDir = '~/Desktop/WML/';
saveDir = '~/Google Drive/data/';

% Add location of support files to path.
addpath(genpath(fullfile(localDir, 'supportFiles')));

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
load(fullfile(localDir, 'supportFiles/WML_subID_mappings.mat'));

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
if exist(fullfile(saveDir, ['sub' num2str(prefs.subID) '_train_day4.mat']), 'file') == 2
    disp('Records suggest that this participant has already completed 4 days of training! This is not possible.');
    ch = input('Are you sure that you have entered the participant ID correctly [y, n]? ', 's');
    if strcmp(ch, 'yes') || strcmp(ch, 'YES') || strcmp(ch, 'y') || strcmp(ch, 'Y')
        disp('If you are sure that you have entered the participant ID correctly,');
        prefs.day = str2num(input('then enter the correct day here [1, 2, 3, 4]: ', 's'));
        flag = 1;
    elseif strcmp(ch, 'no') || strcmp(ch, 'NO') || strcmp(ch, 'n') || strcmp(ch, 'N')
        error('Please start over and be sure to enter the correct participant ID.');
    else
        error('Your response must be either yes or no. Please start over.');
    end
    clear ch ch2
elseif exist(fullfile(saveDir, ['sub' num2str(prefs.subID) '_train_day3.mat']), 'file') == 2
    prefs.day = 4; flag = 0;
elseif exist(fullfile(saveDir, ['sub' num2str(prefs.subID) '_train_day2.mat']), 'file') == 2
    prefs.day = 3; flag = 0;
elseif exist(fullfile(saveDir, ['sub' num2str(prefs.subID) '_train_day1.mat']), 'file') == 2
    prefs.day = 2; flag = 0;
else
    prefs.day = 1; flag = 0;
end

issueflag = 0;
if flag == 0
    
    disp(['Records indicate that this is Day ' num2str(prefs.day) ' of training for this participant']);
    ch = input('Is this correct [y, n]? ', 's');
    if strcmp(ch, 'no') || strcmp(ch, 'NO') || strcmp(ch, 'n') || strcmp(ch, 'N')
        ch2 = input('Have you entered the participant ID correctly [y, n]? ', 's');
        if strcmp(ch2, 'yes') || strcmp(ch2, 'YES') || strcmp(ch2, 'y') || strcmp(ch2, 'Y')
            disp('If you are sure that you have entered the participant ID correctly,');
            prefs.day = str2num(input('then enter the correct day here [1, 2, 3, 4]: ', 's'));
            issueflag = 1;
        elseif strcmp(ch2, 'no') || strcmp(ch2, 'NO') || strcmp(ch2, 'n') || strcmp(ch2, 'N')
            error('Please start over and be sure to enter the correct participant ID.');
        else
            error('Your response must be either yes or no. Please start over.');
        end
    else
        disp('..............starting.............');
    end
    clear ch ch2
    
end
clear flag

% Import audio for alert.
[beep_y, beep_Fs] = audioread(fullfile(localDir, 'supportFiles/doorbell.wav'));

% Import yoked stimuli if this is a Watch Dynamic participant. The second
% column of yoke is the WD participant while the first column of yoke is
% the DI participant.
if prefs.group == 3
    
    % Get yoked subID.
    prefs.subID_DI = yoke(find(yoke(:, 2) == prefs.subID), 1);
    
    % Import yoked subject's drawing trajectories. Account for change
    % in file naming scheme earlly on.
    if (prefs.subID_DI == 11 || prefs.subID_DI == 14 || prefs.subID_DI == 16)
        sub_yoke = load(fullfile(saveDir, ['train_sub' num2str(prefs.subID_DI) '_day' num2str(prefs.day) '.mat']));
    else
        sub_yoke = load(fullfile(saveDir, ['sub' num2str(prefs.subID_DI) '_train_day' num2str(prefs.day) '.mat']));
    end
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
    prefs.xcenter = prefs.w1Width/2; prefs.ycenter = prefs.w1Height/2;
    % Dimensions of stimulus presentation area.
    prefs.rectForStim = [prefs.w0Width+prefs.xcenter-(prefs.scale/2) 50 prefs.w0Width+prefs.xcenter+(prefs.scale/2) 50+prefs.scale]; %
    %[prefs.w0Size(3)+prefs.xcenter-prefs.scale prefs.w1Size(4)-600 prefs.w0Size(3)+prefs.xcenter+prefs.scale prefs.w1Size(4)-300];
    [prefs.w2, prefs.w2Size] = PsychImaging('OpenWindow', prefs.s1, prefs.backColor, prefs.rectForStim);
    prefs.w2Width = prefs.w2Size(3); prefs.w2Height = prefs.w2Size(4);
    % Dimensions of drawing area.
    prefs.rectForDrawing = [prefs.w0Width+prefs.xcenter-(prefs.scale/2) 580 prefs.w0Width+prefs.xcenter+prefs.scale/2 580+prefs.scale]; %
    %[prefs.w0Size(3)+prefs.xcenter-prefs.scale prefs.w1Size(4)-2500 prefs.w0Size(3)+prefs.xcenter+prefs.scale prefs.w1Size(4)-2200];
    [prefs.w3, prefs.w3Size] = PsychImaging('OpenWindow', prefs.s1, prefs.backColor, prefs.rectForDrawing);
    prefs.w3Width = prefs.w3Size(3);
    prefs.w3Height = prefs.w3Size(4);
    
end

% Set the text size.
Screen('TextSize', prefs.w1, 80);

% Set up the output file
if issueflag
    outputfile = fopen([saveDir '/sub' num2str(prefs.subID) '_train_day' num2str(prefs.day) '_' datestr(now,'mm-dd-yyyy_HH-MM') '.txt'],'a');
else
    outputfile = fopen([saveDir '/sub' num2str(prefs.subID) '_train_day' num2str(prefs.day) '.txt'],'a');
end
fprintf(outputfile, 'subID\t group\t day\t symbolname\t block\t trial\t drawduration\t trialduration\n');

% Hide cursor and orient to the Matlab command window for user input.
HideCursor([], prefs.w1);
commandwindow;

%% Record.

% Start screen
Screen('FillRect', prefs.w1, prefs.backColor);
PresentCenteredText(prefs.w1,'Ready?', 60, prefs.foreColor, prefs.w1Size);
Screen('Flip',prefs.w1)

% Wait for subject to press spacebar
while 1
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyCode(KbName('space'))==1
        break
    end
end

Screen('FillRect', prefs.w1, prefs.backColor);
Screen('Flip',prefs.w1)

% Screen
Screen('FillRect', prefs.w1, prefs.backColor);
Screen('FillRect', prefs.w2, prefs.backColor);
Screen('FillRect', prefs.w3, prefs.backColor);
Screen('Flip', prefs.w3, [], [], [], 0); %0 to flip all onscreen windows

% Read in target symbols.
tsymbol_dir = dir(fullfile(localDir, 'stimuli', 'typed_symbols_targets'));

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
        
        [keyIsDown,secs,keyCode] = KbCheck;
        pressedKeys = find(keyCode);
        
        % ESC key quits the experiment
        if keyCode(KbName('ESCAPE')) == 1
            clear all
            close all
            sca
            return;
        end
        
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
            
            [prefs] = drawNoInk2(prefs);
            
        elseif prefs.group == 3
            
            % Find the appropriate symbol. Loop because sample is struct.
            %             for k = 1:size(sample, 2)
            
            sample_tbl = struct2table(sub_yoke.sample);
            
            idx = find(strcmp(sample_tbl.symbol, prefs.symbol) & sample_tbl.block == block);
            disp(idx)
            %                 % Make sure that this instance comes from the same prefs.block as
            %                 % it was drawn by the DI participant.
            %                 if strcmp(sample(k).symbol, prefs.symbol) && sample(k).block == block
            %
            %                     idx = k;
            %
            %                 end
            
            %             end
            
            % Display.
            [prefs] = watchDynamic(prefs, sub_yoke.sample(idx).dynamicStim);
            
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
        
        if prefs.group == 1 || prefs.group == 2
            
            % Save drawing duration.
            if max(prefs.time)-min(prefs.time) > 0.01
                
                sample(count).drawduration = max(prefs.time)-min(prefs.time);
                
            else
                sample(count).drawduration = NaN;
                
            end
            
            % Save dynamic stim for yoked participant.
            sample(count).dynamicStim = prefs.dynamicStim;
            
            % Save static stim.
            sample(count).staticStim = prefs.image;
            
            if prefs.group == 1
                
                % Write out the static image for DI participants.
                %                 imwrite(prefs.image, fullfile(rootDir, 'visualStim', ['sub' num2str(prefs.subID) '_trial' num2str(trial) '_' prefs.symbol_name]));
                if issueflag
                    imwrite(prefs.image, fullfile(saveDir, 'static_images', ['sub' num2str(prefs.subID) '_day' num2str(prefs.day) '_trial' num2str(trial) '_' prefs.symbol_name '_' datestr(now,'mm-dd-yyyy_HH-MM')]));
                else
                    imwrite(prefs.image, fullfile(saveDir, 'static_images', ['sub' num2str(prefs.subID) '_day' num2str(prefs.day) '_trial' num2str(trial) '_' prefs.symbol_name]));
                end
            end
            
        else
            
            sample(count).drawduration = NaN;
            sample(count).dynamicStim = NaN;
            sample(count).staticStim = NaN;
            
        end
        
        Screen('FillRect', prefs.w1, prefs.backColor);
        Screen('FillRect', prefs.w2, prefs.backColor);
        Screen('FillRect', prefs.w3, prefs.backColor);
        flip_off = Screen('Flip', prefs.w3,[], [], [], 0); %0 to flip all onscreen windows
        
        % Get trial duration.
        sample(count).trialduration = flip_off - flip_on;
        clear flip_on flip_off
        
        % Save results to file
        fprintf(outputfile, '%d\t %d\t %d\t %s\t %d\t %d\t %2.2f\t %2.2f\n',...
            prefs.subID, sample(count).group, sample(count).day, sample(count).symbolname, sample(count).block, sample(count).trial, sample(count).drawduration, sample(count).trialduration);
        
        % Update counter.
        count = count + 1;
        
    end
    
    % Add in the mandatory 3 minute break at half-way point (after block 5).
    if block == 5
        
        toc
        disp(num2str(toc-tic));
        
        Screen('FillRect', prefs.w2, prefs.backColor);
        Screen('Flip', prefs.w2, [], [], [], 0); %0 to flip all onscreen windows
        
        Screen('FillRect', prefs.w1, prefs.backColor);
        Screen('Flip', prefs.w1, [], [], [], 0); %0 to flip all onscreen windows
        
        Screen('FillRect', prefs.w1, prefs.backColor);
        PresentCenteredText(prefs.w1, '3 minute rest', prefs.fontSize, prefs.foreColor, prefs.w1Size);
        Screen('Flip', prefs.w1);
        soundsc(beep_y,beep_Fs);
        
        WaitSecs(60*3);
        
        Screen('FillRect', prefs.w1, prefs.backColor);
        PresentCenteredText(prefs.w1, 'Break is over! Ready?', prefs.fontSize, prefs.foreColor, prefs.w1Size+[0 0 0 -200]);
        %         PresentCenteredText(prefs.w1, 'Please alert the research assistant.', prefs.fontSize, prefs.foreColor, prefs.w1Size+[0 0 0 -20]);
        Screen('Flip', prefs.w1);
        soundsc(beep_y,beep_Fs);
        
        waitForTrigger2('space');
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
        soundsc(beep_y, beep_Fs);
        
        waitForTrigger2('space');
        Screen('FillRect', prefs.w1, prefs.backColor);
        Screen('Flip', prefs.w1);
        
    end
    
end

% Save static and dynamic stimuli as a mat file.
if issueflag
    save(fullfile(saveDir, ['sub' num2str(prefs.subID) '_train_day' num2str(prefs.day) '_' datestr(now,'mm-dd-yyyy_HH-MM') '.mat']), 'sample');
else
    save(fullfile(saveDir, ['sub' num2str(prefs.subID) '_train_day' num2str(prefs.day) '.mat']), 'sample');
end

% Backup cloud storage to local device.
copyfile(fullfile(saveDir, ['sub' num2str(prefs.subID) '_train_day' num2str(prefs.day) '*.mat']), fullfile(localDir, 'data'))
copyfile(fullfile(saveDir, ['sub' num2str(prefs.subID) '_train_day' num2str(prefs.day) '*.txt']), fullfile(localDir, 'data'))
copyfile(fullfile(saveDir, 'static_images', ['sub' num2str(prefs.subID) '_day' num2str(prefs.day) '*.bmp']), fullfile(localDir, 'data', 'static_images'))

%% Close all.
clear PsychImaging;
fclose(outputfile);
sca;
ShowCursor;

