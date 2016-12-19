% Reads and parses labeled sleep phase events with time and duration (event time window).
%
classdef SleepPhaseEventParser
    
    properties(Constant)
        DEFAULT_EVENT_DURATION = 30; %seconds
    end
    
    properties
        eventFilePathAndName = [];
    end
    
    methods
        function obj = SleepPhaseEventParser(eventFilePathAndName)
            obj.eventFilePathAndName = eventFilePathAndName;
        end
        
        function [ events ] = run(obj)
            events = [];
            
            if (contains(obj.eventFilePathAndName, '*'))
                file = dir(obj.eventFilePathAndName);
                if ( isempty( file ) )
                    warning( 'EVENTS:missing', 'Missing event-file in %s - ignoring patient', obj.eventFilePathAndName ); 
                    return;
                end
                fileNameAndPath = [ file.folder '\' file.name ];
            else
                fileNameAndPath = obj.eventFilePathAndName;
            end
            
            [fileID, errmsg] = fopen( fileNameAndPath, 'r' );
            if(~isempty(errmsg))
                disp(fprintf('Error when opening file. %s: %s', errmsg, fileNameAndPath));
                return;
            end
            
            % event-file is a copy-paste from the word-docx - needs a different
            % parsing function
            if ( strfind( fileNameAndPath, '_docx' ) )
                [ events ] = obj.parseDocxEvents( fileID );
                events.type = 2;
                
            else
                [ events ] = obj.parseEvents( fileID );
                events.type = 1;
                
            end
            
            
        end
        
        function [ events ] = parseDocxEvents(obj, fileID )
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
            
            parseState = PARSESTATE_HEADER;
            
            while ( true )
                line = fgets( fileID );
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
                        segmentCount = ceil( delta / obj.DEFAULT_EVENT_DURATION );
                        
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
                            events.durations( eventIdx ) = obj.DEFAULT_EVENT_DURATION;
                            events.time( eventIdx ) = startTime + ( ( eventIdx - 1 ) * obj.DEFAULT_EVENT_DURATION );
                        end
                        
                        parseState = PARSESTATE_IDX;
                    end
                end
            end
            
            fclose( fileID );
            
            events.header.eventsIncluded = unique( events.names );
        end
        
        function [ events ] = parseEvents(obj, fileID )
            %PARSEEVENTS Summary of this function goes here
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
            
            PARSESTATE_HEADER = 1;
            PARSESTATE_EVENTSINCLUDED = 2;
            PARSESTATE_SEARCHDATAHEADER = 3;
            PARSESTATE_DATACOLUMNS = 4;
            
            PATIENT_LINE = 'Patient:';
            PATIENTID_LINE = 'Patient ID:';
            RECDATE_LINE = 'Recording Date:';
            INCLUDED_LINE = 'Events Included:';
            SESSION_LINE = 'Scoring Session:';
            SCORER_LINE = 'Scorer Name:';
            SESSIONTIME_LINE = 'Scoring Time:';
            
            DATAHEADER_LINE = 'Sleep Stage';
            DATAHEADER_TIME = 'Time';
            DATAHEADER_DURATION = 'Duration';
            DATAHEADER_EVENT = 'Event';
            
            EVENT_TIMEFORMAT = 'dd.mm.yyyy HH:MM:SS';
            
            eventColIdx = 0;
            durationColIdx = 0;
            timeColIdx = 0;
            
            lastEventStartTime = [];
            dayOverflow = 0;
            
            parseState = PARSESTATE_HEADER;
            
            while ( true )
                line = fgets( fileID );
                if ( false == ischar( line ) )
                    break;
                end
                
                line = strtrim( line );
                isEmptyline = 0 == length( char( line ) );
                if ( isEmptyline )
                    continue;
                end
                
                % reading header
                if ( PARSESTATE_HEADER == parseState )
                    if ( 1 == strfind( line, PATIENT_LINE ) )
                        s = strsplit( line, PATIENT_LINE );
                        events.header.patient = strtrim( s{ 2 } );
                        
                    elseif ( 1 == strfind( line, PATIENTID_LINE ) )
                        s = strsplit( line, PATIENTID_LINE );
                        events.header.patientId = strtrim( s{ 2 } );
                        
                    elseif ( 1 == strfind( line, RECDATE_LINE ) )
                        s = strsplit( line, RECDATE_LINE );
                        events.header.recordingDate = strtrim( s{ 2 } );
                        
                    elseif ( 1 == strfind( line, INCLUDED_LINE ) )
                        parseState = PARSESTATE_EVENTSINCLUDED;  %% reading events-included list
                    end
                    
                    % parsing events-included
                elseif ( PARSESTATE_EVENTSINCLUDED == parseState )
                    if ( 1 == strfind( line, SESSION_LINE ) )
                        line = fgets( fileID );
                        s = strsplit( line, SCORER_LINE );
                        events.header.session.scorer = strtrim( s{ 2 } );
                        
                        line = fgets( fileID );
                        s = strsplit( line, SESSIONTIME_LINE );
                        events.header.session.time = strtrim( s{ 2 } );
                        
                        parseState = PARSESTATE_SEARCHDATAHEADER; %% looking for header-line of events
                        
                    else
                        line( ismember( line, ' ' ) ) = [];
                        events.header.eventsIncluded{ end + 1 } = line;
                    end
                    
                elseif ( PARSESTATE_SEARCHDATAHEADER == parseState )
                    if ( 1 == strfind( line, DATAHEADER_LINE ) )
                        events.data.headers = strsplit( line );
                        
                        % Sleep Stage is separated by white-space, combine it
                        events.data.headers{ 1 } = [ events.data.headers{ 1 } events.data.headers{ 2 } ];
                        events.data.headers( 2 ) = [];
                        
                        % Time and time-format is separted by white-space. extract
                        % time-format to separate field and remove from original
                        % header-label (NOTE: removing [ and ] brackets
                        timeColIdx = findStrInCell( events.data.headers, DATAHEADER_TIME );
                        events.data.timeFormat = events.data.headers{ timeColIdx + 1 };
                        events.data.timeFormat = events.data.timeFormat( 2 : end - 1 );
                        events.data.headers( timeColIdx + 1 ) = [];
                        
                        % Duration has attached [s] which is the duration-format,
                        % extract it to separate field and remove from original
                        % header-label
                        durationColIdx = findStrInCell( events.data.headers, DATAHEADER_DURATION );
                        events.data.durationFormat = events.data.headers{ durationColIdx };
                        events.data.durationFormat = events.data.durationFormat( length( DATAHEADER_DURATION ) + 1 : end );
                        events.data.durationFormat = events.data.durationFormat( 2 : end - 1 );
                        events.data.headers{ durationColIdx } = DATAHEADER_DURATION;
                        
                        eventColIdx = findStrInCell( events.data.headers, DATAHEADER_EVENT );
                        
                        parseState = PARSESTATE_DATACOLUMNS; %% parsing events
                    end
                    
                elseif ( PARSESTATE_DATACOLUMNS == parseState )
                    columns = strsplit( line, '\t' );
                    
                    % transform event-duration string to number
                    duration = str2num( columns{ durationColIdx } );
                    % ignore events with duration of 0
                    if ( 0 == duration )
                        continue;
                    end
                    
                    % remove white-spaces in event-names
                    eventName = columns{ eventColIdx };
                    eventName( ismember( eventName, ' ' ) ) = [];
                    eventNameIdx = findStrInCell( events.header.eventsIncluded, eventName );
                    % ignore unknown labels
                    if ( 0 == eventNameIdx )
                        continue;
                    end
                    
                    % transform event-time string to unix-time
                    eventTimeStr = [ events.header.recordingDate ' ' columns{ timeColIdx } ];
                    eventStartTime = matlabTimeToUnixTime( datenum( eventTimeStr, EVENT_TIMEFORMAT ) );
                    
                    % handle event-time overflow to following day(s)
                    eventStartTime = eventStartTime + ( dayOverflow * 86400 );
                    % overflow of hour to next day => increase day by 1
                    if ( lastEventStartTime > eventStartTime )
                        dayOverflow = dayOverflow + 1;
                        eventStartTime = eventStartTime + ( dayOverflow * 86400 );
                    end
                    lastEventStartTime = eventStartTime;
                    
                    events.durations( end + 1 ) = duration;
                    events.names{ end + 1 } = eventName;
                    events.time( end + 1 ) = eventStartTime;
                end
            end
            
            fclose( fileID );
        end
    end
end
    
    
