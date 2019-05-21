%%%%%%%%%%%%%%%%% SET DEPENDENCIES

%SET LOCATION OF KITTI RAW CALIBRATION FILES - comes with this package for
%reprdoucibility, ALL RIGHTS ARE WITH KITTI!
mainrt = 'kitti';
calib_dir = [mainrt '/calib/'];

%We use KITTI tracking devkit, and tracking data
trackdevkit_dir = ['devkit_tracking/'];
calib_dir_kittitrack = ['devkit_tracking/calib/'];

%We use Piotr's Matlab Toolbox for some data handling/visualization
PMTroot = '/home/cvrr/Documents/eshed/toolbox/';

%Use liblinear - comes with this package
LIBLIN = 'liblinear-weights-1.96';

%%%%%%%%%%%%%%%%%%%%%%

vids = {'2011_09_26_drive_0005_sync','2011_09_26_drive_0014_sync','2011_09_26_drive_0032_sync',...
    '2011_09_26_drive_0036_sync','2011_09_26_drive_0051_sync','2011_09_26_drive_0059_sync',...
    '2011_09_26_drive_0084_sync','2011_09_26_drive_0091_sync'};

subjlist = {};
for i=1:18
    subjlist{1,i} = [ 'S' num2str(i) '/']; 
end

addpath(genpath('.'));

if(~exist(PMTroot,'dir'))
    disp('Set Toolbox Dir in setup_globals.m!'); pause;
end
addpath(genpath(PMTroot))



if(~exist(trackdevkit_dir,'dir') || ~exist(calib_dir_kittitrack,'dir'))
    disp('Set tracking Dir in setup_globals.m!'); pause; 
end

addpath([LIBLIN '/' 'matlab']);
