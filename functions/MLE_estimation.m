function [spectrum] = MLE_estimation(para, X, H, target_para, STAR_array, sensor_array)
%Maximum Likelihood Estimation (MLE) of the 2D DOAs of the target
%  [spectrum] = MLE_estimation(para, X, H, target_para, STAR_array, sensor_array)
%Inputs:
%   para: structure of the initial parameters
%   X: structure of the obtained optimization variables
%   H: BS-STARS channel
%   target_para: target paramaters
%   BS_array: locations of antennas at the BS array
%   STAR_array: location of elements at the STARS array
%   sensor_array: location of elements at the sensor
%Outputs:
%   spectrum: spectrum of MLE
%Date: 20/06/2022
%Author: Zhaolin Wang

%% generate transmit signal 
[V,D] = eig(X.Rs); d = diag(abs(D));
Pr = sqrt(d') .* V;
C = X.P * sqrt(1/2) * (randn(para.K, para.L) + 1i*randn(para.K, para.L));
S = Pr * sqrt(1/2) * (randn(para.M, para.L) + 1i*randn(para.M, para.L));
T = C + S;
T = diag(X.theta_r)*H*T;

%% steering vector
a = steering_vector(STAR_array, target_para.phi_h*pi/180, target_para.phi_v*pi/180);
b = steering_vector(sensor_array, target_para.phi_h*pi/180, target_para.phi_v*pi/180);

%% signal model
G_S = target_para.alpha * b * a.'; 
N_s = sqrt(para.noise/2)*(randn(para.N_sensor, para.L) + 1i * randn(para.N_sensor, para.L));
Y_s = G_S*T + N_s;
y_s = vec(Y_s);


%% calculate spectrum of MLE
phi_h_search=linspace(0, 180,500);
phi_v_search = linspace(-90,90,500);

spectrum = zeros(length(phi_h_search), length(phi_v_search));
for h = 1:length(phi_h_search)
    for v = 1:length(phi_v_search)

        a_search = steering_vector(STAR_array, phi_h_search(h)*pi/180,phi_v_search(v)*pi/180);
        b_search = steering_vector(sensor_array, phi_h_search(h)*pi/180,phi_v_search(v)*pi/180);
    
        delta = vec(b_search*a_search.'*T);
        spectrum(v,h) = abs(delta'*y_s) / norm(delta)^2;

    end
end

spectrum = spectrum ./ max(max(spectrum));

figure; hold on; colormap('hot');
mesh(phi_h_search ,phi_v_search,spectrum); 
title('Normalized Spectrum of MLE');
xlabel("Azimuth angle (degree)"); ylabel("Elevation angle (degree)"); colorbar;
xlim([0,180]); ylim([-90,90]); 
view([0,90]); 

end

