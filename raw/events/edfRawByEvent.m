function [ raw ] = edfRawByEvent( edfFile, requiredEdfSignals, events )
%FEATURESBYEVENT Summary of this function goes here
%   Detailed explanation goes here

    raw = [];

    edfData = BlockEdfLoadClass( edfFile );
    edfData = edfData.blockEdfLoad();

    signalCount = length( requiredEdfSignals{ 1 } );
    selectedSignals = zeros( signalCount, 1 );
    
    totalSampleRates = 0;
    
    % NOTE: this ensures that all required edf-channels are available in the
    % given order and using indirect indexing (see below) it is enusred
    % that all data is then assembled in the required order.
    for i = 1 : signalCount
        signalLabel = requiredEdfSignals{ events.type }{ i };
        signalIdx = findStrInCell( edfData.signal_labels, signalLabel );
        if ( isempty( signalIdx ) )
            warning( 'EDF:missing', 'In EDF-File %s signal %s not found in global configuration - ignoring EDF-file', edfFile, signalLabel );
            return;
        end
        
        selectedSignals( i ) = signalIdx;
        totalSampleRates = totalSampleRates + edfData.sample_rate( signalIdx );
    end

    EDF_TIMEFORMAT = 'dd.mm.yy HH.MM.SS';

    ASSUMED_EVENT_DURATION = 30;
    eventCount = length( events.time );
    
    % NOTE: assuming we only cover events with duration of 30:(R,W,N1,N2,N3)
    rawSamplesPerWindowCount = totalSampleRates * ASSUMED_EVENT_DURATION;
    raw.data = zeros( eventCount, rawSamplesPerWindowCount );
    raw.labels = zeros( eventCount, 1 );
    raw.startEventIdx = 0;
    raw.endEventIdx = eventCount;
    
    edfStartDateStr = [ edfData.edf.header.recording_startdate ... 
        ' ' edfData.edf.header.recording_starttime ];
    
    edfStartTime = matlabTimeToUnixTime( ...
        datenum( edfStartDateStr, EDF_TIMEFORMAT ) );
    edfEndTime = edfStartTime + edfData.signalDurationSec;
    
    for i = 1 : eventCount
        eventTime = events.time( i );
       
        % stop feature-calculation when reached end of elf-data
        if ( eventTime > edfEndTime )
            break;
        end
        
        % ignoring events which occured BEFORE start of data-recording
        if ( eventTime < edfStartTime )
            continue;
        end

        if ( 0 == raw.startEventIdx )
            raw.startEventIdx = i;
        end
                   
        eventDuration = events.durations( i );
        if ( eventDuration ~= ASSUMED_EVENT_DURATION )
            warning( 'EDF:invalidevent', 'Found Event with duration not matching assumed duration' );
            return;
        end
        
        tDelta = eventTime - edfStartTime;
        
        columnFromIndex = 1;
        columnToIndex = 1;
        
        terminate = false;
        
        for j = 1 : signalCount
            % NOTE: use indirect indexing on the selected signals because
            % need correct global ordering of EDF-signals
            idx = selectedSignals( j );
            sampleRate = edfData.sample_rate( idx );

            edfDataFromIdx = tDelta * sampleRate;
            edfDataToIdx = edfDataFromIdx + ( eventDuration * sampleRate ) - 1;
            
            if ( edfDataToIdx > length( edfData.edf.signalCell{ idx } ) )
                terminate = true;
                break;
            end
            
            columnToIndex = columnFromIndex + ( edfDataToIdx - edfDataFromIdx );
            
            raw.data( i, columnFromIndex : columnToIndex ) = edfData.edf.signalCell{ idx }( edfDataFromIdx : edfDataToIdx );
            
            columnFromIndex = columnToIndex + 1;
        end
        
        if ( false == terminate )
            raw.endEventIdx = i;
            
            eventName = events.names{ i };
            eventNameIdx = findStrInCell( events.classes, eventName );

            raw.labels( i ) = eventNameIdx;
            
        else
            break;
        end
    end
    
    invalidLabelsIdx = find( raw.labels == 0 );
    raw.labels( invalidLabelsIdx ) = [];
    raw.data( invalidLabelsIdx, : ) = [];
end
