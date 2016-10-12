function [ output_args ] = visualizeLabeledData( msrData, labels )
%VISUALIZELABELEDDATA Summary of this function goes here
%   Detailed explanation goes here

    % visualize
    % for i = 1 : length( fileNameSensors )
    %     visualizeLabeledData( msrDataCombined, i, labels );
    % end

    t = msrData( end, : );
    x = msrData( 1, : );
    y = msrData( 2, : );
    z = msrData( 3, : );
  
    figure;
    plot( t, x, t, y, t, z, t, labels );
    %plot( t, x, t, y, t, labels );
end

