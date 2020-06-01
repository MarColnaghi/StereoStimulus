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
function table  = StimGenDefaultTable( stimType )
%This function generates the default values in the StimGen gui table. Each
%stimulus type has its own default table. These defaults are stored into a
%cell array so they can easily be placed into the gui's table. As the user
%scolls through the stimTypes in the stimtype box of the gui, these tables
% will appear. NOTE: The order of the parameters matters. If a stimulus is
% NOT randomized parameters that are lower in the table will be varied
% first. For example if you run FF gratings at 2 contrast and 12
% orientaions the orientation will cycle then the contrast will cycle.

% store default values to a cell array
switch stimType
   
    case 'Full-field Flash'
       table = {'Delay Shade',128, [], [];...
             'Duration Shade', 255, [], [];...
             'Wait Shade', 128, [], [];...
             'Timing (delay,duration,wait) (s)', 1, 2, 1;...
             'Repeats', 0, [], [];...
             'Initialization Screen (s)', 5, [], [];...
             'External trigger', 0, [], [];...
             'Output trigger', 0, [], []};
         
    case 'Radially Moving Bar'
        table = {'Screen Luminance (0-100%)', 50, 10, 50;...
              'Bar Luminance (0-100%)', 0, 10, 0;...
              'Width (degs)', 5, 1, 5;...
              'Length (degs)', 30, 1, 30;...  
              'Speed (degs/sec)', 10, 1, 10;...
              'Orientation', 0, 30, 330;...
              'Timing (delay,wait) (s)', 1, 1, [];...
              'Blank', 0, [], []; 
              'Randomize', 0, [], [];...
              'Interleave', 0, [], [];...
              'Repeats', 0, [], [];...
              'Initialization Screen (s)', 5, [], [];...
              'External trigger', 0, [], [];...
              'Output trigger', 0, [], []};
        
    case 'Receptive Field Mapping'
        table = {'N Grid Locations x', 8, [], [];...
             'N Grid Locations y', 8, [], [];...
             'Dimensions (degrees)', 5, [], [];...
             'Timing (delay,duration,wait) (s)', 0.1, 1 , 0.1;...
             'ON_OFF', 1, [], [];...
             'Repeats', 1, [], [];...
             'Initialization Screen (s)', 5, [],[];...
             'Output trigger', 0, [], [];...
             'External trigger', 0, [], []};
        
    case 'Full-field Drifting Grating'
        table = {'Spatial Frequency (cpd)', 0.04, .04, 0.04;...
              'Temporal Frequency (cps)', 3, 1, 3;...
              'Contrast (base,exp_1,exp_2)', 2, 7, 7;...
              'Orientation', 0, 30, 330;...
              'Timing (delay,duration,wait) (s)', 1, 2, 1;...
              'Blank', 1, [], [];... 
              'Randomize', 1, [], [];...
              'Interleave', 0, [], [];...
              'Interleave Timing', 1, 2, 10;...
              'Repeats', 0, [], [];...
              'Initialization Screen (s)', 5, [], [];...
              'External trigger', 0, [], [];...
              'Output trigger', 0, [], []};
          
%           table = {'Spatial Frequency (cpd)', 0.04, .04, 0.04;...
%               'Temporal Frequency (cps)', 3, 1, 3;...
%               'Contrast (base,exp_1,exp_2)', 2, 7, 7;...
%               'Orientation', 0, 30, 330;...
%               'Timing (delay,duration,wait) (s)', 1, 2, 1;...
%               'Blank', 1, [], [];... 
%               'Randomize', 1, [], [];...
%               'Interleave', 0, [], [];...
%               'Interleave Timing', 1, 2, 10;...
%               'Repeats', 0, [], [];...
%               'Initialization Screen (s)', 5, [], []};
          
    case 'Masked Grating'
         table = {'Spatial Frequency (cpd)', 0.04, .04, 0.04;...
              'Temporal Frequency (cps)', 3, 1, 3;...
              'Diameter (deg)', 5, 3, 32;...
              'Contrast (base,exp_1,exp_2)', 2, 7, 7;...
              'Orientation', 270, 30, 270;...
              'Mask Center (degs)', 0, 0, [];...
              'Mask Type (Sq, Circ, Gauss)', 'Circular',[],[];...
              'Timing (delay,duration,wait) (s)', 1, 2, 1;...
              'Blank', 0, [], [];...
              'Randomize', 1, [], [];...
              'Interleave', 0, [], [];...
              'Interleave Timing', 1, 2, 1;...
              'Repeats', 0, [], [];...
              'Initialization Screen (s)', 3, [], [];...
              'External trigger', 0, [], [];...
              'Output trigger', 0, [], []};
          
    case 'Annular Center-surround Grating'
        table = {'Surround Spatial Frequency (cpd)', 0.04, .04, 0.04;...
              'Center Spatial Frequency (cpd)', 0.04, .04, 0.04;...
              'Surround Temporal Frequency (cps)', 3, 1, 3;...
              'Center Temporal Frequency (cps)', 3, 1, 3;...
              'Center Grating Diameter (deg)', 15, [], [];
              'Surround Diameter (deg)', 25, [], [];
              'Surround Contrast', 1, 1, 1;...
              'Center Contrast', 1, 1, 1;...
              'Center Orientation', 180, 45, 315 ;...
              'Surround Condition', 1, 1, 5;...
              'Stimulus Center (degs)', 0, 0, [];...
              'Timing (delay,duration,wait) (s)', 1, 2, 2;...
              'Blank', 0, [], [];... 
              'Randomize', 1, [], [];...
              'Interleave', 1, [], [];
              'Repeats', 0, [], [];...
              'Initialization Screen',2,[],[];...
              'Interleave Timing',1, 2, 2;...
              'External trigger', 0, [], [];...
              'Output trigger', 0, [], []};
          
    case 'Simple Center-surround Grating'
        table = {'Surround Spatial Frequency (cpd)', 0.04, .04, 0.04;...
              'Center Spatial Frequency (cpd)', 0.04, .04, 0.04;...
              'Surround Temporal Frequency (cps)', 3, 1, 3;...
              'Center Temporal Frequency (cps)', 3, 1, 3;...
              'Mask Outer Diameter (deg)', 30, 1, 30;...
              'Center Grating Diameter (deg)', 30, [], [];
              'Surround Contrast', 1, 1, 1;...
              'Center Contrast', 1, 1, 1;...
              'Center Orientation', 270, 45, 270;...
              'Surround Condition', 1, 1, 5;...
              'Stimulus Center (degs)', 0, 0, [];...
              'Timing (delay,duration,wait) (s)', 1, 2, 1;...
              'Blank', 0, [], [];... 
              'Randomize', 0, [], [];...
              'Interleave', 0, [], [];
              'Interleave Timing',1, 2, 10
              'Repeats', 0, [], [];...
              'Initialization Screen',2,[],[];...
              'External trigger', 0, [], [];...
              'Output trigger', 0, [], []};
          
    case 'Gauss Simple Center-surround Grating'
        table = {'Surround Spatial Frequency (cpd)', 0.04, .04, 0.04;...
            'Center Spatial Frequency (cpd)', 0.04, .04, 0.04;...
            'Surround Temporal Frequency (cps)', 3, 1, 3;...
            'Center Temporal Frequency (cps)', 3, 1, 3;...
            'Mask Outer Diameter (deg)', 25, 1, 25;...
            'Outer Gaussian Mask FWHM (deg)', 5, [], [];...
            'Inner Gaussian Mask FWHM (deg)', 5, [],[];...
            'Center Grating Diameter (deg)', 25, [], [];
            'Surround Contrast', 1, 1, 1;...
            'Center Contrast', 1, 1, 1;...
            'Center Orientation', 0, 45, 315;...
            'Surround Condition', 1, 1, 5;...
            'Stimulus Center (degs)', 0, 0, [];...
            'Timing (delay,duration,wait) (s)', 1, 1, 2;...
            'Blank', 1, [], [];...
            'Randomize', 1, [], [];...
            'Interleave', 0, [], [];
            'Interleave Timing', 1, 2, 10;...
            'Repeats', 0, [], [];...
            'Initialization Screen (s)', 5, [], [];...
            'External trigger', 0, [], [];...
            'Output trigger', 0, [], []};
          
    case 'Gridded Grating'
          table = {'Rows', 1, 1, 3;...
              'Columns', 1, 1, 3;...
              'Spatial Frequency (cpd)', .04, .04, .04;...
              'Temporal Frequency (cps)', 3, 1, 3;...
              'Contrast (base,exp_1, exp_2)', 2, 7, 7;...
              'Orientation', 270, 270, 270 ;...
              'Timing (delay,duration,wait) (s)', 2, 4, 2;...
              'Blank', 0, [], [];...
              'Randomize', 0, [], [];...
              'Interleave', 0, [], [];...
              'Repeats', 0, [], [];...
              'Initialization Screen (s)', 5, [], [];...
              'External trigger', 0, [], [];...
              'Output trigger', 0, [], []};
          
    case 'Mouse Controlled Dot'
        table = {'Background Shade', 255, [], [];...
                'Dot Shade', 0, [], [];...
                'Initial Dot Radius (degs)', 2, [], []};
         
    case 'Mouse Controlled Grating'
        table = {'Background Shade', 127, [], [];...
             'Initial Grating Diameter (degs)', 20, [], [];...
             'Initial Grating Angle (degs)', 0, [], [];...
             'Spatial Frequency (cpd)', .08, [], []};
         
    case 'Mouse Controlled Bar'
         table = {'Background Shade', 255, [], [];...
            'Bar Shade', 0, [], [];...
            'Bar Width (degs)', 7, [], [];...
            'Bar Height (degs)', 50, [], [];...
            'Bar Orientation (degs)', 0, [], []};
         
    case 'Single Angle CS'
        table = {'Mask Diameter (deg)', 80, [], [];...
              'Center Grating Diameter (deg)', 30, [], [];
              'Center Orientation', 0, [], [];...
              'Timing (delay,duration,wait) (s)', 1, 2, 1;...
              'Randomize', 1, [], [];...
              'External trigger', 0, [], [];...
              'Output trigger', 0, [], []};
          
    case 'Stereo Bar noRotation'
        table = {'Height', 320, [], [];...
            'Width', 140, [], [];
            'Number of dots', 20000, [], [];...
            'Size of dots', 1, [], [];...
            'Timing (Delay,Duration,Wait) (s)', 2, 2, 2;...
            'Speed', -2, 1, 2;...
            'Orientation',1, -1, 0;
            'Displacement', 7, [], [];...
            'Randomize', 1, [], [];...
            'Interleave', 0, [], [];...
            'Blank', 0, [],[];...
            'Repeats', 1, [], [];...
            'Eyes', 1, 1, 4;...
            'Initialization Screen (s)', 3, [], []};
end
