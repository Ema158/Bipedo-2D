function Func = CycleEssentialModelZMPvar_SSphase_t(R)

% This code is based in "CycleEssentialModelNoImpact".
% It is practically the same just the impact and the structure "robot" were added =)

% ==============================================================================================
global contA % To count the number of cycles performed
Hour = datestr(now,13); % Now ->Read the current hour and date, 13 -> store just the hour, -1 -> default...
fprintf([Hour ' -> Cycle k = %d (of 1200 maximum) for the EssentialModel \n'],contA);
% ==============================================================================================
% global robot gait_parameters
global gait_parameters
global scale
DxProp = R(1)/scale; % Proposed displacement in X
xpfProp = R(2); % Proposed final velocity in X

fprintf('Proposed values [Dx, Dy, xpf, ypf] = [%e,%e]\n',DxProp,xpfProp)
fprintf('-----------------------------------------------------\n')

S = gait_parameters.S;

xfProp = S/2 + DxProp;

X_final = [xfProp;xpfProp]; % previous step
[t,x0,Xt] = robot_step_EssModel_t(X_final); % "robot" structure is needed inside
% % Initial states (current step) after impact
% x0_step1 = X0_step1(1);
% y0_step1 = X0_step1(2);
% xp0_step1 = X0_step1(3);
% yp0_step1 = X0_step1(4);
% Final states (current step) after impact
% xf = Xt(end,1);
% yf = Xt(end,2);
% xpf = Xt(end,3);
% ypf = Xt(end,4);
% fprintf('Final states Step {k-1} = [%f,%f,%f,%f]\n',xfProp,yfProp,xpfProp,ypfProp)
% fprintf('Initial states Step {k} = [%f,%f,%f,%f]\n',x0_step1,y0_step1,xp0_step1,yp0_step1)
% fprintf('Final states Step {k} = [%f,%f,%f,%f]\n',xf_step1,yf_step1,xpf_step1,ypf_step1)

T = gait_parameters.T;

global noLanding
if (isempty(noLanding) || noLanding==0)    % if there was impact    
    % Xt -> It is the solution, i.e. X(t) = [x(t),y(t),xp(t),yp(t)], each COLUMN is one state
    xf = Xt(end,1);
    xpf = Xt(end,2);
    Tk = t(end); % Elapsed time to produce the impact
    
    % Function we want to find its roots
    %fac = scale;  % The factor is to give more enfasis to the selected error
%     Func = [xfProp - xf, yfProp - yf, xpfProp - xpf, ypfProp - ypf, fac*(T - Tk)];
    Func = [xfProp - xf, xpfProp - xpf];
    
    fprintf('Desired time step T = %f. Real time Step at cycle %d, Tk = %f\n',T,contA,Tk)
    fprintf('Proposed final values for the CoM states are: \n[xf(k), xpf(k)] = [%e,%e]\n',xfProp,xpfProp)
%     fprintf('After impact the values for the CoM states are: \n[x0(k+1), y0(k+1), xp0(k+1), yp0(k+1)] = [%f,%f,%f,%f]\n',x0, y0, xp0, yp0)
    fprintf('The final values for the CoM states are: \n[x(T)(k+1), xp(T)(k+1)] = [%e,%e]\n',xf,xpf)
%     fprintf('Function "[xf(k) - xf(k+1),yf(k) - yf(k+1), xpf(k) - xpf(k+1),ypf(k) - ypf(k+1), fac*(T - T(k))]"\n         = [%e,%e,%e,%e,%e]\n',Func)
%     fprintf('with fac = %d\n',fac)    
    fprintf('Function "[xf(k) - xf(k+1), xpf(k) - xpf(k+1)]"\n         = [%e,%e]\n',Func)
        
else % if there was impact
    fprintf('===============================================================================\n')
    fprintf(' Since there was no landing of the free foot, the states are not considered\n')
    fprintf('===============================================================================\n')
    % Start again...
    Func = ones(1,2);
%     xpf = 6.795860e-01; %
%     ypf = 1.909883e-01;
%     Dx = 2.881107e-03;  %
%     Dy = 4.968986e-04;  %
%     % Initial and final position is computed as (this is not used in here)    
%     xf = S/2 + Dx;
%     yf = D/2 + Dy;
    fprintf('Function = [%e,%e,%e,%e]\n',Func);  
    noLanding = 0; % Restart flag
end
global OutOfWorkSpace
if OutOfWorkSpace==1    % if OutOfWorkSpace=[] or OutOfWorkSpace=0 this condition is false
    fprintf('===============================================================================\n')
    fprintf(' Since the essential model is out of workspace, the states are not considered\n')
    fprintf('===============================================================================\n')
    % Start again...
    % We impose an error for the function based on how far it was to finish the step 0.1 is the least possible error we chosed 
    % THIS METHOD HASN'T BEEN PROVED
    Func = (T - Tk + 0.1) * ones(1,4); %  The farther of finishing the step the bigger the error
%     Func = ones(1,4);
    fprintf('Function = [%e,%e,%e,%e]\n',Func);
    OutOfWorkSpace = 0; % Restart flag
end
disp('---------------------------------------------------------------------------------------------------------')
disp('')

contA = contA + 1;
global contB % number of iteration inside the solver
if ~isempty(contB)
    contB = 1;
end
    
global contC 
if ~isempty(contC)  % If contC is empty means it wasn't initialized (in other codes) thus it is not required
                    % to plot the evolution of the CoM in PEvents
    contC = 1;  % If is not empty, then each cycle is re-initialized and the variables must be cleaned
    global CoMx CoMy
    CoMx = [];
    CoMy = [];        
end
% -----------------------------------------------------------------

