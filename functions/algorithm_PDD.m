function [X] = algorithm_PDD(para, H, h, target_para)
%PDD algorithm for minimizing CRB subject to the communication SINR constraints
%  [X] = algorithm_PDD(para, H, h, target_para)
%Inputs:
%   para: structure of the initial parameters
%   H: BS-STARS channel
%   h: STARS-user channels
%   target_para: target paramaters
%Outputs:
%   X: structure of the obtained optimization variables
%Date: 20/06/2022
%Author: Zhaolin Wang

rho = 1; % penalty term
c = 0.95; % reduction factor of rho
epsilon = 1e-4; % convergence criteria

%% initialization
X.theta_t = ones(para.N_RIS,1);
X.theta_r = zeros(para.N_RIS,1);

% dual variables
Upsilon = zeros(para.N_RIS, para.N_RIS);


%% PDD algorthm
v_all = []; CRB_all = [];
eta = 10;
disp('%%%%%%%%%%%%%%%%%%%%%%%%%% Outer Loop - 1 %%%%%%%%%%%%%%%%%%%%%%%%%%');
for i = 1:40

    % optimize AL problem
    [X, CRB] = algorithm_BCD(para, X, Upsilon, rho, H, h, target_para);
    
    CRB_all = [CRB_all, CRB];
    % calculate constraint violation
    [v] = constraint_violation(X, H); disp(['i - ' num2str(i) ', v - ' num2str(v)]);
    v_all = [v_all, v];
    disp(['%%%%%%%%%%%%%%%%%%%%%%%%%% Outer Loop - ' num2str(i+1) ', Violation - ' num2str(v) ' %%%%%%%%%%%%%%%%%%%%%%%%%%']);
    
    if v < epsilon % algorithm converged
        break; 
    end
    
    if v <= eta    
        % update dual variables
        Theta_r = diag(X.theta_r);
        Upsilon = Upsilon + 1/rho*(X.F - Theta_r*H*X.Rx*H'*Theta_r');
    else
        % update penalty term
        rho = c*rho; 
        disp(['rho - ' num2str(rho)]);
    end

    eta = 0.99*v;

end
figure; 
subplot(2,1,1);
plot(CRB_all, '-ob', 'LineWidth', 1.5); 
xlabel('Number of cumulative BCD iterations'); 
ylabel('CRB');
subplot(2,1,2);
semilogy(v_all, '-or', 'LineWidth', 1.5); xlabel('Number of outer PDD iterations');
ylabel('Violation');


end


function [h] = constraint_violation(X, H)
    Theta_r = diag(X.theta_r);
    h = abs(X.F - Theta_r*H*X.Rx*H'*Theta_r');
    h = max(max(h));
end