warning ( 'off', 'all' );

clear();

OTUPUT_FOLDER = '2016-11-16_RAW';

% 30-sec events only !
EVENT_CLASSES = { 'R', 'W', 'N1', 'N2', 'N3' };

% NOTE: this are all channels
% REQUIRED_EDF_SIGNALS = { 'Re Bein', 'EKG', 'Li Bein', 'Kinn 1', 'REF', ...
%     'E1-M2', 'E2-M1', 'C3-M2', 'C4-M1', 'O1-M2', 'O2-M1', 'F3-M2', ...
%     'F4-M1', 'Thermistor', 'Thorax', 'Abdomen', 'SpO2', 'Flow_DR', ...
%     'Snore_DR', 'Position_DR' };

% NOTE: this are the polysomnography-only channels
REQUIRED_EDF_SIGNALS = { { 'Kinn 1', 'Re Bein', 'Li Bein', 'E1-M2',  'E2-M1', 'C3-M2', 'C4-M1', 'O1-M2', 'O2-M1', 'F3-M2', 'F4-M1' }, ...
    { 'Chin1-Chin2', 'Rat1-Rat2', 'Lat1-Lat2', 'LOC-A2', 'ROC-A1', 'C3-A2', 'C4-A1', 'O1-A2', 'O2-A1', 'F3-A2', 'F4-A1' } };

% NOTE: mapped channels have different sampling frequency => becomes
% problem when combining raw-data!

tic

disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );

% disp( 'Extracting RAW events of MSR only ...' );
% extractRawEventsPatientFolder(  CONF.PATIENTS_DATA_PATH, OTUPUT_FOLDER, REQUIRED_EDF_SIGNALS, ...
%     EVENT_CLASSES, false, true, false );
% disp( 'Finished Extracting RAW events of MSR only.' );

% disp( 'Extracting RAW events of ZEPHYR only ...' );
% extractRawEventsPatientFolder(  CONF.PATIENTS_DATA_PATH, OTUPUT_FOLDER, REQUIRED_EDF_SIGNALS, ...
%     EVENT_CLASSES, false, false, true );
% disp( 'Finished Extracting RAW events of ZEPHYR only.' );
% 
disp( 'Extracting RAW events of MSR & ZEPHYR ...' );
extractRawEventsPatientFolder(  CONF.PATIENTS_DATA_PATH, OTUPUT_FOLDER, REQUIRED_EDF_SIGNALS, ...
    EVENT_CLASSES, false, true, true );
disp( 'Finished Extracting RAW events of MSR & ZEPHYR.' );

% disp( 'Extracting RAW events of EEG only ...' );
% extractRawEventsPatientFolder(  CONF.PATIENTS_DATA_PATH, OTUPUT_FOLDER, REQUIRED_EDF_SIGNALS, ...
%     EVENT_CLASSES, true, false, false );
% disp( 'Finished Extracting RAW events of EEG only.' );

% NOTE: ignoring all EEG-combinations because resulting in out of memory
% disp( 'Extracting RAW events of EEG & MSR ...' );
% extractRawEventsPatientFolder(  CONF.PATIENTS_DATA_PATH, OTUPUT_FOLDER, REQUIRED_EDF_SIGNALS, ...
%     EVENT_CLASSES, true, true, false );
% disp( 'Finished Extracting RAW events of EEG & MSR.' );
% 
% disp( 'Extracting RAW events of EEG & ZEPHYR ...' );
% extractRawEventsPatientFolder(  CONF.PATIENTS_DATA_PATH, OTUPUT_FOLDER, REQUIRED_EDF_SIGNALS, ...
%     EVENT_CLASSES, true, false, true );
% disp( 'Finished Extracting RAW events of EEG & ZEPHYR.' );
% 
% disp( 'Extracting RAW events of EEG & MSR & ZEPHYR ...' );
% extractRawEventsPatientFolder(  CONF.PATIENTS_DATA_PATH, OTUPUT_FOLDER, REQUIRED_EDF_SIGNALS, ...
%     EVENT_CLASSES, true, true, true );
% disp( 'Finished Extracting RAW events of EEG & MSR & ZEPHYR.' );

disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );

toc