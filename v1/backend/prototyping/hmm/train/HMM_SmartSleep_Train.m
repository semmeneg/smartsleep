function [ hmm ] = HMM_SmartSleep_Train( trainingSet, MAX_CLUSTER, MAX_GENERATIONS )
%HMM_TRAIN Summary of this function goes here
%   Detailed explanation goes here

    stateNames = [ 1 2 3 4 5 6 ];
    % specifying the TPM in the following order
    % lying, sitting, standing, walking, running, cycling
    tpm = ...
        [ 0.9500 0.0100 0.0400 0.0000 0.0000 0.0000 ; ...
          0.0200 0.8500 0.0900 0.0400 0.0000 0.0000 ; ...
          0.0100 0.1200 0.6300 0.1800 0.0300 0.0300 ; ...
          0.0001 0.0700 0.0700 0.8299 0.0200 0.0100 ; ...
          0.0001 0.0100 0.2200 0.3500 0.4099 0.0100 ; ...
          0.0001 0.0100 0.0500 0.0400 0.0000 0.8999 ];
      
    if ( isempty( find( sum( tpm, 2 ) ~= 1.0 ) ) == false )
        error( 'Each TPM-row MUST sum to 1.0' );
    end

    % generation-counter
    g = 1;

    % the global-best error (over all generations)
    bestError = length( trainingSet.featureLabels ) + 1;
    
    % NOTE: kmeans is a stochastic process which can lead to varying
    % results in multiple runs with same k => repeat search for best k
    % for a given number of generations and select HMM with k which
    % resulted in lowest number of errors
    while ( g <= MAX_GENERATIONS )
        % search for best cluster-size (errors decreases with increasing
        % cluster-size k up until some point, experiments showed that with
        % k = 15 errors are already very low)
        % NOTE: start with at least 3 clusters, below too few
        for k = 3 : MAX_CLUSTER
            % perform clustering on reduced-features using k-means with k
            % clusters. will return a symbol-vector which amounts to the
            % clusters each entry is maped to. C is the centroid-matrix,
            % which is necessary for classification because classification
            % needs to perform clustering too but using the parameters
            % used by training-set
            [ symbolVector, C ] = kmeans( trainingSet.pca.reducedFeatures', k );

            % estimate transition- and emission-probabilities using the
            % symbol-vector, the known labels, symbols and statenames
            [ TRANS, EMIS ] = hmmestimate( symbolVector, ... 
                    trainingSet.featureLabels, ...
                    'Symbols', 1 : k, ...
                    'Statenames', stateNames );
                
            % create clustering-info for classification
            clusteringInfo = struct( 'k', k, 'C', C );

            % create hmm-info for classification
            testHmm = struct( 'tpm', { tpm }, 'trans', { TRANS }, ...
                'emis', { EMIS }, 'stateNames', { stateNames }, ...
                'clustering', { clusteringInfo }, ...
                'pcaMat', { trainingSet.pca.reductionMatrix } );

            % perform classification using the currently trained HMM using
            % the training-set itself. states contains the estimated states
            % and likelihood contains the probability of the given state
            [ states, likelihood ] = HMM_SmartSleep_Classify( testHmm, trainingSet );

            % calculate the total number of misclassification
            errors = sum( abs( states - trainingSet.featureLabels ) ~= 0 );
            
            % only care for currently trained HMM if it performed better
            % and the global best
            if ( errors < bestError )
                hmm = testHmm;
                bestError = errors;
            end
        end

        %g
        g = g + 1;
    end

    fprintf( '%s : selected HMM with k = %d and %d errors(%.2f %%)\n', ...
        trainingSet.info.name, hmm.clustering.k, bestError, ...
        ( 100 * ( bestError / length( trainingSet.featureLabels ) ) ) );
end
