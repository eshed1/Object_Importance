%First read all annotations, put by struct in each frame
function [prm,out] = setup_video_raw(tracklets,base_dir,calib_dir);
    prm = [];
    prm.minboxheigt = 10; %25; in pixels
    prm.occlusionLevels = [-1 0 1 2 3 4]; %For importance, all are OK. 
    prm.tracklets = tracklets;
    [veloToCam, K] = loadCalibration(calib_dir);
    prm.base_dir= base_dir;
    prm.veloToCam = veloToCam; prm.K = K;
    %prm.Maxtruncation = 1; %0.8
    
    %This looks better. maybe also check 
    prm.Maxtruncation.ped = .77; %77; %.75; %.7; %Continue study these. 
    prm.Maxtruncation.car = .98;%.98;  %NMext tune these. then make sure rest correct. 
    prm.Maxtruncation.cyc = .85; %prm.Maxtruncation.ped;
    prm.labelsask = 1;
    prm.truncfixdim = 0; %Prevents up/down issues during truncation
    out = getBoxeshelper_final(prm); 
    