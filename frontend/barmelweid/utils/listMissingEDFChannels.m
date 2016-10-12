function [ missingChannels ] = listMissingEDFChannels( edfFile, requiredEdfChannels )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    missingChannels = [];
    
    edfData = BlockEdfLoadClass( edfFile );
    edfData = edfData.blockEdfLoad();

    signalCount = length( requiredEdfChannels );
    selectedSignals = zeros( signalCount, 1 );
    
    for i = 1 : signalCount
        channelName = requiredEdfChannels{ i };
        signalIdx = findStrInCell( edfData.signal_labels, channelName );
        if ( isempty( signalIdx ) )
            missingChannels{ end + 1 } = channelName;
        end
    end
end
