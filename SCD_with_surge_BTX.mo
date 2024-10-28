model SCD_with_surge_BTX
  //This code is provided under the Creative Commons license with no warranty of any kind, expresed or implied. 
  //It simulates the separation of Benzene, Toluene, and O-xylene using semi-continuous distillation as presented in 
  //Azghandi, M. E., Mehdipour, H., & Sahlodin, A. M. (2024). Dynamic modeling and modification of ternary semicontinuous distillation without a middle vessel for improved controllability
  //and energy performance. Chemical Engineering and Processing - Process Intensification, 205, 110021. https://doi.org/10.1016/J.CEP.2024.110021
  //This code has been tested with OpenModelica ver [1.18.0-64bit].
  //The model can be adapted to other mixtures by changing the thermodynamic properties and equations (for non-ideal cases). Controller tunings may need to change too.
  //Feel free to use this code or adapt it to your purpose, and please give credit by citing the above paper.
  //=============================================================================================
  // Introduction of parameters and variables
  //---------------------------------------------------------------------------------------------
  // ##### The column design specifications and parameters
  
  // NC : A counter for components - ternary mixture for simulation including benzene, toluene, and o-xylene -           Integer variable with value between 1 and 3
  // N : Number of stages (including condenser) - Based on bottom-up numbering
  // Nsd : Side-stream stage
  // Nf : Feed stage
  
  //---------------------------------------------------------------------------------------------
  // ##### Main parameters
  
  // F0 : initial feed flow rate in kmol/s
  // R : universal gas constant in J/kmol.k
  // c_V : vapor flow coefficient for column stages
  // c_L : liquid flow coefficient for column stages (weir)
  // dx : auxiliary vars for easy outputting
  // z : mole fraction of components in the fresh feed
  // y : mole fraction of vapor
  // x : mole fraction of liquid
  // x_SurgeTank : mole fraction of liquid in surge tank
  // xD : distillate purity
  // xB : bottom purity
  // xS : side stream purity
  // xSurgeTankTank : surge tank purity
  // T : the temperature of tray in K
  // T_in : the inlet temperature in K
  // P : stage pressure in Pa
  // Pcond : condenser pressure in Pa
  // DDRmax : upper bound on the control action for distillation purity controller
  // DR : distillate ratio
  // Vcond : the condenser volume in m^3
  // V_Vcond : vapor volume in condenser in m^3
  // V_Lcond : liquid volume in condenser in m^3
  // V_LReboiler : liquid volume in condenser in m^3
  // V_SurgeTank : surge tank volume in m^3
  // V_SurgeTank_Min : minimum surge tank volume in m^3
  // QR : Reboiler energy consumption in J/s
  // QC : Condenser energy consumption in J/s
  // CondenserDuty : Duty of Condenser in Mj
  // ReboilerDuty : Duty of Reboiler in Mj
  // Ucond : condenser internal energy of both phases in J
  // S_Recycle : Side stream flow rate for add to feed in kmol/s 
  // Side_ProdFlowRate : Side product flow rate in kmol/s
  // S_FlowRate : side stream flow rate in kmol/s
  // Relux_FlowRate : Reflux flow rate in kmol/s
  // D_FlowRate : Product flow rate at the top of the column (distillate flow rate) in kmol/s
  // Lift_R : lift for reboiler valve
  // Lift_SurgeTank : lift for surge tank valve
  
  //---------------------------------------------------------------------------------------------
  // ##### Mole related parameters
  
  // Mw : Molecular weight in kg/kmol
  // M_L : liquid hold-up in kmol
  // M_L_SurgeTank : surge tank liquid hold-up in kmol
  // M_L_w : amount of liquid over the weir. in other words, minimum liquid hold-up on the trays in kmol
  // M_V : vapor hold-up in kmol
  // M : total hold-up of each component in kmol
  // M_SurgeTank : surge tank hold-up of each component in kmol
  // F_in : Molar flow rate of incoming fresh feed in kmol/s
  // F_L : Molar flow rate of liquid in kmol/s
  // F_V : Molar flow rate of vapor in kmol/s
  // F_L_SurgeTank : Surge tank Molar flow rate of liquid in kmol/s
  
  //---------------------------------------------------------------------------------------------
  // ##### Parameters related to density
  
  // rho_L : molar density in kmol / m^3
  // rho_Lcond_inv : Inverse liquid density in the condenser in m^3/kmol
  // rho_LReboiler_inv : Inverse liquid density in the reboiler in m^3/kmol
  // rho_LSurgeTank_inv : Inverse liquid density in the surge tank in m^3/kmol
  
  //---------------------------------------------------------------------------------------------
  // ##### Vapor pressure calculation parameters
  
  // Pc : the critical pressure in bar
  // Tc : the critical temperature in K
  // a, b, c, d : Wagner equation constants - It should be noted that the vapor pressure is calculated based on Wagner's equation.
  // Pvp : vapor pressure of pure component in Pa
  // Tau : the parameter for Vapor Pressure Correlations
  
  //---------------------------------------------------------------------------------------------
  // ##### Parameters related to enthalpy calculations
  
  // Tref : reference temperature in K
  // h_L : molar enthalpy of liquid phase in J/kmol
  // h_L_SurgeTank : surge tank molar enthalpy of liquid phase in J/kmol
  // h_V : molar enthalpy of vapor phase in J/kmol
  // h_Lcmp : molar enthalpy of liquid phase for each component in J/kmol
  // h_Vcmp : molar enthalpy of vapor phase for each component in J/kmol
  // h_Lcmp_in : molar enthalpy of liquid phase	for each component in feed in J/kmol
  // h_Vcmp_in : molar enthalpy of vapor phase for each component in feed in J/kmol
  // h_in : molar enthalpy of feed in J/kmol
  // H : enthalpy of both phases in J
  // dHTref : Change in molar enthalpy from reference temperature in J/kmol
  // dHTref_in : Change in molar enthalpy from reference temperature for feed temperature in J/kmol
  
  // ##### parameters of enthalpy of formation
  // dHform : the enthalpy of formation in J/mol
  
  // ##### Parameters related to enthalpy of vaporization calculations
  // A_e, B_e, C_e : Calculation parameters of enthalpies of evaporation
  // dHvap : enthalpy of vaporization in J/kmol
  // dHvap_in : enthalpy of vaporization for feed in J/kmol
  
  //---------------------------------------------------------------------------------------------
  // ##### Parameters related to side stream operating modes
  
  // HighPurity : the upper bound of side stream purity
  // LowPurity : the lower bound of side stream purity
  // Lift_sd : Side stream lift for contain recycle or product
  // Semi_divide_Parameter : a parameter for contain open or close for sidedraw valve
  // Puritydp : purity delay parameter
  
  //---------------------------------------------------------------------------------------------
  // ##### Parameters related to controllers
  
  // ##### bias
  
  // QR_bias : Steady-state bias value for reboiler duty in J/s
  // QC_bias : Steady-state bias value for condenser duty in J/s
  // Fin_bias : Steady-state bias value for molar flow rate of incoming fresh feed in kmol/s
  // DR_bias : Steady-state bias value for distillate ratio
  // Lift_R_bias : Steady-state bias value for lift for reboiler valve
  // Lift_SurgeTank_bias : Steady-state bias value for lift for surge tank valve
  
  // ##### proportional gain
  
  // QR_KC : proportional gain of Reboiler volume controller in J/(m^3.s)
  // QC_KC : proportional gain of Condenser pressure controller in J/(Pa.s)
  // Fin_KC : proportional gain of Condenser volume controller in kmol/(m^3.s)
  // DR_KC : proportional gain of distillation purity controller
  // Lift_R_KC : proportional gain of bottom purity controller
  // Lift_SurgeTank_KC : proportional gain of surge tank volume controller in 1/m^3
  
  // ##### integral gain
  
  // QR_KI : integral gain of Reboiler volume controller in J/(m^3.s^2)
  // QC_KI : integral gain of Condenser pressure controller in J/(Pa.s^2)
  // Fin_KI : integral gain of Condenser volume controller in kmol/(m^3.s^2)
  // DR_KI : integral gain of distillation purity controller in 1/s
  // Lift_R_KI ; integral gain of bottom purity controller in 1/s
  // Lift_SurgeTank_kI : integral gain of surge tank volume controller in 1/(m^3.s)
  
  // ##### Set point
  
  // VLReb_SP : Reboiler volume controller set point in m^3
  // Pcond_SP  : Condenser pressure controller set point in Pa
  // VLcond_SP : Condenser volume controller set point in m^3
  // xD_SP : distillation purity controller set point
  // xB_SP : bottom purity controller set point
  // VSurgeTank_SP : surge tank volume controller set point in m^3
  
  // ##### Errors
  
  // VL_R_error : deviation of Reboiler volume from setpoint
  // Pcond_error : deviation of condenser pressure from setpoint
  // VL_C_error : deviation of Reboiler volume from setpoint
  // xD_error : deviation of Distillate purity from setpoint
  // xB_error : deviation of Bottom purity from setpoint
  // VL_SurgeTank_error : deviation of surge tank volume from setpoint
  
  // ##### integral of error
  
  // VL_R_errorint : integral of deviation of Reboiler volume from setpoint
  // Pcond_errorint : integral of deviation of condenser pressure from setpoint
  // VL_C_errorint : integral of deviation of Condenser volume from setpoint
  // xD_errorint : integral of deviation of Distillate purity from setpoint
  // xB_errorint : integral of deviation of Bottom purity from setpoint
  // VL_ST_errorint  : integral of deviation of surge tank volume from setpoint

  //=============================================================================================
  //---------------------------------------------------------------------------------------------
  parameter Integer NC = 3;
  parameter Integer N = 40;
  parameter Integer Nsd = 15;
  parameter Integer Nf = 6;
  //---------------------------------------------------------------------------------------------
  parameter Real F0 = 0.03;
  parameter Real R = 8.314e3;
  parameter Real[N] c_V = {30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30};
  parameter Real[N] c_L = {0.05, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 2.6};
  Real dx;
  Real[NC] z;
  Real[NC, N] y;
  Real[NC, N] x;
  Real[NC] x_SurgeTank;
  Real xD;
  Real xB;
  Real xS;
  Real xSurgeTank; 
  Real[N] T;
  Real T_in = 340;
  Real[N] P(start = {100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 97240});  
  Real Pcond;
  parameter Real DRmax = 0.4;
  Real DR;
  parameter Real Vcond = 0.205;
  Real V_Vcond;
  Real V_Lcond(start = 0.5 * Vcond);
  Real V_LReboiler;
  Real V_SurgeTank;
  Real V_SurgeTank_Min;
  Real QR;
  Real QC;
  Real CondenserDuty;
  Real ReboilerDuty;
  Real Ucond;
  Real S_Recycle;
  Real Side_ProdFlowRate;
  Real S_FlowRate;
  Real Relux_FlowRate;
  Real D_FlowRate;
  Real Lift_R;
  Real Lift_SurgeTank;
  //---------------------------------------------------------------------------------------------
  parameter Real[NC] Mw = {78.11, 92.14, 106.167};
  Real[N] M_L;
  Real M_L_SurgeTank;
  parameter Real[N] M_L_w = {0.01, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.005};
  Real[N] M_V;
  Real[NC, N] M(start = {{1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 2e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 4e-2}, {1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 4e-2}, {1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 4e-2}});
  Real[NC] M_SurgeTank;
  Real F_in;
  Real[N] F_L(start = {0.0045, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.018, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.018, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.004});
  Real[N] F_V(start = {0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0});
  Real F_L_SurgeTank;
  //---------------------------------------------------------------------------------------------
  parameter Real[NC] rho_L = {876 / Mw[1], 867 / Mw[2], 880 / Mw[3]};
  Real rho_Lcond_inv;
  Real rho_LReboiler_inv;
  Real rho_LSurgeTank_inv;
  //---------------------------------------------------------------------------------------------
  parameter Real[NC] Pc = {48.98, 41.06, 37.32};
  parameter Real[NC] Tc = {562.16, 591.80, 630.3};
  parameter Real[NC] a = {-7.01433, -7.31600, -7.60491};
  parameter Real[NC] b = {1.55256, 1.59425, 1.75383};
  parameter Real[NC] c = {-1.8479, -1.93165, -2.27531};
  parameter Real[NC] d = {-3.7130, -3.72220, -3.73771};
  Real[NC, N] Pvp;
  Real[NC, N] tau;
  //---------------------------------------------------------------------------------------------
  parameter Real Tref = 298.15;
  Real[N] h_L;
  Real h_L_SurgeTank;
  Real[N] h_V;
  Real[NC, N] h_Lcmp;
  Real[NC, N] h_Vcmp;
  Real[NC] h_Lcmp_in;
  Real[NC] h_Vcmp_in;
  Real h_in;
  Real[N] H;
  Real[NC, N] dHTref;
  Real[NC] dHTref_in;
  parameter Real[5, NC] alpha = {{3.551, 3.866, 3.289}, {-6.184e-3, 3.558e-3, 34.144e-3}, {14.365e-5, 13.356e-5, 4.989e-5}, {-19.807e-8, -18.659e-8, -8.335e-8}, {8.234e-11, 7.690e-11, 3.338e-11}};
  parameter Real[NC] dHform = {82.88e6, 50.17e6, 19.08e6};
  parameter Real[NC] A_e = {1e6 * 47.41, 1e6 * 53.09, 1e6 * 59.3095};
  parameter Real[NC] B_e = {-0.1231, -0.2774, -0.2791};
  parameter Real[NC] C_e = {0.3602, 0.2774, 0.2791};
  Real[NC, N] dHvap;
  Real[NC] dHvap_in;
  //---------------------------------------------------------------------------------------------
  parameter Real HighPurity = 0.995;
  parameter Real LowPurity = 0.985;
  parameter Real  sideprod_frac = 0.98;
  Real Lift_sd;
  Real Semi_divide_Parameter;
  Real Puritydp;
  //---------------------------------------------------------------------------------------------
  parameter Real QR_bias = 12.5e5;
  parameter Real QC_bias = 12.5e5;
  parameter Real Fin_bias = 0.05;
  parameter Real DR_bias = 0.4;
  parameter Real Lift_R_bias = 10;
  parameter Real Lift_SurgeTank_bias = .5;
  parameter Real QR_KC = 6.9e4;
  parameter Real QC_KC = 6.9e3;
  parameter Real Fin_KC = 0.05;
  parameter Real DR_KC = 4;
  parameter Real Lift_R_KC = 10;
  parameter Real Lift_SurgeTank_KC = .05;
  parameter Real QR_KI = 5e6;
  parameter Real QC_KI = 1e6;
  parameter Real Fin_KI = 0.5;
  parameter Real DR_KI = 0.5;
  parameter Real Lift_R_KI = 40;
  parameter Real Lift_SurgeTank_kI = 0.001;
  parameter Real VLReb_SP = .23 ;
  parameter Real Pcond_SP = 75160;
  parameter Real VLcond_SP = 0.5 * Vcond;
  parameter Real xD_SP = 0.99;
  parameter Real xB_SP = 0.99;
  Real VSurgeTank_SP;
  Real VL_R_error;
  Real Pcond_error;
  Real VL_C_error;
  Real xD_error;
  Real xB_error;
  Real VL_SurgeTank_error;
  Real VL_R_errorint;
  Real Pcond_errorint;
  Real VL_C_errorint;
  Real xD_errorint;
  Real xB_errorint;
  Real VL_ST_errorint;
  //---------------------------------------------------------------------------------------------
  // other
  parameter Real steptime = 277.7778*3600;
  Real[NC, N] K(each start = 1);
  Real F_in_calc;
  Real TotalReboilerDuty;
  Real TotalCondenserDuty;
  Real TotCondDutyCycl;
  Real TotRebDutyCycl;
  Real Duties;
  Real DutiesCycl;
  Real TotalDistProd;
  Real TotalSideProd;
  Real TotalBottomProd;
  Real TotalFeed;
  //=============================================================================================
equation
  //################################## MASS AND ENERGY BALANCSE #################################
  //######################################### FEED TRAY #########################################
  der(M[1:NC, Nf]) = F_in * z[1:NC] + F_L[Nf + 1] * x[1:NC, Nf + 1] + F_V[Nf - 1] * y[1:NC, Nf - 1] - F_L[Nf] * x[1:NC, Nf] - F_V[Nf] * y[1:NC, Nf] + F_L_SurgeTank * x_SurgeTank[1:NC];
  der(H[Nf]) = F_in * h_in + F_L[Nf + 1] * h_L[Nf + 1] + F_V[Nf - 1] * h_V[Nf - 1] - F_L[Nf] * h_L[Nf] - F_V[Nf] * h_V[Nf] + F_L_SurgeTank * h_L_SurgeTank;
  //######################################### OTHER TRAY ########################################
  for i in 2:Nf - 1 loop
    der(M[1:NC, i]) = F_L[i + 1] * x[1:NC, i + 1] + F_V[i - 1] * y[1:NC, i - 1] - F_L[i] * x[1:NC, i] - F_V[i] * y[1:NC, i];
    der(H[i]) = F_L[i + 1] * h_L[i + 1] + F_V[i - 1] * h_V[i - 1] - F_L[i] * h_L[i] - F_V[i] * h_V[i];
  end for;
  //############################# BETWEEN FEED AND SIDE STREAM STAGE ############################
  for i in Nf + 1:Nsd - 2 loop
    der(M[1:NC, i]) = F_L[i + 1] * x[1:NC, i + 1] + F_V[i - 1] * y[1:NC, i - 1] - F_L[i] * x[1:NC, i] - F_V[i] * y[1:NC, i];
    der(H[i]) = F_L[i + 1] * h_L[i + 1] + F_V[i - 1] * h_V[i - 1] - F_L[i] * h_L[i] - F_V[i] * h_V[i];
  end for;
  //---------------------------------------------------------------------------------------------
  der(M[1:NC, Nsd - 1]) = F_L[Nsd] * x[1:NC, Nsd] + F_V[Nsd - 1 - 1] * y[1:NC, Nsd - 1 - 1] - F_L[Nsd - 1] * x[1:NC, Nsd - 1] - F_V[Nsd - 1] * y[1:NC, Nsd - 1] - S_FlowRate  * x[1:NC, Nsd];
  der(H[Nsd - 1]) = F_L[Nsd] * h_L[Nsd] + F_V[Nsd - 1 - 1] * h_V[Nsd - 1 - 1] - F_L[Nsd - 1] * h_L[Nsd - 1] - F_V[Nsd - 1] * h_V[Nsd - 1] - S_FlowRate * h_L[Nsd];
  //###################################### SIDE STREAM STAGE ####################################
  der(M[1, Nsd]) = F_L[Nsd + 1] * x[1, Nsd + 1] + F_V[Nsd - 1] * y[1, Nsd - 1] - F_L[Nsd] * x[1, Nsd] - F_V[Nsd] * y[1, Nsd];
  x[2, Nsd] * der(M_L[Nsd]) + M_L[Nsd] * der(x[2, Nsd]) + y[2, Nsd] * der(M_V[Nsd]) + M_V[Nsd] * der(y[2, Nsd]) = F_L[Nsd + 1] * x[2, Nsd + 1] + F_V[Nsd - 1] * y[2, Nsd - 1] - F_L[Nsd] * x[2, Nsd] - F_V[Nsd] * y[2, Nsd];
  der(M[3, Nsd]) = F_L[Nsd + 1] * x[3, Nsd + 1] + F_V[Nsd - 1] * y[3, Nsd - 1] - F_L[Nsd] * x[3, Nsd] - F_V[Nsd] * y[3, Nsd];
  der(H[Nsd]) = F_L[Nsd + 1] * h_L[Nsd + 1] + F_V[Nsd - 1] * h_V[Nsd - 1] - F_L[Nsd] * h_L[Nsd] - F_V[Nsd] * h_V[Nsd];
  //################################### ABOVE SIDE STREAM STAGE #################################
  for i in Nsd + 1:N - 2 loop
    der(M[1:NC, i]) = F_L[i + 1] * x[1:NC, i + 1] + F_V[i - 1] * y[1:NC, i - 1] - F_L[i] * x[1:NC, i] - F_V[i] * y[1:NC, i];
    der(H[i]) = F_L[i + 1] * h_L[i + 1] + F_V[i - 1] * h_V[i - 1] - F_L[i] * h_L[i] - F_V[i] * h_V[i];
  end for;
  //---------------------------------------------------------------------------------------------
  der(M[1:NC, N - 1]) = (1 - DR) * F_L[N - 1 + 1] * x[1:NC, N - 1 + 1] + F_V[N - 1 - 1] * y[1:NC, N - 1 - 1] - F_L[N - 1] * x[1:NC, N - 1] - F_V[N - 1] * y[1:NC, N - 1];
  der(H[N - 1]) = (1 - DR) * F_L[N - 1 + 1] * h_L[N - 1 + 1] + F_V[N - 1 - 1] * h_V[N - 1 - 1] - F_L[N - 1] * h_L[N - 1] - F_V[N - 1] * h_V[N - 1];
  //########################################### REBOILER #########################################
  der(M[1:NC, 1]) = F_L[2] * x[1:NC, 2] - F_L[1] * x[1:NC, 1] - F_V[1] * y[1:NC, 1];
  der(H[1]) = F_L[2] * h_L[2] - F_L[1] * h_L[1] - F_V[1] * h_V[1] + QR;
  //########################################## CONDENSER #########################################
  der(M[1:NC, N]) = F_V[N - 1] * y[1:NC, N - 1] - F_L[N] * x[1:NC, N] - F_V[N] * y[1:NC, N];
  der(Ucond) = F_V[N - 1] * h_V[N - 1] - F_L[N] * h_L[N] - F_V[N] * h_V[N] - QC;
  //---------------------------------------------------------------------------------------------
  H = M_L .* h_L + M_V .* h_V;
  y[1:NC, 1:N] = K[1:NC, 1:N] .* x[1:NC, 1:N];
  //################################## CALCULATE VAPOR PRESSURES #################################
  //######################################## HYDROLIC EQs. #######################################
  for j in 1:N loop
    for i in 1:NC loop
      Pvp[i, j] = 1e5 * exp(log(Pc[i]) + Tc[i] / T[j] * (a[i] * tau[i, j] + b[i] * tau[i, j] ^ 1.5 + c[i] * tau[i, j] ^ 2.5 + d[i] * tau[i, j] ^ 5));
      tau[i, j] = 1 - T[j] / Tc[i];
      K[i, j] = Pvp[i, j] / P[j];
    end for;
  end for;
  //---------------------------------------------------------------------------------------------
  Ucond = H[N] - P[N] * Vcond;
  Vcond = V_Lcond + V_Vcond;
  V_Vcond = M_V[N] * R * T[N] / P[N];
  V_Lcond = M_L[N] * rho_Lcond_inv;
  rho_Lcond_inv = sum(x[1:NC, N] ./ rho_L[1:NC]);
  for j in 1:N loop
    for i in 1:NC loop
      M[i, j] = M_L[j] * x[i, j] + M_V[j] * y[i, j];
      dHTref[i, j] = R * (alpha[1, i] * (T[j] - Tref) + alpha[2, i] / 2 * (T[j] ^ 2 - Tref ^ 2) + alpha[3, i] / 3 * (T[j] ^ 3 - Tref ^ 3) + alpha[4, i] / 4 * (T[j] ^ 4 - Tref ^ 4) + alpha[5, i] / 5 * (T[j] ^ 5 - Tref ^ 5));
      h_Vcmp[i, j] = dHform[i] + dHTref[i, j];
      h_Lcmp[i, j] = h_Vcmp[i, j] - dHvap[i, j];
    end for;
  //######################################## HYDROLIC EQs. #######################################
  //#################################### CALCULATE ENTHALPIES ####################################
    mid(M_V[j] / (M_L[j] + M_V[j]), sum(x[1:NC, j]) - sum(y[1:NC, j]), M_V[j] / (M_L[j] + M_V[j]) - 1) = 0;
    sum(M[1:NC, j]) = M_L[j] + M_V[j];
    h_L[j] = sum(x[1:NC, j] .* h_Lcmp[1:NC, j]);
    h_V[j] = sum(y[1:NC, j] .* h_Vcmp[1:NC, j]);
  end for;
  for j in 2:N - 1 loop
    if M_L[j] <= M_L_w[j] then
      F_L[j] = 0;
    else
      F_L[j] = 1.0 * c_L[j] * ((M_L[j] - M_L_w[j]) / sqrt(abs(M_L[j] - M_L_w[j]) + 1e-6)) ^ 3;
    end if;
  end for;
  for i in 1:N - 1 loop
    P[i] = 1e5 + 3 * 690 - (i - 1) * 690;
    F_V[i] = c_V[i] * M_V[i] / sqrt(abs(M_V[i]) + 1e-6);
  end for;
  F_V[N] = 0;
  //#################################### CALCULATE ENTHALPIES ####################################
  for i in 1:N loop
    for j in 1:NC loop
      dHvap[j, i] = A_e[j] * exp(B_e[j] * (1 - tau[j, i])) * tau[j, i] ^ C_e[j];
    end for;
  end for;
  //---------------------------------------------------------------------------------------------
  h_in = sum(z .* h_Lcmp_in);
  h_Lcmp_in = h_Vcmp_in - dHvap_in;
  h_Vcmp_in = dHform + dHTref_in;
  dHTref_in = R * (alpha[1, 1:NC] * (T_in - Tref) + alpha[2, 1:NC] / 2 * (T_in ^ 2 - Tref ^ 2) + alpha[3, 1:NC] / 3 * (T_in ^ 3 - Tref ^ 3) + alpha[4, 1:NC] / 4 * (T_in ^ 4 - Tref ^ 4) + alpha[5, 1:NC] / 5 * (T_in ^ 5 - Tref ^ 5));
  for i in 1:NC loop
    dHvap_in[i] = A_e[i] * exp(B_e[i] * (T_in / Tc[i])) * (1 - T_in / Tc[i]) ^ C_e[i];
  end for;
  //######################################## CONTROLLERS #########################################
  // ##### Reboiler volume controller
  VL_R_error = 9 * (VLReb_SP - V_LReboiler);
  der(VL_R_errorint) = 1 / 1000 * VL_R_error;
  QR = mid(0, QR_bias - QR_KC  * VL_R_error  - QR_KI * VL_R_errorint , 3e8);
  // ##### Condenser pressure controller 
  Pcond_error = Pcond_SP - P[N];
  der(Pcond_errorint) = 1 / 1000 * Pcond_error;
  QC = mid(0, QC_bias  - QC_KC * Pcond_error - QC_KI * Pcond_errorint , 3e8);
  // ##### Condenser volume controller
  VL_C_error = VLcond_SP - V_Lcond;
  F_in_calc=Fin_bias + 250*Fin_KC  * (VL_C_error) + Fin_KI * VL_C_errorint;
  F_in = mid(F0,F_in_calc , 0.19);
  if F_in_calc<=0.19 and F_in_calc>=F0 then
  der(VL_C_errorint) = 1 / 1000 * (VL_C_error);
  else
  der(VL_C_errorint)=0;
  end if;
  // ##### Distillate purity controller 
  xD_error = xD_SP - x[1, N];
  der(xD_errorint) = 1 / 1000 * xD_error;
  DR = mid(0, DRmax, (DR_bias  - DR_KC  * xD_error  - DR_KI * xD_errorint));
  // ##### Bottom purity controller
  xB_error = xB_SP - x[3, 1];
  der(xB_errorint) = 1 / 1000 * xB_error ;
  Lift_R  = mid(0, Lift_R_bias - 1 .* Lift_R_KC * xB_error - Lift_R_KI * xB_errorint, 1);
  if M_L[1] <= M_L_w[1] then
    F_L[1] = 0;
  else
    F_L[1] = Lift_R * c_L[1] * ((M_L[1] - M_L_w[1]) / sqrt(abs(M_L[1] - M_L_w[1]) + 1e-6)) ^ 3;
  end if;
  // ##### surge tank volume controller 
  der(M_SurgeTank[1:NC]) = S_Recycle * x[1:NC, Nsd] - F_L_SurgeTank * x_SurgeTank[1:NC];
  VSurgeTank_SP = Vcond;
  V_SurgeTank_Min = VSurgeTank_SP;
  VL_SurgeTank_error = VSurgeTank_SP - V_SurgeTank;
  der(VL_ST_errorint ) = 1 / 1000 * VL_SurgeTank_error;
  Lift_SurgeTank = mid(0, Lift_SurgeTank_bias - Lift_SurgeTank_KC * VL_SurgeTank_error, 1);
  if V_SurgeTank <= V_SurgeTank_Min then
    F_L_SurgeTank = 0;
  else
    F_L_SurgeTank = Lift_SurgeTank * c_L[Nsd] * ((V_SurgeTank - V_SurgeTank_Min) / sqrt(abs(V_SurgeTank - V_SurgeTank_Min) + 1e-6));
  end if;
  //---------------------------------------------------------------------------------------------
  der(TotalDistProd) = D_FlowRate;
  der(TotalSideProd) = Side_ProdFlowRate;
  der(TotalBottomProd) = F_L[1];
  der(TotalFeed) = F_in;
  if M_L[N] <= M_L_w[N] then
    F_L[N] = 0;
  else
    F_L[N] = 1.0 * c_L[N] * ((M_L[N] - M_L_w[N]) / sqrt(abs(M_L[N] - M_L_w[N]) + 1e-6)) ^ 3;
  end if;
  ReboilerDuty = QR / 1e6;
  CondenserDuty = QC / 1e6;
  Duties = TotalReboilerDuty + TotalCondenserDuty;
  if time<=200*3600 then
  der(TotRebDutyCycl)=0;
  der(TotCondDutyCycl)=0;
  else
  der(TotRebDutyCycl)=ReboilerDuty;
  der(TotCondDutyCycl)=CondenserDuty;
  end if;
  DutiesCycl=TotRebDutyCycl+TotCondDutyCycl;
  //##################################### SIDE STREAM MODES ######################################
  // ##### Side product controller (open or close)
  if x[2, Nsd] > HighPurity then
    Lift_sd = sideprod_frac;
    Semi_divide_Parameter = 0.8;
  elseif x[2, Nsd] > LowPurity and x[2, Nsd] <= HighPurity and Puritydp >= 0.7 then
    Lift_sd = sideprod_frac;
    Semi_divide_Parameter = 0.7;
  else
    Lift_sd = 0.0;
    Semi_divide_Parameter = 0;
  end if;
  dx = der(x[2, Nsd]);
  S_Recycle = (1 - Lift_sd) * S_FlowRate;
  Side_ProdFlowRate  = Lift_sd * S_FlowRate;
  D_FlowRate = DR * F_L[N];
  Relux_FlowRate = (1 - DR) * F_L[N];
  S_FlowRate  = z[2] * F_in + .985*x_SurgeTank[2]*F_L_SurgeTank;
  Puritydp = delay(Semi_divide_Parameter, 1);
  der(TotalReboilerDuty) = ReboilerDuty;
  der(TotalCondenserDuty) = CondenserDuty;
  V_LReboiler = M_L[1] * rho_LReboiler_inv ;
  rho_LReboiler_inv = sum(x[1:NC, 1] ./ rho_L[1:NC]);
  //---------------------------------------------------------------------------------------------
  V_SurgeTank = M_L_SurgeTank * rho_LSurgeTank_inv;
  rho_LSurgeTank_inv = sum(x_SurgeTank[1:NC] ./ rho_L[1:NC]);
  for i in 1:NC loop
    M_SurgeTank[i] = M_L_SurgeTank * x_SurgeTank[i];
  end for;
  sum(M_SurgeTank[1:NC]) = M_L_SurgeTank;
  h_L_SurgeTank = sum(x_SurgeTank[1:NC] .* h_Lcmp[1:NC, Nsd]);
  //---------------------------------------------------------------------------------------------
  xS = x[2, Nsd];
  xD=x[1,N];
  xB=x[3,1];
  Pcond=P[N];
  xSurgeTank = x_SurgeTank[2];
 if time <= steptime then
  z[1:NC] = {0.4, 0.2, 0.4};
  else
  z[1:NC] = {0.375, 0.25, 0.375};
  end if;
  
  //###### Initial conditions for the surge tank and integral terms of the PI controllersS #######
initial equation
  x_SurgeTank[1]=0;
  x_SurgeTank[2]=1;
  V_SurgeTank = VSurgeTank_SP;
  Pcond_errorint = -125.8281601;
  VL_R_errorint = -25.2177655;
  VL_C_errorint = -1.2;
  xD_errorint = 0.794105529;
  xB_errorint = 0.247581245;
  VL_ST_errorint = 0;
  //################################## Column initial conditions #################################
 T={417.3572603,	416.4031448,	414.588894,	411.1254204,	405.2517404,	397.5020117,	390.407394,	385.7900109,	383.4192269,	382.2858305,	381.6919441,	381.3102296,	381.0080616,	380.7346449,	380.4709366, 380.2098551,	379.94876,	379.6866624,	379.4231794,	379.1581438,	378.8914511,	378.6229793,	378.352505,	378.079541,	377.8029626,	377.5201206,	377.2247285,	376.9018397,	376.5160376,	375.9843891,	375.1185987,	373.5225794,	370.5076989,	365.3803698,	358.5628841,	352.1724509,	347.9427456,	345.7243186,	344.6308328,	344.0327839};

  M_L={1.858227483,	5.145618051,	5.136260145,	5.123210552,	5.117852175,	5.150891513,	5.204338758,	5.30584809,	5.374553947,	5.407707412,	5.420621183,	5.424625428,	5.425100202,	5.424231427,	5.428611715,	5.427035996,	5.425384511,	5.423699732,	5.421997402,	5.420283183,	5.418558946,	5.416824984,	5.415080569,	5.41332355,	5.411548767,	5.409744032,	5.407880544,	5.405890487,	5.403616461,	5.400707552,	5.396462249,	5.389898331,	5.381602022,	5.380896022,	5.412130952,	5.487010984,	5.570644927,	5.626372514,	5.652856273,	1.34911389};

  M_V={0.013507086,	0.013433291,	0.013330811,	0.013288915,	0.013549053,	0.014214661,	0.015058941,	0.015648998,	0.015939197,	0.016053239,	0.016088757,	0.016093031,	0.0160854,	0.01607329,	0.016059406, 0.016044855,	0.016030018,	0.016015035,	0.015999957,	0.0159848,	0.015969567,	0.015954251,	0.015938834,	0.01592327,	0.015907453,	0.01589113,	0.015873706,	0.015853802,	0.015828347,	0.015791217,	0.015733886,	0.015661606,	0.015655525,	0.015929056,	0.016597646,	0.017366234,	0.017891352,	0.018144616,	0.018240414,	0.002219708};

  y[3,1:N]={0.976425393,	0.94538876,	0.878050906,	0.747640545,	0.544538331,	0.319495517,	0.152569168,	0.063455977,	0.024630821,	0.009281234,	0.00345494,	0.001279344,	0.000472449,	0.000174128,	6.40E-05,	2.35E-05,	8.63E-06,	3.16E-06,	1.16E-06,	4.24E-07,	1.55E-07,	5.65E-08,	2.06E-08,	7.50E-09,	2.73E-09,	9.91E-10,	3.59E-10,	1.30E-10,	4.68E-11,	1.67E-11,	5.82E-12,	1.94E-12,	5.88E-13,	1.50E-13,	2.98E-14,	4.67E-15,	6.24E-16,	7.67E-17,	9.09E-18,	1.06E-18};

  
  annotation(
    __OpenModelica_simulationFlags(lv = "LOG_DASSL,LOG_STATS", s = "dassl"),
    experiment(StartTime = 0, StopTime = 1e6, Tolerance = 1e-06, Interval = 200));
end SCD_with_surge_BTX;
