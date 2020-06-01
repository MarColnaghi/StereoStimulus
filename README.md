# StereoStimulus

StereoStimulus uses [PsychToolBox](http://psychtoolbox.org/) to draw complex stereoscopic stimuli for visual neuroscience experiments. It includes [neuroGit's](https://github.com/mscaudill/neurogit) graphic user interface, providing millisecond-level timing accuracy and the storage of all the parameters of the running experiment. 
Only works with a stereo-compatible Hardware, see Requirements for more detail.

## Stimulus Delivery

Prompt `StimGen` in the command window and select the desired stimulus from the list. Stimulus parameters can be changed directly from the GUI.

**StereoBarNoRotation**

StereoBarNoRotation explois a random dot stereogram (RDS) to present a bar with fixed dimensions (Height and Width) moving along the two main axes. Number and size of dots can be modified accordingly to hardware capacity, as well as displacement difference between the two images. For our experiment's purpose, two servomotors are employed to shut the lenses of the 3D glasses depending on trial type (line 110 to 122 for more information).

## 3D Glasses control
