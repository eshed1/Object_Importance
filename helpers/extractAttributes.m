function [allfts,alllabs] = extractAttributes(prm,gt,metadata);
%
IDXtrackid = prm.IDXtrackid; %prm.IDXFORGEO;
net = [];

blabelonly = prm.labelonly;

bgeo = 0; IDXFORGEO = [];
if(isfield(prm,'bgeo') && prm.bgeo.enabled)
    bgeo = 1;
    IDXFORGEO = prm.IDXFORGEO; %For taking features
end

bgeotemporal = 0;
if(isfield(prm,'bgeotemporal') && prm.bgeotemporal.enabled)
    bgeotemporal = 1;
    bTakeBack = prm.bgeotemporal.takeback;
end

cam = prm.cam;
allfts = []; alllabs = [];
%%
for i_vid = 1:length(gt);
    trainfts = cell(1,length(gt{i_vid})); trainlabs = cell(1,length(gt{i_vid}));
    disp( num2str( i_vid))
    %disp('not parfor');
    
    trainmode =1;
    FRAMECOL = cell(1,length(gt{i_vid}));
    FRAMECOLCNN = cell(1,length(gt{i_vid}));
    
    %%
    for img_idx = 0:1:length(gt{i_vid})-1
        base_dir = metadata(i_vid).base_dir;
        image_dir = fullfile(base_dir, sprintf('/image_%02d/data', cam));
        img = imread(sprintf('%s/%010d.png',image_dir,img_idx));
        currgt = gt{i_vid}{img_idx+1};
        %% extract visual features
        allbbs = [];
        allbbs = currgt.bb;
        if(~isempty(allbbs))
            igidx = allbbs(:,5)==1;
            allbbs(igidx,:) = [];
            %x y w h Height, aspectratio, etc... acdmnrst
            %Might have issue here if all igboxes
            %1 2  3      4   5 6   7    8   9     10    11     12     13
            %h ar trunc  occ cent  dist ori vmag  vori  evmag  evori  id
            
            allobjstats = [allbbs(:,4) allbbs(:,4)./allbbs(:,3) currgt.trunc(~igidx) currgt.occ(~igidx)...
                currgt.currcentroid(~igidx,[1 3]) sqrt(sum(currgt.currcentroid(~igidx,:).^2,2)) currgt.ori(~igidx,:) currgt.currabsvel(~igidx,:) currgt.egovel(~igidx,:) currgt.trackid(~igidx,:)];
            FRAMECOL{img_idx+1} = [allobjstats];
        end
        
        tempfts = []; templabs = [];
        for i_bb = 1:size(allbbs,1)
            fts = [];
            if(blabelonly)
                fts = [];
            else
                if(bgeo)
                    fts = [fts allobjstats(i_bb,IDXFORGEO)];
                end
                
                if(bgeotemporal)
                    %Then for each object, extract previous.
                    %Implmented like this for clarity, but not very
                    %efficient
                    
                    currtracklet = allobjstats(i_bb,IDXtrackid);
                    %Next we see how much to take back start with 1.
                    %NOTE! THIS is alread for index, not 0-based
                    
                    for i_back = img_idx:-1:img_idx+1-bTakeBack
                        FRAMESBACK = max(1,i_back); %first index. if 0 => 1. if img_idx = 1 => second idx. want to take 1
                        if(isempty(FRAMECOL{FRAMESBACK})); idxprev = []; else
                            idxprev = find(FRAMECOL{FRAMESBACK}(:,IDXtrackid) == currtracklet); end
                        if(isempty(idxprev))
                            %Replicate - no previous
                            fts = [fts allobjstats(i_bb,IDXFORGEO)];
                        else
                            fts = [fts FRAMECOL{FRAMESBACK}(idxprev,IDXFORGEO)];
                        end
                    end
                    %%
                    
                end
                
                %Just an example...
                %if(bhog)
                %    fts = [fts getfts_hog(img,allbbs(i_bb,:),modelDims)];
                %end
                
                
            end
            
            currlabel = [currgt.lbls(i_bb)];
            currimplabel = currgt.rank(i_bb,1);
            currimpscore = currgt.rank(i_bb,2);
            
            tempfts= [tempfts;fts];
            templabs = [templabs;currlabel allbbs(i_bb,:) 0 i_vid img_idx currimplabel currimpscore];
        end
        %%
        trainfts{img_idx+1} = [tempfts];
        trainlabs{img_idx+1} = [templabs];
    end
    
    allfts{i_vid} = trainfts;
    alllabs{i_vid} = trainlabs;
end


end
