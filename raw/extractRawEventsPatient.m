function [ patient ] = extractRawEventsPatient( patientPath, patientFolder, outputFolder, ...
    eventClasses, requiredEdfSignals, processEDF, processMSR, processZephyr )
%PROCESSPATIENT Summary of this function goes here
%   Detailed explanation goes here

    patient = initPatientWithEvents( patientPath, patientFolder, outputFolder, eventClasses );
    if ( isempty( patient.events ) )
        return;
    end
    
    if ( processEDF )
        edfDataFolder = [ patient.rawDataPath 'EDF\' ];
        
        if ( ~ exist( edfDataFolder, 'dir' ) )
           warning( 'Missing EDF-Data folder in %s but EDF-flag set', patient.fullPath );
           
        else
            edfFile = dir( [ edfDataFolder '*.edf' ] );
            patient.edfFile = [ edfDataFolder edfFile.name ];
            
            fprintf( 'Processing EDF %s ...', patient.edfFile );

            [ patient.edf ] = edfRawByEvent( patient.edfFile, ...
                requiredEdfSignals, patient.filteredEvents );

            fprintf( 'finished.\n' );
        end
    end
    
    if ( processMSR )
        msrDataFolder = [ patient.rawDataPath 'MSR\' ];
        
        if ( ~ exist( msrDataFolder, 'dir' ) )
           warning( 'Missing MSR-Data folder in %s but MSR-flag set', patient.fullPath );
           
        else
            msrHandFile = dir( [ msrDataFolder '*HAND.mat' ] );
            msrFootFile = dir( [ msrDataFolder '*FUSS.mat' ] );

            fprintf( 'Processing MSR %s ...', msrDataFolder );
            
            patient.msrFiles = { [ msrDataFolder msrHandFile.name ]; [ msrDataFolder msrFootFile.name ] };
            
            [ patient.msr ] = msrRawByEvent( patient.msrFiles, patient.filteredEvents );
            
            fprintf( 'finished.\n' );
        end
    end
    
    if ( processZephyr )
        zephyrDataFolder = [ patient.rawDataPath 'Zephyr\' ];
        
        if ( ~ exist( zephyrDataFolder, 'dir' ) )
           warning( 'Missing Zephyr-Data folder in %s but Zephyr-flag set', patient.fullPath );
           
        else
            zephyrSummaryFile = dir( [ zephyrDataFolder '*Summary.csv' ] );
            patient.zephyrFile = [ zephyrDataFolder zephyrSummaryFile.name ];
            
            fprintf( 'Processing Zephyr %s ...', patient.zephyrFile );
            
            [ patient.zephyr ] = zephyrRawByEvent( patient.zephyrFile, patient.filteredEvents);

            fprintf( 'finished.\n' );
        end
    end

    startIndices = [];
    endIndices = [];
    
    if ( ~ isempty( patient.edf ) )
        startIndices( end + 1 ) = patient.edf.startEventIdx;
        endIndices( end + 1 ) = patient.edf.endEventIdx;
    end
    
    if ( ~ isempty( patient.msr ) )
        startIndices( end + 1 ) = patient.msr.startEventIdx;
        endIndices( end + 1 ) = patient.msr.endEventIdx;
    end
    
    if ( ~ isempty( patient.zephyr ) )
        startIndices( end + 1 ) = patient.zephyr.startEventIdx;
        endIndices( end + 1 ) = patient.zephyr.endEventIdx;
    end
    
    if ( isempty( startIndices ) );
        warning( 'PATIENT:nodata', 'Patient has no relevant data (EDF, MSR or ZEPHYR) - ignoring patient %s', patientFolder );
        return;
    end
    
    combinedStartIdx = max( startIndices );
    combinedEndIdx = min( endIndices );
    
    patient.combinedData = [];
    patient.combinedLabels = [];
    
    if ( ~ isempty( patient.edf ) )
        patient.combinedData = [ patient.combinedData  patient.edf.data( combinedStartIdx : combinedEndIdx, : ) ];
        if ( isempty( patient.combinedLabels ) )
            patient.combinedLabels = patient.edf.labels( combinedStartIdx : combinedEndIdx );
        end
    end
    
    if ( ~ isempty( patient.msr ) )
        patient.combinedData = [ patient.combinedData  patient.msr.data( combinedStartIdx : combinedEndIdx, : ) ];
        if ( isempty( patient.combinedLabels ) )
            patient.combinedLabels = patient.msr.labels( combinedStartIdx : combinedEndIdx );
        end
    end
    
    if ( ~ isempty( patient.zephyr ) )
        patient.combinedData = [ patient.combinedData patient.zephyr.data( combinedStartIdx : combinedEndIdx, : ) ];
        if ( isempty( patient.combinedLabels ) )
            patient.combinedLabels = patient.zephyr.labels( combinedStartIdx : combinedEndIdx );
        end
    end
end
