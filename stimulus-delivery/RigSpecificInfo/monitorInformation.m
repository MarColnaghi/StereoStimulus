%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%copyright (c) 2012  Matthew Caudill
%
%this program is free software: you can redistribute it and/or modify
%it under the terms of the gnu general public license as published by
%the free software foundation, either version 3 of the license, or
%at your option) any later version.

%this program is distributed in the hope that it will be useful,
%but without any warranty; without even the implied warranty of
%merchantability or fitness for a particular purpose.  see the
%gnu general public license for more details.

%you should have received a copy of the gnu general public license
%along with this program.  if not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file contains all the monitor information for the Two Photon Rig;
% comment out the info according to which monitor you want to use.
% a good place to find monitor info is to look on manufacturer website
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%% AOC Q27P1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
monitorInfo.screenNumber = 0;               % 0 - main screen
monitorInfo.screenDistcm = 20;              % distance from mouse
monitorInfo.screenSizecmX = 59.6;           % screen size X (cm)
monitorInfo.screenSizecmY = 33.5;           % screen size Y (cm)
monitorInfo.screenSizeDegX = 2*atan(monitorInfo.screenSizecmX/2/...
                                monitorInfo.screenDistcm)*180/pi;
monitorInfo.screenSizeDegY = 2*atan(monitorInfo.screenSizecmY/2/...
                                monitorInfo.screenDistcm)*180/pi;
monitorInfo.screenSizePixX = 2560;          % resolution X
monitorInfo.screenSizePixY = 1440;          % resolution Y
monitorInfo.degPerPix = monitorInfo.screenSizeDegX/...
                            monitorInfo.screenSizePixX;                     

monitorInfo.powerLawScaleFactor = .0001801; % find these values from manufacturers
monitorInfo.gamma = 2.2;                    % typical value on windows machines is 2.2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%% GENERIC MONITOR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% monitorInfo.screenNumber = 0;
% monitorInfo.screenDistcm = 25;
% monitorInfo.screenSizecmX = 47.7;          
% monitorInfo.screenSizecmY = 26.8;        
% monitorInfo.screenSizeDegX = 2*atan(monitorInfo.screenSizecmX/2/...
%                                 monitorInfo.screenDistcm)*180/pi;
% monitorInfo.screenSizeDegY = 2*atan(monitorInfo.screenSizecmY/2/...
%                                 monitorInfo.screenDistcm)*180/pi;
% monitorInfo.screenSizePixX = 1920;
% monitorInfo.screenSizePixY = 1080;
% monitorInfo.degPerPix = monitorInfo.screenSizeDegX/...
%                             monitorInfo.screenSizePixX;                     
% 
% monitorInfo.powerLawScaleFactor = .0001801;
% monitorInfo.gamma = 2.386;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



