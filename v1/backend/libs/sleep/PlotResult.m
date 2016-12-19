function [acc cfmat] = PlotResult(est, true, verbose)
% [acc cfmat] = plotResult(est, true, verbose)
% INPUTS: est: estimated category [Nx1]
%         true: true category [Nx1]
%         vebose: plot est and true in current axes (defaul: true)
%
% OUTPUTS: acc: classification accuracy (scalar)
%          cfmat: confusion matrix [number of categories x number of categories]
%
% Created by Martin Längkvist, 2012

if nargin==2
    verbose=true;
end

est = single(est(:));
true = single(true(:));
acc=sum(est==true)/rows(true);
[cfmat,btemp] = confusionmat(true,est);

if verbose
    hold on;
    stairs(gca, true,'Color','r', 'LineWidth',2)
    stairs(gca, est,'Color','b', 'LineWidth',1)
    axis tight;
    title(['Accuracy: ' num2str(acc)]);
    ylabel('Category'); xlabel('Sample'); legend('True category', 'Estimated category', 'location', 'northeast')
    disp([0 btemp'; btemp cfmat])
    disp([btemp diag(cfmat)./sum(cfmat,2)])
end

end