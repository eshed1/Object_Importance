%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Data and code for 

@article{ohnbar_importance_PR,
    Author = {Eshed Ohn-Bar and Mohan M. Trivedi},
    Title = {Are All Objects Equal? Deep Spatio-Temporal Importance Prediction in Driving Videos},
    Journal = {Pattern Recognition},
    Year = {2017}
}

@inproceedings{ohnbar_importance,
title={What Makes an On-road Object Important?},
author={E. Ohn-Bar and M. M. Trivedi},
booktitle={IEEE Intl. Conf. Pattern Recognition}, 
year={2016}
}
(best paper award finalist)


Thank you for your interest and I hope this study is useful to you in some way.
The code was available on my website for the last coupld of years, but I've received requests to put it on github.
If any questions, please don't hesitate to contact me

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Content
--------------------------
- annotations: subject annotations for the importance ranking task
- helpers: a variety of tools used in analysis and demos
- data: some pre-run experiments for reproducibility
- kitti: sequences from the raw benchmark used
- devkit_tracking: tracking dataset, some is used for improved annotations
- liblinear-weights-1.96: liblinear (all rights reserved to them)
- Note: some data files are too large for github, to ensure full reproducibility you may download into the 'data' folder the following
https://drive.google.com/file/d/1oWLGXV2CLC-Xji3CGJIRvNu7gkZyjsrY/view?usp=sharing
--------------------------

Steps
--------------------------
main.m contains a complete classification/regression example, from formatting annotations, 
attribute-based importance prediction, and results visualization.

In order to run it, you will need to set some dependencies in 'setup_globals.m'

To visualize and work with the data, you will also need to download KITTI raw benchmark. You can see the required raw sequences in 'kitti' folder.  You also need the tracking training benchmark, placed in devkit_tracking. Both are used because there are some additional object annotations on the tracking benchmark which we incorporate. The data can be loaded using the provided mat files without the KITTI data, but for visualization and understanding the processing/filtering I recommend downloading the associated KITTI data.






