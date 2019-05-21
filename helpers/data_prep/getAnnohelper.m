function [ cleanedup ] = getAnnohelper( currname,currsubj,MAXFRAMES,framesexp )
%annotation loader from KITTI
cleanedup = cell(1,MAXFRAMES);

    upc = 0;
    fs = dir([currsubj currname '*']);
    %may have two of these, if there are need to reconcile, give warning.
    %Kepe backups of original always! 
    if(length(fs)>1); disp('twovides error'); pause; end
    

    anno = dlmread([currsubj fs(1).name]);
    
    %Store by frame numbers. leave empty in missing frames. 
    %Frames start from 0.
    
    for inst = 1:size(anno,1)
        %Push in line by line. Detect anything weird, like high overlap
        %stop. Ideally would replace by most recent ones... 
        currfrm = anno(inst,1);
        
        if(sum(currfrm == framesexp)==0)
            disp('warning! Frame offset detected'); pause
        else
        
        currobj = [];
        currobj.id = anno(inst,2);
        currobj.x = anno(inst,3); currobj.y = anno(inst,4); 
        currobj.w = anno(inst,5); currobj.h = anno(inst,6);
        currobj.rank = anno(inst,7);
        
        %Next, before adding, check against existing. Any high overlap?
        %Then need to REPLACE, not correct.
        oas = compOasstruct(currobj,cleanedup{currfrm+1});
        
        [maxval,maxidx] = max(oas,[],2);
        if(maxval>0.999)
            disp('updating!')
            upc=upc+1;
            cleanedup{currfrm+1}(maxidx) = currobj; 
        else
            cleanedup{currfrm+1} = [cleanedup{currfrm+1};currobj];
        end
        end
        %Check if frame is weird number.
    end
    disp(['updated: ' num2str(upc)]);

end

