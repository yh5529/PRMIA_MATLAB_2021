# PRMIA MATLAB Challenge 2021
PRMIA risk management challenge is an award-winning international student competition. The Risk Management Challenge, a case competition of the PRMIA Institute, empowers undergraduate and graduate students by taking them beyond the classroom and giving them exposure to real-world business situations. The Challenge offers students the opportunity to apply the concepts they have learned and showcase their knowledge, critical thinking skills, leadership, and presentation abilities while competing to win a US$10,000 cash award.
## MATLAB Challenge Question
In this challenge, we need to create a working dashboard and summary report derived from the National Australia Bank case. Your team is responsible for reporting both the risk and performance of an options market making desk. In this role your team should be able to:

1.  Define a portfolio of financial instruments to simulate the NAB case
    
2.  Identify the appropriate performance and risk metrics to monitor
    
3.  Create an interactive dashboard with key parameters and visuals
    
4.  (Optional) Define an automated hedging strategy to manage risk exposure
    
5.  (Optional) Generate a custom report based upon parameters selected from the dashboard

## Dashboard Manual
### File
1. position.csv
Including initial position of portfolio, ask/bid price, strike price, current P&L, Greeks and implied volatility.
2. Currency.csv
Including currency rate information related to initial portfolio.
3. currency_implied.csv
Including implied volatility of currency rate.
4. matrix.csv
Including risk metrics data used in risk analysis
5. hHistoricalVaRES.m
MATLAB function to calcualte value at risk using historical simulation method
6. BSMOption.m
MATLAB function to calculate Delta and option price using Black-Scholes model. It's used in delta hedging stratgy. 
7. portfolio folder
Including three demo portfolios
8. PRMIA_dashboard.mlapp
MATLAB app design code of dashboard
9. TeamAthena.mlx
MATLAB livescript documenting approaches used to develop metrics and visuals
### Instruction
#### Performance Analysis - Position
The dashboard will automatically read data from position file and dispaly data in positions window. 

-   The market data should come from exchange market API and **update tickly** for traders to monitor.
    
-   The start of the day, total buy, total sell, and net positions are included in the dashboard.
    
-   Profit and loss are **colored** with regard to the numerical sign.
    
- **Greeks** are calculated according to the Black-Scholes formula.
**![](https://lh3.googleusercontent.com/k5y6M7IKk68IZJLn0D52wbi_sa0EbfEQzGZMkEUoT2iDF_4Fp6Wd9E3MAlxMRDubgyH1YoLBpCne6IHKGLDFY5kWsehCMwVUd5sucPS0eoRm1EpWYnYbrX-uToWdGIa8)**
#### Performance Analysis - Performance
The performance panel is used for analyzing current performance based on uploaded portfolio. If there is no portfolio uploaded, it is still able to plot history curency movement and implied volitility of currency rate but will receive an error for P&L ploting. 
-   The performance panel supports period selection, statistics and capital calculations, simulation checkbox (**reinvest, transaction cost**), and multiple portfolio performance comparison.
-  Plots of currency price and volatility will change as the  shift of time period. Transaction cost and reinvest options can be applied separately and every new combination will plot a new P&L curve. 
   
- Quantitative researchers can run simulations by **loading their portfolios** to justify their strategies for future use.
**![](https://lh6.googleusercontent.com/zBvYen1A80GLWQNYY0QzH8FdMMKNwGIhUEz-I0dNJPjhWExJvDXLbAIrTSCbMW63qCU_EW763ELMpyZonKj1mhtQOjPuYg5jk5pJPSrdTCagnOlqXDOthWyxaoBEF2XP)**
#### Risk Analysis - VaR and ESbacktesting
This panel will calcualte VaR and process ES backtesting based on uploaded portfolio. It also supports time period selection and custom VaR level. The first window shows comparison of hitorical VaR, ES and portfolio return. The second window shows compatison between VaR calculated by different methods (**Normal**, **Historical simulation** and **EWMA**).


-   VaR and ES are defined as losses, thus positive, which outline the left tail distribution of the return.
    
- When the daily return breaks any of the risk metrics, the lamp will turn red for **alarm**! Green means safe and red  means dangerous.
**![](https://lh5.googleusercontent.com/M4eMIbr0e0tKrMdQt2c40wPCoIrC-Un8fVKiCwLz0rxZQ1dGZZ0hvT_vy8vADGbeMsnlDwMX0Q4ht451-Eyk2CiT4CDWrNNQRLEuZKQSbzfcKp6fkIhtVNAvks1czbQ_)**
**![](https://lh5.googleusercontent.com/74smJjoi1lg-ziTZ3N2NiJ_eboOjlRvl46CEAGr0XTs9lhWxkVJdT1pKirMWOnTF_nNaWNRgUvifxxAv60rFGYorQbC6VJnQ3FZ9dapDyDKQR2xe1Uy54RgE29b8rxkP)**

#### Risk Analysis - Risk Matrix
The risk matrix panel will provide custom options for risk metrics with different underlying price.
-   The quantitative trader will be able to monitor changes in the risk metrics and their portfolio value under stressed conditions.
-   The greeks presented should be the trader’s portfolio compound greeks which reflects the true exposure to the underlying asset.
-   The underlying price and volatility price percentage changes requires text input of numbers separated by commas.
-   The risk metrics support multiple selection.
**![](https://lh4.googleusercontent.com/EExLRohcOIXdhEKbx3Zpx5sW7y2ypEWajRbztUGQm7ITcdOT-6xoiyQkfnIF-BQLzeY7K5NGbXMg_zCMBDLxuE2S79fMC8cLXFrF73Qopv7VoidaOLS2kE_17NbqDsSy)**

#### Delta Hedge Simulation

![Hedge](E:\MATLAB\PRMIA\Hedge.jpg)


## Related Source
[Greeks Calculation MATLAB](https://www.mathworks.com/matlabcentral/fileexchange/69544-calcgreeks-calculate-option-greeks-european-black-scholes)
[Delta Hedging](https://nms.kcl.ac.uk/john.armstrong/courses/fm06/book/matlab-chapter6.pdf)