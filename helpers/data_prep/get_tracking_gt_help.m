function [tracklets,trackletsbyids,dcboxes] = get_tracking_gt_help(seq_idx,root_dir,calib_dir,prm);
%%

%TAKES A SEQUENCE INDEX AND RETURNS THE TRACKLETS
dcboxes = [];
trackletsbyids = []; %Returns not by frame, but by tracklet...
out = [];
% options
data_set = 'training';

% set camera
cam = 2; % 2 = left color camera

% show data for tracking sequences
nsequences = numel(dir(fullfile(root_dir,data_set, sprintf('image_%02d',cam))))-2;
%seq_idx=0;
% get sub-directories
image_dir = fullfile(root_dir,data_set, sprintf('image_%02d/%04d',cam, seq_idx));
label_dir = fullfile(root_dir,data_set, sprintf('label_%02d/',cam));
%calib_dir = fullfile(root_dir,data_set, 'calib');
P = readCalibration(calib_dir,seq_idx,cam);

% get number of images for this dataset
nimages = length(dir(fullfile(image_dir, '*.png')));

% load labels
tracklets = readLabels(label_dir, seq_idx);

%Save. already has all values. these ones take priority over raw. do next.
alltracks=[tracklets{:}];
trackletsbyids = cell(1,1+max([alltracks.id]));  %0-bsaed to 1-based

for it = 1:numel(tracklets)
    
    for obj_idx=1:numel(tracklets{it})
         tempabsvel = -1000; %Default value, not available...
        
        if(strcmp(tracklets{it}(obj_idx).type,'DontCare'))
            %0-based -> 1-based
            dcboxes = [dcboxes;tracklets{it}(obj_idx).frame tracklets{it}(obj_idx).x1+1 tracklets{it}(obj_idx).y1+1 ...
                tracklets{it}(obj_idx).x2-tracklets{it}(obj_idx).x1 tracklets{it}(obj_idx).y2-tracklets{it}(obj_idx).y1];
            %disp('here');
        else
            currid = tracklets{it}(obj_idx).id+1;
            
            %0-based -> 1-based
            tracklets{it}(obj_idx).x1 = tracklets{it}(obj_idx).x1+1;
            tracklets{it}(obj_idx).x2 = tracklets{it}(obj_idx).x2+1;
            tracklets{it}(obj_idx).y1 = tracklets{it}(obj_idx).y1+1;
            tracklets{it}(obj_idx).y2 = tracklets{it}(obj_idx).y2+1;
            
            %rotation between [-pi,pi] always
            tracklets{it}(obj_idx).ry = wrapToPi(tracklets{it}(obj_idx).ry);
            tracklets{it}(obj_idx).alpha = wrapToPi(tracklets{it}(obj_idx).alpha);
            %%
                trackletsbyids{currid} = [trackletsbyids{currid};tracklets{it}(obj_idx)];
          
    end
 
    end
end

trackletsbyids = trackletsbyids(~cellfun('isempty',trackletsbyids));

%%



end


