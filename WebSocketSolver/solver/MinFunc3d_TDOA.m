function [fval] = MinFunc3d_TDOA(x,y,z,X,Y,Z,toa,NumBeacons, c)
fval = 0;

for j = 2:NumBeacons
    fval = fval + (sqrt((X(j)-x)^2 + (Y(j)-y)^2 + (Z(j)-z)^2) - ...
        sqrt((X(1)-x)^2 + (Y(1)-y)^2 + (Z(1)-z)^2) -  toa(j) + toa(1))^2;
end