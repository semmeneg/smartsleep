
% disp( 'DBN-Training on RAW-events of MSR ONLY ...' );
% trainPatientsRawEventsDBN( CONF.ALL_PATIENTS_DATA_PATH, 'allpatients_RAWEVENTS_MSR' );
% disp( 'Finished DBN-Training on RAW-events of MSR ONLY.' );

% NOTE: ignore ZEPHYR for now, as its data is garbage because device fell
% off during night which led to invalid data (identified by HR = 0 for a
% prolonged period - not assuming the patient died and then rose from the dead...)
disp( 'DBN-Training on RAW-events of ZEPHYR ONLY ...' );
trainPatientsRawEventsDBN( CONF.ALL_PATIENTS_DATA_PATH, 'allpatients_RAWEVENTS_ZEPHYR' );
disp( 'Finished DBN-Training on RAW-events of ZEPHYR ONLY.' );
% 
% disp( 'DBN-Training on RAW-events of MSR & ZEPHYR ...' );
% trainPatientsRawEventsDBN( CONF.ALL_PATIENTS_DATA_PATH, 'allpatients_RAWEVENTS_MSR_ZEPHYR' );
% disp( 'Finished DBN-Training on RAW-events of MSR & ZEPHYR.' );
% 
% % NOTE: ignoring all EEG-related data because EEG causes extreme huge
% % amount of data due to lots of channels and high sample rate (most of the
% % channels are sampled at 200Hz)
% disp( 'DBN-Training on RAW-events of EEG ONLY ...' );
% trainPatientsRawEventsDBN( CONF.ALL_PATIENTS_DATA_PATH, 'allpatients_RAWEVENTS_EEG' );
% disp( 'Finished DBN-Training on RAW-events of EEG ONLY.' );
% 
% disp( 'DBN-Training on RAW-events of EEG & MSR ...' );
% trainPatientsRawEventsDBN( CONF.ALL_PATIENTS_DATA_PATH, 'allpatients_RAWEVENTS_EEG_MSR' );
% disp( 'Finished DBN-Training on RAW-events of EEG & MSR.' );
% 
% disp( 'DBN-Training on RAW-events of EEG & ZEPHYR ...' );
% trainPatientsRawEventsDBN( CONF.ALL_PATIENTS_DATA_PATH, 'allpatients_RAWEVENTS_EEG_ZEPHYR' );
% disp( 'Finished DBN-Training on RAW-events of EEG & ZEPHYR.' );
% 
% disp( 'DBN-Training on RAW-events of EEG & MSR & ZEPHYR ...' );
% trainPatientsRawEventsDBN( CONF.ALL_PATIENTS_DATA_PATH, 'allpatients_RAWEVENTS_EEG_MSR_ZEPHYR' );
% disp( 'Finished DBN-Training on RAW-events of EEG & MSR & ZEPHYR.' );