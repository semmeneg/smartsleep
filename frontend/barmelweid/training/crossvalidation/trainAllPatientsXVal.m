function [ ] = trainAllPatientsXVal( patientsDataPath, ...
    allPatientsFile, wekaPath, ratio )
%TRAIN Summary of this function goes here
%   Detailed explanation goes here

    load( [ patientsDataPath allPatientsFile ] );
    patientCount = length( allPatients );
    
    splitPercent = ratio;
    splitIdx = floor( patientCount * splitPercent );
    
    patientsHalf1 = allPatients( 1 : splitIdx );
    patientsHalf2 = allPatients( splitIdx + 1 : end );
    
    hasEdf = false == isempty( allPatients{ 1 }.edf );
    hasMsr = false == isempty( allPatients{ 1 }.msr );
    hasZephyr = false == isempty( allPatients{ 1 }.zephyr );
    
    xvalPath = [ patientsDataPath 'CrossValidation\' ];
    mkdir( xvalPath );
    
    patientHalfLabels = [];
    patientHalfData = [];
    patientChannels = [];
    patientEventClasses = allPatients{ 1 }.filteredEvents.classes;
    
    for i = 1 : length( patientsHalf1 )
        patient = patientsHalf1{ i };

        patientHalfLabels = [ patientHalfLabels; patient.combinedLabels ];
        patientHalfData = [ patientHalfData; patient.combinedData ];
        patientChannels = patient.combinedChannels; % NOTE: all must match
    end

    [ arffFileFirst, modelFileFirst ] = ...
        trainCombinedData( patientHalfData, patientHalfLabels, ...
            patientEventClasses, patientChannels, 'XValidation_First', ...
            xvalPath, wekaPath, hasEdf, hasMsr, hasZephyr );
    
    patientHalfLabels = [];
    patientHalfData = [];
    
    for i = 1 : length( patientsHalf2 )
        patient = patientsHalf2{ i };

        patientHalfLabels = [ patientHalfLabels; patient.combinedLabels ];
        patientHalfData = [ patientHalfData; patient.combinedData ];
        patientChannels = patient.combinedChannels; % NOTE: all must match
    end

    [ arffFileSecond, modelFileSecond ] = ...
        trainCombinedData( patientHalfData, patientHalfLabels, ...
            patientEventClasses, patientChannels, 'XValidation_Second', ...
            xvalPath, wekaPath, hasEdf, hasMsr, hasZephyr );
    
    [ output ] = classifyWithWEKAModel( wekaPath, ...
        modelFileFirst, arffFileSecond, false );
    
    crossValResultsFile = [ xvalPath 'XValidation_CROSSCLASSIFICATIONRESULT' ]; 
    
    if ( hasEdf )
        crossValResultsFile = [ crossValResultsFile '_EEG' ];
    end
    
    if ( hasMsr )
        crossValResultsFile = [ crossValResultsFile '_MSR' ];
    end
    
    if ( hasZephyr )
        crossValResultsFile = [ crossValResultsFile '_ZEPHYR' ];
    end
    
    crossValResultsFile = [ crossValResultsFile '.txt' ];
    
    writeTextToFile( output, crossValResultsFile );
end
