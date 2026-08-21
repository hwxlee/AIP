# Pharmacology-Informed Prediction of Antipsychotic-Induced Parkinsonism

This repository contains the code for a pharmacology-informed sequential modeling framework to predict antipsychotic-induced parkinsonism (AIP) using longitudinal real-world data.

The framework integrates longitudinal pharmacologically weighted antipsychotic exposure with baseline patient characteristics using an attention-based long short-term memory (LSTM) network.

## Workflow Overview

The analysis includes:

- construction of pharmacologically weighted APD exposure in consecutive 30-day windows
- construction of window-level AIP outcomes and post-event masking
- sequential modeling using an attention-based LSTM
- integration of baseline patient characteristics
- internal model development and evaluation
- assessment of overall and window-specific predictive performance

The SAS code illustrates construction of the sequential APD exposure and outcome data used as model inputs. Baseline patient characteristics, comorbidities, and concomitant medication variables are assumed to be prepared separately and merged with the sequential exposure data before model training.

## Data Availability

Individual-level healthcare data used in this study are not publicly available because of privacy and data-use restrictions.

## Citation

If you use this code in your research, please cite our paper:

**Citation: TBA**
