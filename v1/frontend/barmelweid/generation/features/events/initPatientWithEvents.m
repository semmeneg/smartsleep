function [ patient ] = initPatientWithEvents( patientPath, patientFolder, ...
    outputFolder, eventClasses )
%initPatientWithEvents Construct patient struct with labeled events.

    patient = [];
    patient.edf = [];
    patient.msr = [];
    patient.zephyr = [];
    patient.events = [];
   
    patient.msrFiles = [];
    patient.zephyrFile = [];

    patient.path = patientPath;
    patient.folder = patientFolder;    
    patient.fullPath = [ patientPath patientFolder '\' ];
    patient.rawDataPath = [ patient.fullPath '1_raw\'] ;
    patient.preprocessedOutputFolder = [ patient.fullPath '2_preprocessed\' outputFolder '\' ];    

%     if ( deletePreviousOutput )
%         [ st, msg ] = cmd_rmdir( patient.smartSleepPath );
%     end
    
    % check if event-file exists
    eventFile = dir( [ patient.rawDataPath '*.txt' ] );
    if ( isempty( eventFile ) )
        warning( 'EVENTS:missing', 'Missing event-file in %s - ignoring patient', patient.fullPath ); 
        return;
    end
    
    patient.eventFile = [ patient.rawDataPath eventFile.name ];

    % event-file is a copy-paste from the word-docx - needs a different
    % parsing function
    if ( strfind( eventFile.name, '_docx' ) )
        [ patient.events ] = parseDocxEvents( patient.eventFile ); 
        patient.events.type = 2;
        
    else
        [ patient.events ] = parseEvents( patient.eventFile );
        patient.events.type = 1;
        
    end
    
    % filter events not belonging to defined eventClasses
    patient.filteredEvents = filterEvents( patient.events, eventClasses );
    patient.filteredEvents.classes = eventClasses;    
end
