function [ events ] = parseEvents( eventFileName )
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
    
    fid = fopen( eventFileName, 'r' );

    while ( true )
        line = fgets( fid );
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
                line = fgets( fid );
                s = strsplit( line, SCORER_LINE );
                events.header.session.scorer = strtrim( s{ 2 } );
                 
                line = fgets( fid );
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

    fclose( fid );
end
