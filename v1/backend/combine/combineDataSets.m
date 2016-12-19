function [ combinedDataSet ] = combineDataSets( rootFolder, ...
    includeMobileData, remapActivitiesUnique )
%COMBINEDATASETS Summary of this function goes here
%   Detailed explanation goes here

    combinedDataSet = [];
    combinedDataSet.features.data = [];
    combinedDataSet.features.labels = [];
    combinedDataSet.dbn.data = [];
    combinedDataSet.dbn.labels = [];
    combinedDataSet.dbn.features = [];

    % NOTE: assuming the following folder-structure for combining data-sets
    % 1st layer: root-folder - contains only subfolders which contain the 
    %            data of a test-subject where the subfolder is named as the
    %            test-subject
    % 2nd layer: subfolder of a given test-subject - contains only
    %            subfolders named as the activities which are of interest
    %            in the given data. Note that the folder-names can contain
    %            multiple activity-names separted by comma. All these
    %            activities are then extracted out of the data-set in the
    %            3rd layer
    % 3rd layer: the subfolder of a given activity of a given test-subject
    %            - contains subfolders: MSR and Mobile AND the
    %            activities-file
    % 4th layer: MSR and Mobile subfolders contain the necessary data

    activityMappings = [];
    activityMappingsBack = [];
    activityMappingsNextId = 1;
    
    testSubjectsFolderList = listDirFiles( rootFolder, 'dir' );
    for i = 1 : length( testSubjectsFolderList )
        testSubjectFolder = testSubjectsFolderList{ i };
        testSubjectFolderFullPath = sprintf( '%s\\%s', rootFolder, testSubjectFolder.name );

        testSubjectActivitiesFolderList = listDirFiles( testSubjectFolderFullPath, 'dir' );
        for j = 1 : length( testSubjectActivitiesFolderList ) 
            activityFolder = testSubjectActivitiesFolderList{ j };
            activityFolderFullPath = sprintf( '%s\\%s', testSubjectFolderFullPath, activityFolder.name );
        
            msrDataFolder = sprintf( '%s\\MSR', activityFolderFullPath );
            mobileDataFolder = sprintf( '%s\\Mobile', activityFolderFullPath );

            % NOTE: MSR AND Mobile Data is mandatory! ignoring activities
            % which lack either

            if ( ~ exist( msrDataFolder, 'dir' ) )
               warning( 'Missing MSR-Data folder in %s - MSR-Data is mandatory, ignoring activity', activityFolderFullPath );
               continue;
            end

            if ( includeMobileData )
                if ( ~ exist( mobileDataFolder, 'dir' ) )
                   warning( 'Missing Mobile-Data folder in %s - Mobile-Data is mandatory, ignoring activity', activityFolderFullPath );
                   continue;
                end
            end
            
            dataSetParams = [];
            % don't perform training for sub-sets, will be done for the combined set
            dataSetParams.dbn.train = false;
            dataSetParams.name = sprintf( '%s_%s', testSubjectFolder.name, activityFolder.name );

            dataSetParams = findMSRFiles( msrDataFolder, dataSetParams );
            % not all necessary MSR-files found:
            % need 2 .mat files: wrist.mat and ankle.mat
            if ( isempty( dataSetParams ) )
               continue;
            end

            % only process mobile-files when flag to include mobile-data is
            % set
            if ( includeMobileData )
                dataSetParams = findMobileFiles( mobileDataFolder, dataSetParams );
                % not all necessary mobile-files found:
                % ACCELEROMETER, SPEED
                if ( isempty( dataSetParams ) )
                   continue;
                end
            end
            
            [ dataSetParams ] = findActivityFile( activityFolderFullPath, dataSetParams );
            % activities-file not found
            if ( isempty( dataSetParams ) )
               continue;
            end
            
            dataSet = generateDataSet( dataSetParams );
            
            % initialize data-structures which won't change between subsets of data
            % by first dataSet 
            if ( ~ isfield( combinedDataSet, 'activitiesInfo' ) )
                combinedDataSet = copyDataSetInvariants( combinedDataSet, dataSet );
            end
            
            % extract activities
            allActivities = strsplit( activityFolder.name, ',' );
            for k = 1 : length( allActivities )
                activityName = allActivities{ k };
                activityIdx = find( ismember( combinedDataSet.activitiesInfo.classes, activityName ) );
                
                if ( isempty( activityIdx ) )
                    % with this code it is possible to use folder names like
                    % this: standing_general,walking_general_1
                    % this is helpful if there are sets including the same
                    % activities e.g. standing_general, standing_general_1
                    % standing_general_2
                    for r = 1 : size (combinedDataSet.activitiesInfo.classes, 2)
                        found = strfind(activityName, char(combinedDataSet.activitiesInfo.classes(r)));
                        if ( ~isempty(found) )
                            activityName = combinedDataSet.activitiesInfo.classes(r);
                            break;
                        end
                    end
                    activityIdx = find( ismember( combinedDataSet.activitiesInfo.classes, activityName ) );
                    if ( isempty( activityIdx ) )
                        error( 'Should not occur: undefined activity: %s ', activityName);
                    end

                    %error( 'should not occur' );
                end

                 % copy all features and their labels
                featureIdx = dataSet.features.labels == activityIdx;
                sampleCount = sum( featureIdx );
                
                % copy all DBN-data and their labels
                dbnDataIdx = dataSet.dbn.labels == activityIdx;
                dbnSampleCount = sum( dbnDataIdx );
                
                % NOTE: can remap labels to have continuous label-range
                % without loops when some activities are not present in
                % training-set
                if ( remapActivitiesUnique )
                    if ( length( activityMappings ) < activityIdx || ...
                        0 == activityMappings( activityIdx ) )
                        activityMappings( activityIdx ) = activityMappingsNextId;
                        activityMappingsBack( activityMappingsNextId ) = activityIdx;
                        
                        activityMappingsNextId = activityMappingsNextId + 1;
                    end
                    
                    activityIdx = activityMappings( activityIdx );
                end
                
                combinedDataSet.features.data( :, end + ( 1 : sampleCount ) ) = ...
                    dataSet.features.data( :, featureIdx );
                combinedDataSet.features.labels( end + ( 1 : sampleCount ) ) = activityIdx;

                combinedDataSet.dbn.data( end + ( 1 : dbnSampleCount ), : ) = ...
                    dataSet.dbn.data( dbnDataIdx, : );
                combinedDataSet.dbn.labels(end + ( 1 : dbnSampleCount ), 1 ) = activityIdx;
            end
        end
    end
    
    if ( remapActivitiesUnique )
        combinedDataSet.uniqueActivitiesMappings.forward = activityMappings;
        combinedDataSet.uniqueActivitiesMappings.backward = activityMappingsBack;
    end
end
