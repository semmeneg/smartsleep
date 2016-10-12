function [ userData ] = loadAllUserData( userId, password, dateFrom, dateTo )
%LOADCOMPLETEUSER Summary of this function goes here
%   Detailed explanation goes here

    inputFormat = 'yyyy-mm-dd';
    inputFormatCapitalMonth = 'yyyy-MM-dd';
    
    % first login, to get token for further queries
    loginToken = performMyBasisLogin( userId, password );
    % query user-details 
    userDetails = loadMyBasisUserDetails( loginToken );
   
    dateFromVecNum = datenum( dateFrom, inputFormat );
    dateToVecNum = datenum( dateTo, inputFormat );

    % force loading of week the first iteration
    day = datestr( dateFromVecNum, inputFormat );
    t = datetime( day, 'InputFormat', inputFormatCapitalMonth );
    w = week( t );
    weekIndex = 1;
    newWeek = true;
    
    for i = dateFromVecNum:dateToVecNum
        day = datestr( i, inputFormat );

        if ( newWeek )
            fprintf( 'new week started at day %s, loading weekly summary\n', day );
            
            % query the weekly summary for the given day
            weeklySummary{ weekIndex, : } = loadMyBasisWeeklySummary( loginToken, day );
            
            weekIndex = weekIndex + 1;
            
            newWeek = false;
        end
        
        t = datetime( day, 'InputFormat', inputFormatCapitalMonth );
        wNew = week( t );
        
        % detected new week, problem: matlab starts new week at sunday
        % but basis gives weeklysummaries from monday-sunday, thus
        % wait till next day iteration to load week
        if ( wNew ~= w )
            w = wNew;
            newWeek = true;
        end
        
        % query the metrics of given day
        metrics( i - dateFromVecNum + 1 ) = loadMyBasisMetrics( loginToken, day );
        % query the sleep-data of given day
        sleepData( i - dateFromVecNum + 1 ) = loadMyBasisSleepData( loginToken, day );
        % query the body-states data of given day
        bodyStatesData( i - dateFromVecNum + 1 ) = loadMyBasisBodystates( loginToken, day );
        
        fprintf( 'loaded day %s\n', day );
    end
    
    userData = struct( 'userDetails', { userDetails }, 'metrics', { metrics }, ...
        'sleepDetails', { sleepData }, 'weeklySummary', { weeklySummary }, 'bodyStates', { bodyStatesData } );
end