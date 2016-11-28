warning ( 'off', 'all' );
%warning ( 'on', 'EDF:missing' );
%warning ( 'on', 'EVENTS:missing' );
%warning ( 'on', 'PATIENT:nodata' );
warning ( 'on', 'PATIENT:eventMissmatch' );
warning ( 'on', 'PATIENT:channelsMissmatch' );

clear();

COMBINE_ALL = true;
WINDOW_LENGTH = 30;

OTUPUT_FOLDER = '2016-11-24_Features';


% TODO: specify starting-times for all patients: starting classification when light-off

% EVENT_CLASSES = { 'Arousal', 'Artefakt', 'R', 'W', 'N1', 'N2', 'N3' };
EVENT_CLASSES = { 'R', 'W', 'N1', 'N2', 'N3' };

% NOTE: this are all channels
% REQUIRED_EDF_SIGNALS = { 'Re Bein', 'EKG', 'Li Bein', 'Kinn 1', 'REF', ...
%     'E1-M2', 'E2-M1', 'C3-M2', 'C4-M1', 'O1-M2', 'O2-M1', 'F3-M2', ...
%     'F4-M1', 'Thermistor', 'Thorax', 'Abdomen', 'SpO2', 'Flow_DR', ...
%     'Snore_DR', 'Position_DR' };

% NOTE: this are the polysomnography-only channels
REQUIRED_EDF_SIGNALS = { { 'Kinn 1', 'Re Bein', 'Li Bein', 'E1-M2',  'E2-M1', 'C3-M2', 'C4-M1', 'O1-M2', 'O2-M1', 'F3-M2', 'F4-M1' }, ...
    { 'Chin1-Chin2', 'Rat1-Rat2', 'Lat1-Lat2', 'LOC-A2', 'ROC-A1', 'C3-A2', 'C4-A1', 'O1-A2', 'O2-A1', 'F3-A2', 'F4-A1' } };

ALL_WINDOW_LENGTHS = 30;

tic

for WINDOW_LENGTH = ALL_WINDOW_LENGTHS
    disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );
    fprintf( 'Extracting %d-sec windows ...\n', WINDOW_LENGTH );
    
%     % EEG only
%     disp( 'Extracting feature-windows of EEG ONLY ...' );
%     exportFeatureWindowWEKAPatientFolder( CONF.PATIENTS_DATA_PATH, OTUPUT_FOLDER, REQUIRED_EDF_SIGNALS, ...
%         EVENT_CLASSES, WINDOW_LENGTH, COMBINE_ALL, true, false, false );
%     disp( 'Finished extracting feature-windows of EEG ONLY.' );
% 
    % MSR only
    disp( 'Extracting feature-windows of MSR ONLY ...' );
    exportFeatureWindowWEKAPatientFolder( CONF.PATIENTS_DATA_PATH, OTUPUT_FOLDER, REQUIRED_EDF_SIGNALS, ...
        EVENT_CLASSES, WINDOW_LENGTH, COMBINE_ALL, false, true, false );
    disp( 'Finished extracting feature-windows of MSR ONLY ...' );

    % ZEPHYR only
    disp( 'Extracting feature-windows of ZEPHYR ONLY ...' );
    exportFeatureWindowWEKAPatientFolder( CONF.PATIENTS_DATA_PATH, OTUPUT_FOLDER, REQUIRED_EDF_SIGNALS, ...
        EVENT_CLASSES, WINDOW_LENGTH, COMBINE_ALL, false, false, true );
    disp( 'Finished extracting feature-windows of ZEPHYR ONLY.' );

    % MSR & ZEPHYR
    disp( 'Extracting feature-windows of MSR & ZEPHYR ...' );
    exportFeatureWindowWEKAPatientFolder( CONF.PATIENTS_DATA_PATH, OTUPUT_FOLDER, REQUIRED_EDF_SIGNALS, ...
        EVENT_CLASSES, WINDOW_LENGTH, COMBINE_ALL, false, true, true );
    disp( 'Finished extracting feature-windows of MSR & ZEPHYR.' );
% 
%     % EEG & MSR 
%     disp( 'Extracting feature-windows of EEG & MSR  ...' );
%     exportFeatureWindowWEKAPatientFolder( CONF.PATIENTS_DATA_PATH, OTUPUT_FOLDER, REQUIRED_EDF_SIGNALS, ...
%         EVENT_CLASSES, WINDOW_LENGTH, COMBINE_ALL, true, true, false );
%     disp( 'Finished extracting feature-windows of EEG & MSR.' );
% 
%     % EEG & ZEPHYR 
%     disp( 'Extracting feature-windows of EEG & ZEPHYR  ...' );
%     exportFeatureWindowWEKAPatientFolder( CONF.PATIENTS_DATA_PATH, OTUPUT_FOLDER, REQUIRED_EDF_SIGNALS, ...
%         EVENT_CLASSES, WINDOW_LENGTH, COMBINE_ALL, true, false, true );
%     disp( 'Finished extracting feature-windows of EEG & ZEPHYR.' );
%     
%     % EEG & MSR & ZEPHYR
%     disp( 'Extracting feature-windows of EEG & MSR & ZEPHYR ...' );
%     exportFeatureWindowWEKAPatientFolder( CONF.PATIENTS_DATA_PATH, OTUPUT_FOLDER, REQUIRED_EDF_SIGNALS, ...
%         EVENT_CLASSES, WINDOW_LENGTH, COMBINE_ALL, true, true, true );
%     disp( 'Finished extracting feature-windows of EEG & MSR & ZEPHYR.' );
    
    fprintf( 'Finished extracting %d-sec windows ...\n', WINDOW_LENGTH );
    disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );
end

toc