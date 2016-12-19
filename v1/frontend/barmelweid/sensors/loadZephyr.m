function [ zephyr ] = loadZephyr( zephyrSummaryFile, selectedChannels )
%LOADZEPHYR Summary of this function goes here
%   Detailed explanation goes here

    TIMEFORMAT = 'dd/mm/yyyy HH:MM:SS';

    t = readtable( zephyrSummaryFile );
    
    tableSize = size( t, 1 );
    time = t( :, 'Time' );
    timeStrs = table2cell( time );
    
    zephyr.data = table2array( t( :, selectedChannels ) );
    zephyr.data = str2double(zephyr.data);
    zephyr.time = zeros( tableSize, 1 );
    
    for i = 1 : tableSize
        zephyr.time( i ) = matlabTimeToUnixTime( ...
            datenum( timeStrs{ i }, TIMEFORMAT ) );
    end
end
