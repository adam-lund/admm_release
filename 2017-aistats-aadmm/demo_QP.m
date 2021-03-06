%demo ADMM, QP
close all;
clear;
clc;
addpath('./solver')
rng(2016);

%% minimize  1/2 u'Qu+q'u s.t. Au<=b
nu=500;
nb=250;

Q1 = randn(nu, nu)/10.0;
Q=Q1'*Q1;

fprintf('QP, condition of Q:%e\n', cond(Q));
q = randn(nu, 1);
A = randn(nb, nu);
b = randn(nb, 1);


%% paramters
opts = get_default_opts();
opts.maxiter = 200; %max iteration
opts.tau = 0.1; %initial stepsize
opts.tol = 1e-5; %relative stop criterion, 
opts.verbose = 0; 


fprintf('ADMM start...\n');
%%
% ADMM
opts.adp_flag = 0; %fix tau, no adaptation
[sol1,outs1] = aadmm_qp(Q, q, A, b, opts);
fprintf('vanilla ADMM complete after %d iterations!\n', outs1.iter);

% adaptive ADMM
opts.adp_flag = 5; %AADMM with spectral penalty
[sol2,outs2] = aadmm_qp(Q, q, A, b, opts);
fprintf('adaptive ADMM complete after %d iterations!\n', outs2.iter);

% Nesterov ADMM
opts.adp_flag = 2; % Nesterove ADMM
[sol3,outs3] = aadmm_qp(Q, q, A, b, opts);
fprintf('Nesterove ADMM complete after %d iterations!\n', outs3.iter);

% adaptive ADMM baseline: residual balance
opts.adp_flag = 3; %residual balance
[sol4,outs4] = aadmm_qp(Q, q, A, b, opts);
fprintf('RB ADMM complete after %d iterations!\n', outs4.iter);

% adaptive ADMM baseline: normalized residual balance
opts.adp_flag = 4; %normalized residual balance
[sol5, outs5] = aadmm_qp(Q, q, A, b, opts);
fprintf('NRB ADMM complete after %d iterations!\n', outs5.iter);

%%
legends = {'Vanilla ADMM', 'Fast ADMM', 'Residual balance', 'Normalized RB', 'Adaptive ADMM'};
figure,
semilogy(outs1.tols, '-.g'),
hold,
semilogy(outs3.tols, '-.r');
semilogy(outs4.tols, '--m');
semilogy(outs5.tols, '--', 'Color',[0.7 0.2 0.2]);
semilogy(outs2.tols, 'b');
ylabel('Relative residual', 'FontName','Times New Roman');
ylim([10^(-3) 10]);
xlabel('Iteration', 'FontName','Times New Roman');
legend(legends, 'FontName','Times New Roman');