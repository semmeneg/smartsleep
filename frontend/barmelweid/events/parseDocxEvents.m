function [ events ] = parseDocxEvents( eventFileName )
%PARSEDOCXEVENTS Summary of this function goes here
%   Detailed explanation goes here

    events = [];
    events.header = [];
    events.header.patient = '';
    events.header.patientId = '';
    events.header.recordingDate = '';
    events.header.eventsIncluded = [];
    events.header.session = [];
    events.header.session.scorer = '';
    events.header.session.time = '';
    events.durations = [];
    events.names = [];
    events.time = [];
    
    ORIGINAL_EVENT_NAMES = { 'NREM 1', 'NREM 2', 'NREM 3', 'REM', 'Wake' };
    MAPPED_EVENT_NAMES = { 'N1', 'N2', 'N3', 'R', 'W' };

    EVENT_TIMEFORMAT = 'dd.mm.yyyy HH:MM:SS AM';
   
    PARSESTATE_HEADER = 1;
    PARSESTATE_IDX = 2;
    PARSESTATE_STATE = 3;
    
    EVENT_DURATION = 30;
    
    parseState = PARSESTATE_HEADER;
    
    fid = fopen( eventFileName, 'r' );

    while ( true )
        line = fgets( fid );
        if ( false == ischar( line ) )
            break;
        end
        
        line = strtrim( line );
       
        if ( isempty( line ) )
            continue;
        end
        
        if ( PARSESTATE_HEADER == parseState )
            if ( 1 == strfind( line, 'Licht aus:' ) )
                lightOffDateStr = strsplit( line );
                lightOffDateStr = [ lightOffDateStr{ 3 } ' ' lightOffDateStr{ 4 } ' ' lightOffDateStr{ 5 } ];
                
                startTime = matlabTimeToUnixTime( datenum( lightOffDateStr, EVENT_TIMEFORMAT ) );
            end

            if ( 1 == strfind( line, 'Licht an:' ) )
                lightOnDateStr = strsplit( line );
                lightOnDateStr = [ lightOnDateStr{ 3 } ' ' lightOnDateStr{ 4 } ' ' lightOnDateStr{ 5 } ];
                
                endTime = matlabTimeToUnixTime( datenum( lightOnDateStr, EVENT_TIMEFORMAT ) );
               
                parseState = PARSESTATE_IDX;
                
                delta = endTime - startTime;
                segmentCount = ceil( delta / EVENT_DURATION );
                
                events.durations = zeros( segmentCount, 1 );
                events.names = cell( segmentCount, 1 );
                events.time = zeros( segmentCount, 1 );
            end
        else
            if ( PARSESTATE_IDX == parseState )
                if ( isstrprop( line, 'digit' ) )
                    eventIdx = str2num( line );
                    parseState = PARSESTATE_STATE;
                end
                
            elseif ( PARSESTATE_STATE == parseState ) 
                eventName = line;
                
                mappedEventNameIdx = findStrInCell( ORIGINAL_EVENT_NAMES, eventName );
                % only include event if a mapping was found
                if ( false == isempty( mappedEventNameIdx ) )
                     mappedEventName = MAPPED_EVENT_NAMES{ mappedEventNameIdx };
                
                    events.names{ eventIdx } = mappedEventName;
                    events.durations( eventIdx ) = EVENT_DURATION;
                    events.time( eventIdx ) = startTime + ( ( eventIdx - 1 ) * EVENT_DURATION );
                end

                parseState = PARSESTATE_IDX;
            end
        end
    end
    
    fclose( fid );

    events.header.eventsIncluded = unique( events.names );
end
