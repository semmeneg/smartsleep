function [ x ] = removeNan( x )
%REMOVENAN Summary of this function goes here
%   Detailed explanation goes here

    firstNonNanIndex = find( ~isnan( x ), 1, 'first' );
    lastNonNanIndex = find( ~isnan( x ), 1, 'last' );
    
    % only nans, replace by 0
    if ( isempty( firstNonNanIndex ) )
        x = zeros( length( x ), 1 );
        return;
    end
    
    %ensure we start and end with NAN to be able to interpolate
    if ( 1 ~= firstNonNanIndex )
        x( 1 ) = x( firstNonNanIndex );
    end

    if ( length( x ) ~= lastNonNanIndex )
        x( end ) = x( lastNonNanIndex );
    end
        
    nanIndices = isnan( x );

    if ( ~isempty( nanIndices ) )
        allIdx = 1 : length( x );
        x( nanIndices ) = interp1( allIdx( ~nanIndices ), ...
            x( ~nanIndices ), allIdx( nanIndices ), 'linear' ); 
    end
end

