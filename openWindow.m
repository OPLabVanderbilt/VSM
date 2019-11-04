function win = openWindow(p) % open up the window! 

Screen('Preference', 'SkipSyncTests',1);             % Add this line to run on laptop
win.screenNumber = max(Screen('Screens')); % may need to change for multiscreen displays

%   p.windowed = 0; %%% 1  == smaller screen for debugging; 0 === full-sized screen for experiment
if p.windowed
    x_size=  1024; y_size = 768;
    [win.onScreen,rect] = Screen('OpenWindow', win.screenNumber, [128 128 128],[0 0 x_size y_size],[],[],[]);
    win.screenX = x_size;
    win.screenY = y_size;
    win.screenrect = [0 0 x_size y_size];
    win.centerX = (x_size)/2; % center of screen in X direction
    win.centerY = (y_size)/2; % center of screen in Y direction
    win.centerXL = floor(mean([0 win.centerX])); % center of left half of screen in X direction
    win.centerXR = floor(mean([win.centerX win.screenX])); % center of right half of screen in X direction
        % % Compute foreground and fixation rectangles
    win.forerect = round(win.screenrect./1.5);
    win.forerect = CenterRect(win.forerect,win.screenrect);
else
    [win.onScreen rect] = Screen('OpenWindow', win.screenNumber, [128 128 128],[],[],[],[]);
    [win.screenX, win.screenY] = Screen('WindowSize', win.onScreen); % check resolution
    win.screenrect  = [0 0 win.screenX win.screenY]; % screen rect
    win.centerX = win.screenX * 0.5; % center of screen in X direction
    win.centerY = win.screenY * 0.5; % center of screen in Y direction
    win.centerXL = floor(mean([0 win.centerX])); % center of left half of screen in X direction
    win.centerXR = floor(mean([win.centerX win.screenX])); % center of right half of screen in X direction
    % % Compute foreground and fixation rectangles
    win.forerect = round(win.screenrect./1.5);
    win.forerect = CenterRect(win.forerect,win.screenrect);

    HideCursor; % hide the cursor since we're not debugging
end

Screen('BlendFunction', win.onScreen, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% basic drawing and screen variables
win.black    = BlackIndex(win.onScreen);
win.white    = WhiteIndex(win.onScreen);
win.gray     = mean([win.black win.white]);

win.backColor = win.gray;
win.foreColor = win.gray;

%%% 9 colors mat
win.colors_9 = [255 0 0; ... % red
    0 255 0; ...% green
    0 0 255; ...% blue
    255 255 0; ... % yellow
    255 0 255; ... % magenta
    0 255 255; ... % cyan 
    255 255 255; ... % white
    1 1 1; ... %black
    255 128 0]; % orange! 

%%%% 7 colors mat
win.colors_7 = [255 0 0;... % red
    0 255 0;... %green
    0 0 255;... % blue
    255 255 0;... % yellow
    255 0 255; ... % magenta
    255 255 255;... % white
    0 0 0]; % black

win.fontsize = 24;

% make a dummy call to GetSecs to load the .dll before we need it
dummy = GetSecs; clear dummy;
end