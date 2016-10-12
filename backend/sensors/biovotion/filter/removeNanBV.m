function [ dsout ] = removeNanBV( dsout, i )
%REMOVENAN Summary of this function goes here
%   Detailed explanation goes here

    firstNonNanIndex = find( ~isnan( dsout.Sensors.data( :, i ) ), 1, 'first' );
    lastNonNanIndex = find( ~isnan( dsout.Sensors.data( :, i ) ), 1, 'last' );

    %ensure we start and end with NAN to be able to interpolate
    if ( 1 ~= firstNonNanIndex )
        dsout.Sensors.data( 1, i ) = dsout.Sensors.data( firstNonNanIndex, i );
    end

    if ( size( dsout.Sensors.data( :, i ), 1 ) ~= lastNonNanIndex )
        dsout.Sensors.data( end, i ) = dsout.Sensors.data( lastNonNanIndex, i );
    end
        
    nanIndices = isnan( dsout.Sensors.data( :, i ) );

    if ( ~isempty( nanIndices ) )
        allIdx = 1 : size( dsout.Sensors.data( :, i ), 1 );
        dsout.Sensors.data( nanIndices, i ) = interp1( allIdx( ~nanIndices ), ...
            dsout.Sensors.data( ~nanIndices, i ), allIdx( nanIndices ), 'linear' ); 
    end
end

