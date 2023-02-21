function [a] = steering_vector(array, theta, phi)
%Calculate the steering vector
%  [a] = steering_vector(array, theta, phi)
%Inputs:
%   array: locations of antennas in the antenna array
%   theta: azimuth angle of the target
%   phi: elevation angle of the target
%Outputs:
%   a: steering vector
%Date: 20/06/2022
%Author: Zhaolin Wang

a = exp(-1i*array*K(theta,phi));
end

%% Wavenumber vector
function k = K(theta,phi)
k = pi * [cos(theta).*cos(phi), sin(theta).*cos(phi), sin(phi)]';
end

