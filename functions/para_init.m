function [values] = para_init()
%Construct a struct of the initial values for all the parameters 
%  [values] = para_init()
%Inputs:
%   None
%Outputs:
%   values: a struct
%Date: 28/05/2021
%Author: Zhaolin Wang

values.noise_dB = -110; % noise power in dBm
values.noise = 10^(values.noise_dB/10); 


values.M = 10; % overall antennas
values.RIS_size = [5,2]; % reflecting elements at RIS
values.N_RIS = values.RIS_size(1)*values.RIS_size(2); % reflecting elements at RIS
values.N_sensor = 5;
values.L = 100;

values.Pt = 10^(30/10); % overall transmit power
values.n = 1; % equivalent noise power
values.K = 4; % user number
values.phi_m = 0; % desired direction
values.pathloss_indirect = @(d) 30 + 20*log10(d); % path loss with d in m
% values.pathloss_indirect = @(d) 35.6 + 22*log10(d); % path loss with d in m
values.pathloss_direct =  @(d) 32.6 + 36.7*log10(d); % path loss with d in m

values.rician = 1; % rician factor
values.gamma = 10^(0/10);

values.STAR_loc = [0,0,0];
values.BS_loc = [30, 40, 0];

% user locations
range = [20, 50];
values.user_loc = zeros(values.K, 3);
for i = 1:values.K/2
    values.user_loc(i,:) = [ (range(2)-range(1))*rand(1) + range(1), -180*rand(1), 180*rand(1)-90 ];
end

for i = values.K/2+1:values.K
    values.user_loc(i,:) = [ (range(2)-range(1))*rand(1) + range(1), 180*rand(1), 180*rand(1)-90 ];
end

% target locations
values.target_loc = [30, 120, 30];

end

