%assume short 1000 calls at 60
n = 1000;
asset_price = [56.8,58];
% two other call options A,B
[fairValue_A, greeks_A] = calcGreeks(56.8, 65, 5, 2.5, 35, 120/365, 'call', 365);
[fairValue_B, greeks_B] = calcGreeks(56.8, 70, 5, 2.5, 35, 120/365, 'call', 365);
delta_A = greeks_A.delta;
gamma_A = greeks_A.gamma;
vega_A = greeks_A.vega;
delta_B = greeks_B.delta;
gamma_B = greeks_B.gamma;
vega_B = greeks_B.vega;
W = zeros(3,length(asset_price));
for i = 1:length(asset_price)
    [fairValue ,greeks] = calcGreeks(asset_price(i), 60, 5, 2.5, 35, 120/365, 'call', 365);
    delta = greeks.delta*(-n);
    gamma = greeks.gamma*(-n);
    vega = greeks.vega*(-n);
    greeks_AB = [gamma_A gamma_B;vega_A vega_B];
    greeks_portfolio = [greeks.gamma*n;greeks.vega*n];
    w = greeks_AB\greeks_portfolio;
    greeks_AB_d = [delta_A delta_B;gamma_A gamma_B;vega_A vega_B];
    greeks_portfolio_d = [delta;gamma;vega];
    w_n = greeks_AB_d*w + greeks_portfolio_d;
    W(:,i) = w_n;
end









function [fairValue, greeks] = calcGreeks(spot, strike, rate, yield, volatility, maturity, putCallInd, annualFactor)
% calcGreeks - Calculate Greeks (Black/Scholes, Vanilla European Option, Closed Form)
%
% calcGreeks computes and reports the fair price value and numerous Greek values
% for vanilla European options, using the Black-Sholes-Merton model, optimized
% for performance. No toolbox is required - only basic Matlab.
%
% Any input parameter can be vectorized (examples below), but only one parameter
% can be vectorized.
%
% calcGreeks is used by the IQFeed-Matlab connector (IQML - https://undocumentedmatlab.com/IQML)
%
% Syntax:
%    [fairValue, greeks] = calcGreeks(spot, strike, rate, yield, volatility, maturity, putCallInd, annualFactor)
%
% Inputs:
%    spot         - (mandatory) Underlying asset's spot price
%    strike       - (mandatory) Derivative contract's strike price
%    rate         - (default: 0) Domestic risk-free interest rate (%)
%    yield        - (default: 0) Foreign interest rate (Forex) or dividend yield (stock)
%    volatility   - (default: 0.3) Historic volatility of the underlying asset's price
%    maturity     - (default: 1.0) Number of years until derivative contract expires
%    putCallInd   - (default: 'Call') Either 1 (Call), -1 (Put), or [1,-1] (both)
%                   or as strings: "Call", 'put', 'cp', {'Call',"put"} etc.
%    annualFactor - (default: 1) Used to de-annualize Theta, Charm, Veta, Color
%                   1: report annualized values; 365: report 1-day estimates
%                   Typical values: 1, 365, 252
%
% Usage examples:
%
%    % Example 1: vectorized call/put
%    >> [fairValue, greeks] = calcGreeks(56.8, 60, 5, 2.5, 35, 15/365, {'call',"put"}, 365)
%    fairValue =
%         0.5348    3.6700
%    greeks = 
%       struct with fields:
%          delta: [0.2347  -0.7642]
%           vega: 3.5347
%          theta: [-0.0421 -0.0378]
%            rho: [0.5260  -1.9347]
%           crho: [0.5480  -1.7839]
%          omega: [24.9311 -11.8278]
%         lambda: [24.9311 -11.8278]
%          gamma: 0.0762
%          vanna: 0.6959
%          charm: [-0.0025 -0.0275]
%          vomma: 5.7897
%          volga: 5.7897
%           veta: 0.1876
%          speed: 0.0123
%          zomma: -0.0929
%          color: -0.0010
%         ultima: -40.2881
%
%    % Example 2: vectorized strike prices
%    >> [fairValue, greeks] = calcGreeks(56.8, 45:5:65, 5, 2.5, 35, 15/365, 'c', 365)
%    fairValue =
%        11.8345    6.8966    2.6769    0.5348    0.0493
%    greeks = 
%       struct with fields:
%          delta: [0.9985 0.9666 0.6921 0.2347 0.0321]
%           vega: [0.0178 0.8334 4.0419 3.5347 0.8280]
%          theta: [-0.0025 -0.0125 -0.0495 -0.0421 -0.0098]
%            rho: [1.8445 1.9730 1.5055 0.5260 0.0729]
%           crho: [2.3308 2.2564 1.6155 0.5480 0.0749]
%          omega: [4.7925 7.9612 14.6854 24.9311 36.9547]
%         lambda: [4.7925 7.9612 14.6854 24.9311 36.9547]
%          gamma: [3.8391e-04 0.0180 0.0871 0.0762 0.0178]
%          vanna: [-0.0144 -0.3673 -0.4341 0.6959 0.3948]
%          charm: [0.0251 0.0284 0.0220 -0.0025 -0.0039]
%          vomma: [0.5531 7.8117 2.5186 5.7897 8.4126]
%          volga: [0.5531 7.8117 2.5186 5.7897 8.4126]
%           veta: [0.0070 0.1174 0.1619 0.1876 0.1272]
%          speed: [-3.2418e-04 -0.0085 -0.0124 0.0123 0.0079]
%          zomma: [0.0108 0.1170 -0.1946 -0.0929 0.1303]
%          color: [1.2500e-04 0.0013 -0.0023 -0.0010 0.0016]
%         ultima: [12.4303 6.2331 -20.1849 -40.2881 13.3330]
%
% Bugs and suggestions:
%    Please send to Yair Altman (altmany at gmail dot com)
%
% Technical description:
%    https://en.wikipedia.org/wiki/Greeks_(finance)#Delta
%
% Release history:
%    1.0  2018-11-28: initial version
%    1.1  2018-11-28: retrying to upload as a toolbox...
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.
% Programmed and Copyright by Yair M. Altman: altmany(at)gmail.com
    %{
    See also:
     - http://option-price.com
     - https://en.wikipedia.org/wiki/Greeks_(finance)
     - http://www.walkingrandomly.com/?p=4416
     - https://www.nag.co.uk/numeric/MB/manual64_24_1/pdf/S/s30ab.pdf
     - https://www.nag.co.uk/numeric/MB/manual64_25_1/pdf/S/s30ab.pdf
     - https://www.nag.co.uk/content/using-nag-toolbox-matlab-part-5
     - https://www.maplesoft.com/support/help/Maple/view.aspx?path=Finance/BlackScholesGamma (etc.)
     - https://www.mathworks.com/matlabcentral/fileexchange/10428-plotmethegreeks
     - https://www.mathworks.com/matlabcentral/fileexchange/44258-vanilla-option-price-black-scholes-close-form
     - https://www.mathworks.com/matlabcentral/fileexchange/44289-vanilla-option-greeks-black-scholes-close-form
    %}
    % Assign default values to optional input args
    if nargin < 8, annualFactor = 1;  end  % compatibility with Matlab's Financial Toolbox, NAG, Maple
    if nargin < 7, putCallInd   = 1;  end  % default: Call
    if nargin < 6, maturity     = 1;  end  % default: 1 year
    if nargin < 5, volatility   = 30; end  % default: 30%
    if nargin < 4, yield        = 0;  end  % default: 0%
    if nargin < 3, rate         = 0;  end  % default: 0%
    if nargin < 2, error('At least one spot price and one strike price must be specified!'); end
    % Normalize % values to fractions:
    rate  = rate/100;
    yield = yield/100;
    volatility = volatility/100;
    % Normalize putCallInd that can be specified in many different formats
    try %#ok if isa(putCallInd,'string')
        putCallInd = controllib.internal.util.hString2Char(putCallInd);
    end
    if iscellstr(putCallInd)
        putCallInd = cellfun(@(c)c(1),putCallInd);
    end
    if ischar(putCallInd)
        putCallInd = unique(lower(regexprep(putCallInd,'[^PpCc]','')),'stable');
        pcVal = [];
        for idx = 1 : length(putCallInd)
            if putCallInd(idx)=='c'
                pcVal(end+1) = +1; %#ok<AGROW>
            elseif putCallInd(idx)=='p'
                pcVal(end+1) = -1; %#ok<AGROW>
            end
        end
        if isempty(pcVal), error('Either put or call or both must be specified!'); end
        putCallInd = pcVal;
    elseif iscell(putCallInd)
        putCallInd = [putCallInd{:}];
    end
    % Calculate basic mathematical values that are used below
    r = rate;
    q = yield;
    b = r-q;  % Carry rate: https://www.nag.co.uk/numeric/MB/manual64_25_1/pdf/S/s30ab.pdf
    sqrt_maturity = sqrt(maturity);
    f = volatility .* sqrt_maturity;
    sqr_sigma = volatility .* volatility;
    sqr_sigma_2 = 0.5 * sqr_sigma;
    d1 = (log(spot./strike) + (b + sqr_sigma_2) .* maturity) ./ f;
    d2 = d1 - f; %=(log(spot/strike) + (r-q-sqr_sigma_2) * maturity) / f;
    eqm = exp(-q .* maturity);
    erm = exp(-r .* maturity);
    npd1 = 1/sqrt(2*pi) * exp(-d1.^2/2); %=normpdf(d1);
    epd1 = eqm .* npd1;
    sepd1 = spot .* epd1;
    sqrt2 = sqrt(2);
    ncd1 = 0.5*erfc(-putCallInd.*d1/sqrt2); %=0.5*erf(putCallInd*d1/sqrt2)+0.5; %=normcdf(putCallInd*d1);
    ncd2 = 0.5*erfc(-putCallInd.*d2/sqrt2); %=0.5*erf(putCallInd*d2/sqrt2)+0.5; %=normcdf(putCallInd*d2);
    ecd1 = eqm .* ncd1;
    ecd2 = erm .* ncd2;
    secd1 = spot   .* ecd1;
    secd2 = strike .* ecd2;
    % Compute and report the fair value (bail-out immediately if greeks are not requested)
    fairValue = putCallInd .* (secd1 - secd2);
    if nargout < 2,  return,  end
    % 1st-order Greeks
    greeks.delta = putCallInd .* ecd1;
    greeks.vega  = sepd1 .* sqrt_maturity; %*0.01
    greeks.theta = (-sepd1 .* sqr_sigma_2 ./ f + putCallInd.*(q.*secd1 - r.*secd2)) / annualFactor;
    greeks.rho   = putCallInd .* maturity .* secd2; %*0.01
    greeks.crho  = greeks.rho .* secd1 ./ secd2;  %https://www.nag.co.uk/numeric/MB/manual64_25_1/pdf/S/s30ab.pdf
    greeks.omega = greeks.delta .* spot ./ fairValue;
    greeks.lambda = greeks.omega; %synonym
    % 2nd-order Greeks
    d12 = d1 .* d2;
    greeks.gamma = epd1 ./ spot ./ f;
    greeks.vanna = -epd1 .* d2 ./ volatility;  % =vega/spot*(1-d1/f);
    greeks.charm = q .* greeks.delta - epd1 .* (b./f - 0.5*d2./maturity) / annualFactor;
    greeks.vomma = sepd1 .* f .* d12 / sqr_sigma;  % AKA volga, vega convexity
    greeks.volga = greeks.vomma; %synonym
    greeks.veta  = -sepd1 .* sqrt_maturity .* (q + b.*d1./f - 0.5*(1+d12)./maturity) / annualFactor; %*0.01
    % 3rd-order Greeks
    greeks.speed  = -greeks.gamma ./ spot .* (d1./f + 1);
    greeks.zomma  =  greeks.gamma .* (d12-1) ./ volatility;
    greeks.color  = -greeks.gamma .* (q + 1./(2*maturity) + (b./f - d2./(2*maturity)).*d1) / annualFactor;
    greeks.ultima = -greeks.vega ./ sqr_sigma .* (d12.*(1-d12) + d1.*d1 + d2.*d2);
end



