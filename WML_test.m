% WML_test.m

% Originally written by Krista Ehinger, December 2012
% Downloaded on Oct 2, 2020 from : http://www.kehinger.com/PTBexamples.html
% Modified by Sophia Vinci-Booher in 2020

% Add mask after a 25 ms stim presentation time, no time out for mask, forced-choice response
% Adjust size presentation of stim so that they are similar in size (see WML_trail for example)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up the experiment (don't modify this section)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sca; clear all; clc;
rootDir = '~/Desktop/WML/';
saveDir = '~/Google Drive/data/';

% Add location of support files to path.
addpath(genpath(fullfile(rootDir, 'supportFiles')));

settingsImageSequence; % Load all the settings from the file
rand('state', sum(100*clock)); % Initialize the random number generator

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
if exist(fullfile(rootDir, 'data', ['test_sub' num2str(prefs.subID) '_day4.mat']), 'file') == 2
    disp('Records suggest that this participant has already completed 4 days! This is not possible.');
    ch = input('Are you sure that you have entered the participant ID correctly [y, n]? ', 's');
    if strcmp(ch, 'yes') || strcmp(ch, 'YES') || strcmp(ch, 'y') || strcmp(ch, 'Y')
        disp('If you are sure that you have entered the participant ID correctly,');
        prefs.day = str2num(input('then enter the correct day here [1, 2, 3, 4]: ', 's'));
        flag = 1;
    elseif strcmp(ch, 'no') || strcmp(ch, 'NO') || strcmp(ch, 'n') || strcmp(ch, 'N')
        error('Please start over and be sure to enter the correct participant ID.');
    end
    clear ch ch2
elseif exist(fullfile(rootDir, 'data', ['test_sub' num2str(prefs.subID) '_day3.mat']), 'file') == 2
    prefs.day = 4; flag = 0;
elseif exist(fullfile(rootDir, 'data', ['test_sub' num2str(prefs.subID) '_day2.mat']), 'file') == 2
    prefs.day = 3; flag = 0;
elseif exist(fullfile(rootDir, 'data', ['test_sub' num2str(prefs.subID) '_day1.mat']), 'file') == 2
    prefs.day = 2; flag = 0;
else
    prefs.day = 1; flag = 0;
end

if flag == 0
    
    disp(['Records indicate that this is Day ' num2str(prefs.day) ' for this participant']);
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

% Keyboard setup
KbName('UnifyKeyNames');
KbCheckList = [KbName('space'),KbName('ESCAPE')];
for i = 1:length(responseKeys)
    KbCheckList = [KbName(responseKeys{i}),KbCheckList];
end
RestrictKeysForKbCheck(KbCheckList);

% Screen setup
clear screen
whichScreen = max(Screen('Screens')); %select desktop (min), not tablet (max)
rect = Screen('Rect', whichScreen);
[window1, ~] = Screen('Openwindow',whichScreen,backgroundColor,rect,[],2);
slack = Screen('GetFlipInterval', window1)/2;
W=rect(RectRight); % screen width
H=rect(RectBottom); % screen height
Screen(window1,'FillRect',backgroundColor);
Screen('Flip', window1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up stimuli lists and results file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the image files for the experiment
imageFolder = fullfile(rootDir, 'stimuli/typed_symbols_all/');

% Select the distractor block, so that a participant does not see the same
% distractor more than once in the experiment and so that the distractors
% occur randomly across blocks between participants.
t_imgList = dir(fullfile(imageFolder,'S*.bmp'));
d_imgList = dir(fullfile(imageFolder,'D*.bmp'));
if prefs.day == 1
    d_imgList = d_imgList(distractor_list(1:40, prefs.subID));
elseif prefs.day == 2
    d_imgList = d_imgList(distractor_list(41:80, prefs.subID));
elseif prefs.day == 3
    d_imgList = d_imgList(distractor_list(81:120, prefs.subID));
elseif prefs.day == 4
    d_imgList = d_imgList(distractor_list(121:160, prefs.subID));
end
imgList = cat(1, t_imgList, d_imgList);
imgList = {imgList(:).name};
nTrials = length(imgList);

% Load the text file (opt ynniynional)
if strcmp(textFile,'none') == 0
    showTextItem = 1;
    textItems = importdata(textFile);
else
    showTextItem = 0;
end

% Set up the output file
outputfile = fopen([saveDir '/test_sub' num2str(prefs.subID) '_day' num2str(prefs.day) '.txt'],'a');
fprintf(outputfile, 'subID\t imageCondition\t trial\t textItem\t imageFile\t response\t RT\n');

% Randomize the trial list
randomizedTrials = randperm(nTrials);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Start screen
Screen('DrawText',window1,'Press the space bar to begin', (W/2-300), (H/2), textColor);
Screen('Flip',window1)
% Wait for subject to press spacebar
while 1
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyCode(KbName('space'))==1
        break
    end
end

% Run experimental trials
for t = randomizedTrials
    
    % Load image
    file = imgList{t};
    img = imread(fullfile(imageFolder,file));
    imageDisplay = Screen('MakeTexture', window1, img);
    
    % Calculate image position (center of the screen)
    imageSize = size(img);
    pos = [(W-imageSize(2))/2 (H-imageSize(1))/2 (W+imageSize(2))/2 (H+imageSize(1))/2];

    % Screen priority
    Priority(MaxPriority(window1));
    Priority(2);
    
    % Show fixation cross
    fixationDuration = 0.5; % Length of fixation in seconds
    drawCross(window1,W,H);
    tFixation = Screen('Flip', window1);

    % Blank screen
    Screen(window1, 'FillRect', backgroundColor);
    Screen('Flip', window1, tFixation + fixationDuration - slack,0);

    % Show text item (optional)
    if showTextItem
        % Display text
        textString = textItems{t};
        textDuration = 2; % How long to show text (in seconds)
        Screen('DrawText', window1, textString, (W/2-200), (H/2), textColor);
        tTextdisplay = Screen('Flip', window1);

        % Blank screen
        Screen(window1, 'FillRect', backgroundColor);
        Screen('Flip', window1, tTextdisplay + textDuration - slack,0);
        Screen(tTextdisplay,'Close');
    else
        textString = '';
    end
    
    % Show the images
    Screen(window1, 'FillRect', backgroundColor);
    Screen('DrawTexture', window1, imageDisplay, [], pos);
    startTime = Screen('Flip', window1); % Start of trial
    
    % Get keypress response
    rt = 0;
    resp = 0;
    while GetSecs - startTime < trialTimeout
        [keyIsDown,secs,keyCode] = KbCheck;
        respTime = GetSecs;
        pressedKeys = find(keyCode);
                
        % ESC key quits the experiment
        if keyCode(KbName('ESCAPE')) == 1
            clear all
            close all
            sca
            return;
        end
        
        % Check for response keys
        if ~isempty(pressedKeys)
            for i = 1:length(responseKeys)
                if KbName(responseKeys{i}) == pressedKeys(1)
                    resp = responseKeys{i};
                    rt = respTime - startTime;
                end
            end
        end
        
        % Exit loop once a response is recorded
        if rt > 0
            break;
        end

    end

    % Blank screen
    Screen(window1, 'FillRect', backgroundColor);
    Screen('Flip', window1, tFixation + fixationDuration - slack,0);
    
    % Save results to file
    fprintf(outputfile, '%d\t %s\t %d\t %s\t %s\t %s\t %f\n',...
        prefs.subID, imageFolder, t, textString, file, resp, rt);
    
    % Clear textures
    Screen(imageDisplay,'Close');
    
    % Provide a short break after a certain number of trials
    if mod(t,breakAfterTrials) == 0
        Screen('DrawText',window1,'Break time. Press space bar when you''re ready to continue', (W/2-300), (H/2), textColor);
        Screen('Flip',window1)
        % Wait for subject to press spacebar
        while 1
            [keyIsDown,secs,keyCode] = KbCheck;
            if keyCode(KbName('space')) == 1
                break
            end
        end
    else
    
        % Pause between trials
        if timeBetweenTrials == 0
            while 1 % Wait for space
                [keyIsDown,secs,keyCode] = KbCheck;
                if keyCode(KbName('space'))==1
                    break
                end
            end
        else
            WaitSecs(timeBetweenTrials);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End the experiment (don't change anything in this section)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RestrictKeysForKbCheck([]);
fclose(outputfile);
Screen(window1,'Close');
close all
sca;
return

%  y

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Draw a fixation cross (overlapping horizontal and vertical bar)
function drawCross(window,W,H)
    barLength = 16; % in pixels
    barWidth = 2; % in pixels
    barColor = 0.5; % number from 0 (black) to 1 (white) 
    Screen('FillRect', window, barColor,[ (W-barLength)/2 (H-barWidth)/2 (W+barLength)/2 (H+barWidth)/2]);
    Screen('FillRect', window, barColor ,[ (W-barWidth)/2 (H-barLength)/2 (W+barWidth)/2 (H+barLength)/2]);
end