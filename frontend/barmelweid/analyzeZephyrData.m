PATIENTS_DATA_PATH = 'E:\FH\Job\SmartSleep Data\Barmelweid\SmartSleepPatienten\';

files = dir( [ PATIENTS_DATA_PATH 'Patient*' ] );
dirFlags = [ files.isdir ];
allPatientFolders = files( dirFlags );

ZEPHYR_CHANNELS = { 'HR', 'BR', 'SkinTemp', 'PeakAccel', ...
        'BRAmplitude', 'BRNoise', 'BRConfidence', 'ECGAmplitude', ...
        'ECGNoise', 'HRConfidence', 'HRV', 'VerticalMin', 'VerticalPeak', ...
        'LateralMin', 'LateralPeak', 'SagittalMin', 'SagittalPeak' };
    
figure;

for i = 1 : length( allPatientFolders )
    subplot( 7, 4, i );
    
    patient = initPatientWithEvents( PATIENTS_DATA_PATH, allPatientFolders( i ).name, false );
    if ( isempty( patient.events ) )
        title( sprintf( '%s\n%s', patient.folder, 'missing events' ) );
        continue;
    end
    
    zephyrDataFolder = [ PATIENTS_DATA_PATH allPatientFolders( i ).name '\Zephyr\' ];
    if ( ~ exist( zephyrDataFolder, 'dir' ) )
        title( sprintf( '%s\n%s', patient.folder, 'missing zephry-data' ) );
        continue;
    end

    zephyrSummaryFile = dir( [ zephyrDataFolder '*Summary.csv' ] );
    zephyrRawData = loadZephyr( [ zephyrDataFolder zephyrSummaryFile.name ], ZEPHYR_CHANNELS );
    
    startIdx = find( zephyrRawData.time >= patient.events.time( 1 ), 1 );
    endIdx = find( zephyrRawData.time >= patient.events.time( end ), 1 );
    
    hrData = zephyrRawData.data( :, 1 );
    plot( hrData );
    yL = get( gca,'YLim' );
    line( [ startIdx startIdx ], yL, 'Color','r', 'LineWidth', 2 );
    line( [ endIdx endIdx ], yL, 'Color','r', 'LineWidth', 2 );
    title( patient.folder );
end