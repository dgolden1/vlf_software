function [scm_out, efi_out, common_epoch] = get_scm_efi_on_common_epoch(scm, scm_epoch, efi, efi_epoch)
% Function to put SCM and EFI data on a common epoch
% Epochs are only included in the output if there is both scm and efi data
% within four seconds of that epoch (the normal cadence of the filter bank
% FBK data).

% By Daniel Golden (dgolden1 at stanford dot edu) November 2011
% $Id$

common_epoch = (min([scm_epoch; efi_epoch]):4/86400:max([scm_epoch; efi_epoch])).';
% common_epoch = (datenum([2008 01 01 0 0 03]):4/86400:max([scm_epoch; efi_epoch])).';

% For each epoch, find the distance to the nearest scm epoch and the
% nearest efi epoch
dist_to_scm_epoch = abs(common_epoch - scm_epoch(interp1(scm_epoch, 1:length(scm_epoch), common_epoch, 'nearest', 'extrap')));
dist_to_efi_epoch = abs(common_epoch - efi_epoch(interp1(efi_epoch, 1:length(efi_epoch), common_epoch, 'nearest', 'extrap')));

idx_valid = dist_to_efi_epoch < 4/86400 & dist_to_scm_epoch < 4/86400;

common_epoch = common_epoch(idx_valid);
scm_out = interp1(scm_epoch, scm, common_epoch, 'nearest');
efi_out = interp1(efi_epoch, efi, common_epoch, 'nearest');
