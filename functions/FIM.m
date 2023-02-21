function [J_pp, J_pa, J_aa] = FIM(para, R, alpha, B, B_h, B_v)
%Calculate the FIM
%  [J_pp, J_pa, J_aa] = FIM(para, R, alpha, B, B_h, B_v)
%Inputs:
%   para: structure of the initial parameters
%   R: covariance matrix
%   alpha: complex amplitude
%   B: sensing channel
%   B_h: derivation of B w.r.t. phi_h
%   B_v: derivation of B w.r.t. phi_v
%Outputs:
%   J_pp, J_pa, J_aa: elements in FIM
%Date: 20/06/2022
%Author: Zhaolin Wang

J_hh = 2*abs(alpha)^2*para.L/para.noise * real( trace(B_h*R*B_h') );
J_hv = 2*abs(alpha)^2*para.L/para.noise * real( trace(B_h*R*B_v') );
J_vv = 2*abs(alpha)^2*para.L/para.noise * real( trace(B_v*R*B_v') );

J_pp = [J_hh, J_hv; J_hv, J_vv];

J_pa = 2*real(conj(alpha)*para.L/para.noise * [trace(B*R*B_h'); trace(B*R*B_v')] * [1, 1i]);

J_aa = 2*para.L/para.noise*eye(2)*trace(B*R*B');
   
end

