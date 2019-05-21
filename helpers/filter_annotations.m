function [gt,thr] = getGt(prm,outvids,metadata)
%FILTERS outvids according to desired label/geometrical properties by
%setting an ignore flag in the bounding box annotation

%removed tram, annotations are not that great.
classes = { {'Car','Van', 'Truck'},... %1
    {'Pedestrian'},... %2
    {'Cyclist'}}; %3


gt = [];  gt_c = 1; igc = 0;
for i_vid = 1:size(outvids,1)
    rankres = outvids(i_vid,:);
    dcboxes = metadata(i_vid).dcboxes;
    %%
    for img_idx=0:length(rankres{1})-1
        %%
        currdcboxes = [];
        if(~isempty(dcboxes))
        currdcboxes = dcboxes(dcboxes(:,1)==img_idx,2:5);
        end
        
        currbb = rankres{end}{img_idx+1}.currbb;
        NBOXES = size(currbb,1);
        
        currtypes = rankres{end}{img_idx+1}.currtypes;
        currocc = rankres{end}{img_idx+1}.currocc;
        currtrunc = rankres{end}{img_idx+1}.currtrunc;
        
        %%
        %Visualize crop to image again
        bvis = 0;
        if(bvis)
        cam = 2;
        image_dir = fullfile(metadata(i_vid).base_dir, sprintf('/image_%02d/data', cam));
        img = imread(sprintf('%s/%010d.png',image_dir,img_idx));
        imshow(img); bbApply('draw',currbb); bbApply('draw',currdcboxes,'r');  %Fix next! almost there. 
        end
        %% importance.
        totalrank = []; %Accumulates over subjects
        for subji=1:length(rankres)
            totalrank= [totalrank rankres{subji}{img_idx+1}.currrank];
        end
        
        notsane = sum(totalrank<1)>0 | sum(totalrank>3)>0;
        if(notsane);
             disp('warning!'); pause;
        end
        
        avgrank = nanmean(totalrank,2);
        avgvote = nanmedian(totalrank,2);
        stdrank = nanstd(totalrank,[],2);
        
        if(any(isnan(avgrank)))
            disp('hh');
        end
        
        %%
        %Conservative vote
        avgvote = ceil(avgvote);
        %
        igflags = zeros(NBOXES,1);
        torem = []; currlabs = [];
        for i_bb = 1:NBOXES
            currclass = -1;
            for i_class = 1:length(classes)
                bfound = 0;
                bposclassidx = strcmp(currtypes(i_bb),classes{i_class});
                bfound = sum(bposclassidx==1)>0;
                if(bfound); currclass = i_class; end
            end
            %%
            currlabs = [currlabs;currclass];
            
            bpos = currclass>-1;
            %big = sum(strcmp(currtypes(i_bb),igclass));
            %%
            %Check with ignore boxes
            if(isempty(currdcboxes)); dcoas = 0; else; dcoas = max(bbGt('compOas',currbb(i_bb,:),currdcboxes,ones(size(currdcboxes,1),1))); end
            %%
            
            %             if(bpos == 0 && big==0)
            %                 %In nonpositive or non-ignore classes? Just remove! False
            %                 %positives!
            %                 torem = [torem;i_bb];
            %             else
            
            bCarTrunc = currclass ==1 && currtrunc(i_bb)>prm.Maxtruncation.car;
            bPedTrunc = currclass ==2 && currtrunc(i_bb)>prm.Maxtruncation.ped;
            bCycTrunc = currclass ==3 && currtrunc(i_bb)>prm.Maxtruncation.cyc;
            bOcc = sum(currocc(i_bb) == prm.occlusionLevels)==0;
            bHigh = currbb(i_bb,4) < prm.minboxheigt;
            bWidth = currbb(i_bb,3) < prm.MINWIDTH;
            bArea = currbb(i_bb,3).*currbb(i_bb,4) < prm.MINAREA; %Probably overly cautios
            bTYPE = currclass == -1;
            
            bDC = dcoas>prm.dcoverlap;
            
            
            
            %if(bIG);
            %    dcoas
            %    igc=igc+1
            %end
                        
            if( bCarTrunc || bPedTrunc || bCycTrunc || bOcc || bHigh || bWidth || bArea || bDC || bTYPE)
                igflags(i_bb)=1;
            end
        end
        %%
        %currbb(torem,:) = [];
        if(~isempty(torem));
            disp('CANT HANDLE'); pause;
        end
        gt{i_vid}{img_idx+1}.bb = [currbb igflags];
        gt{i_vid}{img_idx+1}.lbls = currlabs;
        gt{i_vid}{img_idx+1}.rank = [avgvote avgrank ];
        gt{i_vid}{img_idx+1}.trunc = rankres{end}{img_idx+1}.currtrunc;
        gt{i_vid}{img_idx+1}.occ = rankres{end}{img_idx+1}.currocc;
        gt{i_vid}{img_idx+1}.ori = rankres{end}{img_idx+1}.currori;
        gt{i_vid}{img_idx+1}.trackid = rankres{end}{img_idx+1}.currtrack;
        gt{i_vid}{img_idx+1}.currcentroid = rankres{end}{img_idx+1}.currcentroid;
        gt{i_vid}{img_idx+1}.currabsvel = rankres{end}{img_idx+1}.currabsvel;
        gt{i_vid}{img_idx+1}.egovel = rankres{end}{img_idx+1}.egovel;%repmat(rankres{end}{img_idx+1}.egovel,[size(currbb,1) 1]);
        gt{i_vid}{img_idx+1}.stdrank = [ stdrank];
        
        
        
    end
    
end

end