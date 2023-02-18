# Computer Vision Examples

MATLAB implementations of four computer vision algorithms. Homework for the Advanced Topics in Computer Vision course at the University of Ljubljana, Faculty of Computer and Information Science in 2019.

There is a porocilo.pdf file for each project, which contains a report with experimentation and analysis in the Slovenian language. 
All testing was done with the [Tracking Evaluation Toolkit](https://github.com/alanlukezic/tracking-toolkit-lite) and [VOT sequences](http://www.votchallenge.net/challenges.html).

## Optical Flow
Implementation of Lucas-Kanade and Horn-Schunck methods for estimating the optical flow - a vector field that, in our case, tells us the movement of every pixel between consecutive picture frames. 

## Mean-shift Tracker
Mean-shift is the iterative method for searching the maximum of the probability density function. We used it to implement a tracker that searches for the region containing the most similar colour histogram to the target's histogram. 

## Correlation Filter Tracker
An online learning tracking algorithm that uses a correlation filter for the classifier. It produces a high correlation output for the region containing the target and a low correlation for the background. During tracking the classificator learns to be increasingly discriminative for the given target.

## Particle Tracker
A particle is one sample of a complex probability density function. It represents a visual model and is weighted based on the similarity to the target's visual model. In every step of tracking, particles are sampled and moved by the dynamic model and the target is localized.

The folder also contains an implementation of the Kalman filter with three dynamic models. 
