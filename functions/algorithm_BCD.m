function [X, CRB_all] = algorithm_BCD(para, X, Upsilon, rho, H, h, target_para)
%BCD algorithm for solving the AL problem
%  [X, CRB_all] = algorithm_BCD(para, X, Upsilon, rho, H, h, target_para)
%Inputs:
%   para: structure of the initial parameters
%   X: structure of the obtained optimization variables in previous PDD iteration
%   Upsilon: dual variable
%   rho: penalty factor
%   H: BS-STARS channel
%   h: STARS-user channels
%   target_para: target paramaters
%Outputs:
%   X: structure of the obtained optimization variables in current PDD iteration
%   CRB_all: obtained CRBs in each BCD iteration
%Date: 20/06/2022
%Author: Zhaolin Wang

obj_pre = 100;
CRB_all = [];
for i = 1:40
    [Q, F, P, Rs, Rx] = update_F_waveform(para, X, Upsilon, rho, H, h, target_para); X.F = F; X.P = P; X.Rs = Rs; X.Rx = Rx;
    [theta_t, theta_r] = update_theta(para, X, Upsilon, rho, H, h); X.theta_t = theta_t; X.theta_r = theta_r;
    

    % calculate the fractional reduction
    Theta_r = diag(X.theta_r);
    Diff = norm(X.F - Theta_r*H*X.Rx*H'*Theta_r' + rho*Upsilon,'fro')^2;
    CRB = trace_inv(Q);
    obj = 1e4*CRB + 1/(2*rho) * Diff;
    reduction = abs(obj_pre - obj) / obj_pre;
    
    % calculate CRB
    [J_pp, J_pa, J_aa] = FIM(para, Theta_r*H*X.Rx*H'*Theta_r', target_para.alpha, target_para.B, target_para.B_h, target_para.B_v);
    CRB_R = inv(J_pp - J_pa * inv(J_aa) * J_pa.');
    CRB_R = real(trace(CRB_R)); 
    CRB_all = [CRB_all, CRB_R];
    disp(['Inner loop - ' num2str(i) ', CRB - ' num2str(CRB_R)]);
    
    if reduction < 1e-3
        break; 
    end
    obj_pre = obj;
end

end


%%
function [Q, F, P, Rs, Rx] = update_F_waveform(para, X, Upsilon, rho, H, h, target_para)


Theta_t = diag(X.theta_t); Theta_r = diag(X.theta_r);
h_eff = H'*Theta_t'*h;

cvx_begin quiet
    % optimization variables
    variable F(para.N_RIS,para.N_RIS) complex semidefinite
    variable Q(2, 2) complex semidefinite
    variable PP(para.M, para.M, para.K) complex
    variable Rx(para.M, para.M) complex semidefinite

    % constraints
    [J_pp, J_pa, J_aa] = FIM(para, F, target_para.alpha, target_para.B, target_para.B_h, target_para.B_v);
    S = [J_pp - Q, J_pa; J_pa', J_aa];
    S == hermitian_semidefinite(4);

    real(trace(Rx)) <= para.Pt;
    Rx - sum(PP,3) == hermitian_semidefinite(para.M);
    for k = 1:para.K
        Pk = PP(:,:,k); hk = h_eff(:,k);
        Pk == hermitian_semidefinite(para.M); 
        (1 + 1/para.gamma)*quad_form(hk, Pk) >= quad_form(hk, Rx) + 1;
    end

    % objective function
    Diff = F - Theta_r*H*Rx*H'*Theta_r' + rho*Upsilon;
    obj = 1e4*trace_inv(Q) + 1/(2*rho) * sum_square_abs(vec(Diff));
    minimize(obj);  
cvx_end   

P = zeros(para.M, para.K);
for k = 1:para.K
    Pk = PP(:,:,k); hk = h_eff(:,k);
    P(:,k) = (hk' * Pk * hk)^(-1/2)*Pk*hk;
    
end
Rs = Rx - P*P';


end

%%
function [theta_t, theta_r] = update_theta(para, X, Upsilon, rho, H, h)

Rx = H*X.Rx*H';
[E,D] = eig(Rx); d = diag(abs(D)); R1 = length(d) - length(d(d<1e-3));
V = zeros(para.N_RIS, para.N_RIS, R1);
for k = 1:R1
    vk = sqrt(d(k)) * E(:,k);
    V(:,:,k) = diag(vk);
end

F = X.F + rho*Upsilon;

A = zeros(para.N_RIS, para.N_RIS, para.K);
for k = 1:para.K
    hk = h(:,k);
    ak = diag(hk')*H*X.P; Ak = diag(hk')*H*X.Rs*H'*diag(hk);
    akk = ak(:,k); ak(:,k) = [];
    A(:,:,k) = 1/para.gamma * (akk*akk')- ak*ak'-Ak;
end

Qt_n = X.theta_t*X.theta_t';
Qr_n = X.theta_r*X.theta_r';
cvx_begin quiet
    % optimization variables
    variable Qt(para.N_RIS, para.N_RIS) complex semidefinite
    variable Qr(para.N_RIS, para.N_RIS) complex semidefinite

    % constraints
    for k = 1:para.K
        real(trace(A(:,:,k)*conj(Qt))) >= 1;
    end
    diag(Qt + Qr) == ones(para.N_RIS,1);
    
    % objective function
    B = 0;
    for k = 1:R1
        Vk = V(:,:,k);
        B = B + Vk*Qr*Vk';
    end

    obj = norm(F-B,"fro");
    minimize(obj);
cvx_end

% construct rank-one solution through eigenvalue decompisition
[E,D] = eig(Qt); 
theta_t = sqrt(D(end,end)) * E(:,end);
[E,D] = eig(Qr); 
theta_r = sqrt(D(end,end)) * E(:,end);

end



