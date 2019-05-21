%this script was used to genreate 'kitti_importance.mat', which contains 'outvids'
%and 'metadata'
setup_globals

%A little complicated, as we are going around between raw data and tracking
%challenge (which contains better annotations, don't care boxes).

outvids = cell(length(vids),length(subjlist));
metadata = [];

%FOR SANITY
discont = 0;
bONLYDCMODE = 1; %LOAD from KITTI-raw, but we load DC boxes from tracking benchmark

%Don't need to change
MAXFRAMES = 20000;
imgskip = 10;
framesexp = [0:imgskip:MAXFRAMES];


for i_vid = 1:length(vids)
    base_dir = [mainrt '/' vids{i_vid}];
    tracklets = readTracklets([base_dir '/tracklet_labels.xml']);
    
    [prm,out] = setup_video_raw(tracklets,base_dir,calib_dir);
    
    [ outfix ] = lr_border( out );
    %%
    
    bdebugvis = 0;
    if(bdebugvis)
        f0 = 0; %0 %0-based
        for frmnum = f0:length(out)-1 %0-based
            close all
            I = imread([base_dir '/image_02/data/' sprintf('%.10d',frmnum) '.png']);
            %outfix{frmnum+1}.truncation
            if(~isempty(out{frmnum+1}))
                out{frmnum+1}.currtrunc
                %out{frmnum+1}.currocc
                
                
                imshow(I); hold on;
                if(~isempty(out{frmnum+1}.currbb))
                    
                    allbbs = out{frmnum+1}.currbb;
                    allbbs(:,3:4) = allbbs(:,3:4)-1; %MUST SUBTRACT 1 OTHERWISE IT MIGHT BE IMAGE SIZE EXACTLY!
                    
                    bbApply('draw',allbbs(:,:));
                end
            end
            
            pause(.3);
        end
    end
    %%
    oxts = loadOxtsliteData(base_dir);
    
    
    seqmap  = vid_to_tracking_map();
    mapidx = strcmp(vids{i_vid},seqmap(:,1));
    outtracking = []; btrackavail = 0; outtracking_byid = []; dcboxes= [];
    
    %GET CORRESPONDING TRACKING SEQUENCE FOR current video
    if(isstr(seqmap{mapidx,2})); trackseq = str2double(seqmap{mapidx,2}); else trackseq = seqmap{mapidx,2}; end
    %%
    bestchoice = outfix;
    if(trackseq==-1)
        disp('INFO NOT AVAILABLE');
    else
        %GET TRACKING Ground Truth
        %root_dir = '/media/nas/Datasets/KITTI/devkit_tracking/';
        
        %Also have it return don't care tracklets... this can be per frame
        %or per tracklet, but no point of per tracklet...
        %prm is passed in to possibly filter out annotations for
        %classification! but currently unused, filtered later
        
        [outtracking,outtracking_byid,dcboxes] = get_tracking_gt_help(trackseq,trackdevkit_dir,calib_dir_kittitrack,prm);
        %%
        tmp = [];
        for i_temp = 1:length(outtracking_byid)
            currval = outtracking_byid{i_temp}(1).frame;
            tmp = [tmp;currval];
        end
        [~,idxtmp] = sort(tmp);
        outtracking_byid=outtracking_byid(idxtmp);
        
        
        
        
        bdebugvis = 0;
        if(bdebugvis)
            f0 = 0; %0 %0-based
            for frmnum = f0 %:length(outtracking)-1 %0-based
                close all
                I = imread([base_dir '/image_02/data/' sprintf('%.10d',frmnum) '.png']);
                %outfix{frmnum+1}.truncation
                if(~isempty(outtracking{frmnum+1}))
                    %  out{frmnum+1}.currtrunc
                    %out{frmnum+1}.currocc
                    cx1 = [outtracking{frmnum+1}.x1]';
                    cy1 = [outtracking{frmnum+1}.y1]';
                    cx2 = [outtracking{frmnum+1}.x2]';
                    cy2 = [outtracking{frmnum+1}.y2]';
                    
                    allbbs = [cx1 cy1 cx2-cx1 cy2-cy1];
                    
                    %%
                    imshow(I); hold on;
                    
                    bbApply('draw',allbbs(:,:));
                end
                
                
                pause(.3);
            end
        end
        
        bdebugvis = 0;
        if(bdebugvis)
            f0 = 0; %0 %0-based
            for frmnum = f0:length(outtracking)-1 %0-based
                close all
                I = imread([base_dir '/image_02/data/' sprintf('%.10d',frmnum) '.png']);
                allbbs = [];
                for jid = 5 %1:length(outtracking_byid)
                    frms = [outtracking_byid{jid}.frame];
                    idxf = []; idxf = find(frms == frmnum);
                    if(~isempty(idxf))
                        cx1 = [outtracking_byid{jid}(idxf).x1]';
                        cy1 = [outtracking_byid{jid}(idxf).y1]';
                        cx2 = [outtracking_byid{jid}(idxf).x2]';
                        cy2 = [outtracking_byid{jid}(idxf).y2]';
                        
                        allbbs = [cx1 cy1 cx2-cx1 cy2-cy1];
                    end
                end
                %%
                currdcboxes = dcboxes(find(dcboxes(:,1)==frmnum),2:5);
                
                
                %  if(~isempty(outtracking{frmnum+1}))
                %  out{frmnum+1}.currtrunc
                
                
                %%
                imshow(I); hold on;
                
                bbApply('draw',allbbs(:,:));
                bbApply('draw',currdcboxes(:,:),'k');
                
                
                pause(1);
            end
        end
        %%
        %Add velocitities and oxts.
        for track_id_v =1:length(outtracking_byid) %outtracking_byid contains no dont care boxes, so can do this
            tempcent = cat(1,outtracking_byid{track_id_v}.t);
            %Compute velocities,
            tempabsvel = []; tempabsvel = diff(tempcent,[],1);
            
            if(isempty(tempabsvel))  %Only one known instance of the tracklet
                tempabsvel = [0 0 0];
            else
                tempabsvel = [tempabsvel(1,:);tempabsvel];
            end
            
            
            for track_inst = 1:length(outtracking_byid{track_id_v}) %Incremens over frames
                %outtracking_byid{track_id_v}(track_inst).currabsvel = tempabsvel(track_inst,:);
                curVmag = sqrt(sum(tempabsvel(track_inst,:).^2));
                curVori = atan(tempabsvel(track_inst,1)/tempabsvel(track_inst,3));
                outtracking_byid{track_id_v}(track_inst).currabsvel = [curVmag curVori];
                
                %Add oxts from raw data
                currframe = outtracking_byid{track_id_v}(track_inst).frame+1; %0-based -> 1-based
                %outtracking_byid{track_id_v}(track_inst).egovel =
                %outfix{currframe}.egovel;%sometimes raw is empty if no raw
                %tracklets...
                vf = oxts{currframe}(9);  vf = mstokmh(vf);
                vl = oxts{currframe}(10); vl = mstokmh(vl);
                vu = oxts{currframe}(11); vu = mstokmh(vu);
                Vmag = sqrt(vf.^2 + vl.^2 + vu.^2);
                Vdir = atan(vf/vl);
                outtracking_byid{track_id_v}(track_inst).egovel = [Vmag Vdir];
                % if(isempty(outfix{currframe}.egovel))
                %     pause
                % end
            end
        end
        
        
        %%
        bestchoice = outtracking;
        btrackavail = 1;
    end
    %
    
    if(btrackavail)
        tracklets = [ outtracking_byid];
        if(bONLYDCMODE)
            [ tracklets2 ] = convertformat_raw2track( outfix );
            if(length(tracklets)~=length(tracklets2))
                disp('mismatch between tracking and raw'); pause
            else
                tracklets = tracklets2;
            end
        end
    else
        [ tracklets ] = convertformat_raw2track( outfix );
    end
    
    %%
    %sanity - Make sure all tracks are continous...
    for temp_t = 1:length(tracklets)
        tempframes = cat(1,tracklets{temp_t}.frame);
        if(length(tempframes) ~= (tempframes(end)-tempframes(1)+1))
            disp('WARNING!');
            pause
            discont=discont+1
        end
    end
    
    parfor subi = 1:length(subjlist)
        [ temptracklets ] = append_ranking_for_subj(tracklets, subi,subjlist,i_vid,vids,MAXFRAMES,framesexp );
        outvids{i_vid,subi} = temptracklets;
    end
    metadata(i_vid).dcboxes = double(dcboxes);
    metadata(i_vid).video = vids{i_vid};
    metadata(i_vid).btrackavail = btrackavail;
    metadata(i_vid).nframes = length(outfix);
    metadata(i_vid).calib_dir = calib_dir;
    metadata(i_vid).base_dir = base_dir;
    disp(['finished video ' num2str(i_vid)]);
end

