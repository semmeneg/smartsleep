function [ f ] = createEdgeDetectFigure( dsout, i, medianFilterWidth, edgeThresh )
%EDGEDETECT Summary of this function goes here
%   Detailed explanation goes here

    edgeFilter = 'Sobel';
    filtered = medfilt1( dsout.Sensors.data( :, i ), medianFilterWidth );
    
    [ I, thresh ] = edge( filtered, edgeFilter, edgeThresh, 'horizontal' );
    
    d( :, 1 ) = filtered;
    d( :, 2 ) = nan; % nans won't get drawed at all in a plot
    d( find( I ), 2 ) = d( find( I ), 1 ); % draw only samples masked as edge
    
    f = figure( 'Name', sprintf( 'Edge Detection of %s', dsout.Sensors.vnames{ :, i } ), ... 
            'NumberTitle', 'off', ...
            'visible', 'on' );
        
    p = plot( d );
    legend( sprintf( 'Median (width %d)', medianFilterWidth ), sprintf( '%s (thresh %.3f)', edgeFilter, thresh ) )

    set( p( 2 ), 'linewidth', 3 );
end
