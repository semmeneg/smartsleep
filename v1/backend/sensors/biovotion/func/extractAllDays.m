function [ allDays ] = extractDays( aggData, i, days )
%EXTRACTALLDAYS Summary of this function goes here
%   Detailed explanation goes here

    allDays = aggData( :, i, days );
    [ x, y, z ] = size( allDays );
    allDays = reshape( allDays, [ x z ] );
    
    [i j]=find( allDays);
	allDays = allDays(min(i):max(i),min(j):max(j));
end
