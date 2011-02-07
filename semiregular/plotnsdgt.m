function [] = plotnsdgt(c,a,varargin)
%PLOTNSDGT Plot spectrogram from nonstationary Gabor coefficients
%   Usage:  plotnsdgt(c,a,dynrange,sr);
%
%   Input parameters:
%         c        : Cell array of coefficients.
%         a        : Vector of time positions of windows.
%         dynrange : Colorscale dynamic range in dB (default 60 dB).
%         sr       : signal sample rate in Hz (default 1 Hz).
%
%   PLOTNSDGT(c,a) plots the spectrogram from coefficients computed with the
%   functions NSDGT or NSDGTREAL. For more details on the format of the
%   variables c and _a, please read the NSDGT function help.
%
%   The function takes the following arguments at the end of the command line:
%
%     'fs'         - Assume a sampling rate of fs Hz.
%
%-    'real'       - Assume coefficients from NSDGTREAL. This is the default.
%
%-    'complex'    - Assume coefficients from NSDGT.
%
%-    'image'      - Use 'imagesc' to display the spectrogram. This is the
%                    default.
%
%-    'clim',[clow,chigh] - Use a colormap ranging from clow to chigh. These
%                    values are passed to IMAGESC. See the help on IMAGESC.
%
%-    'dynrange',r - Use a colormap in the interval [chigh-r,chigh], where
%                    chigh is the highest value in the plot.
%
%-    'xres',xres  - Approximate number of pixels along x-axis / time.
%
%-    'yres',yres  - Approximate number of pixels along y-axis / frequency
%
%-    'contour'    - Do a contour plot to display the spectrogram.
%          
%-    'surf'       - Do a surf plot to display the spectrogram.
%
%-    'mesh'       - Do a mesh plot to display the spectrogram.
%
%-    'colorbar'   - Display the colorbar. This is the default.
%
%-    'nocolorbar' - Do not display the colorbar.
%
%   See also: nsdgt, nsdgtreal

%   AUTHOR : Florent Jaillet & Peter L. Soendergaard
%   TESTING: OK 
%   REFERENCE: NA

timepos=cumsum(a)-a(1);

% Define initial value for flags and key/value pairs.
definput.flags.plottype={'image','contour','mesh','pcolor'};
definput.flags.transformtype={'real','complex'};

definput.flags.clim={'noclim','clim'};
definput.flags.colorbar={'colorbar','nocolorbar'};

definput.keyvals.clim=[0,1];
definput.keyvals.dynrange=[];
definput.keyvals.xres=800;
definput.keyvals.yres=600;
definput.keyvals.fs=[];

[flags,kv,fs]=ltfatarghelper({'fs','dynrange'},definput,varargin);

cwork=zeros(kv.yres,length(a));

%% -------- Interpolate in frequency ---------------------

for ii=1:length(a)
  column=20*log10(abs(c{ii}+realmin));
  M=length(column);
  cwork(:,ii)=interp1(linspace(0,1,M),column,linspace(0,1,kv.yres),'nearest');
end;

%% --------  Interpolate in time -------------------------
% this is non-equidistant, so we use a cubic spline

if isempty(fs)
  fs=1;
end;

% Time positions (in Hz) of our samples.
timepos = (cumsum(a)-a(1))/fs;

% Time positions where we want our pixels plotted.
xr=((0:kv.xres-1)/kv.xres*timepos(end)).';

coef=zeros(kv.yres,kv.xres);
for ii=1:kv.yres
  data=interp1(timepos,cwork(ii,:).',xr,'nearest').';
  coef(ii,:)=data;
end;

% 'dynrange' parameter is handled by thresholding the coefficients.
if ~isempty(kv.dynrange)
  maxclim=max(coef(:));
  coef(coef<maxclim-kv.dynrange)=maxclim-kv.dynrange;
end;

xr=linspace(0,timepos(end),kv.xres);
yr=linspace(0,fs/2,kv.yres);
  
switch(flags.plottype)
  case 'image'
    if flags.do_clim
      imagesc(xr,yr,coef,kv.clim);
    else
     imagesc(xr,yr,coef);
    end;
  case 'contour'
    contour(xr,yr,coef);
  case 'surf'
    surf(xr,yr,coef);
  case 'pcolor'
    pcolor(xr,yr,coef);
end;

if flags.do_colorbar
  colorbar;
end;

axis('xy');
xlabel('Time (s)')
ylabel('Frequency (Hz)')

