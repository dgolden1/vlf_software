function [net, tr] = sp_create_pr_neural_network(inputs, targets)
% Generate a neural network for determining whether emissions exist in a
% given epoch

% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id$

% Autogenerated by nprtool

% Create Network
numHiddenNeurons = 15;  % Adjust as desired
net = newpr(inputs,targets,numHiddenNeurons);
net.divideParam.trainRatio = 70/100;  % Adjust as desired
net.divideParam.valRatio = 15/100;  % Adjust as desired
net.divideParam.testRatio = 15/100;  % Adjust as desired

% net.trainParam.max_fail = 20;

% Train and Apply Network
[net,tr] = train(net,inputs,targets);
outputs = sim(net,inputs);

% Plot
% plotperf(tr)
plotconfusion(targets(tr.trainInd), outputs(tr.trainInd), 'Main', ...
  targets(tr.valInd), outputs(tr.valInd), 'Validation', ...
  targets(tr.testInd), outputs(tr.testInd), 'Test', ...
  targets, outputs, 'Total');