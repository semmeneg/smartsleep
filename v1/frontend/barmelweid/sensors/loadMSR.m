function [ msr ] = loadMSR( msrMatFile )
%LOADMSR Summary of this function goes here
%   Detailed explanation goes here

    load( msrMatFile );
    
    timeChannelIndex = 0;
    accChannelNames = { 'ACC x', 'ACC y', 'ACC z' };
    
    for i = 1 : length ( InfoChannelNames )
        if ( strcmpi( InfoChannelNames( i ), 'time' ) )
            timeChannelIndex = i;
        end

        for j = 1 : length( accChannelNames )
            if ( strcmpi( InfoChannelNames( i ), accChannelNames{ j } ) )
                msr.data( j, : ) = removeNan( MSR( i, : ) );
                break;
            end
        end
    end
    
    if ( timeChannelIndex == 0 )
        error( 'No time found in MSR' ); 
    end
    
    t = datenum( InfoStartTime, 'yyyy-mm-dd HH:MM:SS' );
    startTimeInMs = matlabTimeToUnixTime( t );
    
    msr.time = MSR( timeChannelIndex, : ) + startTimeInMs; 
end
