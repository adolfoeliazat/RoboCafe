function [fval] = MinFunc3d_TOF(x,y,z,X,Y,Z,d,NumBeacons);
fval = 0;

for j = 1:NumBeacons
    fval = fval + (sqrt((X(j)-x)^2 + (Y(j)-y)^2 + (Z(j)-z)^2) -d(j))^2;
end
