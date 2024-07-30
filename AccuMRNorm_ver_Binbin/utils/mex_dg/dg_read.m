%DG_READ - MEX utility to read the event (.dgz) file.
%  DG = DG_READ(DGZFILE) will return recorded events in the dgzfile.
%
%  ESSxxx, the our task control program running on QNX will record events
%  as .evt and it is compiled and zipped as .dgz after the experiment.
%  DG_READ read such .dgz and returns event data as a structure like following.
%
%  dg = dg_read('//Win49/N/DataNeuro/A98.nm5/a98nm5_001.dgz');
%  dg = 
%            e_pre: {33x1 cell}
%          e_names: [256x22 char]
%          e_types: {[1062x1 double]}
%       e_subtypes: {[1062x1 double]}
%          e_times: {[1062x1 double]}
%         e_params: {{1062x1 cell}}
%              ems: {{3x1 cell}}
%        spk_types: {[0x1 double]}
%     spk_channels: {[0x1 double]}
%        spk_times: {[0x1 double]}
%        obs_times: 0
%         filename: '//Win49/N/DataNeuro/A98.nm5/a98nm5_001.dgz'
%
%
%  TASK PARAMETERS :
%  .e_pre has control paramters set in ESSGUI.
%
%  EVENT NAMES :
%  .e_names are 256 event names.  .e_types has recorded event numbers.
%  Note that event number starts from 0 to 255 and need to add +1 for matlab
%  indexing to get event name as string.
%  For an example, event 19 is deblank(dg.e_names(19+1,:)) = 'Start Obs Period'.
%
%  EVENT TYPES, SUBTYPES, PARAMETERS AND TIMINGS
%  .e_types/e_subtypes/e_times/e_params/ems/spk_... are cell arrays of data for each
%  observation periods. Combination of e_types/e_subtypes/e_times/e_params tells what kind
%  of events(subtype, event parameter) is recorded at which timing (e_times) in mseconds.
%  For an example, in the first observation period and the first recored event, 
%    dg.e_types{1}(1)    = 19;     % event type as 'Start Obs Period'      
%    dg.e_subtypes{1}(1) = 0;      % subtype as 0
%    dg.e_params{1}{1}   = [0 1];  % event parameters, 
%    dg_e_times{1}{1}    = 0;      % relative timing in the obsp as 0 msec
%  Note that meaning of e_params is dependent on the C code of ess system, and may differ
%  from program to program.
%
%
%  See also ADF_INFO, ADF_READ