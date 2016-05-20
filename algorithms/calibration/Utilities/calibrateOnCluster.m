% For use after exporting calibration job toa HPC cluster. vis the GUI
% Written by Tim Peterson Jan 2016. Edited May 2016 to allow sequential 
% calibration of multiple models.
% NOTE: The variable 'modelPath' and 'iModel' should have been set by the matlab task
% script (see jobSubmission.m').

display('Moving to project file path...');
cd ..
cd ..
cd ..
addpath(genpath(pwd));

display('Loading list of model names...');
modelName = readtable('ModelNames.txt');
modelName = modelName{iModel,:};
modelName = strtrim(modelName);

% Determine the number of models
isValidModel = cellfun(@(x) ~isempty(x), modelName);
modelName = modelName(isValidModel);
nModels = length(modelName);

cd('models');

% Loop through each model name and calibrate
for i=1:nModels

    % Read in model options
    display('Reading in model options...');    
    cd(modelName{i});
    fid = fopen('options.txt');
    lineString = strtrim(fgetl(fid));
    calibStartDate = datenum(lineString);ls

    lineString = strtrim(fgetl(fid));
    calibEndDate = datenum(lineString);
    calibMethod = strtrim(fgetl(fid));
    lineString = strtrim(fgetl(fid));
    calibMethodSetting= str2num(lineString);

    % Read in model .mat file
    display('Loading model data file ...');
    load('HPCmodel.mat');

    % Calibrate model
    saveResults=false;
    try
        display('Starting calibration...');
        calibrateModel( model, calibStartDate, calibEndDate, calibMethod,  calibMethodSetting);
        saveResults=true;
    catch ME
        display(['Calibration failed: ',ME.message]);
        cd ..
        continue;
    end

    if saveResults
        try
            display('Saving results...');
            save('results.mat','model');
        catch ME
            display(['Saving results failed: ',ME.message]);
        end
    end
    
    % Exit model folder
    cd ..
end

% Kill matlab. This is an unfortuante requirement when the MEX function
% doIRFconvolution.c offloads to Xeon Phi Cards (using Intel icc compiler).
display('Killing matlab...');
pause(60);
system(['kill ',num2str(feature('getpid'))]);