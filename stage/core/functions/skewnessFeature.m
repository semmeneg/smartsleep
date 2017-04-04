function [ scalar ] = skewnessFeature( data, featureInfo )
%SKEWNESS Summary of this function goes here
%   Detailed explanation goes here

    %% !!!! requires Statistics and Machine Learning Toolbox
%     scalar = skewness( data{ 1 } );
    
    
    % try to go with this. To be verified !!!
    x = data;
    scalar =  (sum((x-mean(x)).^3)./length(x)) ./ (var(x,1).^1.5);
end

