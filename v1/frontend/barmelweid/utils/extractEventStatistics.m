ALL_PATIENTS_PATH = 'E:\FH\Job\SmartSleep Data\Barmelweid\SmartSleepPatienten\';

EXPECTED_EVENT_CLASSES = { 'Moving', 'Arousal', 'RERA', 'Lichtaus', 'Lichtan', ...
    'Artefakt', 'R', 'W', 'N1', 'N2', 'N3' };

% eventClassesDurations = cell( length( EXPECTED_EVENT_CLASSES ), 1 );
% 
% totalEventsCount = 0;
% 
% files = dir( [ ALL_PATIENTS_PATH 'Patient*' ] );
% dirFlags = [ files.isdir ];
% allPatientFolders = files( dirFlags );
% 
% patientCount = length( allPatientFolders );
% 
% for i = 1 : patientCount
%     p = initPatientWithEvents( ALL_PATIENTS_PATH, allPatientFolders( i ).name, false );
% 
%     if ( isempty( p.events ) )
%         continue;
%     end
%   
% 	for j = 1 : length( p.events.names )
%         eventName = p.events.names{ j };
%         eventDuration = p.events.durations( j );
%         
%         idx = findStrInCell( EXPECTED_EVENT_CLASSES, eventName );
%         
%         eventClassesDurations{ idx } = [ eventClassesDurations{ idx } eventDuration ];
%         
%         totalEventsCount = totalEventsCount + 1;
% 	end
% end

fprintf( 'Event-Statistics\n' );
fprintf( 'Total Events: %d\n\n', totalEventsCount );

fprintf( '%8s \t %5s \t %7s \t %4s \t %6s \t %4s \t %4s \t %6s \n', 'Event', 'Count', 'Percent', 'Min', 'Max', 'Mean', 'Std', 'Median' );
fprintf( '----------------------------------------------------------------------------\n' );

for i = 1 : length( EXPECTED_EVENT_CLASSES ) 
    eventClassData = eventClassesDurations{ i };
    
    minDur = min( eventClassData);
    maxDur = max( eventClassData);
    meanDur = mean( eventClassData);
    stdDur = std( eventClassData);
    medianDur = median( eventClassData);
    count = length( eventClassData );
    
    percent = ( 100 * ( count / totalEventsCount )) ;
    
    fprintf( '%8s \t %5d \t %6.2f%%', EXPECTED_EVENT_CLASSES{ i }, count, percent );

    if ( 0 ~= count )
        fprintf( '\t%5.2f', minDur );
        fprintf( '\t%7.2f', maxDur );
        fprintf( '\t%9.2f', meanDur );
        fprintf( '\t%5.2f', stdDur );
        fprintf( '\t%7.2f',  medianDur );
    end
    
    fprintf( '\n' );
end

fprintf( '----------------------------------------------------------------------------\n' );