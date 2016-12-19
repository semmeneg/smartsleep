function [coefs, scores, variances, t2] = PlotPCA(varargin)
% SYNTAX: [coefs, scores, variances, t2] = PlotPCA(E1, ... , En)
% Plots the feature matrix E1 to En in different colors. n<=14. See princomp
% for detailed information about outputs.
%
% EXAMPLE:
% E1 = randn(100,5); E2 = randn(50,5); E3 = randn(5,5);
% [coefs, scores, variances, t2] = PlotPCA(E1, E2, E3)
%
% Created by Martin Längkvist, 2012

colors = {'b.' 'g.' 'r.' 'c.' 'm.' 'y.' 'k.' 'bx' 'gx' 'rx' 'cx' 'mx' 'yx' 'kx'};

E=[];
group=[];
for i=1 : nargin
    E = [E; varargin{i}];
    group = [group; i*ones(size(varargin{i},1),1)];
end

[coefs, scores, variances, t2] = princomp(E);

figure; hold on;
for i = 1 : nargin
    plot3(removerows(scores(:,1),find(group~=i)), removerows(scores(:,2),find(group~=i)), removerows(scores(:,3),find(group~=i)), colors{i},'MarkerSize',5);
end

xlabel('1st Principal Component')
ylabel('2nd Principal Component')
zlabel('3rd Principal Component')
axis tight;

var_percentage = variances./sum(variances);
title(['Variances: ' num2str(var_percentage(1:3)', 2)])

end

