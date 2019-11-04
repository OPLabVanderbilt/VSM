%-------------------------------------------------------------------------
% PTB3 implementation of a color change detection task following Luck &
% Vogel (1997).
% Programmed by Kirsten Adam 2012 (updated March 2016)
%
%  "change" is "/", "no change" = "z" key
%-------------------------------------------------------------------------
function ChangeDetection_Color_Function_9colors_MAS(p,win)
% Build an output file and check to make sure that it doesn't exist yet
% either
fileName = [p.root,filesep,'Subject Data',filesep,num2str(p.subNum), '_ColorK_9colors.mat'];
Screen('Preference', 'SkipSyncTests',1);             % Add this line to run on laptop

if p.subNum ~= 0 % "0" is considered the practice subject number -- if any other # except 0 don't allow over-writing of the file
    if exist(fileName)
        Screen('CloseAll');
        msgbox('File already exists!', 'modal')
        return;
    end
end
%----------------------------------------------------
% Get screen params, build the display
%----------------------------------------------------
commandwindow; % select the command win to avoid typing in open scripts
ListenChar(2); % don't print things in the command window

% set the random state to the random seed at the beginning of the experiment!!
rand('state',p.rndSeed);
prefs = getPreferences();  % function that grabs all of our preferences (at the bottom of this script)

% set up fixation point rect (b/c uses both prefs and win)
win.fixrect = [(win.centerX - prefs.fixationSize),(win.centerY - prefs.fixationSize), ...
    (win.centerX  + prefs.fixationSize), (win.centerY + prefs.fixationSize)];
%--------------------------------------------------------
% Preallocate some variable structures! :)
%--------------------------------------------------------
% Stimulus parameters:
stim.setSize = NaN(prefs.numTrials,prefs.numBlocks);
stim.change = NaN(prefs.numTrials,prefs.numBlocks);
% Response params
stim.response = NaN(prefs.numTrials,prefs.numBlocks);
stim.accuracy = NaN(prefs.numTrials,prefs.numBlocks);
stim.rt = NaN(prefs.numTrials,prefs.numBlocks);
% Location params
stim.probeLoc = NaN(prefs.numTrials,prefs.numBlocks,2); % 3rd dimension = (x,y) coordinates
stim.presentedColor = NaN(prefs.numTrials,prefs.numBlocks); % color originally presented at the probed location
stim.probeColor = NaN(prefs.numTrials,prefs.numBlocks); % color presented during the actual probe test

% stim.itemLocs is a cell structure that will save the locations (centroids
% of all items. stim.itemLocs{trialNumber,blockNumber} = [xloc1 xloc2 ....; yloc1, yloc2 ...];
% stim.itemColors is a cell structure taht identifies the color of each
% item. stim.itemColors{trialNumber,blockNumber} = [col1,col2...]. To
% identify the RGB value, find the matching row in stim.colorList.
%---------------------------------------------------
%  Put up instructions
instruct(win)
%---------------------------------------------------
% Begin Block loop
%---------------------------------------------------
for b = 1:prefs.numBlocks
    
    %%%% pick out the order of trials for this block, based on
    %%%% full Factorial Design
    prefs.order(:,b) = Shuffle(1:prefs.numTrials);
    stim.setSize(:,b) = prefs.setSizes(prefs.fullFactorialDesign(prefs.order(:,b), 1));
    stim.change(:,b) = prefs.change(prefs.fullFactorialDesign(prefs.order(:,b),2));
    
    % save the color list!! for later use!!!
    stim.colorList = repmat(win.colors_9,2,1);
    %-------------------------------------------------------
    % Begin Trial Loop
    %-------------------------------------------------------
    for t = 1:prefs.numTrials
        %--------------------------------------------------------
        % Figure out the conditions for this  trial!
        %--------------------------------------------------------
        nItems = stim.setSize(t,b);
        change = stim.change(t,b);
        
        win.colors = win.colors_9;
        %--------------------------------------------------------
        % Create and flip up the basic stimulus display
        %--------------------------------------------------------
        Screen('FillRect',win.onScreen,win.foreColor,win.forerect);      % Draw the foreground win
        Screen('FillOval',win.onScreen,win.black,win.fixrect);           % Draw the fixation point
        Screen('DrawingFinished',win.onScreen);                          % Tell ptb we're done drawing for the moment (makes subsequent flip command execute faster)
        Screen('Flip',win.onScreen);                                     % Flip all the stuff we just drew onto the main display
        
        % compute and grab a random index into the color matrix
        colorIndex = randperm(size(win.colors,1));
        
        % calculate the stimulus locations for this trial!
        %%% centroid coordinates for all items!!
        [xPos,yPos] = getStimLocs(prefs,win,nItems);
        
        %%%% save the locations of ALL items!!!!
        stim.itemLocs{t,b} = [xPos;yPos];
        stim.itemColors{t,b} = colorIndex(1:nItems);
        
        % Wait the fixation interval
        WaitSecs(prefs.ITI); %
        
        % Draw squares on the main win
        Screen('FillRect',win.onScreen,win.foreColor,win.forerect);            % Draw the foreground win
        Screen('FillOval',win.onScreen,win.black,win.fixrect);           % Draw the fixation point
        for i = 1:nItems % note, this could be made faster with "Fillrects" instead of a loop! 
            Screen('FillRect',win.onScreen,win.colors(colorIndex(i),:),[(xPos(i)-prefs.stimSize/2),(yPos(i)-prefs.stimSize/2),(xPos(i)+prefs.stimSize/2),(yPos(i)+prefs.stimSize/2)]);
        end
        Screen('DrawingFinished',win.onScreen);
        Screen('Flip',win.onScreen);
        
        % Wait the sample duration
        WaitSecs(prefs.stimulusDuration); % stimulus Dur + retention, since not a memory task ...
        
        % draw blank screen
        Screen('FillRect',win.onScreen,win.foreColor,win.forerect);            % Draw the foreground win
        Screen('FillOval',win.onScreen,win.black,win.fixrect);           % Draw the fixation point
        Screen('DrawingFinished',win.onScreen);
        Screen('Flip',win.onScreen);
        
        %------------------------------------------------------------------
        % Figure out the change stuff
        %------------------------------------------------------------------
        changeIndex = randperm(nItems);
        changeLocX = xPos(changeIndex(1)); changeLocY = yPos(changeIndex(1));
        
        sColor = colorIndex(changeIndex(1));  % sColor is the square-of-interest's color if NOT a change condition!
        dColors = Shuffle(colorIndex(~ismember(colorIndex,sColor))); % different colors from chosen square
        changeColor = win.colors(dColors(1),:); % now we use the index to pick the change color!
        
        % wait the ISI
        WaitSecs(prefs.retentionInterval); % stimulus Dur + retention, since not a memory task ...
        
        % Draw a new square on the screen, with the color value determined
        % by whether it's a change trial or not
        Screen('FillRect',win.onScreen,win.foreColor,win.forerect);            % Draw the foreground win
        Screen('FillOval',win.onScreen,win.black,win.fixrect);           % Draw the fixation point
        if change == 1
            Screen('FillRect',win.onScreen,changeColor,[(changeLocX-prefs.stimSize/2),(changeLocY-prefs.stimSize/2),(changeLocX+prefs.stimSize/2),(changeLocY+prefs.stimSize/2)]);
            stim.probeColor(t,b) = dColors(1);
            stim.probeLoc(t,b,:) = [changeLocX,changeLocY];
        else
            Screen('FillRect',win.onScreen,win.colors(sColor,:),[(changeLocX-prefs.stimSize/2),(changeLocY-prefs.stimSize/2),(changeLocX+prefs.stimSize/2),(changeLocY+prefs.stimSize/2)]);
            stim.probeColor(t,b) = sColor;
            stim.probeLoc(t,b,:) = [changeLocX,changeLocY];
        end
        
        stim.presentedColor(t,b) = sColor;
        
        Screen('DrawingFinished',win.onScreen);
        Screen('Flip',win.onScreen);
        
        % Wait for a response
        rtStart = GetSecs;
        
        while KbCheck; end;
        KbName('UnifyKeyNames');   % This command switches keyboard mappings to the OSX naming scheme, regardless of computer.
        % unify key names so we don't need to mess when switching from mac
        % to pc ...
        escape = KbName('ESCAPE');  % Mac == 'ESCAPE' % PC == 'esc'
        prefs.changeKey = KbName('/?'); % on mac, 56 % 191 == / pc
        prefs.nochangeKey = KbName('z'); % on mac, 29  % 90 == z
        space = KbName('space');
        
        while 1
            [keyIsDown,secs,keyCode]=KbCheck;
            if keyIsDown
                if keyCode(escape)                              % if escape is pressed, bail out
                    ListenChar(0);
                    % save data file at the end of each block
                    save(fileName,'p','stim','prefs','win');
                    Screen('CloseAll');
                    return;
                end
                kp = find(keyCode); 
                kp = kp(1); % in case they press 2 buttons at the exact same time!!! 
                if kp== prefs.changeKey || kp== prefs.nochangeKey  % previously 90/191, PC
                    stim.response(t,b)=kp;
                    rtEnd = GetSecs;
                    break
                end
            end
        end
        
        Screen('FillRect',win.onScreen,win.foreColor,win.forerect);            % Draw the foreground win
        Screen('FillOval',win.onScreen,win.black,win.fixrect);           % Draw the fixation point
        Screen('DrawingFinished',win.onScreen);
        Screen('Flip',win.onScreen);
        
        stim.rt(t,b) = rtEnd-rtStart;
        
        % Check accuracy
        if change == 1
            if stim.response(t,b) == prefs.changeKey  % 191 == / on pc
                stim.accuracy(t,b)=1;
            else
                stim.accuracy(t,b)=0;
            end
        else
            if stim.response(t,b) == prefs.nochangeKey  % 90 == z on pc
                stim.accuracy(t,b)=1;
            else
                stim.accuracy(t,b)=0;
            end
        end
        
    end    % end of trial loop
    
    % save data file at the end of each block
    save(fileName,'p','stim','prefs','win');
    
    % tell subjects that they've finished the current block / the experiment
    if b<prefs.numBlocks
        tic
        while toc < prefs.breakLength*60;
            tocInd = round(toc);
            Screen('FillRect',win.onScreen,win.foreColor,win.forerect);            % Draw the foreground win
            Screen('FillOval',win.onScreen,win.black,win.fixrect);           % Draw the fixation point
            Screen(win.onScreen, 'DrawText', 'Take a break.', win.centerX-110, win.centerY-75, [255 255 255]);
            Screen(win.onScreen, 'DrawText',['Time Remaining: ',char(num2str((prefs.breakLength*60)-tocInd))], win.centerX-110, win.centerY-40, [255 0 0 ]);
            Screen(win.onScreen, 'DrawText', ['Block ',num2str(b),' of ',num2str(prefs.numBlocks),' completed.'], win.centerX-110, win.centerY+20, [255 255 255]);
            Screen('Flip', win.onScreen);
        end
    end
    
    if b == prefs.numBlocks;
        
        Screen('TextSize',win.onScreen,24);
        Screen('TextFont',win.onScreen,'Arial');
        Screen(win.onScreen, 'DrawText', 'Finished this task! Press the spacebar.', win.centerX-250, win.centerY-75, [255 255 255]);
        Screen('Flip', win.onScreen);
        
        % Wait for a spacebar press to continue with next block
        while 1
            [keyIsDown,secs,keyCode]=KbCheck;
            if keyIsDown
                kp = find(keyCode);
                if kp == space
                    break;
                end
            end
        end
        
    end
end    % end of the block loop

end % end Change Detection function

%-------------------------------------------------------------------------
%  ADDITIONAL FUNCTIONS EMBEDDED IN SCRIPT !!
%-------------------------------------------------------------------------
function instruct(win)

InstructImage = imread([pwd,'/Instructions_CD'],'png','BackgroundColor',[win.gray/255,win.gray/255,win.gray/255]);
textOffset = 200;
textSize = 15;

sizeInstruct = size(InstructImage);
rectInstruct = [0 0 sizeInstruct(2) sizeInstruct(1)];
rectTestCoor = [win.centerX,win.centerY-(sizeInstruct(1)*.2)];

InstructText = ['Remember the colors!  \n'...
    '1. Wait for the squares to appear.\n'...
    '2. See the squares \n'...
    '3. Remember the squares \n'...
    '4. Same or different? \n'...
    '  \n'...
    'If the color is the same, press "z".\n'...
    'If the color is different, press "/". \n'...
    'This task is pretty difficult and you will probably have to guess a lot, \n'...
    'but it is important that you keep trying \n'...
    'Press spacebar to begin'];

% InstructText = ['Remember the colors. \n'... %%%% Note, Chinese text was actually used in the study, but does not render in English matlab! 
%     '  \n'...
%     '1. 空屏等待颜色色块的出现。\n'...
%     '  \n'...
%     '2. 颜色色块的出现。\n'...
%     '  \n'...
%     '3. 记住全部的颜色色块。\n'...
%     '  \n'...
%     '4. 判断后面出现的颜色和前面出现的颜色是一致，还是不一致\n'...
%     '  \n'...
%     '如果显示的颜色与记忆颜色一致，请左手按"z"键。\n'...
%     '  \n'...
%     '如果显示的颜色与记忆颜色不一致，请右手按"/"键。 \n'...
%     '  \n'...
%     '请按空格键开始实验'];

% Show image again, but with explanatory text
Screen('FillRect', win.onScreen, win.gray);
Screen('TextSize', win.onScreen, win.fontsize);

Screen('PutImage',win.onScreen,InstructImage,CenterRectOnPoint(rectInstruct,rectTestCoor(1),rectTestCoor(2)));
Screen('TextSize', win.onScreen, textSize); % 24 = number pixels
DrawFormattedText(win.onScreen, InstructText, win.centerX-textOffset,win.centerY+(sizeInstruct(1)*.35),win.white);
Screen('Flip', win.onScreen);

% Wait for a spacebar press to continue with next block
while KbCheck; end;
KbName('UnifyKeyNames');   % This command switches keyboard mappings to the OSX naming scheme, regardless of computer.
space = KbName('space');
while 1
    [keyIsDown,secs,keyCode]=KbCheck;
    if keyIsDown
        kp = find(keyCode);
        if kp == space
            break;
        end
    end
end
end
%-------------------------------------------------------------------------
function [xPos,yPos] = getStimLocs(prefs,win,nItems)
% segment the inner window into four quadrants - for xCoords, 1st
% row = positions in left half of display, 2nd row = right half.
% For yCoords - 1st row = top half, 2nd row = bottom half
xCoords = [linspace((win.forerect(1)+prefs.stimSize),win.centerX-prefs.stimSize,300); linspace(win.centerX+prefs.stimSize,(win.forerect(3)-prefs.stimSize),300)];
yCoords = [linspace((win.forerect(2)+prefs.stimSize),win.centerY-prefs.stimSize,300); linspace(win.centerY+prefs.stimSize,(win.forerect(4)-prefs.stimSize),300)];
xLocInd = randperm(size(xCoords,2)); yLocInd = randperm(size(yCoords,2));

% Pick x,y coords for drawing stimuli on this trial, making sure
% that all stimuli are seperated by >= prefs.minDist
if nItems ==1
    xPos = [xCoords(randi(2),xLocInd(1))];  % pick randomly from first and second x rows (L/R halves)
    yPos = [yCoords(randi(2),yLocInd(1))];  % pick randomly from first and second y rows (Top/Bottom).
elseif nItems ==2
    randomPosition = randi(2);
    if randomPosition == 1
        xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2))]; % pick one left and one right item
        yPos = [yCoords(randi(2),yLocInd(1)),yCoords(randi(2),yLocInd(2))]; % pick randomly, top or bottom
    else
        xPos = [xCoords(randi(2),xLocInd(1)),xCoords(randi(2),xLocInd(2))]; % pick randomly, left or right!
        yPos = [yCoords(1,yLocInd(1)),yCoords(2,yLocInd(2))]; % pick one top, one bottom!
    end
elseif nItems ==3
    xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4))]; % one L one R
    yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4))]; % one top one bottom for e/ L/R
    % let's use the same scheme as 4 items, but randomly leave one
    % out!
    randomOrder = randperm(4);
    xPos = xPos(randomOrder(1:3));
    yPos = yPos(randomOrder(1:3));
elseif nItems ==4
    xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4))]; % one L one R
    yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4))]; % one top one bottom for e/ L/R
elseif nItems ==5
    randomPosition = randi(2); % pick one of two quadrants to stick the second item
    while 1
        if randomPosition == 1
            xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
            xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(1,xLocInd(5))];
            yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(1,yLocInd(5))];
            % make sure that w/in quadrant points satisfy the minimum
            % distance requirement
            if sqrt(abs(xPos(1)-xPos(5))^2+abs(yPos(1)-yPos(5))^2)>prefs.minDist
                %             if sqrt((xPos(2)-xPos(6))^2+(yPos(2)-yPos(6))^2)>prefs.minDist
                break;
            end
        elseif randomPosition == 2
            xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
            xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(2,xLocInd(5))];
            yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(1,yLocInd(5))];
            % make sure that w/in quadrant points satisfy the minimum
            % distance requirement
            if sqrt((xPos(2)-xPos(5))^2+(yPos(2)-yPos(5))^2)>prefs.minDist
                break;
            end
        end
    end
elseif nItems ==6
    randomPosition = randi(2); % put extra squares in top or bottom half;
    while 1
        if randomPosition == 1
            xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
            xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(1,xLocInd(5)),xCoords(2,xLocInd(6))];
            yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(1,yLocInd(5)),yCoords(1,yLocInd(6))];
            % make sure that w/in quadrant points satisfy the minimum
            % distance requirement
            if sqrt(abs(xPos(1)-xPos(5))^2+abs(yPos(1)-yPos(5))^2)>prefs.minDist
                if sqrt((xPos(2)-xPos(6))^2+(yPos(2)-yPos(6))^2)>prefs.minDist
                    break;
                end
            end
        else
            xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
            xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(1,xLocInd(5)),xCoords(2,xLocInd(6))];
            yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(2,yLocInd(5)),yCoords(2,yLocInd(6))];
            % make sure that w/in quadrant points satisfy the minimum
            % distance requirement
            if sqrt(abs(xPos(3)-xPos(5))^2+abs(yPos(3)-yPos(5))^2)>prefs.minDist
                if sqrt((xPos(4)-xPos(6))^2+(yPos(4)-yPos(6))^2)>prefs.minDist
                    break;
                end
            end
        end
    end
elseif nItems == 8
    while 1
        xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
        xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(1,xLocInd(5)),xCoords(2,xLocInd(6)),xCoords(1,xLocInd(7)),xCoords(2,xLocInd(8))];
        yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(1,yLocInd(5)),yCoords(1,yLocInd(6)),yCoords(2,yLocInd(7)),yCoords(2,yLocInd(8))];
        % make sure that w/in quadrant points satisfy the minimum
        % distance requirement
        if sqrt(abs(xPos(1)-xPos(5))^2+abs(yPos(1)-yPos(5))^2)>prefs.minDist
            if sqrt((xPos(2)-xPos(6))^2+(yPos(2)-yPos(6))^2)>prefs.minDist
                if sqrt((xPos(3)-xPos(7))^2+(yPos(3)-yPos(7))^2)>prefs.minDist
                    if sqrt((xPos(4)-xPos(8))^2+(yPos(4)-yPos(8))^2)>prefs.minDist
                        break;
                    end
                end
            end
        end
    end
end

end
%-------------------------------------------------------------------------
%  CHANGE PREFERENCES!
%-------------------------------------------------------------------------
function prefs = getPreferences
%%%% Design conditions
prefs.numBlocks = 3;
prefs.nTrialsPerCondition = 25;
prefs.setSizes = [6]; % only set size 2 for this experiment right now.
prefs.change = [0,1]; % 0 = no change, 1 = change!

%%%%% timing
prefs.retentionInterval =  [1.000]; % win.refRate;% 1 sec  (or, if we don't do this we can jitter .... )
prefs.stimulusDuration = [.250]; %win.refRate/2;% 500 ms
prefs.ITI = 1.000;  %prefs.retentionInterval;
prefs.breakLength = .1*5; % number of minutes for block


%%%%% stimulus size & positions
prefs.stimSize = 51;
prefs.minDist = prefs.stimSize*1.5;
prefs.fixationSize = 6;

%%%%% randomize trial order of full factorial design order
prefs.fullFactorialDesign = fullfact([length(prefs.setSizes), ...
    length(prefs.change), ...
    length(prefs.retentionInterval), ...
    length(prefs.stimulusDuration), ...
    prefs.nTrialsPerCondition]);  %add prefs.numBlocks? No, because we are using fully counterbalanced blocks.

%%%%% total number of trials in each fully-crossed block.
prefs.numTrials = size(prefs.fullFactorialDesign,1);
end