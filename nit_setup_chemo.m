 function nit = nit_setup_chemo(nit,varargin)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization of experiment setup
% Versions: 0.1 : D. Bianchi, August 2020
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add documentation here:
% Simulates a chemostat culture with initial nutrients concentrations and constant flow
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 %--------------------------------------------------------------------------------
 % First define all CONSTANT parameters
 %--------------------------------------------------------------------------------

 %-------------------------------
 % General setup
 SetUp.StartTime = 0;		% Duration of chemostat culture (days)
 SetUp.EndTime = 3.0*365;	% Duration of chemostat culture (days)
 SetUp.dt = 1/24/2;		% timestep (days)

 %-------------------------------
 % Chemostat setup
 SetUp.Vol = 1;			% Volume of the culture (m3)
 SetUp.Flow = 1 * 0.05;		% Flow rate in the chemostat (m3/d)
 % NOTE: set Flow = 0 to recover "batch" behavior (i.e. initial condition run)

 %-------------------------------
 % Define the type and properties of light forcing
 SetUp.iTemp = 1;      % Case (1) : constant temperature
                       % Case (2) : variable temperature (to be implemented if needed)
 SetUp.TempRef = 10;   % Temperature of the chemostat culture

 %--------------------------------------------------------------------------------
 % Here performs any substitution of default parameters based on user input (varargin)
 SetUp = parse_pv_pairs(SetUp,varargin);
 %--------------------------------------------------------------------------------

 %--------------------------------------------------------------------------------
 % Second, define/process derived variables
 %--------------------------------------------------------------------------------

 % Environmental conditions
 % add here any environmental conditions, use the time vector for time dependent
 % variables (e.g. light, or temperature)
 SetUp.evarnames = {'Temp'};
 SetUp.nevar = length(SetUp.evarnames);

 % Time vector
 SetUp.time = [SetUp.StartTime:SetUp.dt:SetUp.EndTime];
 SetUp.ntime = length(SetUp.time);

 %--------------------------------------------------------------------------------
 % Set temperature conditions
 switch SetUp.iTemp
 case 1
    % Case (1) : constant temperature
    % Vector of light values (defined in each time step):
    SetUp.Env.Temp = SetUp.TempRef * ones(1,SetUp.ntime);
 otherwise
    error(['Error Temperature Off!']);
 end

 nit.SetUp = SetUp;

