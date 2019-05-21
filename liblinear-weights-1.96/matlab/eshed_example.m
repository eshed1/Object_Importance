%per-instance weight. Check next. Almost there. Can also try to do this
%with the other matlab code that ignores 2 and 3. try that. Also try with
%and without rescale. Finish this. see 

tic
model = train(ones(size(l_tr_sw,1),1),l_tr_sw(:,1),sparse(double(d_tr_sw)),['-s 0 -c .1 -B 1']); %0.1 is good
toc
%%
