function SingleAngleCS(trials)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%%%%%%%%%%%%%%%%%%%%%% DEFAULTS FOR TESTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UNCOMMENT THIS SECTION FOR RUNNING STIMULUS AS STAND ALONE; COMMENT ABOVE
% CONFLICTING FUNCTION 
%  function [trials] = simpleCS(stimType,table)
%  if nargin<1
%      table = {'Mask Diameter (deg)', 70, [], [];...
%               'Center Grating Diameter (deg)', 30, [], [];
%               'Center Orientation', 0, [], [];...
%               'Timing (delay,duration,wait) (s)', 1, 2, 1;...
%               'Randomize', 1, [], []};
%  stimType = 'SimpleCS';
%     
%  end
%  trials = simpleCSTrialsStruct(stimType,table);
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

% When Screen('OpenWindow',w,color) is called, PTB performs many checks of
% your system. The time it takes to perform these checks depends on the
% noisiness of your system (up to two seconds on 2-photon rig). During this
% time it displays a white screen which is obviously not good for visual
% stimulation. We can disable the startup screen using the following. The
% sreen will now be black before visual stimulus
Screen('Preference', 'VisualDebuglevel', 3);
% see http://psychtoolbox.org/FaqBlueScreen for a reference

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    %Query monitorInformation for screenNumber
    screenNumber = monitorInfo.screenNumber;

    % COLOR INFORMATION OF SCREEN
    whitePix = WhiteIndex(screenNumber);
    blackPix = BlackIndex(screenNumber);
    
    %Convert balck and white to luminance values to determine gray
    %luminance
    whiteLum = PixToLum(whitePix);
    blackLum = PixToLum(blackPix);
    grayLum = (whiteLum + blackLum)/2;
    
    % Now determine the pixel value of gray from the gray luminance
    grayPix = GammaCorrect(grayLum);
    
    % CONVERSION FROM DEGS TO PX AND SIZING INFO FOR SCREEN
    %conversion factor specific to monitor
    degPerPix = monitorInfo.degPerPix;
    % Size of the Surround grating (in pix) that we will draw (1.5 times 
    % monitor width)
    visibleSize = 1.5*monitorInfo.screenSizePixX;
    
%%%%%%%%%%%%%%%%%%%%%%%%%% INITIAL SCREEN DRAW %%%%%%%%%%%%%%%%%%%%%%%%%%%    
% We start with a gray screen before generating our stimulus and displaying
% our stimulus.

    % HIDE CURSOR FROM SCREEN
    HideCursor;
    % OPEN A SCREEN WITH A BG COLOR OF GRAY (RETURN POINTER W)
	[w, screenRect]=Screen(screenNumber,'OpenWindow', grayPix);
    
    % ENABLE ALPHA BLENDING OF GRATING WITH THE MASK
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%%%%%%%%%%%%%%%%%%%%%%%%% PREP SCREEN FOR DRAWING %%%%%%%%%%%%%%%%%%%%%%%%%

% SCRIPT PRIORITY LEVEL
% Query for the maximum priority level availbale on this system. This
% determines the priority level of the matlab thread (0= normal,
% 1=high, 2=realTime priority) note that a setting of 2 may cause the
% keyboard to be unresponsive. You may want to play with this number if
% you have trouble recovering the screen back
    
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);

% INTERFRAME INTERVAL INFO   
    % Get the montior inter-frame-interval 
    ifi = Screen('GetFlipInterval',w);
    
    %on old slow machines we may not be able to update every ifi. If your
    %graphics processor is too slow you can buy a better one or adjust the
    %number of frames to wait between flips below
    
    waitframes = 1; %I expect most new computers can handle updates at ifi
    ifiDuration = waitframes*ifi;
    

%%%%%%%%%%%%%%%%%%%% GET STIMULUS TIMING INFORMATION %%%%%%%%%%%%%%%%%%%%%%
    
    % The wait, duration, and delay are stored in trials structure. They
    % are the same for all trials so just get timing info from 1st trial
    delay = trials(1).Timing(1);
    duration = trials(1).Timing(2);
    wait = trials(1).Timing(3);
 
    %%%%%%%%%%%%%%%%%%%%%% DRAW PRESTIM GRAY SCREEN %%%%%%%%%%%%%%%%%%%%%%%
    % We call the function stimInitScreen to draw a screen to the window
    % before the stimulus appears to allow for any adaptation that is need
    % to a change in luminance
    stimInitScreen(w,trials(1).Initialization_Screen,grayPix,ifiDuration)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%% CONSTRUCT AND DRAW TEXTURES %%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % This is the main body of the code. We will loop through the trials
   % structures and construct a surround grating, a mask, a center grating
   % and an inner mask from the stimulus paprameters of each trial and
   % execute the drawing in a while loop. All of this must be done in a
   % single loop becasue we need to close the textures in the trial loop
   % after using each texture becasue otherwise they will hang around in
   % memory and cause the familiar Java runtime error: Out of memory.
   
   % Exit Codes and initialization
    exitLoop=0; %This is a flag indicating we need to break from the trials
                % structure loop below. The flag becomes true (=1) if the
                % user presses any key
    
    
    % MAIN LOOP OVER TRIALS TO CONSTRUCT TEXS AND DRAW THEM
    for trial=1:numel(trials)
        if exitLoop==1;
            break;
        end

        n=0;        % This is a counter to shift our grating on each redraw
        
    % To make a center-surround stimulus we will need to construct 4
    % textures that will be overlayed. The first will be our full-field
    % grating that will form the surround stimulus. On top of this we will
    % lay our mask, we will then draw our center stimulus, and lastly we
    % will draw a cicrular mask on top of the square center grating.
    % for the center grating we need to know the center-size (degs) the
    % spatial frequency and the contrast to make a static grating image.
    % For the mask we need the mask diameter, and for the surround grating,
    % we need the saptial frequency and contrast
    
        %%%%%%%%%%%%%%%%%%% CONSTRUCT SURROUND TEXTURE %%%%%%%%%%%%%%%%%%%%
        % We start by constructing a surround grating texture (note 
        % in prior stimuli I was explicit to take care not to compute a 
        % grating texture if the trial was blank to save on computation.
        % However this makes the code a little more difficult to read so I
        % abandon that here. We will always make all textures but in the
        % draw loop we will only draw what we need to show
        
        % we construct a grating texture from parameters of the trial
        % Get the contrast, spatial frequency of the trial
        surrContrast = 1;
        surrSpaceFreq = .04;
    
        % convert to pixel units
        surrPxPerCycle = ceil(1/(surrSpaceFreq*degPerPix));
        surrFreqPerPix = (surrSpaceFreq*degPerPix)*2*pi;
    
        % construct a 2-D grid of points to calculate our grating over
        % (note we extend by one period to account for shift of
        % grating later)
        x = meshgrid(-(visibleSize)/2:(visibleSize)/2 +...
            surrPxPerCycle, 1);
    
        % compute the grating in Luminance units
        surrGrating = grayLum +...
            (whiteLum-grayLum)*surrContrast*cos(surrFreqPerPix*x);
    
        % convert grating to pixel units
        surrGrating = GammaCorrect(surrGrating);
    
        % make the grating texture and save to gratingtex cell array
        % note it is not strictly necessary to save this to a cell
        % array since we will delete at the end of the loop but I want
        % to be explicit with the texture so that I am sure to delete
        % it when it is no longer needed in memory
        surroundGratingTex{trial}=Screen('MakeTexture', w,...
                                          surrGrating);
                                      
        %%%%%%%%%%%%%%%% CONSTRUCT OUTER MASK TEXTURE %%%%%%%%%%%%%%%%%%%%%
        % The gray mask is simply a gray circle overlayed on the surround
        % grating that will appear below the center grating to be drawn
        % after the mask texture

        % Get the mask diameter in degrees from the trials structure
        maskDiameter = trials(trial).Mask_Outer_Diameter;
        % Convert the mask Diameter to degrees
        maskDiamPix = ceil((maskDiameter/degPerPix));
        % construct a grid of mask locations so we can set the alpha
        % channel to 0 where the grating should show through the mask
        % (i.e. the complement or area outside the circular mask)
        [maskX, maskY] = meshgrid(-maskDiamPix/2:...
            maskDiamPix/2);
        % construct the rectangular mask, a square of size maskDiamPix
        mask = ones(maskDiamPix+1, maskDiamPix+1,2)*grayPix;
        % set the alpha channel of the complimentary region (outside of
        % the circle to be transparent so the grating shows through
        mask(:,:,2) = 255*(1-(maskX.^2+maskY.^2 >= (maskDiamPix/2)^2));
        % Construct the mask
        maskTex{trial} = Screen('MakeTexture', w, mask);
        
         %%%%%%%%%%%%% CONSTRUCT THE CENTER GRATING %%%%%%%%%%%%%%%%%%%%%%%%
        % Now we construct the center grating to be overlayed onto the
        % outer mask

        % Get the contrast, spatial frequency and diameter of the trial
        centerContrast = 1;
        centerSpaceFreq = .04;
        centerDiam = trials(trial).Center_Grating_Diameter;
        
        % convert to pixel units
        centerPxPerCycle = ceil(1/(centerSpaceFreq*degPerPix));
        centerFreqPerPix = (centerSpaceFreq*degPerPix)*2*pi;
        centerDiamPix = round(centerDiam/degPerPix);
        
        % construct a 2-D grid of points to calculate our grating over
        % (note we extend by one period to account for shift of
        % grating later)
        x = meshgrid(-(centerDiamPix)/2:(centerDiamPix)/2 +...
            centerPxPerCycle, 1);
        
        % compute the grating in Luminance units
        centerGrating = grayLum +...
            (whiteLum-grayLum)*centerContrast*cos(centerFreqPerPix*x);
        
        % convert grating to pixel units
        centerGrating = GammaCorrect(centerGrating);
        
        % make the grating texture and save to gratingtex cell array
        % note it is not strictly necessary to save this to a cell
        % array since we will delete at the end of the loop but I want
        % to be explicit with the texture so that I am sure to delete
        % it when it is no longer needed in memory
        centerGratingTex{trial}=Screen('MakeTexture', w,...
            centerGrating);

        %%%%%%%%%%%%%% CONSTRUCT AN INNER MASK %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % We now need to cover the inner square grating with an inner mask
        % to make a circular grating patch. The size of this inner mask
        % will match the size of the center grating
        
        % Get the inner mask diameter in degrees from the trials structure
        innerMaskDiameter = trials(trial).Center_Grating_Diameter;
        % Convert the inner mask Diameter to degrees
        innerMaskDiamPix = ceil((innerMaskDiameter/degPerPix));
        % construct a grid of inner mask locations so we can set the
        % alpha channel to 0 where the grating should show through the
        % mask (i.e. the circular region defined by the grating
        % diameter
        [inMaskX, inMaskY] = meshgrid(-innerMaskDiamPix/2:...
            innerMaskDiamPix/2);
        % construct the rectangular inner mask, initially it is a
        % square of size innerMaskDiamPix
        innerMask = ones(innerMaskDiamPix+1, innerMaskDiamPix+1,2)...
            *grayPix;
        % set the alpha channel in the circle to be 0 so the center
        % grating shows through
        innerMask(:,:,2) = 255*(1-(inMaskX.^2+inMaskY.^2 <=...
            (innerMaskDiamPix/2)^2));
        
        % Construct the mask
        innerMaskTex{trial} = Screen('MakeTexture', w, innerMask);

    %%%%%%%%%%%%%%% OBTAIN GRATING PARAMS FROM TRIALSSTRUCT %%%%%%%%%%%%%%%
    % To draw each texture, we will need the temporal frequencies and the
    % orientations of the inner and outer gratings and construct rectangles
    % to draw the textures to.

    % Get the parameters for drawing the both the center and surround
    % gratings
    surrTempFreq = 3;
    centerTempFreq = 3;
    %surrOrientation = trials(trial).Surround_Orientation;
    centerOrientation = trials(trial).Center_Orientation;
    
    % calculate amount to shift the gratings with each screen update
    surrShiftPerFrame= ...
        surrTempFreq * surrPxPerCycle * ifiDuration;
    
    centerShiftPerFrame= ...
        centerTempFreq * centerPxPerCycle * ifiDuration;
    
    % Calculate the destination rectangles. We will need the x y
    % location of the grating from the first trial and we will need the
    % size of the screen so that the grating center will be referenced
    % to the screen center. So when the user slects x = 20 degs and y
    % =0 degs the grating will shift from the center of the screen
    % twenty degrees to the right. Note that the y positive direction
    % is downwards along screen so the y position has a negative sign
    % to reverse this Now +y moves grating up. Remenber degrees must be
    % converted to pixels
    x = 0+...
        monitorInfo.screenSizePixX/2;
    y = 0+...
        monitorInfo.screenSizePixY/2;
    
    % create destination rectangle for the surround (size of grating)
    surrDstRect = [0 0 visibleSize visibleSize];
    % create destination rectangle for the center
    centerDstRect=[0 0 centerDiamPix+1 centerDiamPix+1];
    
    % center each dstRect about user selected x,y coordinate
    surrDstRect=centerRectOnPoint(surrDstRect,x,y);
    centerDstRect=centerRectOnPoint(centerDstRect,x,y);
    
    % create a destination rectanlge for the mask
    maskDstRect = [0 0 maskDiamPix maskDiamPix];
    
    % center the maskDstRect to the x,y location
    maskDstRect=centerRectOnPoint(maskDstRect,x,y);
    
    % Note we do not need to specify the inner mask dst rect becasue
    % the inner mask will be drawn to the same rectangle as the center
    % grating
        
    %%%%%%%%%%%%%%%%%%%%%%% PARALLEL PORT TRIGGER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% After constructing the stimulus texture we are now ready to trigger the 
% parallel port and begin our draw to the screen. This function
% is located in the stimGen helper functions directory.
if trials(trial).Output_trigger == 1
    daq_out_trigger;
end

        

    %%%%%%%%%%%%%%%% WAIT FOR EXTERNAL TRIGGER
%    This function is located in the stimGen helper functions directory.
    if trials(trial).External_trigger == 1
        waitfordaq;
    end
    
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%% DRAW TEXTURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % In DRAW TEXTURES, we will obtain specific parameters such as the
    % orientation etc for each trial in the trials struct. We will then
    % draw an initial gray screen persisting for a time called delay. This
    % screen will then be followed by the center surround stimulus composed
    % of overlaying all the above defined textures The sum time of these
    % presentations will equal the stimulus duration (e.g. if duration is 3
    % secs, each grating condition will appear for 1-sec). Following the
    % different grating conditions a gray screen will be shown persisting
    % for a time called wait
    
    %%%%%%%%%%%%%%%%%%%% DRAW DELAY GRAY SCREEN %%%%%%%%%%%%%%%%%%%%%%%%%%%      
    % DEVELOPER NOTE: Prior versions of stimuli used the func WaitSecs to
    % draw gray screens. This is a bad practice because the function sleeps
    % the matlab thread making the computer unresponsive to KbCheck clicks.
    % In addition PTB only guarantees the accuracy of WaitSecs to the
    % millisecond scale whereas VBL timestamps described below uses
    % GetSecs() a highly accurate submillisecond estimate of the system
    % time. All times should be referenced to this estimate for better
    % accuracy.
    
    % We start by performing an initial screen flip using Screen, we return
    % back a time called vbl. This value is a high precision time estimate
    % of when the graphics card performed a buffer swap. This time is what
    % all of our times will be referenced to. More details at
    % http://psychtoolbox.org/FaqFlipTimestamps
        vbl=Screen('Flip', w);
    
    % The first time element of the stimulus is the delay from trigger
    % onset to stimulus onset
        delayTime = vbl + delay;
        
    % Display a gray screen while the vbl is less than delay time. NOTE
    % we are going to add 0.5*ifi to the vbl to give us some headroom
    % to take possible timing jitter or roundoff-errors into account.
        while (vbl < delayTime)
            % Draw a gray screen
            Screen('FillRect', w,grayPix);
            
            % update the vbl timestamp and provide headroom for jitters
            vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
            
            % exit the while loop and flag to one if user presses any key
            if KbCheck
                exitLoop=1;
                break;
            end
        end
        
     %%%%%%%%%%%%%%%%%%%% DRAW CENTER-SURROUND STIMULUS %%%%%%%%%%%%%%%%%%%
     % If the trial is a blank then we do not need worry about all the
     % drawings of the textures, otherwise we must calculate the grating
     % shifts for each draw loop for each grating (since they may have
     % different spatial and temporal frequencies) and draw them
     vbl=Screen('Flip', w);
     
     % Set the runtime of each trial by adding duration to vbl time
     runtime = vbl + duration;
     
     while (vbl < runtime)
         % calculate the offset of the grating and use the mod func
         % to ensure the grating snaps back once the border is
         % reached
         surrXOffset = mod(n*surrShiftPerFrame,surrPxPerCycle);
         % calculate the same offset for the center grating
         centerXOffset = mod(n*centerShiftPerFrame,...
             centerPxPerCycle);
         n = n+1;
         
         %%%%%% SET ALL SRC RECTANGLES TO EXCISE TEXS FROM %%%%%%%%%
         
         surrSrcRect = [surrXOffset 0 ...
             surrXOffset+visibleSize+1 visibleSize+1];
         
         centerSrcRect = [centerXOffset 0 ...
             centerXOffset+centerDiamPix+1 centerDiamPix+1];
         
         maskSrcRect = [0 0 maskDiamPix+1 maskDiamPix+1];
         
         innerMaskSrcRect = [0 0 centerDiamPix+1 centerDiamPix+1];
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
      %%%%%%%%%%%%%%%%%%%%% DRAW EACH TEXTURE %%%%%%%%%%%%%%%%%%%
      switch trials(trial).Condition
          
          case 'centerAlone'
                Screen('DrawTextures', w, centerGratingTex{trial},...
                centerSrcRect, centerDstRect, centerOrientation);
      
                Screen('DrawTextures', w, innerMaskTex{trial},...
                innerMaskSrcRect, centerDstRect, centerOrientation);
            
          case 'iso'
                Screen('DrawTextures', w, surroundGratingTex{trial},...
                surrSrcRect,surrDstRect, centerOrientation);
      
                Screen('DrawTextures', w, maskTex{trial}, maskSrcRect,...
                maskDstRect, centerOrientation);
      
                Screen('DrawTextures', w, centerGratingTex{trial},...
                centerSrcRect, centerDstRect, centerOrientation);
      
                Screen('DrawTextures', w, innerMaskTex{trial},...
                innerMaskSrcRect, centerDstRect, centerOrientation);
            
          case 'cross1'
                Screen('DrawTextures', w, surroundGratingTex{trial},...
                surrSrcRect,surrDstRect, centerOrientation+90);
      
                Screen('DrawTextures', w, maskTex{trial}, maskSrcRect,...
                maskDstRect, centerOrientation);
      
                Screen('DrawTextures', w, centerGratingTex{trial},...
                centerSrcRect, centerDstRect, centerOrientation);
      
                Screen('DrawTextures', w, innerMaskTex{trial},...
                innerMaskSrcRect, centerDstRect, centerOrientation+90);
          
          case 'cross2'
                Screen('DrawTextures', w, surroundGratingTex{trial},...
                surrSrcRect,surrDstRect, centerOrientation-90);
      
                Screen('DrawTextures', w, maskTex{trial}, maskSrcRect,...
                maskDstRect, centerOrientation);
      
                Screen('DrawTextures', w, centerGratingTex{trial},...
                centerSrcRect, centerDstRect, centerOrientation);
      
                Screen('DrawTextures', w, innerMaskTex{trial},...
                innerMaskSrcRect, centerDstRect, centerOrientation-90);
            
          case 'surroundAlone'
                Screen('DrawTextures', w, surroundGratingTex{trial},...
                surrSrcRect,surrDstRect, centerOrientation);
            
                Screen('DrawTextures', w, maskTex{trial}, maskSrcRect,...
                maskDstRect, centerOrientation);
            
      end % end of switch
      
      % Draw a box at the bottom right of the screen to record
                % all screen flips using a photodiode. Please see the file
                % FlipCheck.m in the stimulus directory for further
                % explanation
                FlipCheck(w, screenRect, [whitePix, blackPix], n)
                
                % update the vbl timestamp and provide headroom for jitters
                vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
                
                % exit the while loop and flag to one if user presses any
                % key
                if KbCheck
                    exitLoop=1;
                    break;
                end
     end
      %%%%%%%%%%%%%%%%%%%%% DRAW INTERSTIMULUS GRAY SCREEN %%%%%%%%%%%%%%
        % Between trials we want to draw a gray screen for a time of wait
        
        % Flip the screen and collect the time of the flip
        vbl=Screen('Flip', w);
        
        % We will loop until delay time referenced to the flip time
        waitTime = vbl + wait;
        % 
        while (vbl < waitTime)
            % Draw a gray screen
            Screen('FillRect', w,grayPix);
            
            % update the vbl timestamp and provide headroom for jitters
            vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
            
            % exit the while loop and flag to one if user presses any key
            if KbCheck
                exitLoop=1;
                break;
            end
        end
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % IMPORTANT YOU MUST CLOSE EACH TEXTURE IN THE LOOP OTHERWISE THESE
    % OBJECTS WILL REMAIN IN MEMORY FOR SOME TIME AND ULTIMATELY LEAD TO
    % JAVA OUT OF MEMORY ERRORS!!!
    Screen('Close', centerGratingTex{trial})
    Screen('Close', surroundGratingTex{trial})
    Screen('Close', maskTex{trial})
    Screen('Close', innerMaskTex{trial})
      
    end
   % Restore normal priority scheduling in case something else was set
    % before:
    %%Priority(0);
	
	%The same commands wich close onscreen and offscreen windows also close
	%textures.
	Screen('CloseAll');
    
catch 
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    Priority(0);
    psychrethrow(psychlasterror);
end   
    