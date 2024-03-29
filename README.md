# Patient Non-Specific Seizure Detection in the Intensive Care Unit

This is the code accompanying a project by Chris Painter and John Bernabei at the University of Pennsylvania's Center for Neuroengineering and Therapeutics that seeks to train and validate a cross-patient seizure detector for use in the intensive care unit. Our cohort is comprised of 32 patients with seizures and 99 patients without seizures collected in the ICU at the Hospital of the University of Pennsylvania

## Workflow

Begin by downloading a relevant body of patient scalp-EEG data an clinical seizure annotations from iEEG.org. 

After having acquired the data you would like to use, use the script titled "patient_clustering_pipeline" to extract features, using the included method "get_Features.m", from the raw EEG signal provided. Save the output feature cell array generated by this script in a ".mat" file.

Next, use "ExperimentWorkbench.m" as your base for applying the method proposed in this project. Details are provided in this function, but the high level process is that this function randomly holds out a subset of patients for testing, learns k-means clusters for the leftover training set of patients and trains cluster-specific classifiers for each of these clusters, finds the clusters that each of the test set patients would have belonged to from the training set, and then makes seizure or not seizure predictions for test set patients using the cluster-specific classifiers. Test statistics are then calculated.

Many more methods are used for smaller tasks derivative of the above, and so a list of relevant functions is given below.

## Essential Scripts/Functions

As mentioned above you will want to begin with these highest level scripts/functions in the "experiments" folder: 
- labeled_data_preprocessing.m
- unlabeled_data_preprocessing.m
- ExperimentWorkbench.m
- FigureWorkbench.m

On the high-level essential path fo understanding what this project is attempting, look in the "utils" folder for:
- patient_Clustering.m
- patient_ClusteringTest.m
- Data2Cluster.m
- get_Features.m

In the same folder and worth looking at, but less critical to understanding what's interesting about this approach are:
- random_Forest.m
- VoteFiltering.m
- RemoveStatic.m
- MovingWinFeats.m
- AdvancedRecallMeasure.m
- line_Length.m
- JustMetrics.m


## Contact

Reach out to cpainter at wharton dot upenn dot edu or johnbe at seas dot upenn dot edu for questions.
