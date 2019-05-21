function run_showvid(base_dir,calib_dir,rankres,pauserate,bwrite)
% KITTI RAW DATA DEVELOPMENT KIT
% 
% This tool displays the images and the object labels for the benchmark and
% provides an entry point for writing your own interface to the data set.
% Before running this tool, set root_dir to the directory where you have
% downloaded the dataset. 'root_dir' must contain the subdirectory
% 'training', which in turn contains 'image_2', 'label_2' and 'calib'.
% For more information about the data format, please look into readme.txt.
%
% Input arguments:
% base_dir .... absolute path to sequence base directory (ends with _sync)
% calib_dir ... absolute path to directory that contains calibration files
%
% Usage:
%   SPACE: next frame
%   '-':   last frame
%   'x':   +10 frames
%   'y':   -10 frames
%   'q':   quit
%
% Occlusion Coding:
%   green:  not occluded
%   yellow: partly occluded
%   red:    fully occluded
%   white:  unknown

% clear and close everything
close all; dbstop error; clc;
disp('======= VIDEO PREVIEW - PAY ATTENTION =======');

% options (modify this to select your sequence)
% the base_dir must contain:
%   - the data directories (image_00, image_01, ..)
%   - the tracklet file (tracklet_labels.xml)
% the calib directory must contain:
%   - calib_cam_to_cam.txt
%   - calib_velo_to_cam.txt
% cameras:
%   - 0 = left grayscale
%   - 1 = right grayscale
%   - 2 = left color
%   - 3 = right color
if nargin<1
  % base_dir = '/mnt/karlsruhe_dataset/2011_09_26/2011_09_26_drive_0009_sync';
  base_dir = '/media/data/kitti/2011_09_26/2011_09_26_drive_0056';
end
if nargin<2
  calib_dir = '/media/data/kitti/2011_09_26';
end
cam = 2; % 0-based index

% get image sub-directory
image_dir = fullfile(base_dir, sprintf('/image_%02d/data', cam));

% get number of images for this dataset
%nimages = length(dir(fullfile(image_dir, '*.png')));
nimages = (dir(fullfile(image_dir, '*.png')));

%Some bug, some hidden files. Make sure all sizes are greater than some
%value. 
remim = [];
for ii=1:length(nimages)
    if(nimages(ii).bytes < 5000); remim = [remim;ii]; end
end
nimages(remim) = [];
nimages = length(nimages);

% set up figure
gh = visualization('init',image_dir);

%bwrite = 1;
if(bwrite)
Z = VideoWriter(['/media/Data/videos/10fps_' num2str(nimages) '_' num2str(round(rand(1)*10000))]);
Z.FrameRate = 10;
open(Z)
end
% main loop (start at first image of sequence)
img_idx = 0;
while img_idx < nimages-1
  
  % visualization update for next frame
  [fghandle,Ivis] = visrank('update',image_dir,gh,img_idx,nimages);
  
  
  %Draw box with importance measure.... 
  totalbbs = []; totalrank = [];totalZ = [];
 
  for subji=1:length(rankres)
       if(~isempty(rankres{subji}{img_idx+1}))
      totalbbs = rankres{subji}{img_idx+1}.currbb;
      totalZ = rankres{subji}{img_idx+1}.currcentroid;
      totalrank= [totalrank rankres{subji}{img_idx+1}.currrank];
       end
  end
  
  %Some may have unavailable annotations. Remove them! Do not overlay. do
  %next.
  %totalrank(totalrank<1) = nan;
  %totalrank(totalrank>3) = 3;
  if(~isempty(totalZ))
  [Zidx,Zval] = sort(totalZ(:,3));
  end
  
  
  if(sum(totalrank<1)>0 | sum(totalrank>3)>0); disp('warning!'); pause; end
  
  
  avgrank = nanmean(totalrank,2);  %Between 1-3.
 
  
  %Patches
  %Next, we plot from green to red. and mix based on average...
  %CHANGED HERE! NOTICE!
  %numadd= 5;
  numadd= 20;
   %interpcolos = [1 0 0;1 0.5 0;0 1 0];
   interpcolos = [1 0 0; 1 0.7961 0; 0 1 0];
   newcols = [];
   for jadd=1:3
   a1 = linspace(interpcolos(1,jadd),interpcolos(2,jadd),numadd);
   a2 = linspace(interpcolos(2,jadd),interpcolos(3,jadd),numadd);
   newcols(:,jadd) = [a1';a2'];
   end
   newcols(:,4) = linspace(1,3,2*numadd);
%    %%
%    figure
%    for xx=1:10
%        plot(xx,xx,'r*','color',newcols(xx,:))
%        hold on
%    end
%    
  %%
  %Permute by depth
  if(~isempty(totalZ))
  totalbbs = totalbbs(Zval,:);
  avgrank = avgrank(Zval,:);
  end
  
  
  Nboxes = size(totalbbs,1); patch_handlec=1;
  for obj_i = 1:Nboxes
      if(~isnan(avgrank(obj_i)))
       tempbb = totalbbs(obj_i,:);
    xs = [tempbb(1)]; xe = tempbb(1)+tempbb(3);
    ys = [tempbb(2)]; ye = tempbb(2)+tempbb(4);
    
    %Clip to image
    xs = max(1,xs);
    ys = max(1,ys);
    xe = min(xe,size(Ivis,2));
    ye = min(ye,size(Ivis,1));
    %sometimes xs after
  if(xs>size(Ivis,2)-1 || ys>size(Ivis,1)-1 || xe<1 || ye<1)
else
    box_x = [xs xs xe xe];
    box_y = [ys ye ye ys];
    [rankval,rankloc] = min(abs(newcols(:,4)-avgrank(obj_i)));
   % patch_handle = patch(box_x,box_y,[1 1 1 1; 1 1 1 1],[newcols(rankloc,1:3)],'facealpha',0.5); 
    patch_handles(patch_handlec) = patch(box_x,box_y,[1 1 1 1],[newcols(rankloc,1:3)],'facealpha',0.15);  %0.2 lower means more transparent
     patch_handlec = patch_handlec+1;
  end
      end
  end
  %%
  %htx = text(size(Ivis,2)-30,0,sprintf('frame %d/%d',img_idx,nimages-1), 'parent', fghandle{1}.axes,'color','g','HorizontalAlignment','right','VerticalAlignment','top','FontSize',14,'FontWeight','bold','BackgroundColor','black', 'Interpreter','none');
   %htx = text(size(Ivis,2)-30,0,sprintf('frame %d/%d',img_idx,nimages-1),'color','g','HorizontalAlignment','right','VerticalAlignment','top','FontSize',14,'FontWeight','bold','BackgroundColor','black', 'Interpreter','none');
   
 %%
  
  if(bwrite)
      writeVideo(Z,getframe);
  end
  
  pause(pauserate);
  
  for i_del = 1:length(patch_handles)
     delete(patch_handles(i_del)); 
  end
 % delete(htx);
  %%
  
img_idx = min(img_idx+1,  nimages-1);
  % force drawing and tiny user interface
  %waitforbuttonpress; 
  %key = get(gcf,'CurrentCharacter');
  %switch lower(key)                         
  %  case 'q',  break;                                 % quit
  %  case '-',  img_idx = max(img_idx-1,  0);          % previous frame
  %  case 'x',  img_idx = min(img_idx+100,nimages-1);  % +100 frames
  %  case 'y',  img_idx = max(img_idx-100,0);          % -100 frames
  %  otherwise, img_idx = min(img_idx+1,  nimages-1);  % next frame
  %end
    
 
end

if(bwrite)
   close(Z); 
end
% clean up
close all;
