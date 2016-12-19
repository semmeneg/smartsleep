function [ ] = visualizeHMMErrors( hmm, trainingData, testData )
%TRAINANDTESTHMM Summary of this function goes here
%   Detailed explanation goes here

    [ states, likelihood ] = HMM_SmartSleep_Classify( hmm, testData );

    % calculate errors
    stateCount = length( states );
    originalLabels = testData.featureLabels;
    delta = abs( originalLabels - states );

    errorLabelsIdx = find( delta ~= 0 );

    errorLabelsVis = nan( stateCount, 1 );
    errorLabelsVis( errorLabelsIdx ) = states( errorLabelsIdx );
    errorLabelsCorrectVis = nan( stateCount, 1 );
    errorLabelsCorrectVis( errorLabelsIdx ) = originalLabels( errorLabelsIdx );

    % calculate and print confusion matrix 
    cm = calcConfusionMat( hmm.stateNames, states, originalLabels );
    fprintf( 'Confusion-Matrix for classifying %s using %s\n', testData.info.name, trainingData.info.name );
    disp( cm );

    % visualize classifications 
    figure;
    t = 1 : stateCount;
    [ ax, p1, p2 ] = plotyy( t, states, t, likelihood );
    ylim( ax(1), [ 0 6.5 ] );
    ylim( ax(2), [ 0 1.0 ] );
    ylabel( ax(1), 'Classified Labels' );
    ylabel( ax(2), 'Likelihood' );

    % plot( states );
    % ylabel( 'Labels' );
    % xlabel( 'Time' );
    % ylim( [ 0.5 6.5 ] );

    % visualize errors
    hold on;
    plot( errorLabelsVis, '-o', 'Color', [ 1.0, 0.0, 0.0 ], 'LineWidth', 1 );
    % visualize 
    hold on; 
    plot( errorLabelsCorrectVis, '-o', 'Color', [ 0.0, 1.0, 0.0 ], 'LineWidth', 1 );

    % add legend & title
    legend( 'Classified Labels', 'Errors', 'Corrected' );
    title( sprintf( 'Classification of %s using HMM trained by %s', ...
        testData.info.name, trainingData.info.name ) );
end

