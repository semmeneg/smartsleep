function [ relativeCM ] = transformCMToRelative( CM )
%TRANSFORMCMTORELATIVE Summary of this function goes here
%   Detailed explanation goes here

    relativeCM = CM;
    rowEventsCount = sum( CM, 2 );

    for i = 1 : length( rowEventsCount )
        relativeCM( i, : ) = CM( i, : ) / rowEventsCount( i );
    end
end
