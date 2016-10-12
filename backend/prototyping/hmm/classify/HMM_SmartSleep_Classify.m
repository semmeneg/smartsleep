function [ states, likelihood ] = HMM_SmartSleep_Classify( hmm, testSet )
%HMM_TRAIN Summary of this function goes here
%   Detailed explanation goes here

    reductionMat = hmm.pcaMat;
    % using the matrix of the training-set to perform feature-reduction
    reducedFeatures = pcaReduce( testSet.features', reductionMat );
    
    k = hmm.clustering.k;
    C = hmm.clustering.C;
    % perform clustering using parameters of training-set
    symbolVector = kmeans( reducedFeatures', k, 'MaxIter', 1, 'Start', C );
    
    [ PSTATES, logpseq ] = hmmdecode( symbolVector', hmm.tpm, hmm.emis );
    %estimatesStates  = hmmviterbi( symbolVector', hmm.tpm, hmm.emis );
    
    [ likelihood, states ] = max( PSTATES );

    %states = estimatesStates;
end
