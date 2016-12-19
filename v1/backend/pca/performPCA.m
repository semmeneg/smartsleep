function [ pcaStruct ] = performPCA( featureData )
%PERFORMPCA Summary of this function goes here
%   Detailed explanation goes here

    % create the PCA reduction-matrix to cover 95% of the variance. this
    % matrix is later needed as well for classification as during
    % classification PCA-reduction needs to be performed too but using the
    % matrix of the training-set (otherwise could lead to different matrix)
    VAR_LIMIT = 95.0;
    MIN_DIMENSIONS = 5;
    reductionMat = pcaReductionMat( featureData', VAR_LIMIT, MIN_DIMENSIONS );
    % reduce the features using the reduction-matrix of the PCA
    % NOTE: after reduction we cannot say anything about the MEANING of the
    % reduced features e.g. make assumptions about ranges/clusters/mean,... 
    reducedFeatures = pcaReduce( featureData', reductionMat );

    pcaStruct = struct ( 'reductionMatrix', reductionMat, ...   % the PCA-matrix to multiply the feature-vector with to get the reduced data: transform from high dimension to low dimension
        'minDim', MIN_DIMENSIONS, ...                           % the minimum number of dimensions to be required in the resulting reduced vector
        'varPercent', VAR_LIMIT, ...                            % the limit of variance: add dimensions until this limit has been reached
        'reducedFeatures', reducedFeatures );                   % the actual PCA reduced features: original feature-timeseries are multiplied with reductionMat to retrieve this reduced feature-timeseries
end
