/*
================================================================================
POWER QUERY ETL TRANSFORMATIONS (M CODE)
Project: HR Employee Attrition Analytics
Dataset: WA_Fn-UseC_-HR-Employee-Attrition.csv
Author: Rohith Chandran E (@rohithce-hub)
================================================================================
Description:
Performs schema typing, null handling, categorical binning, and flag derivations
required for demographic and survival curve analytics in Power BI.
================================================================================
*/

let
    // 1. Source Connection
    Source = Csv.Document(
        File.Contents("WA_Fn-UseC_-HR-Employee-Attrition.csv"),
        [Delimiter=",", Columns=35, Encoding=1252, QuoteStyle=QuoteStyle.None]
    ),
    
    // 2. Promote Column Headers
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    
    // 3. Strict Schema Typing
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{
        {"Age", Int64.Type}, 
        {"Attrition", type text}, 
        {"BusinessTravel", type text}, 
        {"DailyRate", Int64.Type}, 
        {"Department", type text}, 
        {"DistanceFromHome", Int64.Type}, 
        {"Education", Int64.Type}, 
        {"EducationField", type text}, 
        {"EmployeeCount", Int64.Type}, 
        {"EmployeeNumber", Int64.Type}, 
        {"EnvironmentSatisfaction", Int64.Type}, 
        {"Gender", type text}, 
        {"HourlyRate", Int64.Type}, 
        {"JobInvolvement", Int64.Type}, 
        {"JobLevel", Int64.Type}, 
        {"JobRole", type text}, 
        {"JobSatisfaction", Int64.Type}, 
        {"MaritalStatus", type text}, 
        {"MonthlyIncome", Int64.Type}, 
        {"MonthlyRate", Int64.Type}, 
        {"NumCompaniesWorked", Int64.Type}, 
        {"Over18", type text}, 
        {"OverTime", type text}, 
        {"PercentSalaryHike", Int64.Type}, 
        {"PerformanceRating", Int64.Type}, 
        {"RelationshipSatisfaction", Int64.Type}, 
        {"StandardHours", Int64.Type}, 
        {"StockOptionLevel", Int64.Type}, 
        {"TotalWorkingYears", Int64.Type}, 
        {"TrainingTimesLastYear", Int64.Type}, 
        {"WorkLifeBalance", Int64.Type}, 
        {"YearsAtCompany", Int64.Type}, 
        {"YearsInCurrentRole", Int64.Type}, 
        {"YearsSinceLastPromotion", Int64.Type}, 
        {"YearsWithCurrManager", Int64.Type}
    }),
    
    // 4. Age Bracket Derivation (Demographic Segmentation)
    #"Added Age Band" = Table.AddColumn(#"Changed Type", "age_band", each 
        if [Age] <= 25 then "18-25" 
        else if [Age] <= 35 then "26-35" 
        else if [Age] <= 45 then "36-45" 
        else if [Age] <= 55 then "46-55" 
        else "55+", 
        type text
    ),
    
    // 5. Tenure Bracket Derivation (Survival Curve Analysis)
    #"Added Tenure Band" = Table.AddColumn(#"Added Age Band", "tenure_band", each 
        if [YearsAtCompany] <= 2 then "0-2 Years" 
        else if [YearsAtCompany] <= 5 then "3-5 Years" 
        else if [YearsAtCompany] <= 10 then "6-10 Years" 
        else if [YearsAtCompany] <= 20 then "11-20 Years" 
        else "20+ Years", 
        type text
    ),
    
    // 6. Monthly Income Tier Derivation (Compensation Equity)
    #"Added Income Band" = Table.AddColumn(#"Added Tenure Band", "income_band", each 
        if [MonthlyIncome] < 3000 then "< $3k" 
        else if [MonthlyIncome] < 5000 then "$3k-$5k" 
        else if [MonthlyIncome] < 10000 then "$5k-$10k" 
        else if [MonthlyIncome] < 15000 then "$10k-$15k" 
        else "$15k+", 
        type text
    ),
    
    // 7. Binary Attrition Flag (Facilitates Numerical Matrix Calculations & AI Visuals)
    #"Added Attrition Flag" = Table.AddColumn(#"Added Income Band", "attrition_flag", each 
        if [Attrition] = "Yes" then 1 else 0, 
        Int64.Type
    )
in
    #"Added Attrition Flag"
