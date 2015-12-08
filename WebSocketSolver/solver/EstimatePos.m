function [ pos ] = EstimatePos(TOF_TDOAtemp,type )
% TOF_TDOAtemp: An Nx2 matrix where the first column contains the ID of the
%       beacons whose range measurement was received. The second column
%       contains either the TOF values or the TOA values. If TOA values are
%       got, then TDOA method is used. TOA to TDOA part is done in this
%       code, so if 5 beacons are seen and we effetively use 4 TDOA values,
%       the TOF_TDOA vector should have all the 5 beacons TOA values.
% type: could be 'f' for TOF or 'a' for TDOA
% pos: [x,y] estimate of receiver position

% Read the map data from a file tht we hand-code
[ SearchLim, BeaconPos ] = ReadMap();

[val,ind] = sort(TOF_TDOAtemp(:,2));
TOF_TDOA = TOF_TDOAtemp(ind,:); % sort such that shortest range/tof/toa 
%is the first row, so that if we are doing tdoa, we subtract the shortest range

LOSbeaconsID = TOF_TDOA(:,1);
LOSBeaconsPos = BeaconPos(LOSbeaconsID,:); % Read the Beacon positions

Nb = length(LOSbeaconsID); % Number of beacons
RangeExp = TOF_TDOA(:,2);

% Parameters for search
XlimSearchInit = SearchLim(1,:);
YlimSearchInit = SearchLim(2,:);
ZlimSearchInit = SearchLim(3,:);
res = [0.2 0.2 0.1;...
    %0.1 0.1 0.02;...
    0.02 0.02 0.01];

[x,y,z] = tri_multi_laterate3D_VariedResNbeac(LOSBeaconsPos,RangeExp,XlimSearchInit,YlimSearchInit,ZlimSearchInit, res,type);
x_est = x; y_est = y;

pos = [x_est y_est];

figure; scatter(BeaconPos(:,1),BeaconPos(:,2));

end

