warning ( 'off', 'all' );
%warning ( 'on', 'EDF:missing' );
%warning ( 'on', 'EVENTS:missing' );
%warning ( 'on', 'PATIENT:nodata' );
warning ( 'on', 'PATIENT:eventMissmatch' );
warning ( 'on', 'PATIENT:channelsMissmatch' );

DELETE_OUTPUT_ONFIRSTRUN = true;

WEKA_PATH = 'C:\Program Files\Weka-3-8';
ALL_PATIENTS_PATH = 'C:\Data\SmartSleep\SmartSleep Data\Barmelweid\SmartSleepPatienten\';


ARFF_FOR_EACH_PATIENT = false;

EVENT_CLASSES = { 'Arousal', 'Artefakt', 'R', 'W', 'N1', 'N2', 'N3' };

% NOTE: this are all channels
% REQUIRED_EDF_SIGNALS = { 'Re Bein', 'EKG', 'Li Bein', 'Kinn 1', 'REF', ...
%     'E1-M2', 'E2-M1', 'C3-M2', 'C4-M1', 'O1-M2', 'O2-M1', 'F3-M2', ...
%     'F4-M1', 'Thermistor', 'Thorax', 'Abdomen', 'SpO2', 'Flow_DR', ...
%     'Snore_DR', 'Position_DR' };

% NOTE: this are the polysomnography-only channels
REQUIRED_EDF_SIGNALS = { { 'Kinn 1', 'Re Bein', 'Li Bein', 'E1-M2',  'E2-M1', 'C3-M2', 'C4-M1', 'O1-M2', 'O2-M1', 'F3-M2', 'F4-M1' }, ...
    { 'Chin1-Chin2', 'Rat1-Rat2', 'Lat1-Lat2', 'LOC-A2', 'ROC-A1', 'C3-A2', 'C4-A1', 'O1-A2', 'O2-A1', 'F3-A2', 'F4-A1' } };

tic

disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );

% EEG only
disp( 'Training on events EEG ONLY ...' );
trainFeatureEventsWEKAPatientFolder( ALL_PATIENTS_PATH, WEKA_PATH, DELETE_OUTPUT_ONFIRSTRUN, ...
   REQUIRED_EDF_SIGNALS, EVENT_CLASSES, ARFF_FOR_EACH_PATIENT, ...
   true, false, false );
disp( 'Finished training on events EEG ONLY.' );

% MSR only
disp( 'Training on events MSR ONLY ...' );
trainFeatureEventsWEKAPatientFolder( ALL_PATIENTS_PATH, WEKA_PATH, false, ...
   REQUIRED_EDF_SIGNALS, EVENT_CLASSES, ARFF_FOR_EACH_PATIENT, ...
   false, true, false );
disp( 'Finished training on events MSR ONLY.' );

% ZEPHYR only
disp( 'Training on events ZEPHYR ONLY ...' );
trainFeatureEventsWEKAPatientFolder( ALL_PATIENTS_PATH, WEKA_PATH, false, ...
   REQUIRED_EDF_SIGNALS, EVENT_CLASSES, ARFF_FOR_EACH_PATIENT, ...
   false, false, true );
disp( 'Finished training on events ZEPHYR ONLY.' );

% MSR & ZEPHYR
disp( 'Training on events MSR & ZEPHYR ...' );
trainFeatureEventsWEKAPatientFolder( ALL_PATIENTS_PATH, WEKA_PATH, false, ...
   REQUIRED_EDF_SIGNALS, EVENT_CLASSES, ARFF_FOR_EACH_PATIENT, ...
   false, true, true );
disp( 'Finished training on events MSR & ZEPHYR.' );

% EEG & MSR
disp( 'Training on events EEG & MSR ...' );
trainFeatureEventsWEKAPatientFolder( ALL_PATIENTS_PATH, WEKA_PATH, false, ...
   REQUIRED_EDF_SIGNALS, EVENT_CLASSES, ARFF_FOR_EACH_PATIENT, ...
   true, true, false );
disp( 'Finished training on events EEG & MSR.' );

% EEG & ZEPHYR
disp( 'Training on events EEG & ZEPHYR ...' );
trainFeatureEventsWEKAPatientFolder( ALL_PATIENTS_PATH, WEKA_PATH, false, ...
   REQUIRED_EDF_SIGNALS, EVENT_CLASSES, ARFF_FOR_EACH_PATIENT, ...
   true, false, true );
disp( 'Finished training on events EEG & ZEPHYR.' );

% EEG & MSR & ZEPHYR
disp( 'Training on events EEG & MSR & ZEPHYR ...' );
trainFeatureEventsWEKAPatientFolder( ALL_PATIENTS_PATH, WEKA_PATH, false, ...
   REQUIRED_EDF_SIGNALS, EVENT_CLASSES, ARFF_FOR_EACH_PATIENT, ...
   true, true, true );
disp( 'Finished training on events EEG & MSR & ZEPHYR.' );

disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );

toc