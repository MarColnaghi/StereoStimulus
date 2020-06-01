# StereoStimulus

StereoStimulus uses [PsychToolBox](http://psychtoolbox.org/) to draw complex stereoscopic stimuli for visual neuroscience experiments. It includes [neuroGit's](https://github.com/mscaudill/neurogit) graphic user interface, providing millisecond-level timing accuracy and the storage of all the parameters of the running experiment. 
Only works with a stereo-compatible Hardware, see Requirements for more detail.

## Stimulus Delivery

Prompt `StimGen` in the command window and select the desired stimulus from the list. Stimulus parameters can be changed directly from the GUI.

**StereoBarNoRotation**

StereoBarNoRotation exploits random dot stereograms (RDS) to effeectively present a rectangular bar with fixed dimensions (Height and Width) moving along the two main axes. Number and size of dots can be modified accordingly to hardware capacity, as well as displacement difference between the two images. For our experiment's purpose, two servomotors are employed to mechanicaly shut the lenses of the 3D glasses depending on trial type (line 110 to 122 for more information).

## 3D Glasses Control
To control [our 3D glasses](http://xpandvision.com/products/xpand-3d-glasses-lite-ir-rf/), we have created an Arduino-based controller. We were able to extract the refresh rate signal from our graphic card's (NVidia Quadro) 3 PIN MINI-DIN to provide the accurate synch to the glasses, which, in turn, repeatedly shut one of the two lenses based on which frame (Left/Right) is displayed.

## Requirements
  Stereo-compatible Graphic Card.
  120Hz Refresh Rate Monitor
  3D IR glasses
