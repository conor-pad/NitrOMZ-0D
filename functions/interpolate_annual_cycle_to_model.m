function var_model = interpolate_annual_cycle_to_model(time0,var0,time_model,int_mode);
% ----------------------------------------------------------------------------------------
% Interpolates annual cycle (in day) of a variable, to mode tinestep (converted to hours)
% Input:
% time0 : time vector of the annual cycle to interpolate. Values in days, between [0,365]
% var0 : variable to interpolate, defined on time0
% time_model : time vector of the model, any arbitrary length, including multiple years (hours)
% Output:
% var_model : variable interpolated on time vector of the model
% ----------------------------------------------------------------------------------------

 %--------------
 % NOTE: same interpolation approach can be used for variables read in from files
 %       as long as 1 year of data is provided
 %--------------
 % Interpolates the idealized annual cycle "var0" onto model time vector
 % repeating annual cycle multiple times if needed, and converting time0 to hours.
 % Note, here it is assumed that (model) time=0 correspond to January 1st at 00:00

 % If needed, deals with multiple annual cycle, if EndTime > 1year
 % Finds number of years from model time vector:
 nyears = ceil(time_model(end)/24/365);

 % Number of time-steps in var0 original time-series
 ntstep0 = length(var0);
 % First, repeats var0 if multiple years are specified by model final timestep
 var0_ny = repmat(var0,[1 nyears]);
 % New time vector, includes multiple years (assume year length=365 d)
 time0_ny = nan(size(var0_ny));
 % Fills in new time vector with original days plus 365 days for each additional year
 for indy=1:nyears
    indy0 = (indy-1)*ntstep0 + 1;
    indy1 = indy*ntstep0;
    time0_ny(indy0:indy1) = (indy-1)*365 + time0;
 end
 % Pads time0 and var0 with last (e.g. December) value, before first (i.e. January) value 
 % to allow interpolation for the first time-steps of the model
 time0_ny = [time0(end)-365,time0_ny];
 var0_ny = [var0(end) var0_ny];

 % Initializes PAR to NaNs
 var_model = nan(size(time_model)); 
 % Perform the interpolation of the provided annual cycle onto model timesteps
 % Converts time0  from days to hours 
 var_model= interp1(time0_ny*24,var0_ny,time_model,int_mode);



