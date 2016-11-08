classdef CONF
    % Encapsulates some common configuration parameters
    %   
    
    properties(Constant)
%         PATIENTS_DATA_PATH = 'C:\Data\Projects\SmartSleep\SmartSleep Data\Barmelweid\SmartSleepPatienten\';
%         ALL_PATIENTS_DATA_PATH = 'C:\Data\Projects\SmartSleep\SmartSleep Data\Barmelweid\SmartSleepPatienten\all\';

        PATIENTS_DATA_PATH = '\\VBOXSVR\SmartSleep\SmartSleep Data\Barmelweid\SmartSleepPatienten\';
        ALL_PATIENTS_DATA_PATH = '\\VBOXSVR\SmartSleep\SmartSleep Data\Barmelweid\SmartSleepPatienten\all\';
        
        WEKA_PATH = 'C:\Program Files\Weka-3-8';
                
        RAW_DATA_SUBFOLDER = '1_raw';
        PREPROCESSED_DATA_SUBFOLDER = '2_preprocessed';
        TRAINED_DATA_SUBFOLDER = '3_trained';
        CLASSIFIED_DATA_SUBFOLDER = '4_classified';
        
        ALL_PATIENTS_PREPROCESSED_DATA_PATH = [ CONF.ALL_PATIENTS_DATA_PATH CONF.PREPROCESSED_DATA_SUBFOLDER '\' ];
        ALL_PATIENTS_TRAINED_DATA_PATH = [ CONF.ALL_PATIENTS_DATA_PATH CONF.TRAINED_DATA_SUBFOLDER '\' ];
        ALL_PATIENTS_TRAINED_DNB_DATA_PATH = [ CONF.ALL_PATIENTS_DATA_PATH CONF.TRAINED_DATA_SUBFOLDER '\DBN\' ];
        ALL_PATIENTS_CLASSIFIED_DATA_PATH = [ CONF.ALL_PATIENTS_DATA_PATH CONF.CLASSIFIED_DATA_SUBFOLDER '\' ];
        ALL_PATIENTS_CLASSIFIED_WEKA_DATA_PATH = [ CONF.ALL_PATIENTS_DATA_PATH CONF.CLASSIFIED_DATA_SUBFOLDER '\Weka\' ];
        
        %data sources and combinations
        EEG = 'EEG';
        MSR = 'MSR';
        ZEPHYR = 'ZEPHYR';
        MSR_ZEPHYR = 'MSR_ZEPHYR';
        EEG_MSR = 'EEG_MSR';
        EEG_ZEPHYR = 'EEG_ZEPHYR';
        EEG_MSR_ZEPHYR = 'EEG_MSR_ZEPHYR';
    end
    
    methods(Static)
        function setup()
            setenv('JAVA_HOME','C:\Program Files\Java\jdk1.8.0_102');
            setenv('PATH','C:\Program Files\Java\jdk1.8.0_102\bin');
        end
%         
%         function outputPath = getOutputPath()
%             outputPath = [ CONF.ALL_PATIENTS_DATA_PATH 'results\DBN' ];
%         end
%         
        function outputPath = getOutputPathWithTimestamp()
            outputPath = [ CONF.getOutputPath() '\' datestr(now,'yyyy-mm-dd_HH-MM-SS')];
        end
        
        function outputPath = getRawDataOutputPath()
            outputPath = [ CONF.ALL_PATIENTS_DATA_PATH 'results\DBN_rawdata' ];
        end
        
        function outputPath = getRawDataOutputPathWithTimestamp()
            outputPath = [ CONF.getRawDataOutputPath() '\' datestr(now,'yyyy-mm-dd_HH-MM-SS') ];
        end        
        
    
    end

end
