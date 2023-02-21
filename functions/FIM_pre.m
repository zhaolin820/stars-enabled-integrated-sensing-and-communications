function [B, B_h, B_v] = FIM_pre(para, STAR_array, sensor_array)
%Calculate the derivations in FIM
%  [B, B_h, B_v] = FIM_pre(para, STAR_array, sensor_array)
%Inputs:
%   para: structure of the initial parameters
%   STAR_array: location of elements at the STARS array
%   sensor_array: location of elements at the sensor
%Outputs:
%   B: sensing channel
%   B_h: derivation of B w.r.t. phi_h
%   B_v: derivation of B w.r.t. phi_v
%Date: 20/06/2022
%Author: Zhaolin Wang

phi_h = para.target_loc(2)*pi/180; phi_v = para.target_loc(3)*pi/180; 

a = steering_vector(STAR_array, phi_h,phi_v);
b = steering_vector(sensor_array, phi_h,phi_v);
Ea = diag(a);
Eb = diag(b);
B = b*a.';

B_h = 1i * pi * sin(phi_h)*cos(phi_v) * ( Eb*sensor_array(:,1)*a.' + b*STAR_array(:,1).'*Ea.');
B_v = 1i * pi * cos(phi_h)*sin(phi_v) * ( Eb*sensor_array(:,1)*a.' + b*STAR_array(:,1).'*Ea.') - 1i * pi * cos(phi_v)* b * STAR_array(:,3).' * Ea.';

end

