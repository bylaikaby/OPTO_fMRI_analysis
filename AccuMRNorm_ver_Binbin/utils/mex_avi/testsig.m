

adffile = '//Win49/F/DataNeuro/G02.NM1/g02nm1_30_2.adfw';

[nchan,nobs,sampt,obslen] = adf_info(adffile);

t = (1:obslen)*sampt/1000.0;


fprintf('\n reading signals...');
swapsig = adf_read(adffile,0,0);
photsig = adf_read(adffile,0,1);

fprintf('\n cleaning signals...');
% clean swap signal
highLv = max(swapsig(:));
lowLv  = min(swapsig(:));
tmpidx = find(swapsig >= highLv*0.5);
swapsig(:) = 0;  swapsig(tmpidx) = highLv;

% clean phot signal
photmax = max(photsig(:))*0.5;
tmpidx = find(swapsig >= photmax*0.5);
photsig(:) = 0;  photsig(tmpidx) = photmax;


fprintf('\n detecting edges...');
% detect HIGH to LOW edges
swapedge = find([0,diff(swapsig)] < -highLv/2 & swapsig < highLv*0.2);
% make sure edges are far part each other (~5msec).
swapedge = swapedge(find(diff(swapedge) > round(5/sampt)));

% detect LOW to HIGH edges
photedge = find([0,diff(photsig)] > photmax/2 & photsig > photmax*0.5);
% make sure edges are far part each other (~5msec).
photedge = photedge(find(diff(photedge) > round(5/sampt)));

% find the first peak after the swap edge;
fprintf('\n finding frame starts...');
stimT = ones(1,length(swapedge))*-1;
s = 1;
swapedge = [swapedge, swapedge(end)+round(20/sampt)];
tmpT = photedge;
for k=1:length(swapedge)-1,
  tmpi = find(tmpT > swapedge(k));
  if length(tmpi) > 0,
    tmpv = tmpT(tmpi(1));
    if tmpv <= swapedge(k+1),
      stimT(s) = tmpv;
      s = s + 1;
      tmpT = tmpT(tmpi);
    else
      fprintf('no peaks !![%d] ',k);
    end
  else
    fprintf('empty !![%d] ',k);
  end
end

stimT = stimT(find(stimT >= 0))*sampt;





tmpdat = zeros(1,obslen);
tmpdat(swapedge) = highLv;
tmpdat2 = zeros(1,obslen);
tmpdat2(photedge) = highLv;

fprintf('nedges = %d, npeaks = %d\n',length(swapedge),length(photedge));



tsel = (1:500000) + 500000;
figure;

plot(t(tsel),swapsig(tsel),'b');
hold on;
plot(t(tsel),photsig(tsel),'g');
plot(t(tsel),tmpdat(tsel),'r');
plot(t(tsel),tmpdat2(tsel),'black');

