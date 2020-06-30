function ReceptiveFieldMapping(trials)

%%%%%%%%%%%%%%%%%%%%% DEFAULTS FOR TESTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UNCOMMENT THIS SECTION FOR RUNNING STIMULUS AS STAND ALONE; COMMENT ABOVE

% table = {'N Grid Locations x', 8, [], [];...
%          'N Grid Locations y', 8, [], [];...
%          'Dimensions (degrees)', 5, [], [];...
%          'Timing (delay,duration,wait) (s)', 0.1, 1 , 0.1;...
%          'ON_OFF', 1, [], [];...
%          'Repeats', 1, [], [];...
%          'Initialization Screen (s)', 5, [],[];...
%          'Output trigger', 0, [], [];...
%          'External trigger', 0, [], []};
%     
% stimType = 'Receptive Field Mapping';
%    
% trials = trialStruct(stimType, table);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


%%%%%%%%%%%%%%%%%%%%% OPEN A SCREEN & DETERMINE PARAMETERS %%%%%%%%%%%%%%%%
% Use a try except block to prevent the screen from hanging. During testing
% if the screen does hang press cntrl C or cntrl-alt del to bring up the
% task manager to stop PTB execution
try
    % Require OPENGL becasue some of the functions used here need the
    % OPENGL version of PTB
    AssertOpenGL;
    
%%%%%%%%%%%%%%%%%%%%%% GET SPECIFIC MONITOR INFORMATION %%%%%%%%%%%%%%%%%%%

    % SCREEN WE WILL DISPLAY ON
    screenNumber = monitorInfo.screenNumber;

    % COLOR INFORMATION OF SCREEN
    whitePix = WhiteIndex(screenNumber);
    blackPix = BlackIndex(screenNumber);
    whiteLum = PixToLum(whitePix);
    blackLum = PixToLum(blackPix);
    grayLum = (whiteLum + blackLum)/2;
    grayPix = GammaCorrect(grayLum);
  
    %grayPix = 128;
    % CONVERSION FROM DEGS TO PX AND SIZING INFO FOR SCREEN
    %conversion factor specific to monitor
    degPerPix = monitorInfo.degPerPix;
    % Size of the grating (in pix) that we will draw (1.5 times 
    % monitor width)
    visibleSize = 1.5*monitorInfo.screenSizePixX;
    
%%%%%%%%%%%%%%%%%%%%%%%%%% INITIAL SCREEN DRAW %%%%%%%%%%%%%%%%%%%%%%%%%%%    
% We start with a gray screen before generating our stimulus and displaying
% our stimulus. 

    % HIDE CURSOR FROM SCREEN
    HideCursor;
    % OPEN A SCREEN WITH A BG COLOR OF GRAY (RETURN POINTER W)
	[w, screenRect]=Screen('OpenWindow',screenNumber, grayPix);
    % SCRIPT PRIORITY LEVEL
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);

% INTERFRAME INTERVAL INFO   
    % Get the montior inter-frame-interval 
    ifi = Screen('GetFlipInterval',w);    
    waitframes = 1; %I expect most new computers can handle updates at ifi
    ifiDuration = waitframes*ifi;
    
% CREATE A DESTINATION RECTANGLE where the stimulus will be drawn to
    dstRect=[0 0 visibleSize visibleSize];
    %center the rectangle to the screen
    dstRect=CenterRect(dstRect, screenRect);
    
%%%%%%%%%%%%%%%%%%%%%% DRAW INITIALIZATION SCREEN %%%%%%%%%%%%%%%%%%%%%%%%%%%
stimInitScreen(w,trials(1).Initialization_Screen,grayPix,ifiDuration)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%% CONSTRUCT AND DRAW TEXTURES %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the main body of the code. We will loop through our trials array
% structure, construct a grating texture based on the values for each trial
% and then execute the drawing in a while loop. All of this must be done in
% a single loop becasue we need to close the textures in the trial loop
% after using each texture becasue otherwise they will hang around in
% memory and cause the familiar Java runtime error: Out of memory.

% Exit Codes and initialization
    exitLoop=0;
    
    % MAIN LOOP OVER TRIALS TO CONSTRUCT TEXTURES AND DRAW THEM
    for trial=1:numel(trials)
        if exitLoop==1;
            break;
        end
       n=0; % keep track of frames drawn
       
%%%%%%%%%%%%%%%%%%%% GET STIMULUS TIMING INFORMATION %%%%%%%%%%%%%%%%%%%%%%
    delay = trials(trial).Timing(1);
    duration = trials(trial).Timing(2);
    wait = trials(trial).Timing(3);
    
%%%%%%%%%%%%%%%%%%%% COMPUTE STIMULUS LOCATIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%
    stim_location = trials(trial).stim_location;
    size_x = trials(trial).N_Grid_Locations_x;
    size_y = trials(trial).N_Grid_Locations_y;
    stim_x = mod(stim_location-1, size_x) + 1;
    stim_y = (stim_location - stim_x)/size_x + 1;
    
    square_size_pix = trials(trial).Dimensions/degPerPix;
    stim_rect = [0 0 square_size_pix square_size_pix];
    stim_rect = CenterRect(stim_rect, screenRect);
    stim_rect(1) = stim_rect(1) + (stim_x-(size_x+1)/2)*square_size_pix;
    stim_rect(3) = stim_rect(3) + (stim_x-(size_x+1)/2)*square_size_pix;
    stim_rect(2) = stim_rect(2) + (stim_y-(size_y+1)/2)*square_size_pix;
    stim_rect(4) = stim_rect(4) + (stim_y-(size_y+1)/2)*square_size_pix;
    origin_rect = [0 0 1/degPerPix 1/degPerPix];
    origin_rect = CenterRect(origin_rect, screenRect);
    
    if(trials(trial).ON_OFF == 1)
        clr = whitePix;
    else
        clr = blackPix;
    end
    
    %fprintf("N = %i, x = %i, y = %i\n", stim_location, stim_x, stim_y);

    %%%%%%%%%%%%%%%%%%%%%%% PARALLEL PORT TRIGGER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % After constructing the stimulus texture we are now ready to trigger the 
    % parallel port and begin our draw to the screen. This function
    % is located in the stimGen helper functions directory.
    if trials(trial).Output_trigger == 1
        daq_out_trigger;
    end
    %%%%%%%%%%%%%%%% WAIT FOR EXTERNAL TRIGGER
    if trials(trial).External_trigger == 1
        waitfordaq;
    end
%%%%%%%%%%%%%%%%%%%% DRAW PRESTIM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Screen('FillRect', w, [255 128 0] , origin_rect);
    vbl=Screen('Flip', w);
    delayTime = vbl + delay;
    
    while (vbl < delayTime)
        % Draw a gray screen and flip
        Screen('FillRect', w,grayPix);
        %Screen('FillRect', w, [255 128 0] , origin_rect)
        vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
        % exit the while loop and flag to one if user presses any key
        if KbCheck
            exitLoop=1;
            break;
        end
    end
    
%%%%%%%%%%%%%%%%%%%% DRAW STIM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %Screen('FillRect', w, [255 128 0] , origin_rect);
    vbl = Screen('Flip', w);
    runtime = vbl + duration;
    
    while (vbl < runtime)
         n = n+1;
        % Draw stim and flip
        Screen('FillRect', w,grayPix);
        Screen('FillRect', w, clr, stim_rect);
        %Screen('FillRect', w, [255 128 0] , origin_rect);
        FlipCheck(w, screenRect, [whitePix, blackPix], n)
        vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
        % exit the while loop and flag to one if user presses any key
        if KbCheck
            exitLoop=1;
            break;
        end
    end

%%%%%%%%%%%%%%%%%%%%% DRAW INTERSTIMULUS GRAY SCREEN %%%%%%%%%%%%%%%%%%%%%%
    %Screen('FillRect', w, [255 128 0] , origin_rect);
    vbl=Screen('Flip', w);
    waitTime = vbl + wait;
        
    while (vbl < waitTime)
        Screen('FillRect', w,grayPix);
        %Screen('FillRect', w, [255 128 0] , origin_rect)
        vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
        % exit the while loop and flag to one if user presses any key
        if KbCheck
            exitLoop=1;
            break;
        end
    end
    
    
    end
    
    
    % Restore normal priority scheduling in case something else was set
    % before:
    Priority(0);
	
	%The same commands wich close onscreen and offscreen windows also close
	%textures. We still need to close any screens opened prior to the trial
	%loop ( the prep screen for example)
	Screen('CloseAll');
catch 
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    Priority(0);
    psychrethrow(psychlasterror);
end
%%%%%%%%%%%%%%%%%%%%%%%% Turn On PTB verbose warnings %%%%%%%%%%%%%%%%%%%%
Screen('Preference', 'Verbosity',3);
% please see the following page for an explanation of this function
%  http://psychtoolbox.org/FaqWarningPrefs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
java.lang.Runtime.getRuntime().gc % call garbage collect (likely useless)
return