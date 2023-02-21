function [BS_array, STAR_array, sensor_array] = generate_arrays(para)
%Generate the locations of antennas in the antenna arrays
%  [values] = para_init()
%Inputs:
%   para: structure of the initial parameters
%Outputs:
%   BS_array: locations of antennas at the BS array
%   STAR_array: location of elements at the STARS array
%   sensor_array: location of elements at the sensor
%Date: 20/06/2021
%Author: Zhaolin Wang


BS_array = [(1:para.M)'-(para.M+1)/2, zeros(para.M,1), zeros(para.M,1)];
sensor_array = [(1:para.N_sensor)'-(para.N_sensor+1)/2, zeros(para.N_sensor,1), zeros(para.N_sensor,1)];

STAR_array = zeros(para.N_RIS, 3);
for i = 1:para.RIS_size(1)
    for  j = 1:para.RIS_size(2)
        n = (i-1)*para.RIS_size(2) + j;
        STAR_array(n,:) = [ i, 0, j ];
    end
end
STAR_array = STAR_array - [(para.RIS_size(1)+1)/2, 0, 0];

figure; hold on;
plot3(STAR_array(:,1),STAR_array(:,2),STAR_array(:,3),'sb','LineWidth',2,'MarkerSize',10);
plot3(sensor_array(:,1),sensor_array(:,2),sensor_array(:,3),'sr','LineWidth',2,'MarkerSize',10);
title('Locations of Antennas');
grid on;
xlabel('x'); 
ylabel('y');
zlabel('z');
view(45,30);
end

