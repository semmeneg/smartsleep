function [ patient ] = initPatientWithEvents( patientPath, patientFolder, ...
    deletePreviousOutput )
%LOADPATIENTEVENT Summary of this function goes here
%   Detailed explanation goes here

    patientFullPath = [ patientPath patientFolder '\' ];

    patient = [];
    patient.edf = [];
    patient.msr = [];
    patient.zephyr = [];
    patient.events = [];
   
    patient.path = patientPath;
    patient.folder = patientFolder;
    patient.fullPath = patientFullPath;
    patient.smartSleepPath = [ patient.fullPath 'SmartSleep\' ];
    patient.msrFiles = [];
    patient.zephyrFile = [];
    
    if ( deletePreviousOutput )
        [ st, msg ] = cmd_rmdir( patient.smartSleepPath );
    end
    
    % check if event-file exists
    eventFile = dir( [ patient.fullPath '*.txt' ] );
    if ( isempty( eventFile ) )
        warning( 'EVENTS:missing', 'Missing event-file in %s - ignoring patient', patient.fullPath ); 
        return;
    end
    
    patient.eventFile = [ patient.fullPath eventFile.name ];

    % event-file is a copy-paste from the word-docx - needs a different
    % parsing function
    if ( strfind( eventFile.name, '_docx' ) )
        [ patient.events ] = parseDocxEvents( patient.eventFile ); 
        patient.events.type = 2;
        
    else
        [ patient.events ] = parseEvents( patient.eventFile );
        patient.events.type = 1;
        
    end
end
