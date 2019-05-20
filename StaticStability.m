% NGF - Static stability (Tim Attwell, 20.05.19)
% Takes aircraft design properties and finds the static stability and
% static margin of the design.
%% Housekeeping
close all
clear
clc

%% Aircraft geometric properties, values, and constants.
L_f = 19 ;      % Fuselage length(m)
w_f = 3.5 ;     % Fuselage max width(m)
S_w = 50 ;      % Wing area(m^2)
cbar = 5.2 ;    % Mean aerodynamic chord(m)
AR =  ;         % Aspect ratio
LAMBDA_14 =  ;  % Sweep at quater chord (deg)
lambda =  ;     % Taper ratio
h_h =  ;        % Height of horizontal stabalizer ABOVE the wing(m)
l_h =  ;        % Length of horizontal stabalizer BEHIND the wing(m)
b =  ;          % Wing span(m)
K_f = 2.8 ;     % Fuselage pitching moment constant found from NACA TR-711
C_m0_w =  ;     % Incompressible airfoil zero lift pitching moment 
eps1 =  ;       % Wing twist (deg)


%% Longitudinal Static Stability

% Pitching moment generated by the fuselage empirically given by:
C_mf = K_f * (L_f) * (w_f^2) / (cbar * S_w) ;

% Tail efficiency accounts for difference between dynamic pressure at the
% tail and that at freestream
eta_h = 0.9 ;   % Tailplane efficency factor

% Downwash effect on the horizontal stabalizer
% alf_h = alf - eps
% dalf_h / dalf = 1 - deps / dalf = depsdalf

% deps / dalf given empirically by:
K_A = (1 / AR) - (1 / (1 + AR^1.7)) ;
K_lambda = (10 - 3 * lambda) / 7 ;
K_h = (1 - abs(h_h/b)) / ((2 * l_h / b)^(1/3)) ;

depsdalf = 4.44 * ((K_A * K_lambda * K_h * ((cos(LAMBDA_14))^(1/2)))^(1.19)) * (a_w / a_w_0) ;

% Bringing everything together:
dCmcgdalf = -a_w * ((x_ac_w - x_cg)/cbar) + C_Mf - eta_h * ...
    a_h * (1 - depsdalf) * (S_h / S_w) * ((x_ac_h - x_cg)/cbar) ;

if dCmcfdalf > 0
    disp("The aircraft is unstable in pitch (dC_m/d_alf > 0)")
elseif dCmcfdalpf == 0
    disp("The aircraft is neutrally stable in pitch(dC_m/d_alf = 0)")
elseif dCmcfdalpf < 0
    disp("The aircraft is stable in pitch(dC_m/d_alf < 0)")
end

%% Neutral point and static margin

% Neutral point calculation
x_np = cbar * ((a_w * (x_ac_w / cbar)) - C_Mf + (eta_h * a_h * (1 - depsdalf) * (S_h / S_w) * (x_ac_h / cbar)) ...
    / (a_w + eta_h * a_h * (1 - depsdalf) * (S_h / S_w))) ;

% Engine off static margin 
SMoff = (x_np - x_cg) / cbar

if SMoff > 20
    disp("The static margin is way too high! (SM>20)")
elseif SMoff <= 20 && SMoff > 7
    disp("The static margin is high, even for a transport! (7<SM<20")
elseif SMoff <= 7 && SMoff > 4
    disp("The static margin is that of a transport! (4<SM<7)")
elseif SMoff <= 4 && SMoff > 2
    disp("The static margin is that of an early fighter! (0<SM<4)")
elseif SMoff <= 0 && SMoff > -15
    disp("The static margin is that of a modern fighter! (-15<SM<0)")
elseif SMoff <= -15
    disp("The static margin is way too low! (SM<-15)")
end

% Rough engine-on calculation based on past experience
SMon = SMoff - 0.02 

%% Trim Analysis

% Wing zero lif pirching moment empirical calculation:
C_M0_w = (C_m0_airf_0 * ((A * cos(LAMBDA_14) * cos(LAMBDA_14)) / (A + 2 * cos(LAMBDA_14))) - 0.01 * eps1) * (a_w / a_w_0) ;

% Thrust effects:
% In steady level flight:
T = q * S_w * C_D ;
Z_t =  ;           % Distance between vertical cg and thrustline (+ve if thrustline under cg)

% Lift of lifting surfaces:
C_L_w = a_w * (alf + i_w - alf_0_w) ;
C_L_h = a_h * ((alf + i_w - alf_0_w) * (1 - depsdalf) + (i_h - i_w) - (alf_0_h - alf_0_w))


% Total lift and pitching moments about cg for a clean a/c
C_M_cg = (-C_L_w * (x_ac_w - x_cg) / cbar) + C_M0_w + (C_Mf * alf) - (eta_h * C_l_h * (S_h / S_w) * ((x_ac_h - x_cg) / cbar) + ((Z_t * T) / (q * S_w * cbar)) ;
C_L = C_L_w + (eta_h * (S_h / S_w) * C_L_h ;

% Design point
C_L_des = W_des / (q_des * S_w) ; 
C_M_cg_des = 0 ;

i_h = [-3:2:15] ; 

figure(1)
hold on; grid on
for ii = 0 : 9
    plot(CL(ii), C_M_cd(ii)


end

%% Lateral stability




