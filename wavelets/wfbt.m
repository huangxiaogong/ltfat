function c=wfbt(f,wt,varargin)
%WFBT   Wavelet FilterBank Tree
%   Usage:  c=wfbt(f,wt);
%           c=wfbt(f,wt,...);
%
%   Input parameters:
%         f   : Input data.
%         wt  : Wavelet Filterbank tree
%
%   Output parameters:
%         c   : Coefficients stored in a cell-array.
%
%   `c=wfbt(f,wt)` returns coefficients *c* obtained applying wavelet filterbank tree
%   defined by *wt* to the input data *f*. If *f* is a matrix, the transformation 
%   is applied to each of *W* columns. The *wt* parameter can be structure
%   obtained from the |wfbtinit|_ function and modified arbitrarily or it
%   can be cell-array, which is used as a parameter in the internal call of
%   the |wfbtinit|_ function.
%
%   The following flag groups are supported:
%
%         'per','zero','odd','even'
%                Type of the boundary handling.
%
%         'dwt','full'
%                Type of the tree to be used.
%
%         'freq','nat'
%                Frequency or natural order of the coefficient subbands.
%
%   Please see the help on |fwt|_ for a description of the flags.
%
%   Examples:
%   ---------
%   
%   A simple example of calling the |wfbt|_ function using the "full decomposition" wavelet tree:::
% 
%     f = gspi;
%     J = 7;
%     c = wfbt(f,{{'db',10},J},'full');
%     plotfwt(c,44100,90);
%
%   See also: iwfbt, wfbtinit
%


if(nargin<2)
   error('%s: Too few input parameters.',upper(mfilename));  
end

definput.import = {'fwt','wfbtcommon'};
definput.keyvals.dim = [];
[flags,kv,dim]=ltfatarghelper({'dim'},definput,varargin);

% Initialize the wavelet tree structure
wt = wfbtinit(wt,flags.treetype,flags.forder,'ana');
    
%% ----- step 1 : Verify f and determine its length -------
[f,~,Ls,~,dim]=assert_sigreshape_pre(f,[],dim,upper(mfilename));

% Determine next legal input data length.
L = wfbtlength(Ls,wt,flags.ext);

% Pad with zeros if the safe length L differ from the Ls.
if(Ls~=L)
   f=postpad(f,L); 
end


%% ----- step 3 : Run computation
treePath = nodesBForder(wt);
rangeLoc = rangeInLocalOutputs(treePath,wt);
rangeOut = rangeInOutputs(treePath,wt); % very slow
c = comp_wfbt(f,wt.nodes(treePath),rangeLoc,rangeOut,flags.ext);

