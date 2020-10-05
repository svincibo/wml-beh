% Author: Matthew Remmel
% Created on November 15, 2014
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

% NOTE: This program requires that Psychtoolbox is installed in order to function properly.

% Modified on ~12.12.2014 by Sophia Vinci-Booher: Integrated to work with kidWriting.m
% ---Introduced prefs for constants (i.e., prefs.lengthEvents).
% ---Added xy collection for use in control.m.
% ---Saved final image for use in kidWriting.m watchOwn condition.

% Modified on ~12.14.2014 by Sophia Vinci-Booher: Incorporated changes in overall study design.
% ---Added t to collect timestamps for dynamic redraw in AnimateWritingTrajectory.m.

% Modified on 01.04.2015 by Sophia Vinci-Booher: Tidy it up.
% ---Added in comments on previous modifications.
% ---Fixed bug: If pen touched tablet at all before the beginning of trial,
% then a line was drawn from that point to the first penDown location withi n this trial.
% Per documentation on issues with calling GetMouse right after SetMouse, added while loop around SetMouse.

% Modified on 08.31.2016 by Sophia Vinci-Booher: Display tracing guides.
% ---Modifications were to make this usable for a specific application.
% This version of drawInk.m only works with WML_training_draw.m to be used
% with the Wacom tablet.

function [prefs] = drawNoInk2(prefs)

% Line Matrix
input_lines = [[0; 0], [0; 0]];
t = [GetSecs GetSecs];

% Line Controller
lastDownX = 0;
lastDownY = 0;
penUpFlag = true;
penUpFlag2 = true;

% Move mouse to projector and account for SetMouse delay on cursor updating.
while 1
    SetMouse((ceil(prefs.w1Width / 2) + prefs.w0Width), ceil(prefs.w1Height / 2));
    [checkX, checkY] = GetMouse;
    if (checkX==(ceil(prefs.w1Width / 2) + prefs.w0Width)) && (checkY==ceil(prefs.w1Height / 2))
        break;
    end
end

% Start with empty screen.
Screen('FillRect', prefs.w3, prefs.backColor);
% Create frame for guide.
Screen('FrameRect', prefs.w3, prefs.foreColor, prefs.w3Size, prefs.penWidth);
% Flip.
Screen('Flip', prefs.w3);

% Block Time Counter
tic;
% Main input loop
while toc < prefs.lengthEvents
    
    % Get mouse input
    [x, y, buttons] = GetMouse(prefs.w3);
    
    % Only draw if pen is down.
    if any(buttons)
        
        % Don't draw a line if they just put the pen down.
        if penUpFlag
            penUpFlag = false;
            
        else
            
            if penUpFlag2
                lastDownX = x;
                lastDownY = y;
                penUpFlag2 = false;
                
            else
                
                % Dont create line if the pointer hasn't moved.
                if (x ~= lastDownX || y ~= lastDownY)
                    
                    % Create new line from last coord and current and set last coord as the current.
                    input_lines = [input_lines [[lastDownX; lastDownY], [x; y]]];
                    t = [t GetSecs GetSecs];
                    lastDownX = x;
                    lastDownY = y;
                end
                
            end
            
        end
        
    else
        
        % Set flag because they picked the pen up
        penUpFlag = true;
        penUpFlag2 = true;
        
    end
    
    % Draw Frame and text on screen.
    Screen('FillRect', prefs.w3, prefs.backColor);
    Screen('FrameRect', prefs.w3, prefs.foreColor, prefs.w3Size, prefs.penWidth);
    
    % Draw Lines on screen.
%     Screen('DrawLines', prefs.w3, input_lines, prefs.penWidth, prefs.foreColor);
    
    % Redraw image
    Screen('Flip', prefs.w3);
    
end

% Get image.
prefs.image = Screen('GetImage', prefs.w3);

% Get dynamic. Save input_lines, as is.
prefs.dynamicStim = cat(1, input_lines, t);
prefs.dynamicStimMockTablet = cat(1, input_lines, t);

prefs.time = t;

end






