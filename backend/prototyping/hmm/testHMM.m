warning ('off','all');

% maximum number of clusters in k-means
MAX_CLUSTER = 20;
% generations to search for best solution
MAX_GENERATIONS = 10;

if ( 0 == exist( 'hmm_A' ) )
    hmm_A = HMM_SmartSleep_Train( trainingSet_A, MAX_CLUSTER, MAX_GENERATIONS );
end

if ( 0 == exist( 'hmm_B' ) )
    hmm_B = HMM_SmartSleep_Train( trainingSet_B, MAX_CLUSTER, MAX_GENERATIONS );
end

if ( 0 == exist( 'hmm_C' ) )
    hmm_C = HMM_SmartSleep_Train( trainingSet_C, MAX_CLUSTER, MAX_GENERATIONS );
end

if ( 0 == exist( 'hmm_D' ) )
    hmm_D = HMM_SmartSleep_Train( trainingSet_D, MAX_CLUSTER, MAX_GENERATIONS );
end

visualizeHMMErrors( hmm_A, trainingSet_A, trainingSet_A );
visualizeHMMErrors( hmm_A, trainingSet_A, trainingSet_B );
visualizeHMMErrors( hmm_A, trainingSet_A, trainingSet_C );
visualizeHMMErrors( hmm_A, trainingSet_A, trainingSet_D );

visualizeHMMErrors( hmm_B, trainingSet_B, trainingSet_A );
visualizeHMMErrors( hmm_B, trainingSet_B, trainingSet_B );
visualizeHMMErrors( hmm_B, trainingSet_B, trainingSet_C );
visualizeHMMErrors( hmm_B, trainingSet_B, trainingSet_D );
 
visualizeHMMErrors( hmm_C, trainingSet_C, trainingSet_A );
visualizeHMMErrors( hmm_C, trainingSet_C, trainingSet_B );
visualizeHMMErrors( hmm_C, trainingSet_C, trainingSet_C );
visualizeHMMErrors( hmm_C, trainingSet_C, trainingSet_D );

visualizeHMMErrors( hmm_D, trainingSet_D, trainingSet_A );
visualizeHMMErrors( hmm_D, trainingSet_D, trainingSet_B );
visualizeHMMErrors( hmm_D, trainingSet_D, trainingSet_C );
visualizeHMMErrors( hmm_D, trainingSet_D, trainingSet_D );
