function [validationRMSE, validationPredictions] = trainRegressionModel_ForPoly3Gamma(trainingData)
%  Input:
%      trainingData: a matrix with features and the last column the ground truth
%
%  Output:
%      validationPredictions: a vector with the predicted parameter gamma
%
%      validationRMSE: a double containing the RMSE. 
%
% Copyright (c) 2020-2021, Angeliki Katsenou, angeliki.katsenou@bristol.ac.uk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Extract predictors and response
inputTable = array2table(trainingData, 'VariableNames', {'column_1', 'column_2', 'column_3', 'column_4', 'column_5', 'column_6', 'column_7', 'column_8', 'column_9', 'column_10', 'column_11', 'column_12', 'column_13', 'column_14', 'column_15', 'column_16', 'column_17', 'column_18', 'column_19', 'column_20', 'column_21', 'column_22'});

predictorNames = {'column_1', 'column_2', 'column_3', 'column_4', 'column_5', 'column_6', 'column_7', 'column_8', 'column_9', 'column_10', 'column_11', 'column_12', 'column_13', 'column_14', 'column_15', 'column_16', 'column_17', 'column_18', 'column_19', 'column_20', 'column_22'};
predictors = inputTable(:, predictorNames);
response = inputTable.column_21;
isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];

% Data transformation: Select subset of the features
includedPredictorNames = predictors.Properties.VariableNames([true false true false true true true true true false false true true true true true true false false false false]);
predictors = predictors(:,includedPredictorNames);
isCategoricalPredictor = isCategoricalPredictor([true false true false true true true true true false false true true true true true true false false false false]);

% Train the GP regression model
regressionGP = fitrgp(...
    predictors, ...
    response, ...
    'BasisFunction', 'constant', ...
    'KernelFunction', 'matern52', ...
    'Standardize', true);


% Extract predictors and response
inputTable = array2table(trainingData, 'VariableNames', {'column_1', 'column_2', 'column_3', 'column_4', 'column_5', 'column_6', 'column_7', 'column_8', 'column_9', 'column_10', 'column_11', 'column_12', 'column_13', 'column_14', 'column_15', 'column_16', 'column_17', 'column_18', 'column_19', 'column_20', 'column_21', 'column_22'});

predictorNames = {'column_1', 'column_2', 'column_3', 'column_4', 'column_5', 'column_6', 'column_7', 'column_8', 'column_9', 'column_10', 'column_11', 'column_12', 'column_13', 'column_14', 'column_15', 'column_16', 'column_17', 'column_18', 'column_19', 'column_20', 'column_22'};
predictors = inputTable(:, predictorNames);
response = inputTable.column_21;
isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];

% Perform cross-validation
partitionedModel = crossval( regressionGP, 'KFold', 10);

% Compute validation predictions
validationPredictions = kfoldPredict(partitionedModel);

% Compute validation RMSE
validationRMSE = sqrt( kfoldLoss(partitionedModel, 'LossFun', 'mse') );
