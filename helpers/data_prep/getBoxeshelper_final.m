function out = getBoxeshelper(prm);

%Thresholds for accepting boxes
%MINAREA = 50;
%MINWIDTH = 15;

out = [];
bvis = 0;
if(isfield(prm,'bvis'))
    bvis = prm.bvis;
end

%Loop through and output a struct, with frames and atributes as opposed
%to tracklets array.
cam = 2; % 0-based index
tracklets = prm.tracklets;
veloToCam = prm.veloToCam;
K = prm.K;
Maxtruncation = prm.Maxtruncation;
labelsask = prm.labelsask;
occlusionLevels = prm.occlusionLevels;
minboxheigt = prm.minboxheigt;
base_dir = prm.base_dir;
truncfixdim = prm.truncfixdim;


image_dir = fullfile(base_dir, sprintf('/image_%02d/data', cam));
nimages = (dir(fullfile(image_dir, '*.png')));
%Some bug, some hidden files. Make sure all sizes are greater than some
%value.
remim = [];
for ii=1:length(nimages)
    if(nimages(ii).bytes < 5000); remim = [remim;ii]; end
end
nimages(remim) = [];
nimages = length(nimages);

% LOCAL OBJECT COORDINATE SYSTEM:
%   x -> facing right
%   y -> facing forward
%   z -> facing up
for it = 1:numel(tracklets)
    
    % shortcut for tracklet dimensions
    w = tracklets{it}.w;
    h = tracklets{it}.h;
    l = tracklets{it}.l;
    
    % set bounding box corners
    corners(it).x = [l/2, l/2, -l/2, -l/2, l/2, l/2, -l/2, -l/2]; % front/back
    corners(it).y = [w/2, -w/2, -w/2, w/2, w/2, -w/2, -w/2, w/2]; % left/right
    corners(it).z = [0,0,0,0,h,h,h,h];
    
    % get translation and orientation
    t{it} = [tracklets{it}.poses(1,:); tracklets{it}.poses(2,:); tracklets{it}.poses(3,:)];
    rz{it} = wrapToPi(tracklets{it}.poses(6,:));
    occlusion{it} = tracklets{it}.poses(8,:);
    
    borders{it} = tracklets{it}.poses(13:15,:);
    
    if(isfield(tracklets{it},'ranks'))
        rankings{it} = tracklets{it}.ranks;
    else
        rankings{it} = NaN(1,length(tracklets{it}.poses(8,:))); %-1*ones(1,length(tracklets{it}.poses(8,:)));
    end
end

oxts = loadOxtsliteData(base_dir);

img_idx = 0; bkeepgoing= 1;
centhist = []; %For velocity need history getting that now...
boxhist = [];

for img_num = 0:nimages-1
    imrt = sprintf('%s/%010d.png',image_dir,img_idx);
    img = imread(imrt);
    
    for it = 1:numel(tracklets)
        
        % get relative tracklet frame index (starting at 0 with first appearance;
        % xml data stores poses relative to the first frame where the tracklet appeared)
        pose_idx = img_num-tracklets{it}.first_frame+1; % 0-based => 1-based MATLAB index
        
        % only draw tracklets that are visible in current frame
        if pose_idx<1 || pose_idx>(size(tracklets{it}.poses,2))
            continue;
        end
        
        % compute 3d object rotation in velodyne coordinates
        % VELODYNE COORDINATE SYSTEM:
        %   x -> facing forward
        %   y -> facing left
        %   z -> facing up
        R = [cos(rz{it}(pose_idx)), -sin(rz{it}(pose_idx)), 0;
            sin(rz{it}(pose_idx)),  cos(rz{it}(pose_idx)), 0;
            0,                      0, 1];
        
        % rotate and translate 3D bounding box in velodyne coordinate system
        corners_3D      = R*[corners(it).x;corners(it).y;corners(it).z];
        corners_3D(1,:) = corners_3D(1,:) + t{it}(1,pose_idx);
        corners_3D(2,:) = corners_3D(2,:) + t{it}(2,pose_idx);
        corners_3D(3,:) = corners_3D(3,:) + t{it}(3,pose_idx);
        corners_3D      = (veloToCam{cam+1}*[corners_3D; ones(1,size(corners_3D,2))]);
        
        objectcentroid = mean(corners_3D,2); %X Y Z 1
        objectcentroid(2) = max(corners_3D(2,:)); %ESHED CHANGED! This is how its done in tracking. up/down is max.
        
        centhist{img_num+1,it} = objectcentroid;
        
        %ALSO COLLECT BOUNDING BOX FOR FILTERING WHILE TRUNCATED
        corners_2D     = projectToImage(corners_3D, K);
        
        box.x1 = min(corners_2D(1,:)); box.x2 = max(corners_2D(1,:)); box.y1 = min(corners_2D(2,:)); box.y2 = max(corners_2D(2,:));
        newbox.x1 = max(box.x1,1); newbox.y1 = max(box.y1,1); newbox.x2 = min(size(img,2),box.x2); newbox.y2 = min(box.y2,size(img,1));
        newbbformat = [newbox.x1 newbox.y1 newbox.x2-newbox.x1+1 newbox.y2-newbox.y1+1];
        boxhist{img_num+1,it} = newbbformat;
        
    end
end
%%
%Median filter
N = 5; %5 usually
boxhistfilt = boxhist;
for j=1:size(boxhist,2)
    idxsegments = cellfun(@isempty,boxhist(:,j));
    idxf = find(idxsegments==0);
    idxf2 = find([1;diff(idxf)]>1);
    idxf2 = [idxf(1);idxf2];
    segidx = [idxf2 idxf2+[idxf2(2:end)-1;length(idxf)]-1];
    for i=1:size(segidx,1)
        verytemp = [cat(1,boxhist{segidx(i,1):segidx(i,2),j})];
        verytemp(:,2) = medfilt1(verytemp(:,2),N);
        verytemp(:,4) = medfilt1(verytemp(:,4),N);
        
        %Repopulate
        boxhistfilt(segidx(i,1):segidx(i,2),j) = num2cell(verytemp,2);
    end
end
%%


%%

while bkeepgoing
    % disp(num2str(img_idx));
    % visualization update for next frame
    %visualization('update',image_dir,gh,img_idx,nimages);
    imrt = sprintf('%s/%010d.png',image_dir,img_idx);
    if(exist(imrt,'file')~=2)
        bkeepgoing = 0;
        continue
    end
    
    imrt = sprintf('%s/%010d.png',image_dir,img_idx);
    
    img = imread(imrt);
    % imshow(img);
    % bbApply('draw',boxhist{112,12})
    %%
    
    % compute bounding boxes for visible tracklets
    currbb = []; currtrunc = []; currocc = []; currheight = []; currori = []; currtrack = []; currrank = [];
    currcentroid = []; currtypes = []; type_c = 1; ego_vel = []; currabsvel = []; currborder = []; currids = [];
    totalobjs = 0;
    for it = 1:numel(tracklets)
        
        % get relative tracklet frame index (starting at 0 with first appearance;
        % xml data stores poses relative to the first frame where the tracklet appeared)
        pose_idx = img_idx-tracklets{it}.first_frame+1; % 0-based => 1-based MATLAB index
        
        % only draw tracklets that are visible in current frame
        if pose_idx<1 || pose_idx>(size(tracklets{it}.poses,2))
            continue;
        end
        
        % compute 3d object rotation in velodyne coordinates
        % VELODYNE COORDINATE SYSTEM:
        %   x -> facing forward
        %   y -> facing left
        %   z -> facing up
        R = [cos(rz{it}(pose_idx)), -sin(rz{it}(pose_idx)), 0;
            sin(rz{it}(pose_idx)),  cos(rz{it}(pose_idx)), 0;
            0,                      0, 1];
        
        % rotate and translate 3D bounding box in velodyne coordinate system
        corners_3D      = R*[corners(it).x;corners(it).y;corners(it).z];
        corners_3D(1,:) = corners_3D(1,:) + t{it}(1,pose_idx);
        corners_3D(2,:) = corners_3D(2,:) + t{it}(2,pose_idx);
        corners_3D(3,:) = corners_3D(3,:) + t{it}(3,pose_idx);
        corners_3D      = (veloToCam{cam+1}*[corners_3D; ones(1,size(corners_3D,2))]);
        
        % generate an orientation vector and compute coordinates in velodyneCS
        orientation_3D      = R*[0.0, 0.7*l; 0.0, 0.0; 0.0, 0.0];
        orientation_3D(1,:) = orientation_3D(1,:) + t{it}(1, pose_idx);
        orientation_3D(2,:) = orientation_3D(2,:) + t{it}(2, pose_idx);
        orientation_3D(3,:) = orientation_3D(3,:) + t{it}(3, pose_idx);
        orientation_3D      = (veloToCam{cam+1}*[orientation_3D; ones(1,size(orientation_3D,2))]);
        
        % only draw 3D bounding box for objects in front of the image plane
        %THIS ONE LIMITS SOME TRUNCATED! for now leave it.
        if any(corners_3D(3,:)<0.5) || any(orientation_3D(3,:)<0.5)
            continue;
        end
        totalobjs = totalobjs+1;
        %%
        % project the 3D bounding box into the image plane
        corners_2D     = projectToImage(corners_3D, K);
        orientation_2D = projectToImage(orientation_3D, K);
        linevec = orientation_2D(:,2)-orientation_2D(:,1);
        %theta = atan2(linevec(2),linevec(1)); %atan2 output positive in top quadrant. but kitti is opposite.
        
        %%
        
        %Find ego-object vector. N
        objectcentroid = mean(corners_3D,2); %X Y Z 1
        objectcentroid(2) = max(corners_3D(2,:)); %This is how its done in tracking. up/down is max.
        
        %  centhist{img_idx+1,it} = objectcentroid;
        
        %Compute orientation
        egoori = -atan2(objectcentroid(1),objectcentroid(3));
        %%
        vecori3d = orientation_3D(:,2)-orientation_3D(:,1);
        ryy = -(atan2(vecori3d(3),vecori3d(1))); %gives ry. Next, get alpha. we can do it.
        theta = (ryy+egoori);
        
        ryy = wrapToPi(ryy); theta = wrapToPi(theta);
        
        % compute and draw the 2D bounding box from the 3D box projection
        box.x1 = min(corners_2D(1,:))+1;
        box.x2 = max(corners_2D(1,:))+1;
        box.y1 = min(corners_2D(2,:))+1;
        box.y2 = max(corners_2D(2,:))+1; %0-based
        
        %%%%%%%%% HERE VISUALIZES 3D BOXES occlusion{it}(pose_idx),%%%%%%%%%%%%%%
        % draw3Dmine(corners_2D,face_idx,orientation_2D)
        % text(box.x2,box.y2,num2str(round(theta*100)/100),'color','g','fontsize',18,'fontweight','b');
        % drawBox2D(gh,box,occlusion{it}(pose_idx),tracklets{it}.objectType)
        
        %Only push if suits difficult flag.
        %Compute truncation value
        %Find inclusive box
        newbox.x1 = max(box.x1,1); newbox.y1 = max(box.y1,1);
        newbox.x2 = min(size(img,2),box.x2); newbox.y2 = min(box.y2,size(img,1));
        
        
        newbbformat = [newbox.x1 newbox.y1 newbox.x2-newbox.x1+1 newbox.y2-newbox.y1+1];
        bbformat = [box.x1 box.y1 box.x2-box.x1+1 box.y2-box.y1+1];
        %Areas give truncation value as a % of original size.
        abig = bbApply('area',bbformat);
        asmall = bbApply('area', newbbformat);
        
        %imshow(img);
        %hold on
        %bbApply('draw',newbbformat); bbApply('draw',bbformat,'r');
        %pause
        
        
        truncat = 1-asmall./abig;
        
        if((~iscell(labelsask)) || (sum(strcmp(tracklets{it}.objectType,labelsask))>0))
            %Some boxes are bad in projection... sometimes very truncated (no
            %vehicle there but still box)
            %Used to be newbbformat(4)>300 but remobed that, to allow some
            %very tall ones.... like vans.
            bbarea = newbbformat(3)*newbbformat(4);
            
            %             if(newbbformat(3)>1000 || newbbformat(3) < 1 || newbbformat(4) < 1 || bbarea < MINAREA ...
            %                     || (strcmp(tracklets{it}.objectType,'Pedestrian') && truncat > Maxtruncation.ped) ...
            %                     || (strcmp(tracklets{it}.objectType,'Cyclist') && truncat > Maxtruncation.cyc) ...
            %                     || (strcmp(tracklets{it}.objectType,'Person (sitting)') && truncat > Maxtruncation.ped) ...
            %                     || truncat>Maxtruncation.car ...
            %                     || newbbformat(3) < MINWIDTH ...
            %                     || sum(occlusion{it}(pose_idx)==occlusionLevels)==0  ...
            %                     || newbbformat(4) < minboxheigt)
            
            if(newbbformat(3)>1000)
                %Want to ignore later, but not in all cases... I guess if
                %it's a huge box that was projected bad don't want, but
                %small ones are OK.
                
            else
                %  truncat
                %THIS IS NOT ENABLED USUALLY... some rare cases where the
                %projection is bad at high truncation
                if(truncat>0.55 && img_idx > 0 && ~isempty(boxhist{img_idx,it}) && truncfixdim)
                    %newbbformat
                    %  if(img_idx==182 && it ==20)
                    %      disp('w');
                    %  end
                    bbtocopy = boxhist{img_idx,it}; %Previus. BUG, this was only delaying it by 1, we want to totally fix it...
                    
                    %
                    %Instead of fix the box, as in above, just fix 4 dim.
                    
                    bfiltmode = 1;
                    if(bfiltmode==0)
                        % keep same dimension before truncation
                        newycent = newbbformat(2)+newbbformat(4)/2;
                        newheigt = bbtocopy(4);
                        % newbbformat(2)=round(newycent-newheigt/2); newbbformat(4)=newheigt;
                        newbbformat(2)=bbtocopy(2); newbbformat(4)=bbtocopy(4);
                    else
                        %median filter
                        newbbformat = boxhistfilt{img_idx+1,it};
                    end
                    
                    %Recrop to img
                    newbbformat(2) = max(newbbformat(2),1); ey = newbbformat(2)+newbbformat(4);
                    ey = min(ey,size(img,1)); newbbformat(4) = ey-newbbformat(2);
                    %%
                    %imshow(img); bbApply('draw',boxhist{img_idx+1,it});
                    %bbApply('draw',newbbformat,'r');
                    %bbApply('draw',boxhistfilt{img_idx+1,it},'m');
                    
                    %%
                    %We make sure no more changing next... otherwise it
                    %will read from boxhist instead of the newbb that was
                    %modified. this updates the current frame!
                    boxhist{img_idx+1,it} = newbbformat;
                end
                
                
                currtrunc = [currtrunc;truncat];
                currocc = [currocc;occlusion{it}(pose_idx)];
                currborder = [currborder; borders{it}(:,pose_idx)'];
                currids = [currids;it];
                currbb = [currbb;newbbformat];
                currori = [currori;ryy theta];
                currtrack = [currtrack;it];
                currrank = [currrank; rankings{it}(pose_idx)];
                currcentroid = [currcentroid;objectcentroid(1:3)'];
                currtypes{type_c} = [tracklets{it}.objectType]; type_c=type_c+1;
                
                %Either at middle, beginning, or end
                oneentryonly = (img_idx+2<=size(centhist,1) && img_idx>0 && isempty(centhist{img_idx,it}) && isempty(centhist{img_idx+2,it})) || ...
                    (img_idx ==0 && isempty(centhist{img_idx+2,it})) || ...
                    (img_idx+2>size(centhist,1) && isempty(centhist{img_idx,it}));
                
                
                
                if(oneentryonly)
                    %There are some just for one frame,
                    tempabsvel = [0;0;0;0];
                    %Else we get what we can to compute velocity
                elseif(img_idx ==0) %IMG_IDX is 0 -based. so add 1 to everything! current is img_idx+1
                    tempabsvel = centhist{img_idx+2,it}-centhist{img_idx+1,it}; %0-> take 2nd minus 1
                elseif(img_idx+2>size(centhist,1) || isempty(centhist{img_idx+2,it})) %End of overall sequence
                    tempabsvel = centhist{img_idx+1,it}-centhist{img_idx,it}; %Same as padding...
                else
                    %Keep components for now
                    tempabsvel = centhist{img_idx+2,it}-centhist{img_idx+1,it};
                end
                if(size(tempabsvel,1)>1); tempabsvel= tempabsvel'; end
                if(size(tempabsvel,1)==0); disp('warning!'); pause; end
                
                curVmag = sqrt(sum(tempabsvel.^2));
                curVori = atan(tempabsvel(1)/tempabsvel(3));
                
                
                %currabsvel = [currabsvel;tempabsvel];
                currabsvel = [currabsvel;curVmag curVori];
                
            end
        end
        
        
        vf = oxts{img_idx+1}(9);  vf = mstokmh(vf);
        vl = oxts{img_idx+1}(10); vl = mstokmh(vl);
        vu = oxts{img_idx+1}(11); vu = mstokmh(vu);
        Vmag = sqrt(vf.^2 + vl.^2 + vu.^2);
        Vdir = atan(vf/vl); %ignore 3d, or can proje
        %KMH
        
        
        %Ideally would be struct... but OK for now..
        out{img_idx+1}.currtrunc = currtrunc;
        out{img_idx+1}.currocc = currocc;
        out{img_idx+1}.currbb = currbb;
        out{img_idx+1}.currori = currori;
        out{img_idx+1}.currtrack = currtrack;
        out{img_idx+1}.currrank = currrank;
        out{img_idx+1}.currcentroid = currcentroid;
        out{img_idx+1}.currtypes = currtypes;
        out{img_idx+1}.egovel = repmat([Vmag Vdir],size(currtypes,1),1);
        out{img_idx+1}.currabsvel = currabsvel;
        out{img_idx+1}.currborder = currborder; %added for correction
        out{img_idx+1}.ids = currids;
        
        %%
        % if(size(currori,1)~=totalobjs); disp('not all were collected'); pause; end
        %%
        Ilabs = []; Ibbs = [];
        objlist=[];
        if(bvis)
            imshow(img);bbApply('draw',currbb);
            %Set moderate flag and processing here...
            oripoost = []; bb_c = 1;
            for i_bb = 1:size(currbb,1)
                %Some boxes have <0 width/height. ignore these.
                if(currbb(i_bb,3) >0  && currbb(i_bb,4)>0)
                    %if(currocc(i_bb)==0); colocc = [0 1 0];
                    %elseif(currocc(i_bb)==1); colocc = [1 1 0];
                    %elseif(currocc(i_bb)==2); colocc = [1 0 0];
                    %else colocc = [1 1 1];
                    %end
                    if(currrank(i_bb)==1); colocc = [1 0 0];
                    elseif(currrank(i_bb)==2); colocc = [0.5 1 0];
                    elseif(currrank(i_bb)==3); colocc = [0 1 0];
                    else colocc = [1 1 1];
                    end
                    
                    
                    %%%%%% HERE VISUALIZES 2D BOXES WITH OCCLUSIONG/TRUNCATION %%%%%%
                    bbApply('draw',[currbb(i_bb,:) currrank(i_bb,:)],colocc);
                    %text(currbb(i_bb,1)+currbb(i_bb,3),currbb(i_bb,2)+currbb(i_bb,4),num2str(round(currori(i_bb)*100)/100),'color','g','fontsize',18,'fontweight','b');
                    pause(.05)
                    
                    
                    %             if(currbb(i_bb,4)>minboxheigt && sum(currocc(i_bb)==occlusionLevels) && currtrunc(i_bb) <=Maxtruncation ...
                    %                     && checkOri(currori(i_bb),OrientationLim))
                    %                 Ilabs{bb_c} = sprintf('car%02d',1);
                    %                 stats.bbox = [stats.bbox;currbb(i_bb,:)];
                    %             else
                    %                 Ilabs{bb_c} = 'ig';
                    %             end
                    %             oripoost = [oripoost;currori(i_boxts = loadOxtsliteData(base_dir);b)];
                    %             Ibbs(bb_c,:) = currbb(i_bb,:);
                    %             bb_c=bb_c+1;
                end
            end
        end
        %%
        if(img_idx>=nimages)
            break
        end
        
    end
    img_idx = img_idx+1;
end

