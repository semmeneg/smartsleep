function [ ] = visualizeWekaPredictions( wekaImport )
%VISUALIZEPREDICTIONS Summary of this function goes here
%   Detailed explanation goes here

    figure;
    
    actualLabels = wekaImport( :, 1 );
    predictedLabels = wekaImport( :, 2 );
    likelihood = wekaImport( :, 3 );
    likelihood( find( isnan( likelihood ) ) ) = 0.0;
    
    %predictedLabels = spuriousFrameDetection( predictedLabels, likelihood  );
    
    errorIdx = find( ( actualLabels - predictedLabels ) ~= 0 );

    likelihoodWithErrors = nan( length( actualLabels ), 1 );
    likelihoodWithErrors( errorIdx ) = likelihood( errorIdx );

    lMin = min( likelihood );
    lMean = mean( likelihood );
    lStd = std( likelihood );
    l3Std = lMean - 3 * lStd;
    
    likelihoodMean = ones( length( actualLabels ), 1 ) * lMean;
    likelihood50Percent = ones( length( actualLabels ), 1 ) * 0.5;
    likelihood3Std = ones( length( actualLabels ), 1 ) * l3Std;
    
    t = 1 : length( actualLabels );

    hold on;
    [ ax, p1, p2 ] = plotyy( t, actualLabels, t, [ likelihood likelihoodMean likelihood50Percent likelihood3Std likelihoodWithErrors ] );
    %ylim( ax(1), [ 1 6.5 ] );
    ylim( ax(2), [ 0 1.0 ] );
    ylabel( ax(1), 'Labels' );
    ylabel( ax(2), 'Likelihood' );

    p1.Color = [ 0.0, 0.0, 1.0 ];
    
    p2( 2 ).LineStyle = '--';
    
    p2( 3 ).LineStyle = '--';
    
    p2( 4 ).LineStyle = '--';
    
    p2( 5 ).LineWidth = 2;
    p2( 5 ).Marker = 'o';
    p2( 5 ).Color = [ 1.0, 0.0, 0.0 ];
    
    %title( 'Actual labels and likelihood marked with errors' );
    legend( 'Labels', 'Likelihood', 'Likelihood mean', 'Likelihood 0.5', 'Likelihood 3 std', 'Errors' );
    
    fprintf( 'minimum likelihood: %.3f\n', lMin );
    fprintf( 'mean likelihood: %.3f\n', lMean );
    fprintf( 'median likelihood: %.3f\n', median( likelihood ) );
    fprintf( 'std likelihood: %.3f\n', std( likelihood ) );
end

