% Test PatientDataStratification 

load( [ CONF.ALL_PATIENTS_DATA_PATH 'allpatients_EVENTS_EEG.mat' ] );
dataStratificationRatios = [0.6 0.2 0.2];
stratifiedPatientData = PatientDataStratificator(allPatients, dataStratificationRatios);
