"""Script to assess correlations between age prediction error
and English index of multiple deprivation (IMD) variables"""

from pathlib import Path

import pandas as pd
import numpy as np
import statsmodels.api as sm
import matplotlib.pyplot as plt

PROJECT_ROOT = Path('/home/lea/PycharmProjects/predicted_brain_age')


def ols_reg(df, indep, dep):
    """Perform linear regression using ordinary least squares (OLS) method"""

    endog = np.asarray(df[indep], dtype=float)
    exog = np.asarray(sm.add_constant(df[dep]), dtype=float)
    OLS_model = sm.OLS(endog, exog)
    OLS_results = OLS_model.fit()
    OLS_p = OLS_results.pvalues[1]
    OLS_coeff = OLS_results.params[1]

    alpha = 0.05
    n = len(df)
    if OLS_p < alpha:
        print('n=%s, %s and %s - reject H0: p = %.3f, coef = %.3f'
              % (n, indep, dep, OLS_p, OLS_coeff))
    # elif OLS_p >= alpha:
    #     print('%s and %s - fail to reject H0: p = %.3f, coef = %.3f'
    #           % (indep, dep, OLS_p, OLS_coeff))
    # else:
    #     print('Error with %s and %s' % (indep, dep))


def main():
    # Define what subjects dataset should contain: total, male or female
    subjects = 'total'

    # Load dataset with age vars, demographic data from Biobank, demographic data from IMD
    dataset = pd.read_csv(str(PROJECT_ROOT / 'outputs' / subjects / 'age_predictions_demographics.csv'))

    # create list of IMD vars
    col = ['IMD_decile', 'IMD_rank', 'IMD_score',
           'Income_deprivation_decile', 'Income_deprivation_rank', 'Income_deprivation_score',
           'Employment_deprivation_decile', 'Employment_deprivation_rank', 'Employment_deprivation_score',
           'Education_deprivation_decile', 'Education_deprivation_rank', 'Education_deprivation_score',
           'Health_deprivation_decile', 'Health_deprivation_rank', 'Health_deprivation_score',
           'Crime_decile', 'Crime_rank', 'Crime_score',
           'Barries_housing_decile', 'Barries_housing_rank', 'Barries_housing_score',
           'Environment_deprivation_decile', 'Environment_deprivation_rank', 'Environment_deprivation_score',
           'Income_deprivation_aff_children_decile', 'Income_deprivation_aff_children_rank', 'Income_deprivation_aff_children_score',
           'Income_deprivation_aff_elder_decile', 'Income_deprivation_aff_elder_rank', 'Income_deprivation_aff_elder_score']

    # create list of IMD vars with scores only
    col_score = []
    for item in col:
        if item.split('_')[-1] == 'score':
            col_score.append(item)

    # scatter plot per IMD var
    for var in col_score:
        dataset.plot(x='AbsDiff_age-mean', y=var, kind='scatter')
        plt.show()

    # regression per IMD var
    for var in col:
        dataset_var = dataset.dropna(subset=[var])
        ols_reg(dataset_var, 'Diff_age-m', var)


if __name__ == "__main__":
    main()
