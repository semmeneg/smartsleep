function [ ] = showOverlayPlots( varargin )
    if ( 3 > nargin )
        fprintf( 'Error: need at least 3 input parameters: showOverlayPlots( index dsout1 dsout2 ... dsoutN )\n' );
        return;
    end

    i = varargin{ 1 };
    
    if ( ~isnumeric( i ) )
        fprintf( 'Error: first parameter must be numeric\n' );
        return;
    end
    
    data = [];

    for j = 2 : nargin
        dsout = varargin{ j };
        
        if ( ~isfield( dsout, 'Sensors' ) )
            fprintf( 'Error: parameters 2 - N must be DSout-struct\n' );
            return;
        end
        
        data( :, j - 1 ) = dsout.Sensors.data( :, i );
    end
    
    figure;
    p = plot( data );
    colors = hsv( nargin - 1 );
    
    for i = 1 : nargin - 1
        set( p( i ), 'linewidth', i, 'col', colors( i, : ) );
    end
end
