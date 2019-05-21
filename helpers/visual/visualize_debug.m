%Visualization for debug if needed
close all
for i_vid = 2 %1:8
    currgt = gt{i_vid};
    base_dir = metadata(i_vid).base_dir;
    currdcboxes = metadata(i_vid).dcboxes;
    for frmnum =1:length(currgt) %0-based
        imgidx = frmnum-1;
        I = imread([base_dir '/image_02/data/' sprintf('%.10d',imgidx) '.png']);
        imshow(I);
        currbb = currgt{frmnum}.bb;
        currbb=currbb(currbb(:,3)>1,:);
        igvals = currbb(:,5);
        currnotig = currbb(igvals==0,:);
        currdc = [];
        if(~isempty(currdcboxes))
            currdc = currdcboxes(currdcboxes(:,1)==imgidx,2:5);
        end
        currig = currbb(igvals==1,1:4);
        currdc = [currdc;currig];
        bbApply('draw',currnotig);
        bbApply('draw',currdc,'k');
        pause(.5);
    end
end