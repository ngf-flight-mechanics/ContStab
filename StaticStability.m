% NGF - Static Stability (Tim Attwell, 20.05.19)
% Takes aircraft design properties and finds the static stability and static margin of the design.

%% Housekeeping
close all
clear
clc

%% Aircraft geometric properties, values, and constants.

% Aircraft properties
M = 0.85 ;                  % Cruise Mach number
L_f = 20 ;                  % Fusleage length (m)
W_f = 3 ;                   % Fuselage width (m)
D_f = W_f ;                 % Fuselage depth (m)
V_f = 2*pi*(W_f/2)^2 ;      % Fuselage volume (m^3)

% Wing Properties - airfoil
t_c_w = 0.12 ;              % Thickness to chord ratio  
a_sect_W = 6.5541 ;         % Sectional lift curve slope
a_w = 4.5350 ;              % Wing lift curve slope
a_w_0 = 3.419 ;             % Lift curve slope at zero moment
alf_0_w = -2.5 ;            % Zero-lift angle
C_L_max = 1.4 ;             % Max C_L

% Wing Properties - Geometry
WingLoad = 4970.463 ;       % Wing loading (kg)
S_w = 59.65792 ;            % Wing area (m^2)
lambda_w = 0.2 ;            % Wing taper ratio
AR_w = 2.5 ;                % Wing Aspect ratio
b_w = 37.58 ;               % Wing span (m)
c_root_w = 8.7287 ;         % Root chord (m)
c_tip_w = 2.0076 ;          % Tip chord (m)
cbar = 6.069 ;              % Mean aerodynamic chord (m)
ycbar_w = 7.434 ;           % N/A
LAMBDA_14_w = 24.5 ;        % Quarter chord sweep (deg)
GAMMA_w = -3 ;              % Dihedral (deg)
eps1_w = 3 ;                % Twist (deg)
i_w = -3 ;                  % Wing setting angle (deg)

% V-tailplane - Airfoil
t_c_h = 0.10;               % Thickness to chord ratio
a_sect_h = 6.366 ;          % Sectional lift curve slope 
alf_0_h = 0 ;               % Flat tailplane zero-lift angle (deg)
a_h = 2.92 ;                % Flat tailplane lift curve slope
a_h_0 = 2.52 ;              % Flat tailplane lift curve slope at zero moment
alf_0_v = 0 ;               % V-Tail zero lift angle (deg)

% V-tailplane - Geometry
%x_v =  ;                   % x-position of V-tail aerodynamic centre (m)
%z_v =  ;                   % z-position of V-tail aerodynamic centre (m)
S_v =  70 ;                 % V-tail area (m^2)
eps1_v = 0.5 ;              % Twist (deg)
AR_v = 3.5 ;                % V-tail aspect ratio
b_v = 15 ;                  % V-tail span
LAMBDA_v = 41 ;             % Quater chord sweep
GAMMA_v = 42 ;              % Dihedral (deg)
lambda_v = 0.4 ;            % V-tail taper ratio
i_H = 0 ;                   % V-tail setting angle

%% Guesses
x_cg_f = 0.40 ;             % CG position as percentage of fuselage length     
x_cg = x_cg_f * L_f ;
xbar_cg = x_cg / cbar ;

x_w_f = 0.45 ;              % Wing(c/4) position as percentage of fuselage length   
x_w = x_w_f * L_f ;
xbar_w = x_w / cbar ;

x_v_f = 0.95 ;              % V-Tail(c/4) position as percentage of fuselage length  
x_v = x_v_f * L_f ;
xbar_v = x_v / cbar ;

z_w = W_f / 2 ;             % Wing height above fuseage centreline (m)
z_v = z_w + 9.1035 ;        % V-tail(ac) height above fuselage centreline

%{
L_f = 20 ;      % Fuselage length(m)
w_f = 5 ;     % Fuselage max width(m)
S_w = 59.65792 ;      % Wing area(m^2)
S_v = 10 ;        % V-tail area
cbar = 5 ;    % Mean aerodynamic chord(m)
AR = 2.5 ;         % Aspect ratio
LAMBDA_14 = 5 ;  % Sweep at quater chord (deg)
lambda = 5 ;     % Taper ratio
h_h = 5 ;        % Height of horizontal stabalizer ABOVE the wing(m)
l_h = 5 ;        % Length of horizontal stabalizer BEHIND the wing(m)
b = 5 ;          % Wing span(m)
K_f = 2.8 ;     % Fuselage pitching moment constant found from NACA TR-711
C_m0_w = 5 ;     % Incompressible airfoil zero lift pitching moment 
eps1 = 5 ;       % Wing twist (deg)
a_w = 5 ;        % Wing lift curve slope
a_w_0 = 5 ;        % Wing zero lift curve slope
a_h = 5 ;        % Tailplane lift curve slope
x_ac_w = 5 ;     % Aerodynamic centre point of the wing
x_ac_v = 5 ;     % Aerodynamic centre point of the V-tail

x_cg = 5 ;       % Centre of gravity x-position

C_m0_airf_0 = 5 ;    




M = 0.85 ;       % Design Mach number
x_c4 = 5 ;       % Quater chord x-position
GAMMA = 5 ;      % Tail dihedral
%}
M = 0.85 ;
%% Longitudinal Static Stability

% Pitching moment generated by the fuselage empirically given by:
k = polyfit([10,20,30,40,50,60],[0.08,0.3,0.6,1,1.65,2.8],2) ;
K_f = polyval(k, (100 * x_w / L_f)) ;       % Constant from graph in notes 
C_Mf = K_f * L_f * (W_f^2) / (cbar * S_w) ;

% Tail efficiency accounts for difference between dynamic pressure at the
% tail and that at freestream
eta_v = 0.93 ;      % Efficiency of v section of tail is increased

% Downwash effect on the horizontal stabalizer
% alf_h = alf - eps
% dalf_h / dalf = 1 - deps / dalf = de_da

% deps / dalf given empirically by:
K_A = (1 / AR_w) - (1 / (1 + (AR_w^1.7))) ;
K_lambda = (10 - 3 * lambda_w) / 7 ;

h_v = z_v - z_w ;
l_v = x_v - x_w ;
K_h = (1 - abs(h_v/b_w)) / ((2 * l_v / b_w)^(1/3)) ;

de_da = 4.44 * ((K_A * K_lambda * K_h * ((cosd(LAMBDA_14_w))^(1/2)))^(1.19)) * (a_w / a_w_0) ;

%{
% Aerodynamic centre estimation
if M >= 1.1
    dx_ac = 0.112 - 0.004 * M ;             % Supersonic x_ac
elseif M < 1 && M > 0.4
    dx_ac = 0.26 * power(M - 0.4, 2.5) ;    % Subsonic x_ac
end
x_ac = x_c4 + dx_ac * sqrt(S_w) ;
%}

% 'Rotated' lift curve slope
a_v = a_h * power(cosd(GAMMA_v),2) ;
a_v_0 = a_h_0 * power(cosd(GAMMA_v),2) ;

% Bringing everything together:
dCmcgdalf = -a_w * ((x_w - x_cg)/cbar) + C_Mf ...                           % Contribution of main wing
    - (eta_v * a_v * (1 - de_da) * (S_v / S_w) * ((x_v - x_cg)/cbar)) ;     % Contribution of 'V' section


if dCmcgdalf > 0
    disp("The aircraft is unstable in pitch (dC_m/d_alf > 0)")
elseif dCmcgdalf == 0
    disp("The aircraft is neutrally stable in pitch(dC_m/d_alf = 0)")
elseif dCmcgdalf < 0
    disp("The aircraft is stable in pitch(dC_m/d_alf < 0)")
end
disp(dCmcgdalf)

%% Neutral point and static margin

% Neutral point calculation
x_np = cbar * ((a_w * (x_w / cbar)) - C_Mf ... 
    + (eta_v * a_v * (1 - de_da) * (S_v / S_w) * (x_v / cbar))) ...
    / (a_w ...
    + (eta_v * a_v * (1 - de_da) * (S_v / S_w))) ;

% Engine off static margin 
SMoff = (x_np - x_cg) / cbar ;

if SMoff > 0.20
    disp("The static margin is way too high! (SM>20)")
elseif SMoff <= 0.20 && SMoff > 0.07
    disp("The static margin is high, even for a transport! (7<SM<20)")
elseif SMoff <= 0.07 && SMoff > 0.04
    disp("The static margin is that of a transport! (4<SM<7)")
elseif SMoff <= 0.04 && SMoff > 0
    disp("The static margin is that of an early fighter! (0<SM<4)")
elseif SMoff <= 0 && SMoff > -0.15
    disp("The static margin is that of a modern fighter! (-15<SM<0)")
elseif SMoff <= -0.15
    disp("The static margin is way too low! (SM<-15)")
end
disp(SMoff)

% Rough engine-on calculation based on past experience
SMon = SMoff - 0.02 ;
disp(SMon)

%% Trim Analysis
C_m0_airf_0 = 0.7 ;

% Wing zero lif pirching moment empirical calculation:
C_M0_w = (C_m0_airf_0 * ((AR_w * cosd(LAMBDA_14_w) * cosd(LAMBDA_14_w)) / ...
        (AR_w + 2 * cosd(LAMBDA_14_w))) - 0.01 * eps1_w) * (a_w / a_w_0) ;

% Thrust effects:
% In steady level flight:
[Temp, uSound, P, rho] = atmosisa(11277.6);
ucruise = M * uSound;
q = rho * ucruise^2 / 2;
C_L_des = WingLoad/q;

C_D = 0.0425;       % Guess based off of wikipedia

T = q * S_w * C_D ;
Z_t = 0 ;           % Distance between vertical cg and thrustline (+ve if thrustline under cg)

% Design point
C_L_des = WingLoad / (q) ; 
C_M_cg_des = 0 ;


for i_v = [-3:5]
    for alf = [-10:10]

        % Lift of lifting surfaces:
        C_L_w = a_w .* (alf + i_w - alf_0_w) ;
        C_L_v = a_v .* ((alf + i_w - alf_0_w) .* (1 - de_da) + (i_v - i_w) - (alf_0_v - alf_0_w)) ;

        % Total lift and pitching moments about cg for a clean a/c
        C_M_cg(alf+11) = (-C_L_w * (x_w - x_cg) / cbar) + C_M0_w + (C_Mf * alf) - ...
                        (eta_v * C_L_v * (S_v / S_w) * ((x_v - x_cg) / cbar) + ((Z_t * T) / (q * S_w * cbar))) ;
        C_L(alf+11) = C_L_w + (eta_v * (S_v / S_w) * C_L_v) ;

    end

    leg1(i_v+4) = i_v ;
    figure(1)
    hold on;
    grid on;
    plot(C_L(:), C_M_cg(:))
end
legend('-3','-2','-1','0','1','2','3','4','5')
plot(C_L_des, C_M_cg_des, 'x')
hold off

alf = 0.4 ;

% Lift of lifting surfaces:
C_L_w = a_w .* (alf + i_w - alf_0_w) ;
C_L_v = a_v .* ((alf + i_w - alf_0_w) .* (1 - de_da) + (i_v - i_w) - (alf_0_v - alf_0_w)) ;

% Total lift and pitching moments about cg for a clean a/c
C_M_cg = (-C_L_w * (x_w - x_cg) / cbar) + C_M0_w + (C_Mf * alf) - ...
        (eta_v * C_L_v * (S_v / S_w) * ((x_v - x_cg) / cbar) + ((Z_t * T) / (q * S_w * cbar))) ;
C_L = C_L_w + (eta_v * (S_v / S_w) * C_L_v) ;

%% Lateral stability

% Yaw-ing contribution
C_n_beta_w = C_L.^2 * ((1 / (4 * pi * AR_w)) - ...
    (tand(LAMBDA_14_w) / (pi * AR_w * (AR_w + 4 * cosd(LAMBDA_14_w)))) * ...
    (cosd(LAMBDA_14_w) - (AR_w / 2) - (AR_w^2 / (8 * cosd(LAMBDA_14_w))) + ...
    (6 * (x_w - x_cg) * sind(LAMBDA_14_w) / (AR_w * cbar)))) ;

    
C_n_beta_v = -a_h * power(sind(GAMMA_v), 2) ;

C_n_beta_fus = -1.3 * V_f * (D_f / W_f) / (S_w * b_w) ;


% Rolling contributions

ClbetawCL = 5 ;

Z_wf = 5 ;

C_l_beta_gam = (-a_w * GAMMA_w / 4) * ((2 * (1 + 2*lambda_w)) / (3 * (1 + lambda_w))) ;

C_l_beta_wf = -1.2 * ((sqrt(AR_w) * Z_wf * (D_f + W_f)) / (b_w^2)) ;

C_l_beta_w = ClbetawCL * C_L + C_l_beta_gam + C_l_beta_wf ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lifing line coefficients - method obtained from Joseph Derlaga, 16.10.09

alfr = deg2rad(i_h) ;               % Changes to radians
alf0r = deg2rad(alf_0_h) ;          

numlocs = 20 ;                      % Number of planform locations

LHS = zeros(numlocs,numlocs) ;
RHS = zeros(numlocs,1) ;

n = 1:numlocs ;
phi = n .* pi ./ (2 * numlocs) ;    % 

for ii = 1:numlocs
    
    mu = (a_h_0 / (2 * AR_v * (1 + lambda_v))) * (1 + (lambda_v - 1) * cos(phi(ii))) ;
    RHS(ii,1) = mu * (alfr - alf0r) * sin(phi(ii)) ;
    
    for n = 1:numlocs - 1
        LHS(ii, n+1) = sin(n*phi(ii)) * (n * mu + sin(phi(ii))) ;
    end
end

A = LHS\RHS;

ksum = 0 ;
for jj = 3:numlocs
    ksum = ksum + ((3 * sin(jj * pi / 2) * A(jj)) / ((4 - jj^2) * A(1))) ;
end

k_l = 1 + ((3 * pi * A(2)) / (8 * A(1))) + ksum ;

S1_v = S_v/cosd(GAMMA_v) ;
b1_v = b_v/cosd(GAMMA_v) ;

C_l_beta_v = ((2 * S1_v * b1_v) / (3 * pi * S_v * b_v)) * k_l * a_v_0 * sind(GAMMA_v) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

C_n_beta = C_n_beta_w + C_n_beta_fus + C_n_beta_v 

C_l_beta = C_l_beta_w + C_l_beta_v 













