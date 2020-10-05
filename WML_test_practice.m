% WML_test.m

% Originally written by Krista Ehinger, December 2012
% Downloaded on Oct 2, 2020 from : http://www.kehinger.com/PTBexamples.html
% Modified by Sophia Vinci-Booher in 2020

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up the experiment (don't modify this section)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sca; clear all; clc;
rootDir = '~/Desktop/WML/';
saveDir = fullfile(rootDir, 'data');

% saveDir = '~/Google Drive/data/';

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

%%%%%%%%%%%%%%%%%%%%% Parameters: DO NOT CHANGE. %%%%%%%%%%%%%%%%%%%%%%%%
prefs.penWidth = 6; % You can increase the thickness of the pen-tip by increasing this number, but there's a limit to the thickness... around 10 maybe.
prefs.backColor = [255 255 255];   % (0 0 0) is black, (255 255 255) is white
prefs.foreColor = [0 0 0];
prefs.scale = 150;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    prefs.rectForStim = [prefs.w1Width/2-prefs.scale/2 prefs.w1Height/2-prefs.scale/2 prefs.w1Width/2+prefs.scale/2 prefs.w1Height/2+prefs.scale/2];
    %     [250 5 390 145];
    %     [prefs.w2, prefs.w2Size] = PsychImaging('OpenWindow', prefs.s1, prefs.backColor, prefs.rectForStim);
    %     prefs.w2Width = prefs.w2Size(3);
    %     prefs.w2Height = prefs.w2Size(4);
else
    % Dimensions of primary screen
    prefs.w0Size = get(prefs.s0, 'ScreenSize');
    prefs.w0Width = prefs.w0Size(3); prefs.w0Height = prefs.w0Size(4);
    % Dimensions of auxiliary screen.
    [prefs.w1, prefs.w1Size] = PsychImaging('OpenWindow', prefs.s1, prefs.backColor);
    prefs.w1Width = prefs.w1Size(3); prefs.w1Height = prefs.w1Size(4);
    prefs.xcenter = prefs.w1Width/2; prefs.ycenter = prefs.w1Height/2;
    % Dimensions of stimulus presentation area.
    prefs.rectForStim = [prefs.w0Width+prefs.xcenter-(prefs.scale/2) 50 prefs.w0Width+prefs.xcenter+(prefs.scale/2) 50+prefs.scale]; %
    %     %[prefs.w0Size(3)+prefs.xcenter-prefs.scale prefs.w1Size(4)-600 prefs.w0Size(3)+prefs.xcenter+prefs.scale prefs.w1Size(4)-300];
    %     [prefs.w2, prefs.w2Size] = PsychImaging('OpenWindow', prefs.s1, prefs.backColor, prefs.rectForStim);
    %     prefs.w2Width = prefs.w2Size(3); prefs.w2Height = prefs.w2Size(4);
end

% Set the text size.
Screen('TextSize', prefs.w1, 80);

% Hide cursor and orient to the Matlab command window for user input.
% HideCursor([], prefs.w1);
commandwindow;

% Keyboard setup
KbName('UnifyKeyNames');
KbCheckList = [KbName('space'),KbName('ESCAPE')];
for i = 1:length(responseKeys)
    KbCheckList = [KbName(responseKeys{i}),KbCheckList];
end
RestrictKeysForKbCheck(KbCheckList);

% Screen setup
clear screen
whichScreen = prefs.s0; %0 is computer, 1 is tablet
[window1, ~] = Screen('Openwindow',whichScreen,backgroundColor,prefs.w1Size,[],2);
slack = Screen('GetFlipInterval', window1)/2;
W=prefs.w1Width; % screen width
H=prefs.w1Height; % screen height
Screen(prefs.w1,'FillRect',prefs.backColor);
Screen('Flip', prefs.w1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up stimuli lists and results file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the image files for the experiment
td_imageFolder = fullfile(rootDir, 'stimuli/typed_symbols_all/');

% Select the distractor block, so that a participant does not see the same
% distractor more than once in the experiment and so that the distractors
% occur randomly across blocks between participants.
t_imgList = dir(fullfile(td_imageFolder,'S*.bmp'));
d_imgList = dir(fullfile(td_imageFolder,'D*.bmp'));
if prefs.day == 1
    d_imgList = d_imgList(distractor_list(1:40, prefs.subID));
elseif prefs.day == 2
    d_imgList = d_imgList(distractor_list(41:80, prefs.subID));
elseif prefs.day == 3
    d_imgList = d_imgList(distractor_list(81:120, prefs.subID));
elseif prefs.day == 4
    d_imgList = d_imgList(distractor_list(121:160, prefs.subID));
end
td_imgList = cat(1, t_imgList, d_imgList);
td_imgList = {td_imgList(:).name};
nTrials = length(td_imgList);

% Get the noise image files for the experiment
n_imageFolder = fullfile(rootDir, 'stimuli/noise_masks/');

% Select the noise images.
n_imgList = dir(fullfile(n_imageFolder,'nm*.bmp'));
n_imgList = n_imgList(randi(size(n_imgList, 1), [1 size(td_imgList, 2)]));
n_imgList = {n_imgList(:).name};

% Load the text file (optional)
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
Screen('FillRect', prefs.w1, prefs.backColor);
PresentCenteredText(prefs.w1,'Press the space bar to begin', 90, prefs.foreColor, prefs.w1Size);
Screen('Flip',prefs.w1)
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
    file = td_imgList{t};
    img = imread(fullfile(td_imageFolder,file));
    td_imageDisplay = Screen('MakeTexture', prefs.w1, img);
    
    % Load noise mask
    file = n_imgList{t};
    img = imread(fullfile(n_imageFolder,file));
    n_imageDisplay = Screen('MakeTexture', prefs.w1, img);
    
    %     % Calculate image position (center of the screen)
    %     imageSize = size(img);
    %     pos = [(W-imageSize(2))/2 (H-imageSize(1))/2 (W+imageSize(2))/2 (H+imageSize(1))/2];
    
    % Screen priority
    Priority(MaxPriority(prefs.w1));
    Priority(2);
    
    % Show fixation cross
    fixationDuration = 0.5; % Length of fixation in seconds
    drawCross(prefs.w1,W,H);
    tFixation = Screen('Flip', prefs.w1);
    
    % Blank screen
    Screen(window1, 'FillRect', backgroundColor);
    Screen('Flip', prefs.w1, tFixation + fixationDuration - slack,0);
    
    % Show text item (optional)
    if showTextItem
        % Display text
        textString = textItems{t};
        textDuration = 2; % How long to show text (in seconds)
        Screen('DrawText', prefs.w1, textString, (W/2-200), (H/2), textColor);
        tTextdisplay = Screen('Flip', prefs.w1);
        
        % Blank screen
        Screen(prefs.w1, 'FillRect', backgroundColor);
        Screen('Flip', prefs.w1, tTextdisplay + textDuration - slack,0);
        Screen(tTextdisplay,'Close');
    else
        textString = '';
    end
    
    % Show the images
    Screen(prefs.w1, 'FillRect', backgroundColor);
    Screen('DrawTexture', prefs.w1, td_imageDisplay, [], prefs.rectForStim);
    startTime = Screen('Flip', prefs.w1); % Start of trial
    
    % Get keypress response
    rt = 0;
    resp = 0;
    while (GetSecs - startTime) < trialTimeout
        
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
        
        % Replace symbol with noise mask after 25 ms.
        if (GetSecs - startTime) <= 0.25
            
            % Show noise mask
            Screen(prefs.w1, 'FillRect', backgroundColor);
            Screen('DrawTexture', prefs.w1, n_imageDisplay, [], prefs.rectForStim);
            Screen('Flip', prefs.w1); 
    
        end
        
        % Exit loop once a response is recorded
        if rt > 0
            break;
        end
        
    end
    
    % Blank screen
    Screen(prefs.w1, 'FillRect', prefs.backColor);
    Screen('Flip', prefs.w1, tFixation + fixationDuration - slack,0);
    
    % Save results to file
    fprintf(outputfile, '%d\t %s\t %d\t %s\t %s\t %s\t %f\n',...
        prefs.subID, td_imageFolder, t, textString, file, resp, rt);
    
    % Clear textures
    Screen(td_imageDisplay,'Close');
    
    % Provide a short break after a certain number of trials
    if mod(t,breakAfterTrials) == 0
        PresentCenteredText(prefs.w1,'Break time. Press space bar when you''re ready to continue', 90, prefs.foreColor, prefs.w1Size);
        Screen('Flip',prefs.w1)
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