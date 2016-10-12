function [] = visualizeSteps( dataSet )
%VISUALIZESTEPS Summary of this function goes here
%   Detailed explanation goes here

    sensorIdx = 4;
   
    accelerationData = dataSet.sensors{ 1, sensorIdx }.data( 1 : 3, : );
    sensorLabels = dataSet.labels{ 1, sensorIdx };
    
    [ magnitude, stepsIndicator, stepsCount, peaks, valleys ] = detectSteps( accelerationData );
    stepsCount
    steps = nan( 1, length( stepsIndicator ) );
    steps( find( stepsIndicator ~= 0 ) ) = 1;
   
    plot( magnitude, '-' );
    hold on;
    plot( peaks, 'x' );
    hold on;
    plot( valleys, 'x' );
    hold on;
%     plot( magnitudeG, '-' );
%     hold on;
%     plot( accelerationData( 1, : ) );
%     hold on;
%     plot( accelerationData( 2, : ) );
%     hold on;
%     plot( accelerationData( 3, : ) );
%     hold on;    
    plot( steps, 'o' );
    
end

