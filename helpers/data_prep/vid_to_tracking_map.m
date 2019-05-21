function out = vid_to_tracking_map();
%MAPS BETWEEN RAW VIDEOS AND TRACKING BENCHMARK NAMING

vids = {'2011_09_26_drive_0005_sync',...
    '2011_09_26_drive_0014_sync',...
    '2011_09_26_drive_0032_sync',...
    '2011_09_26_drive_0036_sync',...
    '2011_09_26_drive_0051_sync',...
    '2011_09_26_drive_0059_sync',...
    '2011_09_26_drive_0084_sync',...
    '2011_09_26_drive_0091_sync'};

tracklist = {'0000',
             '0004',
             '0008',
             '0009',
              -1,   %NOT IN TRACKING CHALLENGE
              '0011',
              -1,   %NOT IN TRACKING CHALLENGE
              '0013'
             }; 
         
out = [vids' tracklist];
end