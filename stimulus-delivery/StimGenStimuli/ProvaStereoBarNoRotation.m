function ProvaStereoBarNoRotation(trials)

%%%%%%%%%%%%%%%%%%%%% DEFAULTS FOR TESTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UNCOMMENT THIS SECTION FOR RUNNING STIMULUS AS STAND ALONE; COMMENT ABOVE
%
%table = {'xRect', 200;...
%         'yRect', 100;...
%          'numDots', 20000;...
%          'displace', 2;...
%          'horizontal', 1;...
%          'vel', 1;...
%          'dotSize', 2};
%
% stimType = 'StereoBar';
%
%trials = trialStruct(stimType, table);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

a = arduino ('COM5', 'Uno', 'Libraries', 'Servo');
sR = servo(a, 'D9');
sL = servo(a, 'D10');

% Get monitor info from monitorInformation located in RigSpecificInfo dir.
% This structure contains all the pertinent monitor information we will
% need such as screen size and appropriate conversions from pixels to
% visual degrees
monitorInformation;

%%%%%%%%%%%%%%%%%%%%% TURN OFF PTB SYSTEM CHECK REPORT %%%%%%%%%%%%%%%%%%%%
Screen('Preference', 'Verbosity',1);
% This will suppress all but critical warning messages
% At the end of the code we will return the verbosity back to norm level 3
% please see the following page for an explanation of this function
% http://psychtoolbox.org/FaqWarningPrefs
% NOTE: as you debug your code comment this line because PTB will return
% back useful info about memory usage that will tell you about leaks that
% may casue problems

% When Screen('OpenWindow',w,color) is called, PTB performs many checks of
% your system. The time it takes to perform these checks depends on the
% noisiness of your system (up to two seconds on 2-photon rig). During this
% time it displays a white screen which is obviously not good for visual
% stimulation. We can disable the startup screen using the following. The
% sreen will now be black before visual stimulus
Screen('Preference', 'VisualDebuglevel', 3);
% see http://psychtoolbox.org/FaqBlueScreen for a reference


% Require OPENGL becasue some of the functions used here need the
% OPENGL version of PTB
AssertOpenGL;
stereoMode = 1;
PsychDefaultSetup(2);                                                         % BoilerPlate: Allows to work across OS. Unified KbName and Colour (0-1 range);
scrnNum = max(Screen('Screens'));                                             % Selects the monitor. Highest is often the best guess.
bgColor = BlackIndex(scrnNum);                                                % Returns the CLUT index to produce black at the current screen depth.
PsychImaging('PrepareConfiguration');                                         % Open double-buffered onscreen window with the requested stereo mode,
HideCursor;
[windowPtr, windowRect] = PsychImaging('OpenWindow', scrnNum, bgColor, ...
    [], [], [], stereoMode);
priorityLevel = MaxPriority(windowPtr);
Priority(priorityLevel);
xmax = RectWidth(windowRect)/2;
ymax = RectHeight(windowRect)/2;
ifi = Screen('GetFlipInterval',windowPtr);
waitframes = 1;                                                                  %I expect most new computers can handle updates at ifi
ifiDuration = waitframes*ifi;

% KEYBOARD SETUP %

% space = KbName('space');
% escape = KbName('ESCAPE');

% STIMULI DURATION %

delay = trials(1).Timing(1);
wait = trials(1).Timing(3);
duration = trials(1).Timing(2);
setup = 1;

% DOT SETTINGS %

col1 = WhiteIndex(scrnNum);
col2 = col1;
numDots = trials(1).Number_of_dots;
dotSize = trials(1).Size_of_dots;
dots = zeros(2, numDots);
bdots = zeros(2, numDots);
Lbardots = zeros(2, numDots);
Rbardots = zeros(2, numDots);
Lbackdots = zeros(2, numDots);
Rbackdots = zeros(2, numDots);
center = [0 0];

% ALPHA BLENDING %

Screen('BlendFunction', windowPtr, ...
    'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
Screen('Flip', windowPtr);
stimInitScreen(windowPtr,trials(1).Initialization_Screen,bgColor,ifiDuration);

exitLoop=0;

for trial=1:numel(trials)
    if exitLoop==1
        break;
    end
    
    % BAR CONFIG %
    
    if trials(trial).Eyes==1
        writePosition(sL, 0);
        writePosition(sR, 0);
    elseif trials(trial).Eyes==2
        writePosition(sL, 1);
        writePosition(sR, 0);
    elseif trials(trial).Eyes==3
        writePosition(sL, 0);
        writePosition(sR, 1);
    elseif trials(trial).Eyes==4
        writePosition(sL, 1);
        writePosition(sR, 1);
    end
    
    horizontal = trials(trial).Orientation;
    vel = trials(trial).Speed;
    displace = trials(trial).Displacement;
    angle = 0;
    
    if horizontal == 1
        xvel = vel;
        yvel = 0;
        yRect = trials(trial).Height;
        xRect = trials(trial).Width;
    else
        xvel = 0;
        yvel = vel;
        yRect = trials(trial).Width;
        xRect = trials(trial).Height;
    end
    
    RMatrix = [cosd(angle) -sind(angle); sind(angle) cosd(angle)];
    
    buttons = 0;
    vbl = Screen('Flip', windowPtr);
    setupTime = vbl + setup;
    
    while (vbl < setupTime) && ~any(buttons)
        
        % Select left-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', windowPtr, 0);
        
        % Draw left stim:
        Screen('FrameRect', windowPtr, [1 0 0], [], 5);
        
        % Select right-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', windowPtr, 1);
        
        % Draw right stim:
        Screen('FrameRect', windowPtr, [0 1 0], [], 5);
        
        % Tell PTB drawing is finished for this frame:
        Screen('DrawingFinished', windowPtr);
        
        % Keyboard queries and key handling:
        [pressed] = KbCheck;
        if pressed
            % Escape key exits the demo:
            exitLoop = 1;
        end
        
        vbl = Screen('Flip', windowPtr);
    end
    
    vbl = Screen('Flip', windowPtr);
    delayTime = vbl + delay;
    
    % EXIT SETUP & LOOP PRESENTATION
    
    while (vbl < delayTime) && ~any(buttons)                                    % Run until a key is pressed or nmax iterations have been done:
        
        [x,y,buttons] = GetMouse(windowPtr);
        dots(1, :) = (2*(ymax)*rand(1, numDots) - ymax);
        dots(2, :) = (2*(ymax)*rand(1, numDots) - ymax);
        
        
        % Select left-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', windowPtr, 0);
        
        % Draw left stim:
        Screen('DrawDots', windowPtr, dots(1:2, :), dotSize, col1, windowRect(3:4)/2, 3);
        Screen('FrameRect', windowPtr, [1 0 0], [], 5);
        Screen('FillRect', windowPtr, [1 1 1], [0 0 10 10]);
        
        % Select right-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', windowPtr, 1);
        
        % Draw right stim:
        Screen('DrawDots', windowPtr,   dots(1:2, :), dotSize, col2, windowRect(3:4)/2, 3);
        Screen('FrameRect', windowPtr, [0 1 0], [], 5);
        Screen('FillRect', windowPtr, [1 1 1], [0 0 10 10]);
        
        % Tell PTB drawing is finished for this frame:
        Screen('DrawingFinished', windowPtr);
        
        
        % Keyboard queries and key handling:
        [pressed] = KbCheck;
        if pressed
            % Escape key exits the demo:
            exitLoop = 1;
        end
        
        vbl = Screen('Flip', windowPtr);
    end
    
    
    vbl = Screen('Flip', windowPtr);
    runtime = vbl + duration;
    
    while (vbl < runtime) && ~any(buttons)
        [x,y,buttons] = GetMouse(windowPtr);
        % Demonstrate how mouse cursor position (or any other physical pointing
        % device location on the actual display) can be remapped to the
        % stereo framebuffer locations which correspond to those positions. We
        % query "physical" mouse cursor location, remap it to stereo
        % framebuffer locations, then draw some little marker-square at those
        % locations via Screen('DrawDots') below. At least one of the squares
        % locations should correspond to the location of the mouse cursor
        % image:
        
        % NON-DRAWING TASKS %
        
        dots(1, :) = (2*(ymax)*rand(1, numDots) - ymax);
        dots(2, :) = (2*(ymax)*rand(1, numDots) - ymax);
        bdots(1, :) = (2*(ymax)*rand(1, numDots) - ymax);
        bdots(2, :) = (2*(ymax)*rand(1, numDots) - ymax);
        Lbackdots = bdots;
        Rbackdots = bdots;
        
        if horizontal==1
            center = center + [xvel 0];                                            % BAR center offset.
            if center(1) > ymax -xRect -displace || center(1) < -ymax + xRect + displace
                xvel = -xvel;                                                      % If the bar touches the edges, invert the direction.
            end
            
            for i=1:numDots
                if abs(dots(2,i)) < yRect & abs(dots(1,i) - center(1)) < xRect
                    Lbardots(:, i) = dots(:,i);
                    Lbardots(1, i) = Lbardots(1, i) + displace;
                    Rbardots(:, i) = dots(:,i);
                    Rbardots(1, i) = Rbardots(1, i) - displace ;
                else
                    Lbardots(:, i) = 1000;
                    Rbardots(:, i) = 1000;
                end
                if  abs(bdots(2,i)) < yRect & abs(bdots(1,i) - center(1) - displace) < xRect
                    Lbackdots(1,i) = -1000;
                    Lbackdots(2,i) = -1000;
                end
                if  abs(bdots(2,i)) < yRect & abs(bdots(1,i) - center(1) + displace) < xRect
                    Rbackdots(1,i) = -1000;
                    Rbackdots(2,i) = -1000;
                end
            end
        end
        
        if horizontal==0
            center = center + [0 yvel];                                            % BAR center offset.
            if center(2) > ymax -yRect || center(2) < -ymax + yRect
                yvel = -yvel;
            end
            
            for i=1:numDots
                if abs(dots(1,i)) < xRect & abs(dots(2,i) - center(2)) < yRect
                    Lbardots(:, i) = dots(:,i);
                    Lbardots(1, i) = Lbardots(1, i) + displace;
                    Rbardots(:, i) = dots(:,i);
                    Rbardots(1, i) = Rbardots(1, i) - displace ;
                else
                    Lbardots(:, i) = dots(:,i);
                    Lbardots(1, i) = Lbardots(1, i) + 2000;
                    Rbardots(:, i) = dots(:,i);
                    Rbardots(1, i) = Rbardots(1, i) + 2000;
                end
                if  abs(bdots(1,i) - displace) < xRect & abs(bdots(2,i) - center(2)) < yRect
                    Lbackdots(1,i) = -1000;
                    Lbackdots(2,i) = -1000;
                end
                if  abs(bdots(1,i) + displace) < xRect & abs(bdots(2,i) - center(2)) < yRect
                    Rbackdots(1,i) = -1000;
                    Rbackdots(2,i) = -1000;
                end
            end
        end
        
        ldots = [Lbardots Lbackdots];
        rdots = [Rbardots Rbackdots];
        %ldots( :, ~any(ldots,1) )	= [];                                 % Eliminate all empty columns in those matrices.
        %rdots( :, ~any(rdots,1) )	= [];                                 % Eliminate all empty columns in those matrices.
        
        
        
        % DRAWING TASKS %
        
        % Select left-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', windowPtr, 0);
        
        % Draw left stim:
        Screen('DrawDots', windowPtr, ldots(1:2, :), dotSize, col1, windowRect(3:4)/2, 3);
        Screen('FrameRect', windowPtr, [1 0 0], [], 5);
        
        % Select right-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', windowPtr, 1);
        
        % Draw right stim:
        Screen('DrawDots', windowPtr,   rdots(1:2, :), dotSize, col2, windowRect(3:4)/2, 3);
        Screen('FrameRect', windowPtr, [0 1 0], [], 5);
        
        
        % Tell PTB drawing is finished for this frame:
        Screen('DrawingFinished', windowPtr);
        
        
        % Keyboard queries and key handling:
        [pressed] = KbCheck;
        if pressed
            % Escape key exits the demo:
            exitLoop = 1;
        end
        
        vbl = Screen('Flip', windowPtr);
        
    end
    
    vbl = Screen('Flip', windowPtr);
    waitTime = vbl + wait;
    
    while (vbl < waitTime) && ~any(buttons)                                    % Run until a key is pressed or nmax iterations have been done:
        
        [x,y,buttons] = GetMouse(windowPtr);
        dots(1, :) = (2*(ymax)*rand(1, numDots) - ymax);
        dots(2, :) = (2*(ymax)*rand(1, numDots) - ymax);
        
        % Select left-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', windowPtr, 0);
        
        % Draw left stim:
        Screen('DrawDots', windowPtr, dots(1:2, :), dotSize, col1, windowRect(3:4)/2, 3);
        Screen('FrameRect', windowPtr, [1 0 0], [], 5);
        Screen('FillRect', windowPtr, [1 1 1], [0 0 10 10]);
        
        % Select right-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', windowPtr, 1);
        
        % Draw right stim:
        Screen('DrawDots', windowPtr,   dots(1:2, :), dotSize, col2, windowRect(3:4)/2, 3);
        Screen('FrameRect', windowPtr, [0 1 0], [], 5);
        Screen('FillRect', windowPtr, [1 1 1], [0 0 10 10]);
        
        % Tell PTB drawing is finished for this frame:
        Screen('DrawingFinished', windowPtr);
        
        % Keyboard queries and key handling:
        [pressed] = KbCheck;
        if pressed
            % Escape key exits the demo:
            exitLoop = 1;
        end
        
        vbl = Screen('Flip', windowPtr);
    end
end

% If there is an error in our try block, let's
% return the user to the familiar MATLAB prompt.

% Done. Close the onscreen window:
Screen('CloseAll')

% Compute and show timing statistics:
%t = t(1:count);
%dt = t(2:end) - t(1:end-1);
%disp(sprintf('N.Dots\tMean (s)\tMax (s)\t%%>20ms\t%%>30ms\n')); %#ok<DSPS>
%disp(sprintf('%d\t%5.3f\t%5.3f\t%5.0f\t%5.0f\n', numDots, mean(dt), max(dt), sum(dt > 0.020)/length(dt)*100, sum(dt > 0.030)/length(dt)*100)); %#ok<DSPS>

Priority(0);
% We're done.
%return;
end
