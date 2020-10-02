% Author: Matthew Remmel
% Created on December 8, 2014
% Written for use by: The Cognition and Action Neuroimaging Laboratory
% Department of Psychological and Brain Sciences at Indiana
% University, Bloomington, Indiana

% Copyright (c) 2014

% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the "Software"), to
% deal in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
% of the Software, and to permit persons to whom the Software is furnished to do so,
% subject to the following conditions: The above copyright notice and this permission
% notice shall be included in all copies or substantial portions of the Software.

% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
% INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
% PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
% FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
% ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

% NOTE: This program requires that Psychtoolbox is installed in order to function properly

% Modified on 01.01.2015 by Sophia Vinci-Booher: Increased time reliability.
% ---Removed timestamps because it was slowing the program down too much and, in the end, was a redundancy.
% ---Added a restriction on the while loop that requires it to remain within a trial's alloted time.

% Modified on 01.04.2015 by Sophia Vinci-Booher: Increased time fidelity.
% ---Reintroduced timestamps in order to account for the subject initiation
% time. lineData was only collected after penDown time.


function prefs = watchDynamic(prefs, trajectory)

% define array to hold timestamps
timestamps = trajectory(3, :); %%---Removed because redundant.

% define array to hold line data.
line_data = trajectory(1:2, :);

% Draw Frame on screen
Screen('FillRect', prefs.w3, prefs.backColor)
Screen('FrameRect', prefs.w3, prefs.foreColor, prefs.w3Size, prefs.penWidth);

% Flip
Screen('Flip', prefs.w3);

% Animate Writing, draw starting point.
Screen('DrawLines', prefs.w3, line_data(:, 1:2), prefs.penWidth, prefs.foreColor);

% Draw Frame on screen
Screen('FillRect', prefs.w3, prefs.backColor)
Screen('FrameRect', prefs.w3, prefs.foreColor, prefs.w3Size, prefs.penWidth);

% Flip
Screen('Flip', prefs.w3);

i = 4; % Start here because the first 2 columns correspond to zero start values and the second 2 columns correspond to the penDown start location.
tic;
while toc < prefs.lengthEvents
    
    while i < size(line_data, 2)
        
        % Draw Frame and text on screen.
        Screen('FillRect', prefs.w3, prefs.backColor);
        Screen('FrameRect', prefs.w3, prefs.foreColor, prefs.w3Size, prefs.penWidth);
        
        % Draw Lines on screen.
        Screen('DrawLines', prefs.w3, line_data(:, 1:(i)), prefs.penWidth, prefs.foreColor);
        
        % Wait for the initial initiation.
        if i == 4
            WaitSecs(timestamps(i)-timestamps(i-2));
        end
        
        % Redraw image.
        Screen('Flip', prefs.w3);            
            
        % Increment to next pair of lines.
        i = i + 2;
        
    end
    
end

%     % Draw Frame and text on screen.
%     Screen('FillRect', prefs.w3, prefs.backColor);
%     Screen('FrameRect', prefs.w3, prefs.foreColor, prefs.w3Size, prefs.penWidth);
%     Screen('Flip', prefs.w3);


