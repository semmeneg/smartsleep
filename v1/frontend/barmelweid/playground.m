% 
% % x = 1:8;
% % v = [1,10,10,10,10,5,5,5];
% % xq = 1:7/3:8;
% % vq2 = interp1(x,v,xq);
% % disp(vq2);
% % plot(x,v,'o',xq,vq2,':.');
% 
% str = 'Type,Counter,Timestamp,Quality,Value05,Value06,Value07,Value08,Value09,Value10,Value11,Value12,Value13,Value14';
% vars = regexp(str, ',', 'split');
% disp(cell2mat(vars));
% timestampHeaderColumnIdx = find(cell2mat(vars) == 'Timestamp');
% 
% t = table([11;11;12;11],[1;4;2;3],[1;4;2;3],[1;4;2;3]);
% disp(t);
% t = table2array(t);
% disp(t);
% % t = table([18,143,'2016/09/22 10:18:15','',23,7,38,3,'','','',''], ...
% % [11,4212226,'2016/09/22 04:20:47','',164,7521,11606,11019,-160,-4368,464,''], ...
% % [11,4212227,'2016/09/22 04:20:47','',159,7531,11598,11020,-160,-4336,400,'']);
% 
% types= [11,10];
% disp(t(~ismember(t(:,1),types),:));
%     
% % types= [11,10];
% % t[11;4]
% % t(t(:,1) == type,:) = [];
% % 
% % disp(t);


 suite = BiovotionCsvReaderTest;
 suite.run();

% a=2:2:20;
% idx = find(a);
% disp(a)
% disp(idx)
% assumedSamples = 20;
% actualSamples = length(idx);
% interpIdx = 1:actualSamples/assumedSamples:length(idx);
% disp(interpIdx)
% b = interp1(idx,a,interpIdx);
% disp('outcome:')
% disp(b)



