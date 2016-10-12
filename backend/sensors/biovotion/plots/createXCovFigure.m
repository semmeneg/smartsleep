function [ f ] = createXCovFigure( dsout, i, visible )
%GENXCOVFIGURE Summary of this function goes here
%   Detailed explanation goes here

    figureVisible = 'off';
    
    if ( visible )
        figureVisible = 'on';
    end

    f = figure( 'Name', sprintf( 'Cross-Covariance of %s', dsout.Sensors.vnames{ :, i } ), ... 
            'NumberTitle', 'off', ...
            'visible', figureVisible );

    counter = 1;
        
    for j = 1 : 10
        if ( i == j )
           continue;
        end

        c = xcov( dsout.Sensors.data( :, i ), dsout.Sensors.data( :, j ), 'coeff' );

        subplot( 3, 3, counter );
        plot( c );
        axis( [ 0 2 * size( dsout.Sensors.data, 1 ) -1 1 ] )
        axis 'auto y';
        title( sprintf( '%s', dsout.Sensors.vnames{ :, j } ) );

        counter = counter + 1;
    end
end
