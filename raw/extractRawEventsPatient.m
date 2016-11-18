function [ patient ] = extractRawEventsPatient( patientPath, patientFolder, outputFolder, ...
    eventClasses, requiredEdfSignals, processEDF, processMSR, processZephyr )
%PROCESSPATIENT Summary of this function goes here
%   Detailed explanation goes here

    patient = initPatientWithEvents( patientPath, patientFolder, outputFolder, eventClasses );
    if ( isempty( patient.events ) )
        return;
    end
    
    combinedDataEventTimes = []; % intersection over all data sources event start times
    
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
            
            if(~isempty(patient.edf))
                if ( isempty( combinedDataEventTimes ) )
                    combinedDataEventTimes = patient.edf.time;
                else
                    combinedDataEventTimes = intersect( patient.edf.time, combinedDataEventTimes );
                end              
            end                       

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
            
            if(~isempty(patient.msr))
                if ( isempty( combinedDataEventTimes ) )
                    combinedDataEventTimes = patient.msr.time;
                else
                    combinedDataEventTimes = intersect( patient.msr.time, combinedDataEventTimes );
                end              
            end              
            
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
            
            if(~isempty(patient.zephyr))
                if ( isempty( combinedDataEventTimes ) )
                    combinedDataEventTimes = patient.zephyr.time;
                else
                    combinedDataEventTimes = intersect( patient.zephyr.time, combinedDataEventTimes );
                end              
            end            

            fprintf( 'finished.\n' );
        end
    end

    patient.combinedData = [];
    patient.combinedLabels = [];
    
    if ( ~ isempty( patient.edf ) )
        dataIdx = find(ismember(patient.edf.time, combinedDataEventTimes));
        patient.combinedData = [ patient.combinedData patient.edf.data( dataIdx, : ) ];
        patient.combinedLabels = [ patient.combinedLabels patient.edf.labels(dataIdx) ];
    end
    
    if ( ~ isempty( patient.msr ) )
        dataIdx = find(ismember(patient.msr.time, combinedDataEventTimes));
        patient.combinedData = [ patient.combinedData patient.msr.data( dataIdx, : ) ];
        patient.combinedLabels = [ patient.combinedLabels patient.msr.labels(dataIdx) ];
    end
    
    if ( ~ isempty( patient.zephyr ) )
        dataIdx = find(ismember(patient.zephyr.time, combinedDataEventTimes));
        patient.combinedData = [ patient.combinedData patient.zephyr.data( dataIdx, : ) ];
        patient.combinedLabels = [ patient.combinedLabels patient.zephyr.labels(dataIdx) ];
    end
end
