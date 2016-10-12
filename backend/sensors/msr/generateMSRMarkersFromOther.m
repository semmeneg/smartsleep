function [ msrChild ] = generateMSRMarkersFromOther( msrChild, msrParent )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    if ( isfield( msrChild, 'markers' ) )
        return;
    end
        
    if ( false == isfield( msrParent, 'markers' ) )
        return;
    end

    msrChild.markers = nan( 1, length( msrChild.time ) );

    parentMarkerIdx = find( msrParent.markers == 1 );
    parentMarkerTimes = msrParent.time( parentMarkerIdx );
    
    for i = 1 : length( parentMarkerTimes )
        idx = find( msrChild.time >= parentMarkerTimes( i ), 1 );
        msrChild.markers( idx ) = 1;
    end 
end
