function [prefs] = drawNoInk(prefs)

% Move mouse to center of projector.
SetMouse((ceil(prefs.w1Width / 2) + prefs.w0Width), ceil(prefs.w1Height / 2));
count = 0;
tic;
while toc < prefs.lengthEvents
    
    % Get mouse input
        [x, y, buttons] = GetMouse(prefs.w3);
%     [x, y] = RemapMouse('prefs.w1', 'AllViews', x, y);
    
    % Only draw if pen is down.
    if any(buttons)
        
        % Collect coordinate data.
        count = count + 1;
        xy(count, 1) = x;
        xy(count, 2) = y;

    end
    
    % Redraw Frame on screen
    Screen('FillRect', prefs.w3, prefs.backColor)
    Screen('FrameRect', prefs.w3, prefs.foreColor, prefs.w3Size, prefs.penWidth);   % Create frame for guide.
    
    % Redraw image
    Screen('Flip', prefs.w3);
    
end





