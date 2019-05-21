%Attribute models
%Only for classification/regression of importance experiments

bLOADDATA = 1; %The script is self-contained, but loading the annotations and tracklets is faster

setup_globals
%%
bvisualdataset = 0;
if(bvisualdataset)
    %This generates many figures
    visualize_dataset
end
%%
if(bLOADDATA)
    load('data/kitti_importance.mat','outvids','metadata');
else
    %setup data
    %OUTPUT
    %outvids: NumberOfVideos X NumberOfSubjects, cell array of trackelts with importance annotations per subject,
    %metadata: information about each video, such as name, NumberOfFrames, etc.
    prepare_data
end

%Little data conversation
outvidsnew = [];
for i=1:size(outvids,1)  %Video number
    for j=1:size(outvids,2) %Subject number
        
        %Initialize
        nframes = metadata(i).nframes;
        for tframe = 1:nframes
            tempstruct = struct('currtrunc',[],'currocc',[],'currbb',[],'currori',[],'currrank',[],'currcentroid',[],'currtypes',[],'egovel',[],'currabsvel',[],'currtrack',[]);
            outvidsnew{i,j}{tframe} = tempstruct;
        end
        
        currdata = outvids{i,j};
        for tracki=1:length(currdata)
            for framj = 1:length(currdata{tracki})
                currframe = currdata{tracki}(framj).frame+1;
                outvidsnew{i,j}{currframe}.currtrunc(end+1,1) =  [double(currdata{tracki}(framj).truncation)];
                outvidsnew{i,j}{currframe}.currocc(end+1,1) =  [double(currdata{tracki}(framj).occlusion)];
                outvidsnew{i,j}{currframe}.currbb(end+1,1:4) =  [[currdata{tracki}(framj).x1 currdata{tracki}(framj).y1 currdata{tracki}(framj).x2-currdata{tracki}(framj).x1 currdata{tracki}(framj).y2-currdata{tracki}(framj).y1]];
                outvidsnew{i,j}{currframe}.currori(end+1,1) =  [wrapToPi(currdata{tracki}(framj).alpha)];
                outvidsnew{i,j}{currframe}.currrank(end+1,1) =  [currdata{tracki}(framj).ranks];
                outvidsnew{i,j}{currframe}.currcentroid(end+1,1:3) =  [currdata{tracki}(framj).t]; %This is fine!
                outvidsnew{i,j}{currframe}.currtypes{end+1} = currdata{tracki}(framj).type;
                outvidsnew{i,j}{currframe}.egovel(end+1,1:2) =  [currdata{tracki}(framj).egovel];
                outvidsnew{i,j}{currframe}.currabsvel(end+1,1:2) =  [currdata{tracki}(framj).currabsvel];
                outvidsnew{i,j}{currframe}.currtrack(end+1,1) =  [currdata{tracki}(framj).id];
            end
        end
    end
end

%disp('NOTE! Only for classification/regression experiments! No dont care boxes for these');

outvids = outvidsnew;

if(bLOADDATA)
    load('data/gt.mat','gt','prm');
else
    prm = [];
    prm.minboxheigt = 10; %10; height in pixels
    prm.occlusionLevels = [-1 0 1 2 3 4]; %If any of these are important, we allow
    prm.Maxtruncation.ped = .77; %77; %.75; %These truncation values are the limit of reasonable annotation, beyond may or may not be correct
    prm.Maxtruncation.car = .98;%.98;
    prm.Maxtruncation.cyc = .85;
    prm.dcoverlap = .7; %.5 was too restrictive at times...
    prm.MINAREA = 50;
    prm.MINWIDTH = 15;
    
    gt = filter_annotations(prm,outvids,metadata);
end
%%
%Video visualization
bvisual = 0;
if(bvisual)
    bwrite = 0; %Generates video
    for i_vid = 1    %1:8;
        base_dir = [mainrt '/' vids{i_vid}];
        showvideo(base_dir,calib_dir,outvids(i_vid,:),.01,bwrite);
    end
end

%%
%Also see  for additional example of visualization
%visualize_debug.m
%%
%Extract attribute features

%Attributes type features are referred to as 'geo' due to legacy reasons
%("geometrical" features)
prm.bgeo.enabled = 1;

prm.IDXtrackid = 13; %we put the track ID for each instance in the 13 place of the array
prm.IDXFORGEO = 1:12; % 1-12, is the range of array indcies we use for extracting attributes. For all features can do 1:prm.IDXtrackid-1, or can also do less (whatever attributes you'd like)

prm.bgeotemporal.enabled = 1; %temporal attributes extraction as well (for temporal potential)
prm.bgeotemporal.takeback = 31; %Frames back to take attributes for (for temporal analysis)
prm.labelonly = 0; %no features
prm.cam = 2; %camera in KITTI

if(bLOADDATA)
    load('data/AttributeFeatures.mat','allfts','alllabs');
else
    
    [allfts,alllabs] = extractAttributes(prm,gt,metadata);
    %allfts is 1x8, 8 videos, and each cell length is the same as the number of frames in that video
    %alllabs contain label array  (see extractAttributes), including the median
    %and average importance scores for each instance.
end

%%
%Classify/regress important score and show results

%object types
objmodes =  {'veh','ped','cyc','all'};

%Regularization value
Cval = [100 10 1 0.1 0.01 0.001 0.0001 10^-4 10^-5 10^-6 10^-7 10^-8];

%2-fold validation, these are video indices between 1-8 (8 total videos).
%First is for training, second is for testing.
CVlist = {[8     5     6     3],[ 7     4     2     1];...
    [ 7     4     2     1],[8     5     6     3]};

%Running modes
plotmodes = {'all_attributes_with_temporal_component','individual_attribute_analysis','per_subject_analysis'};
plotmode_i = 1; %SET MODE from "plotmodes" above
disp(['running mode:' plotmodes{plotmode_i}]); pause(2);

prm.objmodes = objmodes;
prm.Cval = Cval;
prm.CVlist = CVlist;
prm.plotmode_i = plotmode_i;

%returns array of performance for different feature combination, c-value,
%etc... If lots of C-values, may take awhile...
if(bLOADDATA)
    if(plotmode_i==1)
        %FORMAT IS
        %evalmoderescollect{ft_i,ci,obj_i,i_user,evalmode+1}
        %feature index, c-value, object-type, 1, classification/regression
        load('data/all_attributes_with_temporal_component.mat','evalRes');
    elseif(plotmode_i==2)
        load('data/Individual_attributes_analysis.mat','evalRes');
    end
else
    %%
    %takes a while, ~60 minutes (many experiments, for each C v, each feature length (over time), etc...)
    tic
    [evalRes] = attributesEval(prm,allfts,alllabs);
    toc
    
    %evalRes{1,4,4,1,1} gives 60.38 mean accuracy over all objects mode
    %(with 4th C value)
end
%%
%RESULTS 

evalmode = 0; %0=classification,1=regression. Regression uses only on objects of high importance MAE 

if(plotmode_i==1)
    results_attributes_overtime(evalmode,evalRes);
elseif(plotmode_i==2)
    results_attributes_individual(evalmode,evalRes);
end
%%
%Visualize PR curves for all 5 methods
pr_visualize