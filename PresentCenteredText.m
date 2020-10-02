function PresentCenteredText(win, text, text_size, text_color, subwin_rect)

% Constants for debugging:
% win = 0;
% text = 'Very soon we will be done with this task!';
% text_size = 90;
% text_color = [0 0 0];
% subwin_rect = [0 0 400 360];
% [win, rect] = Screen('OpenWindow', win, [128 128 128], subwin_rect);

%% Scaling of text to window.
% Get text size.
Screen('TextSize', win, text_size);
text_dim = Screen('TextBounds', win, text);
text_x = text_dim(3)-text_dim(1);
text_y = text_dim(4)-text_dim(2);

% Get window size.
subwin_x = subwin_rect(3) - subwin_rect(1);
subwin_y = subwin_rect(4) - subwin_rect(2);

% Rescale if necessary.
if text_x >= subwin_x || text_y >= subwin_y
    if (subwin_x - text_x) < (subwin_y - text_y)
        text_size = floor(text_size * (subwin_x/text_x));
    else
        text_size = floor(text_size * (subwin_y/text_y));
    end
    Screen('TextSize', win, text_size);
    text_dim = Screen('TextBounds', win, text);
end

%% Fill screen buffer.
Screen('DrawText', win, text, ((subwin_rect(3)-subwin_rect(1))/2)-((text_dim(3)-text_dim(1))/2), ((subwin_rect(4)-subwin_rect(2))/2)-((text_dim(4)-text_dim(2))/2),text_color);

