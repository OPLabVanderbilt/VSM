%-------------------------------------------------------------------------
% Script to run multiple experimental scripts in a row
% Programmed by Kirsten Adam, June 2014
% adapted to be 150 trials in 3 blocks by Mackenzie, July 2017
%-------------------------------------------------------------------------

function [] = VSM(subjno,subjini,age,sex,hand)
warning('off','MATLAB:dispatcher:InexactMatch');  % turn off the case mismatch warning (it's annoying)
dbstop if error  % tell us what the error is if there is one
AssertOpenGL;    % make sure openGL rendering is working (aka psychtoolbox is on the path)

p.clockOutput = clock; % record time and date!!
p.rndSeed = round(sum(100*p.clockOutput));
subjini = subjini;
age = age;
sex = sex;
hand = hand;

p.subNum = str2num(subjno);
rand('state',p.rndSeed);

%-------------------------------------------------------------------------
% Important options
%-------------------------------------------------------------------------
try
    p.is_PC = ispc; % detects whether this is a PC or windows machine.
    p.windowed = 0; % 1 = smaller window for easy debugging!
    %-------------------------------------------------------------------------
    % Build an output directory & check to make sure it doesn't already exist
    %-------------------------------------------------------------------------
    p.root = pwd;
    % if the subject data directory doesn't exist, make one!!
    if ~exist([p.root,filesep,'Subject Data',filesep], 'dir');
        mkdir([p.root,filesep,'Subject Data',filesep]);
    end
    %-------------------------------------------------------------------------
    % Build psychtoolbox window & hide the task bar
    %-------------------------------------------------------------------------
    win = openWindow(p);
    %Manually hide the task bar so it doesn't pop up because of flipping
    %the PTB screen during GetMouse: (Note, this is only needed because of an annoying
    % glitch with newer windows machines specifically when calling functions within functions.
    % To avoid having to do this, you can instead make one single script with sub-functions instead of separately
    % saving multiple function files and calling functions from separate scripts.
    if p.is_PC
        ShowHideWinTaskbarMex(0);
    end
    %-------------------------------------------------------------------------
    % Run Experiment 1
    %-------------------------------------------------------------------------
    ChangeDetection_Color_Function_9colors_MAS(p,win);
    %-------------------------------------------------------------------------
    % Close psychtoolbox window and clear it all out!
    %-------------------------------------------------------------------------
    sca;
    ListenChar(0);
    if p.is_PC
        ShowHideWinTaskbarMex(1);
    end
    close all;
    clear all;
catch
    ListenChar(0);
    ShowCursor;
    Screen('CloseAll');
    rethrow(lasterror);
end
end
