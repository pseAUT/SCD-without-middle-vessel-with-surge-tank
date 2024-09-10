model SCD_surgev6_rebL1
  //-----------------------------------------------------------------------
  //DECLARE
  //MolFlow	      = 1 : 1E8 	unit = "kmol/s"    volumetric flowrate
  //Mol		      = 2 : 1e8     unit = "kmol"	   cross-sectional area
  //Volume	      = 1 : 1E8 	unit = "m3" 	   volume
  //Pressure      = 1e5 : 1e7	unit = "Pa"	       pressure kPa
  //Temp	      = 273 : 500	unit = "K"	       temperature in K
  //MolEnthalpy	  = 0 : 1e10	unit = "J/kmol"	   molar enthalpy
  //Energy        = 0 : 1e30	unit = "J"		   energy
  //HeatDuty      = 0 : 1e30	unit = "J/s"	   heat duty
  //SpecHeatCap	  = 10 : 1e6 	unit = "J/K/kmol"
  //-----------------------------------------------------------------------
  parameter Integer NC = 3;
  //number of components
  parameter Integer N = 40;
  //number of stages including reboiler and condenser
  parameter Integer Nsd = 15;
  //Side draw stage
  parameter Integer ifeed = 6;
  //Feed stage
  //-----------------------------------------------------------------------
  //Wagner Constants for Eq. (7-3.3)
  parameter Real[NC] Tc = {562.16, 591.80, 630.3};
  //Vapor Pressure Correlations Parameters (K)
  parameter Real[NC] a = {-7.01433, -7.31600, -7.60491};
  //Vapor Pressure Correlations Parameters
  parameter Real[NC] b = {1.55256, 1.59425, 1.75383};
  //Vapor Pressure Correlations Parameters
  parameter Real[NC] c = {-1.8479, -1.93165, -2.27531};
  //Vapor Pressure Correlations Parameters
  parameter Real[NC] d = {-3.7130, -3.72220, -3.73771};
  //Vapor Pressure Correlations Parameters
  parameter Real[NC] Pc = {48.98, 41.06, 37.32};
  //Vapor Pressure Correlations Parameters (bar)
  //-----------------------------------------------------------------------
  parameter Real Tref = 298.15;
  //reference temperature (K)
  parameter Real[NC] dHform = {82.88e6, 50.17e6, 19.08e6};
  //enthalpy of formation	(J/mol)	[cal. h_V]
  parameter Real[5, NC] alpha = {{3.551, 3.866, 3.289}, {-6.184e-3, 3.558e-3, 34.144e-3}, {14.365e-5, 13.356e-5, 4.989e-5}, {-19.807e-8, -18.659e-8, -8.335e-8}, {8.234e-11, 7.690e-11, 3.338e-11}};
  //Ideal Gas and Liquid Heat Capacities at 298.15 K, "J / (mol . K)"
  //-----------------------------------------------------------------------
  parameter Real[N] k_l = {0.05, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 2.6};
  //liquid flow constant (weir)
  parameter Real[N] k_v = {30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30};
  //vapor flow constant
  parameter Real[N] M_L_min = {0.01, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.005};
  //minimum liquid hold-up on tray (unit = "kmol")
  //-----------------------------------------------------------------------
  parameter Real rmax = 0.4;
  // reflux ratio
  parameter Real F0 = 0.03;
  // initial feedrate  unit = "kmol/s"
  //initial feed rate
  parameter Real Tsd = 300;
  //excess
  //time of triggering shutdown
  parameter Real Tf = Tsd + 100;
  //excess
  //total time
  parameter Real Qrss = 9e8;
  //excess
  //steady state factor of reboiler heat duty
  parameter Real Qcss = 1.905e6;
  //excess
  //steady state factor of condenser heat duty
  parameter Real cr = 2;
  //excess
  //coeff for reflux
  parameter Real Vcond = 0.205;
  // condenser volume  (unit = "m3")
  //-----------------------------------------------------------------------
  //Controllers
  //Setpoints
  parameter Real Pcond_SP = 75160;
  //97240;
  //(unit = "Pa")
  parameter Real VLReb_SP = .23 ;    //2;
  //unit = "kmol"
  parameter Real V_Lcond_SP = 0.5 * Vcond;
  //unit = "m3"
  parameter Real D_SP = 0.99;
  parameter Real B_SP = 0.99;
  //-----------------------------------------------------------------------
  parameter Real[NC] Mw = {78.11, 92.14, 106.167};
  //unit = "kg / kmol"
  parameter Real[NC] rho_L = {876 / Mw[1], 867 / Mw[2], 880 / Mw[3]};
  //componentwise molar density	(unit = "kmol / m3")***check unit
  parameter Real R = 8.314e3;
  //gas constant	J/kmol.K
  parameter Real g = 9.81;
  //excess
  parameter Real P0 = 1e5;
  //excess
  parameter Real[NC] A_e = {1e6 * 47.41, 1e6 * 53.09, 1e6 * 59.3095};
  parameter Real[NC] B_e = {-0.1231, -0.2774, -0.2791};
  parameter Real[NC] C_e = {0.3602, 0.2774, 0.2791};
  //Enthalpies of Vaporization, parameters

  //-----------------------------------------------------------------------
  parameter Real RebDuty_bias = 12.5e5;
  parameter Real CondDuty_bias = 12.5e5;
  parameter Real Fin_bias = 0.05;
  parameter Real rr_bias = 0.4;
  //parameter Real L1_bias = 1;
  parameter Real L1_bias = 10;
  parameter Real surge_bias = .5;

  //-----------------------------------------------------------------------
  //parameter Real Qr_gain = 6.9e3;
  parameter Real Qr_gain = 6.9e4;
  //mutliply by 9 in paper
  parameter Real Qc_gain = 6.9e3;
  parameter Real Fin_gain = 0.05;
  parameter Real rr_gain = 4;//5.975; detune=2
  //parameter Real L1_gain = 1;//1.175; detune
  parameter Real L1_gain = 10;//1.175; detune
  parameter Real surge_gain = .05;//0.5;
 
  //-----------------------------------------------------------------------
  parameter Real Qr_KI = 5e6;   //mutliply by 9 in paper
  parameter Real Qc_KI = 1e6;
  parameter Real Fin_KI = 0.5;
  parameter Real rr_KI = 0.5;
  //parameter Real L1_KI = 4;
  parameter Real L1_KI = 40;
  parameter Real surge_kI = 0.001;//.2;//0.5;

  //-----------------------------------------------------------------------
  //Side draw purities
  parameter Real HighPurity = 0.995;
  parameter Real LowPurity = 0.985;
  //-----------------------------------------------------------------------
  parameter Real  sideprod_frac = 0.98;
  parameter Real steptime = 277.7778*3600;
  //variables
  //Integer  ncycle;
  Real[NC] z;
  Real[NC, N] K(each start = 1);
  Real[NC, N] y;
  //mol fraction in vapor phase
  //(each start= 0.1);
  Real[NC, N] x;
  //mol fraction in liquid phase
  //(each start= 0.9);
  Real[N] M_L;
  // liquid hold-up (unit = "kmol")
  Real[N] M_V;
  // vapor hold-up (unit = "kmol")
  Real[NC, N] M(start = {{1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 2e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 4e-2}, {1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 4e-2}, {1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 4e-2}});
  //total hold-up of each component (unit = "kmol")
  Real F_in;
  Real F_in_calc;
  // total mol flow of feed (unit = "kmol/s")
  Real[N] F_L(start = {0.0045, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.018, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.018, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.0065, 0.004});
  // liquid mol flow out of tray (unit = "kmol/s")
  Real[N] F_V(start = {0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0});
  // vapor mol flow out of tray (unit = "kmol/s")
  //-----------------------------------------------------------------------
  Real[NC, N] Pvp;
  // vapor pressure of pur component (kPa)
  Real[NC, N] tau;
  // for Vapor Pressure Correlations
  Real[N] T;
  // temperature of tray (K)
  Real T_in = 340;
  Real[N] h_L;
  //molar enthalpy of liquid phase (unit = "J/kmol")
  Real[N] h_V;
  //molar enthalpy of vapor phase (unit = "J/kmol")
  Real[NC, N] h_Lcmp;
  //molar enthalpy of liquid phase for each component (unit = "J/kmol")
  Real[NC, N] h_Vcmp;
  //molar enthalpy of vapor phase for each component (unit = "J/kmol")
  Real[NC, N] dHvap;
  //enthalpy of vaporization (unit = "J/kmol")
  Real[NC] h_Lcmp_in;
  //molar enthalpy of liquid phase	for each component in feed (unit = "J/kmol")
  Real[NC] h_Vcmp_in;
  //molar enthalpy of vapor phase for each component in feed (unit = "J/kmol")
  Real[NC] dHvap_in;
  //enthalpy of vaporization for feed (unit = "J/kmol")
  Real h_in;
  //molar enthalpy of feed (unit = "J/kmol")
  Real Qr;
  //reboiler heat duty (unit = "J/s")
  Real Qc;
  //condenser heat duty (unit = "J/s")
  Real[N] H;
  //enthalpy of both phases (unit = "J")
  Real Ucond;
  //condenser internal energy of both phases (unit = "J")
  Real[NC, N] dHTref;
  //Change in molar enthalpy from reference temperature (unit = "J/kmol")
  Real[NC] dHTref_in;
  //Change in molar enthalpy from reference temperature to feed temperature (unit = "J/kmol")
  Real rr;
  //reflux ratio
  //  Real Lowholdup;
  //lowest (hold-up - holdup_min) (unit = "kmol")
  Real[N] P(start = {100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 97240});
  //stage pressure (Pa)
  Real V_Vcond;
  //vapor volume in condenser (unit = "m3")
  Real V_Lcond(start = 0.5 * Vcond);
  //liquid volume in condenser (unit = "m3")
  Real rho_Lcond_inv;
  //liquid density in condenser (unit = "m3/kmol")
  Real P_errorint;
  //integral of deviation of cond pressure from setpoint
  Real ML_errorint;
  //integral of deviation of Reboiler hold up from setpoint
  Real VL_errorint;
  //integral of deviation of Cond hold up from setpoint
  Real D_errorint;
  //integral of deviation of Distillate purity from setpoint
  Real B_errorint;
  //integral of deviation of Bottom purity from setpoint
  //Real SideProduct_Flowrate;
  //gain of Reboiler duty controller
  Real L1;
  //Bottom Rate Lift
  Real F_Lsd;
  //Side draw flow rate (for add to feed) (unit = "kmol/s")
  Real Side_ProdFlow;
  //Side product flow rate (unit = "kmol/s")
  Real CondenserDuty;
  //Duty of Condenser (Mj)
  Real ReboilerDuty;
  //Duty of Reboiler (Mj)
  //Real Distillate_Flowrate;
  //Distillate Flowrate (Lit/s)
  Real Coef;
  //Coefficient for check zero hold up for reflux
  Real Lsd;
  //Side draw lift for contain recycle or product
  Real Semi_divide_Parameter;
  //a parameter for contain open or close for sidedraw valve
  Real Sidedraw_FlowRate;
  //Sidedraw_FlowRate (x_toluene * Feed) (unit = "kmol/s")
  //Real Feed_Flowrate;
  //Feed Flow rate (Lit/s)
  //Real Bottom_Flowrate;
  //Feed Flow rate (Lit/s)
  Real Puritydp;
  //purity delay parameter
  Real Relux_flow;
  Real Dist_Flowrate;
  //Distillate Flowrate (rr * Reflux) (unit = "kmol/s")
  Real Pcond_error;
  //deviation of reboiler duty from setpoint
  Real Reb_L_error;
  //deviation of condenser duty from setpoint
  Real XD_error;
  //deviation of Distillate purity from setpoint
  Real BottomP_error;
  //deviation of Bottom purity from setpoint
  //(start=0);  //integral of deviation of cond pressure from setpoint
  Real TotalReboilerDuty;
  Real TotalCondenserDuty;
  Real TotCondDutyCycl;
  Real TotRebDutyCycl;
  Real Duties;
  Real DutiesCycl;
  //Real F_L_Product_Lit;
  //
  Real TotalDistProd;
  //kmol
  Real TotalSideProd;
  //kmol
  Real TotalBottomProd;
  //kmol
  Real TotalFeed;
  //kmol
  //-------------------
  Real V_L_Reboiler;
  Real rho_L_Reboiler_inv;
  //---------------------------------------------------------------------
  Real ST_errorint;
  Real[NC] M_SurgeTank;
  Real[NC] x_SurgeTank;
  Real SurgeTank_error;
  Real V_SurgeTank;
  Real V_SurgeTankSP;
  Real V_SurgeMin;
  Real Lift_SurgeTank;
  Real F_L_SurgeTank;
  Real M_L_SurgeTank;
  Real h_L_SurgeTank;
  Real rho_L_SurgeTank_inv;
  Real dx;
  //auxiliary vars for easy outputing
  Real xside;
  Real xD;
  Real xB;
  Real Pcond;
  Real xsurge;
  //---------------------------------------------------------------------
equation
//########### MASS AND ENERGY BALANCSE ###########################
//############## FEED TRAY #############################
  der(M[1:NC, ifeed]) = F_in * z[1:NC] + F_L[ifeed + 1] * x[1:NC, ifeed + 1] + F_V[ifeed - 1] * y[1:NC, ifeed - 1] - F_L[ifeed] * x[1:NC, ifeed] - F_V[ifeed] * y[1:NC, ifeed] + F_L_SurgeTank * x_SurgeTank[1:NC];
  der(H[ifeed]) = F_in * h_in + F_L[ifeed + 1] * h_L[ifeed + 1] + F_V[ifeed - 1] * h_V[ifeed - 1] - F_L[ifeed] * h_L[ifeed] - F_V[ifeed] * h_V[ifeed] + F_L_SurgeTank * h_L_SurgeTank;
////############# OTHER TRAY #############################
  for i in 2:ifeed - 1 loop
    der(M[1:NC, i]) = F_L[i + 1] * x[1:NC, i + 1] + F_V[i - 1] * y[1:NC, i - 1] - F_L[i] * x[1:NC, i] - F_V[i] * y[1:NC, i];
//this would b efull refulx unless F_L(N-1) is changed
    der(H[i]) = F_L[i + 1] * h_L[i + 1] + F_V[i - 1] * h_V[i - 1] - F_L[i] * h_L[i] - F_V[i] * h_V[i];
//this would be full refulx unless F_L(N-1) is changed
  end for;
//-----------------------------------------------------------------------
//before sidedraw
  for i in ifeed + 1:Nsd - 2 loop
    der(M[1:NC, i]) = F_L[i + 1] * x[1:NC, i + 1] + F_V[i - 1] * y[1:NC, i - 1] - F_L[i] * x[1:NC, i] - F_V[i] * y[1:NC, i];
//this would b efull refulx unless F_L(N-1) is changed
    der(H[i]) = F_L[i + 1] * h_L[i + 1] + F_V[i - 1] * h_V[i - 1] - F_L[i] * h_L[i] - F_V[i] * h_V[i];
//this would b efull refulx unless F_L(N-1) is changed
  end for;
//-----------------------------------------------------------------------
//Semi
  der(M[1:NC, Nsd - 1]) = F_L[Nsd] * x[1:NC, Nsd] + F_V[Nsd - 1 - 1] * y[1:NC, Nsd - 1 - 1] - F_L[Nsd - 1] * x[1:NC, Nsd - 1] - F_V[Nsd - 1] * y[1:NC, Nsd - 1] - Sidedraw_FlowRate * x[1:NC, Nsd];
//this would b efull refulx unless F_L(N-1) is changed
  der(H[Nsd - 1]) = F_L[Nsd] * h_L[Nsd] + F_V[Nsd - 1 - 1] * h_V[Nsd - 1 - 1] - F_L[Nsd - 1] * h_L[Nsd - 1] - F_V[Nsd - 1] * h_V[Nsd - 1] - Sidedraw_FlowRate * h_L[Nsd];
//this would b efull refulx unless F_L(N-1) is changed
//-----------------------------------------------------------------------
// for side draw
  der(M[1, Nsd]) = F_L[Nsd + 1] * x[1, Nsd + 1] + F_V[Nsd - 1] * y[1, Nsd - 1] - F_L[Nsd] * x[1, Nsd] - F_V[Nsd] * y[1, Nsd];
  x[2, Nsd] * der(M_L[Nsd]) + M_L[Nsd] * der(x[2, Nsd]) + y[2, Nsd] * der(M_V[Nsd]) + M_V[Nsd] * der(y[2, Nsd]) = F_L[Nsd + 1] * x[2, Nsd + 1] + F_V[Nsd - 1] * y[2, Nsd - 1] - F_L[Nsd] * x[2, Nsd] - F_V[Nsd] * y[2, Nsd];
  der(M[3, Nsd]) = F_L[Nsd + 1] * x[3, Nsd + 1] + F_V[Nsd - 1] * y[3, Nsd - 1] - F_L[Nsd] * x[3, Nsd] - F_V[Nsd] * y[3, Nsd];
/*der(M[1:NC, Nsd]) = F_L[Nsd + 1] * x[1:NC,Nsd + 1] + F_V[Nsd - 1] * y[1:NC,  Nsd - 1] - F_L[Nsd] * x[1:NC, Nsd] - F_V[Nsd] * y[1:NC,  Nsd];   */
//this would b efull refulx unless F_L(N-1) is changed
  der(H[Nsd]) = F_L[Nsd + 1] * h_L[Nsd + 1] + F_V[Nsd - 1] * h_V[Nsd - 1] - F_L[Nsd] * h_L[Nsd] - F_V[Nsd] * h_V[Nsd];
//this would b efull refulx unless F_L(N-1) is changed
//after sidedraw
  for i in Nsd + 1:N - 2 loop
    der(M[1:NC, i]) = F_L[i + 1] * x[1:NC, i + 1] + F_V[i - 1] * y[1:NC, i - 1] - F_L[i] * x[1:NC, i] - F_V[i] * y[1:NC, i];
//this would b efull refulx unless F_L(N-1) is changed
    der(H[i]) = F_L[i + 1] * h_L[i + 1] + F_V[i - 1] * h_V[i - 1] - F_L[i] * h_L[i] - F_V[i] * h_V[i];
//this would b efull refulx unless F_L(N-1) is changed
  end for;
//-----------------------------------------------------------------------
//use reflux ratio
  der(M[1:NC, N - 1]) = (1 - rr) * F_L[N - 1 + 1] * x[1:NC, N - 1 + 1] + F_V[N - 1 - 1] * y[1:NC, N - 1 - 1] - F_L[N - 1] * x[1:NC, N - 1] - F_V[N - 1] * y[1:NC, N - 1];
//this would b efull refulx unless F_L(N-1) is changed
  der(H[N - 1]) = (1 - rr) * F_L[N - 1 + 1] * h_L[N - 1 + 1] + F_V[N - 1 - 1] * h_V[N - 1 - 1] - F_L[N - 1] * h_L[N - 1] - F_V[N - 1] * h_V[N - 1];
//this would b efull refulx unless F_L(N-1) is changed
//rr = mid(rmax, cr * Lowholdup, 0);
//  Lowholdup = min(M_L[39] - M_L_min[39], min(M_L[38] - M_L_min[38], min(M_L[37] - M_L_min[37], min(M_L[36] - M_L_min[36], min(M_L[35] - M_L_min[35], min(M_L[34] - M_L_min[34], min(M_L[33] - M_L_min[33], min(M_L[32] - M_L_min[32], min(M_L[31] - M_L_min[31], min(M_L[30] - M_L_min[30], min(M_L[29] - M_L_min[29], min(M_L[28] - M_L_min[28], min(M_L[27] - M_L_min[27], min(M_L[26] - M_L_min[26], min(M_L[25] - M_L_min[25], min(M_L[24] - M_L_min[24], min(M_L[23] - M_L_min[23], min(M_L[22] - M_L_min[22], min(M_L[21] - M_L_min[21], min(M_L[20] - M_L_min[20], min(M_L[19] - M_L_min[19], min(M_L[18] - M_L_min[18], min(M_L[17] - M_L_min[17], min(M_L[16] - M_L_min[16], min(M_L[15] - M_L_min[15], min(M_L[14] - M_L_min[14], min(M_L[13] - M_L_min[13], min(M_L[12] - M_L_min[12], min(M_L[11] - M_L_min[11], min(M_L[10] - M_L_min[10], min(M_L[9] - M_L_min[9], min(M_L[8] - M_L_min[8], min(M_L[7] - M_L_min[7], min(M_L[5] - M_L_min[5], min(M_L[4] - M_L_min[4], min(M_L[3] - M_L_min[3], M_L[2] - M_L_min[2]))))))))))))))))))))))))))))))))))));
////############# REBOILER #############################
  der(M[1:NC, 1]) = F_L[2] * x[1:NC, 2] - F_L[1] * x[1:NC, 1] - F_V[1] * y[1:NC, 1];
  der(H[1]) = F_L[2] * h_L[2] - F_L[1] * h_L[1] - F_V[1] * h_V[1] + Qr;
////############# CONDENSER #############################
  der(M[1:NC, N]) = F_V[N - 1] * y[1:NC, N - 1] - F_L[N] * x[1:NC, N] - F_V[N] * y[1:NC, N];
//full reflux of liquid phase
  der(Ucond) = F_V[N - 1] * h_V[N - 1] - F_L[N] * h_L[N] - F_V[N] * h_V[N] - Qc;
//-----------------------------------------------------------------------
  H = M_L .* h_L + M_V .* h_V;
  y[1:NC, 1:N] = K[1:NC, 1:N] .* x[1:NC, 1:N];
////##########################################
//calculate vapor pressures (equation should be moved to a different file and included here)
  for j in 1:N loop
    for i in 1:NC loop
      Pvp[i, j] = 1e5 * exp(log(Pc[i]) + Tc[i] / T[j] * (a[i] * tau[i, j] + b[i] * tau[i, j] ^ 1.5 + c[i] * tau[i, j] ^ 2.5 + d[i] * tau[i, j] ^ 5));
      tau[i, j] = 1 - T[j] / Tc[i];
//Pvp[i,j] = 1e5*exp((log(Pc[i]))); //TODO: temp
      K[i, j] = Pvp[i, j] / P[j];
    end for;
  end for;
  Ucond = H[N] - P[N] * Vcond;
  Vcond = V_Lcond + V_Vcond;
  V_Vcond = M_V[N] * R * T[N] / P[N];
//P[8] is zero for some reason!
//P[8] =(1e5+3*690) - (8-1)*690	;//0.1 psi drop per tray : temporary
  V_Lcond = M_L[N] * rho_Lcond_inv;
  rho_Lcond_inv = sum(x[1:NC, N] ./ rho_L[1:NC]);
  for j in 1:N loop
    for i in 1:NC loop
      M[i, j] = M_L[j] * x[i, j] + M_V[j] * y[i, j];
      dHTref[i, j] = R * (alpha[1, i] * (T[j] - Tref) + alpha[2, i] / 2 * (T[j] ^ 2 - Tref ^ 2) + alpha[3, i] / 3 * (T[j] ^ 3 - Tref ^ 3) + alpha[4, i] / 4 * (T[j] ^ 4 - Tref ^ 4) + alpha[5, i] / 5 * (T[j] ^ 5 - Tref ^ 5));
      h_Vcmp[i, j] = dHform[i] + dHTref[i, j];
      h_Lcmp[i, j] = h_Vcmp[i, j] - dHvap[i, j];
    end for;
//-----------------------------------------------------------------------
// hydralic eqs
//-----------------------------------------------------------------------
    mid(M_V[j] / (M_L[j] + M_V[j]), sum(x[1:NC, j]) - sum(y[1:NC, j]), M_V[j] / (M_L[j] + M_V[j]) - 1) = 0;
    sum(M[1:NC, j]) = M_L[j] + M_V[j];
    h_L[j] = sum(x[1:NC, j] .* h_Lcmp[1:NC, j]);
    h_V[j] = sum(y[1:NC, j] .* h_Vcmp[1:NC, j]);
  end for;
//-----------------------------------------------------------------------
  for j in 2:N - 1 loop
    if M_L[j] <= M_L_min[j] then
      F_L[j] = 0;
    else
      F_L[j] = 1.0 * k_l[j] * ((M_L[j] - M_L_min[j]) / sqrt(abs(M_L[j] - M_L_min[j]) + 1e-6)) ^ 3;
    end if;
  end for;
//-----------------------------------------------------------------------
  for i in 1:N - 1 loop
    P[i] = 1e5 + 3 * 690 - (i - 1) * 690;
//0.1 psi drop per tray
    F_V[i] = k_v[i] * M_V[i] / sqrt(abs(M_V[i]) + 1e-6);
//should be based on pressure head
  end for;
  F_V[N] = 0;
//total condenser
////############################################################
//## compute enthalpies (should be later moved to a different file and inlucded here)
//Majer and Svoboda, 1985
//Majer, V.; Svoboda, V., Enthalpies of Vaporization of Organic Compounds:
//A Critical Review and Data Compilation, Blackwell Scientific Publications, Oxford, 1985, 300. [all data]
// from http://webbook.nist.gov/cgi/cbook.cgi?ID=C71432&Mask=4
  for i in 1:N loop
    for j in 1:NC loop
      dHvap[j, i] = A_e[j] * exp(B_e[j] * (1 - tau[j, i])) * tau[j, i] ^ C_e[j];
    end for;
  end for;
//compute enthalpy of feed
  h_in = sum(z .* h_Lcmp_in);
//assuming only liquid feed
  h_Lcmp_in = h_Vcmp_in - dHvap_in;
//assuming feed is liquid
  h_Vcmp_in = dHform + dHTref_in;
  dHTref_in = R * (alpha[1, 1:NC] * (T_in - Tref) + alpha[2, 1:NC] / 2 * (T_in ^ 2 - Tref ^ 2) + alpha[3, 1:NC] / 3 * (T_in ^ 3 - Tref ^ 3) + alpha[4, 1:NC] / 4 * (T_in ^ 4 - Tref ^ 4) + alpha[5, 1:NC] / 5 * (T_in ^ 5 - Tref ^ 5));
  for i in 1:NC loop
    dHvap_in[i] = A_e[i] * exp(B_e[i] * (T_in / Tc[i])) * (1 - T_in / Tc[i]) ^ C_e[i];
  end for;
////############################################################
//	level controller for reboiler
  Reb_L_error = 9 * (VLReb_SP - V_L_Reboiler);
// M_L[1];
  der(ML_errorint) = 1 / 1000 * Reb_L_error;
  Qr = mid(0, RebDuty_bias - Qr_gain * Reb_L_error - Qr_KI * ML_errorint, 3e8);
//-----------------------------------------------------------------------
//TODO temp
//Condenser pressure controller
  Pcond_error = Pcond_SP - P[N];
  der(P_errorint) = 1 / 1000 * Pcond_error;
  Qc = mid(0, CondDuty_bias - Qc_gain * Pcond_error - Qc_KI * P_errorint, 3e8);
//-----------------------------------------------------------------------
//Condenser hold up (volume) controller
  F_in_calc=Fin_bias + 250*Fin_gain * (V_Lcond_SP - V_Lcond) + Fin_KI * VL_errorint;
  F_in = mid(F0,F_in_calc , 0.19);
  if F_in_calc<=0.19 and F_in_calc>=F0 then
  der(VL_errorint) = 1 / 1000 * (V_Lcond_SP - V_Lcond);
  else
  der(VL_errorint)=0;
  end if;
//-----------------------------------------------------------------------
//Distillate purity controller
//Coef = k * Lowholdup / sqrt(abs(Lowholdup) + 1e-6);
  Coef = 1;
//Lowholdup / (Lowholdup + 1e-6);
  XD_error = D_SP - x[1, N];
  der(D_errorint) = 1 / 1000 * XD_error;
  rr = mid(0, rmax, Coef * (rr_bias - rr_gain * XD_error - rr_KI * D_errorint));
//-----------------------------------------------------------------------
  der(TotalDistProd) = Dist_Flowrate;
  der(TotalSideProd) = Side_ProdFlow;
  der(TotalBottomProd) = F_L[1];
  der(TotalFeed) = F_in;
//-----------------------------------------------------------------------
//Reflux
  if M_L[N] <= M_L_min[N] then
    F_L[N] = 0;
  else
    F_L[N] = 1.0 * k_l[N] * ((M_L[N] - M_L_min[N]) / sqrt(abs(M_L[N] - M_L_min[N]) + 1e-6)) ^ 3;
//CHC
  end if;
//-----------------------------------------------------------------------
  ReboilerDuty = Qr / 1e6;
//F_L_Pr + F_L[1] + F_L[N];
  CondenserDuty = Qc / 1e6;
//F_L_Pr + F_L[1] + F_L[N] - F_in;
  Duties = TotalReboilerDuty + TotalCondenserDuty;
  if time<=200*3600 then
  der(TotRebDutyCycl)=0;
  der(TotCondDutyCycl)=0;
  else
  der(TotRebDutyCycl)=ReboilerDuty;
  der(TotCondDutyCycl)=CondenserDuty;
  end if;
  DutiesCycl=TotRebDutyCycl+TotCondDutyCycl;
//-----------------------------------------------------------------------
//Bottoms purity controller
  BottomP_error = B_SP - x[3, 1];
  der(B_errorint) = 1 / 1000 * BottomP_error;
  L1 = mid(0, L1_bias - 1.*L1_gain * BottomP_error - L1_KI * B_errorint, 1);
  if M_L[1] <= M_L_min[1] then
    F_L[1] = 0;
  else
    F_L[1] = L1 * k_l[1] * ((M_L[1] - M_L_min[1]) / sqrt(abs(M_L[1] - M_L_min[1]) + 1e-6)) ^ 3;
  end if;
//-----------------------------------------------------------------------
//side product controller (open or close)
  if x[2, Nsd] > HighPurity then
    Lsd = sideprod_frac;
    Semi_divide_Parameter = 0.8;
  elseif x[2, Nsd] > LowPurity and x[2, Nsd] <= HighPurity and Puritydp >= 0.7 then
    Lsd = sideprod_frac;
    Semi_divide_Parameter = 0.7;
  else
    Lsd = 0.0;
    Semi_divide_Parameter = 0;
  end if;
  dx = der(x[2, Nsd]);
/**/

  F_Lsd = (1 - Lsd) * Sidedraw_FlowRate;
  Side_ProdFlow = Lsd * Sidedraw_FlowRate;
  Dist_Flowrate = rr * F_L[N];
  Relux_flow = (1 - rr) * F_L[N];
//-----------------------------------------------------------------------
  Sidedraw_FlowRate = z[2] * F_in + .985*x_SurgeTank[2]*F_L_SurgeTank;
//Sidedraw_FlowRate = 0.13 * F_in;
  Puritydp = delay(Semi_divide_Parameter, 1);
//-----------------------------------------------------------------------
  der(TotalReboilerDuty) = ReboilerDuty;
  der(TotalCondenserDuty) = CondenserDuty;
  V_L_Reboiler = M_L[1] * rho_L_Reboiler_inv;
  rho_L_Reboiler_inv = sum(x[1:NC, 1] ./ rho_L[1:NC]);
//-----------------------------------------------------------------------
////############################################################
//Search Tank hold up controller
  der(M_SurgeTank[1:NC]) = F_Lsd * x[1:NC, Nsd] - F_L_SurgeTank * x_SurgeTank[1:NC];
//-----------------------------------------------------------------------
////############################################################
//Search Tank hold up controller
  V_SurgeTankSP = Vcond;
  V_SurgeMin    = V_SurgeTankSP;
  SurgeTank_error = V_SurgeTankSP - V_SurgeTank;
////////////////
  der(ST_errorint) = 1 / 1000 * SurgeTank_error;
//  Lift_SurgeTank = mid(0, surge_bias - surge_gain * SurgeTank_error - surge_kI * ST_errorint,1);
  Lift_SurgeTank = mid(0, surge_bias - surge_gain * SurgeTank_error, 1);
//-----------------------------------------------------------------------
//Sahlodin: what does Vcond have to do with the surge tank flow rate?
  if V_SurgeTank <= V_SurgeMin then
////////////////
    F_L_SurgeTank = 0;
  else
//Below is a mix of weir and valve eq (makes no sense)
    F_L_SurgeTank = Lift_SurgeTank * k_l[Nsd] * ((V_SurgeTank - V_SurgeMin) / sqrt(abs(V_SurgeTank - V_SurgeMin) + 1e-6));
//    F_L_SurgeTank = Lift_SurgeTank * .005 * ((V_SurgeTank - V_SurgeMin) / sqrt(abs(V_SurgeTank - V_SurgeMin) + 1e-6));

//valve
  end if;
////////////////                      ////////////////
//-----------------------------------------------------------------------
  V_SurgeTank = M_L_SurgeTank * rho_L_SurgeTank_inv;
  rho_L_SurgeTank_inv = sum(x_SurgeTank[1:NC] ./ rho_L[1:NC]);
//-----------------------------------------------------------------------
  for i in 1:NC loop
    M_SurgeTank[i] = M_L_SurgeTank * x_SurgeTank[i];
  end for;
  sum(M_SurgeTank[1:NC]) = M_L_SurgeTank;
//TODO: eq below ignores dynamic energy balance for surge tank dH/dt=
  h_L_SurgeTank = sum(x_SurgeTank[1:NC] .* h_Lcmp[1:NC, Nsd]);
//-----------------------------------------------------------------------
  xside = x[2, Nsd];
  xD=x[1,N];
  xB=x[3,1];
  Pcond=P[N];
  xsurge = x_SurgeTank[2];
 if time <= steptime then
  z[1:NC] = {0.4, 0.2, 0.4};
  else
  z[1:NC] = {0.375, 0.25, 0.375};
  end if;
//-----------------------------------------------------------------------
initial equation
  //M_SurgeTank[1] = 0.0;
  //M_SurgeTank[2] = 0.08;
  //M_SurgeTank[3] = 0.0;
  x_SurgeTank[1]=0;
  x_SurgeTank[2]=1;
  V_SurgeTank = V_SurgeTankSP;
  
//  T[1] = 396.384;
//  T[2] = 380.56;
//  T[3] = 370.118;
//  T[4] = 365.405;
//  T[5] = 363.474;
//  T[6] = 362.599;
//  T[7] = 355.371;
//  T[8] = 353.032;
//  T[9] = 352.159;
//  T[10] = 351.681;
//  T[11] = 351.336;
//  T[12] = 351.046;
//  T[13] = 350.783;
//  T[14] = 350.532;
//  T[15] = 350.287;
//  T[16] = 350.044;
//  T[17] = 349.802;
//  T[18] = 349.56;
//  T[19] = 349.316;
//  T[20] = 349.072;
//  T[21] = 348.826;
//  T[22] = 348.579;
//  T[23] = 348.33;
//  T[24] = 348.079;
//  T[25] = 347.827;
//  T[26] = 347.574;
//  T[27] = 347.319;
//  T[28] = 347.062;
//  T[29] = 346.803;
//  T[30] = 346.543;
//  T[31] = 346.281;
//  T[32] = 346.017;
//  T[33] = 345.752;
//  T[34] = 345.484;
//  T[35] = 345.215;
//  T[36] = 344.944;
//  T[37] = 344.671;
//  T[38] = 344.396;
//  T[39] = 344.12;
//  T[40] = 351.91;
////-----------------------
//  M_L[1] = 0.16;
//  M_L[2] = 0.215225;
//  M_L[3] = 0.21994;
//  M_L[4] = 0.223501;
//  M_L[5] = 0.22499;
//  M_L[6] = 0.225468;
//  M_L[7] = 0.134075;
//  M_L[8] = 0.137595;
//  M_L[9] = 0.138614;
//  M_L[10] = 0.13891;
//  M_L[11] = 0.139013;
//  M_L[12] = 0.139051;
//  M_L[13] = 0.139062;
//  M_L[14] = 0.139059;
//  M_L[15] = 0.13905;
//  M_L[16] = 0.139037;
//  M_L[17] = 0.139022;
//  M_L[18] = 0.139006;
//  M_L[19] = 0.138989;
//  M_L[20] = 0.138972;
//  M_L[21] = 0.138955;
//  M_L[22] = 0.138938;
//  M_L[23] = 0.138921;
//  M_L[24] = 0.138903;
//  M_L[25] = 0.138886;
//  M_L[26] = 0.138868;
//  M_L[27] = 0.13885;
//  M_L[28] = 0.138832;
//  M_L[29] = 0.138814;
//  M_L[30] = 0.138796;
//  M_L[31] = 0.138778;
//  M_L[32] = 0.13876;
//  M_L[33] = 0.138741;
//  M_L[34] = 0.138723;
//  M_L[35] = 0.138704;
//  M_L[36] = 0.138685;
//  M_L[37] = 0.138666;
//  M_L[38] = 0.138647;
//  M_L[39] = 0.138628;
//  M_L[40] = 0.0454533;
////-----------------------
//  M_V[1] = 9.29228e-7;
//  M_V[2] = 9.89954e-7;
//  M_V[3] = 1.03732e-6;
//  M_V[4] = 1.05752e-6;
//  M_V[5] = 1.06406e-6;
//  M_V[6] = 9.11703e-7;
//  M_V[7] = 9.46912e-7;
//  M_V[8] = 9.5729e-7;
//  M_V[9] = 9.60325e-7;
//  M_V[10] = 9.61379e-7;
//  M_V[11] = 9.6177e-7;
//  M_V[12] = 9.61881e-7;
//  M_V[13] = 9.61854e-7;
//  M_V[14] = 9.61758e-7;
//  M_V[15] = 9.61624e-7;
//  M_V[16] = 9.61471e-7;
//  M_V[17] = 9.61308e-7;
//  M_V[18] = 9.61138e-7;
//  M_V[19] = 9.60965e-7;
//  M_V[20] = 9.6079e-7;
//  M_V[21] = 9.60613e-7;
//  M_V[22] = 9.60434e-7;
//  M_V[23] = 9.60255e-7;
//  M_V[24] = 9.60074e-7;
//  M_V[25] = 9.59893e-7;
//  M_V[26] = 9.59711e-7;
//  M_V[27] = 9.59527e-7;
//  M_V[28] = 9.59343e-7;
//  M_V[29] = 9.59157e-7;
//  M_V[30] = 9.58971e-7;
//  M_V[31] = 9.58783e-7;
//  M_V[32] = 9.58594e-7;
//  M_V[33] = 9.58404e-7;
//  M_V[34] = 9.58214e-7;
//  M_V[35] = 9.58022e-7;
//  M_V[36] = 9.57828e-7;
//  M_V[37] = 9.57634e-7;
//  M_V[38] = 9.57439e-7;
//  M_V[39] = 9.96269e-7;
//  M_V[40] = 0.000136266;
////-----------------------
//  P_errorint = 0;
//  ML_errorint = 0;
//  VL_errorint = 0;
//  D_errorint = 0;
//  B_errorint = 0;
////-----------------------
//  TotalDistProd = 0;
//  TotalSideProd = 0;
//  TotalBottomProd = 0;
//  TotalFeed = 0;
////-----------------------
//  TotalReboilerDuty = 0;
//  TotalCondenserDuty = 0;
////-----------------------
//  for i in 1:N loop
//    y[3, i] = 0;
//  end for;
/////////Initial Set II at 1e5 s////////////////////
//  T = {417.3572354, 416.4037081, 414.5919476, 411.1347229, 405.2686884, 397.5101928, 390.416488, 385.7841731, 383.4000252, 382.2592641, 381.6620261, 381.2789127, 380.9761933, 380.7025765, 380.4388103, 380.1777309, 379.91666, 379.6545948, 379.3911471, 379.1261479, 378.8594915, 378.591055, 378.3206133, 378.0476754, 377.7711088, 377.4882482, 377.1927724, 376.8696657, 376.483377, 375.9507349, 375.0831031, 373.4842174, 370.4665229, 365.3405229, 358.5330098, 352.1569978, 347.9372797, 345.7229398, 344.6305677, 344.0327048};
//  M_L = {1.956023676, 4.1524266, 4.144875932, 4.134330655, 4.129873415, 4.156100324, 4.188165735, 4.269944708, 4.325529346, 4.35244287, 4.362959928, 4.36624014, 4.366648592, 4.365962487, 4.372839822, 4.371573518, 4.37024461, 4.368888593, 4.367518341, 4.366138484, 4.364750555, 4.363354798, 4.361950626, 4.360536302, 4.359107658, 4.357654854, 4.356154665, 4.354552442, 4.352721485, 4.350379727, 4.346964662, 4.341694157, 4.335064654, 4.334616559, 4.359918568, 4.420254335, 4.48752551, 4.532334536, 4.553638133, 1.088246124};
//  M_V = {0.007081313, 0.007042595, 0.006988742, 0.006966084, 0.007100369, 0.007438348, 0.007879696, 0.008189463, 0.00834235, 0.008402634, 0.008421526, 0.008423918, 0.008420015, 0.008413742, 0.008406501, 0.008398907, 0.008391162, 0.008383339, 0.008375467, 0.008367553, 0.008359599, 0.008351603, 0.008343553, 0.008335427, 0.008327167, 0.008318643, 0.008309543, 0.008299145, 0.008285848, 0.008266462, 0.00823658, 0.008199085, 0.008196594, 0.008340489, 0.008690346, 0.00909181, 0.009365992, 0.009498285, 0.009548373, 0.002832105};
//  P_errorint = -90.6906563;
//  ML_errorint = -18.18973666;
//  VL_errorint = -16.40145555;
//  D_errorint = 0.792452022;
//  B_errorint = 0.247901532;
//  y[3, 1:N] = {0.97642469, 0.945415648, 0.878190177, 0.748046988, 0.545275704, 0.320267773, 0.153319515, 0.063893215, 0.024837341, 0.009370425, 0.003491913, 0.001294321, 0.000478399, 0.000176427, 6.49E-05, 2.38E-05, 8.74E-06, 3.20E-06, 1.17E-06, 4.29E-07, 1.57E-07, 5.72E-08, 2.09E-08, 7.59E-09, 2.76E-09, 1.00E-09, 3.64E-10, 1.31E-10, 4.73E-11, 1.69E-11, 5.89E-12, 1.96E-12, 5.94E-13, 1.51E-13, 3.01E-14, 4.72E-15, 6.30E-16, 7.76E-17, 9.20E-18, 1.07E-18};

/////////Initial Set III at 1e7 s////////////////////
//  T = {417.3571735, 416.4052661, 414.6003298, 411.1601632, 405.3148469, 397.531883, 390.4280562, 385.7555434, 383.3394816, 382.1821185, 381.5776384, 381.191615, 380.8877973, 380.61381, 380.349961, 380.0889162, 379.8279231, 379.5659515, 379.3026034, 379.0377056, 378.7711502, 378.5028117, 378.2324599, 377.9595936, 377.683058, 377.4001407, 377.1044226, 376.7806887, 376.3930004, 375.8574932, 374.9845223, 373.377227, 370.350953, 365.2277303, 358.4474882, 352.1120124, 347.9209002, 345.7185536, 344.6296031, 344.0323563};
//  M_L={1.965297181,	3.007583937,	3.002116389,	2.994448662,	2.990955581,	3.009090313,	3.014030915,	3.073112079,	3.113639156,	3.133396789,	3.141164412,	3.143613702,	3.143946483,	3.143471048,	3.152089419,	3.151180031,	3.150224588,	3.149249196,	3.148263409,	3.147270666,	3.146272107,	3.145267917,	3.144257673,	3.14324011,	3.1422122,	3.141166807,	3.140087125,	3.138933708,	3.137615371,	3.135929929,	3.13347697,	3.129710892,	3.125039013,	3.124961666,	3.143495013,	3.187035234,	3.235332903,	3.267466891,	3.282759899,	0.786996171};
//  M_V={0.002673987,	0.002659335,	0.002638869,	0.002629592,	0.002678123,	0.002796202,	0.002962013,	0.003079482,	0.003137875,	0.003161048,	0.003168395,	0.003169416,	0.003168018,	0.003165707,	0.003163009,  0.003160174,	0.003157282,	0.00315436,	0.003151419,	0.003148463,	0.003145492,	0.003142505,	0.003139497,	0.003136461,	0.003133375,	0.003130189,	0.003126786,	0.003122896,	0.003117921,	0.003110679,	0.003099569,	0.003085818,	0.003085614,	0.003140523,	0.003272046,	0.003422185,	0.003524593,	0.003574055,	0.003592829,	0.003539308};
//    y[3,1:N]={0.976423077,	0.945490071,	0.878572886,	0.74916065,	0.547292641,	0.322374165,	0.155093773,	0.064862337,	0.025274975,	0.009552798,	0.003565315,	0.001323334,	0.000489698,	0.000180731,	6.64E-05,	2.44E-05,	8.95E-06,	3.28E-06,	1.20E-06,	4.39E-07,	1.60E-07,	5.84E-08,	2.13E-08,	7.75E-09,	2.82E-09,	1.02E-09,	3.71E-10,	1.34E-10,	4.82E-11,	1.72E-11,	5.99E-12,	1.99E-12,	6.03E-13,	1.53E-13,	3.05E-14,	4.78E-15,	6.40E-16,	7.89E-17,	9.38E-18,	1.09E-18};
//  P_errorint = -55.14282603;
//  ML_errorint = -11.08010171;
//  VL_errorint = -0.330917523;
//  D_errorint = 0.787806898;
//  B_errorint = 0.247916879;
//  ST_errorint  = 0;
//-----------------------------------------------------------------------

//Initial Set IV: corrected side draw flow rate
 T={417.3572603,	416.4031448,	414.588894,	411.1254204,	405.2517404,	397.5020117,	390.407394,	385.7900109,	383.4192269,	382.2858305,	381.6919441,	381.3102296,	381.0080616,	380.7346449,	380.4709366, 380.2098551,	379.94876,	379.6866624,	379.4231794,	379.1581438,	378.8914511,	378.6229793,	378.352505,	378.079541,	377.8029626,	377.5201206,	377.2247285,	376.9018397,	376.5160376,	375.9843891,	375.1185987,	373.5225794,	370.5076989,	365.3803698,	358.5628841,	352.1724509,	347.9427456,	345.7243186,	344.6308328,	344.0327839};

  M_L={1.858227483,	5.145618051,	5.136260145,	5.123210552,	5.117852175,	5.150891513,	5.204338758,	5.30584809,	5.374553947,	5.407707412,	5.420621183,	5.424625428,	5.425100202,	5.424231427,	5.428611715,	5.427035996,	5.425384511,	5.423699732,	5.421997402,	5.420283183,	5.418558946,	5.416824984,	5.415080569,	5.41332355,	5.411548767,	5.409744032,	5.407880544,	5.405890487,	5.403616461,	5.400707552,	5.396462249,	5.389898331,	5.381602022,	5.380896022,	5.412130952,	5.487010984,	5.570644927,	5.626372514,	5.652856273,	1.34911389};

  M_V={0.013507086,	0.013433291,	0.013330811,	0.013288915,	0.013549053,	0.014214661,	0.015058941,	0.015648998,	0.015939197,	0.016053239,	0.016088757,	0.016093031,	0.0160854,	0.01607329,	0.016059406, 0.016044855,	0.016030018,	0.016015035,	0.015999957,	0.0159848,	0.015969567,	0.015954251,	0.015938834,	0.01592327,	0.015907453,	0.01589113,	0.015873706,	0.015853802,	0.015828347,	0.015791217,	0.015733886,	0.015661606,	0.015655525,	0.015929056,	0.016597646,	0.017366234,	0.017891352,	0.018144616,	0.018240414,	0.002219708};

    y[3,1:N]={0.976425393,	0.94538876,	0.878050906,	0.747640545,	0.544538331,	0.319495517,	0.152569168,	0.063455977,	0.024630821,	0.009281234,	0.00345494,	0.001279344,	0.000472449,	0.000174128,	6.40E-05,	2.35E-05,	8.63E-06,	3.16E-06,	1.16E-06,	4.24E-07,	1.55E-07,	5.65E-08,	2.06E-08,	7.50E-09,	2.73E-09,	9.91E-10,	3.59E-10,	1.30E-10,	4.68E-11,	1.67E-11,	5.82E-12,	1.94E-12,	5.88E-13,	1.50E-13,	2.98E-14,	4.67E-15,	6.24E-16,	7.67E-17,	9.09E-18,	1.06E-18};

  P_errorint = -125.8281601;
  ML_errorint = -25.2177655;
  VL_errorint = -1.2;//-2.153482179;
  D_errorint = 0.794105529;
  B_errorint = 0.247581245;
  ST_errorint  = 0;
//F_in|Pcond|xD|xB|xside|Qc|Qr|Side_ProdFlow|Lsd|rr|V_L_Reboiler|VLReb_SP|V_SurgeTank|xsurge|F_L_SurgeTank|Lift_SurgeTank
  annotation(
    __OpenModelica_simulationFlags(lv = "LOG_DASSL,LOG_STATS", s = "dassl"),
    experiment(StartTime = 0, StopTime = 1e6, Tolerance = 1e-06, Interval = 200));
end SCD_surgev6_rebL1;
