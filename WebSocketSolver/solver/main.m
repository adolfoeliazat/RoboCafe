% This file simulates ground truth and calls the EstimatePos function and
% tests it
clc; clear; close all;

[ SearchLim, BeaconPos ] = ReadMap();
true_pos = [8.3 2.1 1.7]; % ground truth
LOSbeaconsID = [3 4 5 6 ]; %indicate which beacons are visible
LOSBeaconsPos = BeaconPos(LOSbeaconsID,:);
NoiseSig = 0.30/2;
%NoiseVar = (Noise2sig/2)^2;
Noise = NoiseSig*randn(length(LOSBeaconsPos),1);
RangeTrue = pdist2(LOSBeaconsPos,true_pos) + Noise;% True range

%type = 'f'; %
type = 'f';
if type=='f'
    % TOF ----------------------------------------------------
    type = 'f';
    TOF_TDOA = [LOSbeaconsID' RangeTrue];

else
    % TDOA ---------------------------------------------------
    type = 'a';
    t_offset = 2;
    TOATrue = RangeTrue + t_offset;
    TOF_TDOA = [LOSbeaconsID' TOATrue];
end

[ pos ] = EstimatePos(TOF_TDOA,type )