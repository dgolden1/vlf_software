function varargout = create_neural_network_inputs(events, nn_type)
% [inputs, targets] = create_neural_network_inputs(events)
% Extract inputs and targets from an emission database file.
% 
% If targets is requested as an output, only inputs with associated targets
% will be returned, along with their targets.  Otherwise, all the inputs
% and no targets will be returned.
% 
% If target is requested as an output, the nn_type can be:
%  'noise': target is 0 (noise) or 1 (emission)
%  'emission': target is 0 (chorus) or 1 (hiss)

% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id$

%% Setup
b_targets = nargout > 1;

%% Massage data into format suitable for neural network
if b_targets && isfield(events, 'type')
  
  b_typed = ~cellfun(@isempty, {events.type}); % Events for which the emissions are typed
  events = events(b_typed);

  switch nn_type
    case 'noise'
      targets = cellfun(@isempty, strfind({events.type}, 'noise')); % True if emission type is not 'noise'
      ec = [events.ec];
    case 'emission'
      b_chorus = ~cellfun(@isempty, strfind({events.type}, 'chorus'));
      b_hiss = ~cellfun(@isempty, strfind({events.type}, 'hiss'));
      events = events(b_chorus | b_hiss);

      targets = cellfun(@isempty, strfind({events.type}, 'chorus'));
      ec = [events.ec];
    otherwise
      error('Unknown type: %s', type);
  end
  
else
  ec = [events.ec];
  targets = [];
end

ec_fieldnames = fieldnames(ec);
assert(length(ec_fieldnames) == 19); % If I add or delete fields, I need to modify this function --DIG 2010-09-17

inputs = zeros(length(ec_fieldnames), length(ec));
for kk = 1:length(ec_fieldnames)
  field_val = [ec.(ec_fieldnames{kk})];
  
  % Certain fields need to be massaged for optimal use the the neural
  % network
  switch ec_fieldnames{kk}
    case {'f_peak', 'f_uc', 'f_lc', 'bw', 'xc_mean', 'max_lower_slope', 'max_upper_slope'}
      field_val(field_val == 0) = nan;
      inputs(kk,:) = log(abs(field_val));
    case 'xc_slope'
      inputs(kk,:) = 1./field_val;
    otherwise
      inputs(kk,:) = field_val;
  end
end

%% Assign output arguments
if nargout >= 1, varargout{1} = inputs; end
if nargout >= 2, varargout{2} = targets; end
