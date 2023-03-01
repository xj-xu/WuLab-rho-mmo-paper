function toRun(fname)
% =========================================================================
% toRun.m is the initialization script for running all analysis.
% 
% ------
% @param  fname <char>: file name of .xlsx spreadsheet to be analyzed
%     
% @syntax toRun('.\Rho-demo-data.xlsx');
%
% @dependency callAnalysisFuncs.m
% 
% @version 2023/02/26 XJ
%   added documentation
%   removed redundant lines
% 
% ------
% All rights and permissions belong to
% Wu Lab, Yale University
% February 26, 2023
% =========================================================================
    addpath([cd '/src'])
    experiment = fname;
    roi_intensity = xlsread(fname);
    timeinterval = xlsread(fname,'time interval');
    firstaddsth = xlsread(fname,'perturbation');
%     timestamps = xlsread(fname, 'time stamps');
    callAnalysisFuncs;
    close all